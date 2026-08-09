<?php

namespace App\Services;

use App\Actions\RegisterPatientAction;
use App\Models\Patient;
use App\Models\User;
use App\Support\PatientRules;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use InvalidArgumentException;
use League\Csv\Reader;
use Throwable;

final class PatientImportService
{
    /**
     * Core demographics importable via CSV. `patient_number` is intentionally
     * excluded — it is always server-generated on import.
     */
    public const IMPORTABLE_COLUMNS = [
        'first_name', 'middle_name', 'last_name', 'sex', 'birth_date', 'civil_status',
        'nationality', 'occupation', 'contact_number', 'address', 'email_address',
    ];

    private const MAX_ROWS = 500;

    private const PREVIEW_TTL_MINUTES = 30;

    /** Importable columns whose empty strings normalize to null. */
    private const NULLABLE_COLUMNS = ['middle_name', 'occupation', 'email_address'];

    public function __construct(private readonly RegisterPatientAction $register) {}

    /**
     * Parse an uploaded CSV into normalized row maps keyed by the importable
     * column names. Throws an InvalidArgumentException when required columns
     * are missing or the file exceeds the row cap.
     *
     * @return array<int, array<string, string>>
     */
    public function parse(UploadedFile $file): array
    {
        $reader = Reader::createFromPath($file->getRealPath());
        $reader->setHeaderOffset(0);

        $header = array_map(
            fn (string $column) => $this->normalizeHeader($column),
            $reader->getHeader(),
        );

        $missing = array_diff(self::IMPORTABLE_COLUMNS, $header);
        if ($missing !== []) {
            throw new InvalidArgumentException(
                'Missing required column(s): '.implode(', ', $missing).'.'
            );
        }

        $rows = [];
        foreach ($reader->getRecords() as $record) {
            $values = array_values($record);

            if ($values === [] || collect($values)->every(fn ($value) => $value === null || $value === '')) {
                continue;
            }

            $rows[] = collect(self::IMPORTABLE_COLUMNS)
                ->mapWithKeys(fn (string $column, int $index) => [$column => $values[$index] ?? ''])
                ->all();
        }

        if (count($rows) > self::MAX_ROWS) {
            throw new InvalidArgumentException(
                'Too many rows: a maximum of '.self::MAX_ROWS.' rows can be imported per file.'
            );
        }

        return $rows;
    }

    /**
     * Validate parsed rows and flag each as new / duplicate / invalid.
     *
     * @param  array<int, array<string, string>>  $rows
     * @return array<int, array{row_number: int, data: array<string, mixed>, status: string, errors: array<int, string>}>
     */
    public function validateRows(array $rows): array
    {
        $validated = [];

        foreach ($rows as $index => $row) {
            $normalized = collect($row)
                ->map(fn ($value, string $key) => in_array($key, self::NULLABLE_COLUMNS, true) && $value === '' ? null : $value)
                ->all();

            $validator = Validator::make($normalized, PatientRules::all());
            $errors = [];

            if ($validator->fails()) {
                $status = 'invalid';
                $errors = array_values($validator->errors()->all());
            } elseif ($this->isDuplicate($normalized)) {
                $status = 'duplicate';
            } else {
                $status = 'new';
            }

            $validated[] = [
                'row_number' => $index + 1,
                'data' => $normalized,
                'status' => $status,
                'errors' => $errors,
            ];
        }

        return $validated;
    }

    /**
     * Store validated rows in the session and return the preview payload.
     *
     * @param  array<int, array{row_number: int, data: array<string, mixed>, status: string, errors: array<int, string>}>  $rows
     * @return array{rows: array<int, array{row_number: int, data: array<string, mixed>, status: string, errors: array<int, string>}>, total: int, summary: array{new: int, duplicate: int, invalid: int}, token: string}
     */
    public function preview(array $rows): array
    {
        $token = Str::random(40);

        session()->put("patient-import.{$token}", [
            'rows' => $rows,
            'expires' => now()->addMinutes(self::PREVIEW_TTL_MINUTES),
        ]);

        return [
            'rows' => array_slice($rows, 0, 10),
            'total' => count($rows),
            'summary' => [
                'new' => count(array_filter($rows, fn (array $row) => $row['status'] === 'new')),
                'duplicate' => count(array_filter($rows, fn (array $row) => $row['status'] === 'duplicate')),
                'invalid' => count(array_filter($rows, fn (array $row) => $row['status'] === 'invalid')),
            ],
            'token' => $token,
        ];
    }

    /**
     * Commit the validated rows for a token. Duplicates are re-checked at
     * commit time (race-proof); invalid rows are never written. Each row
     * commits in its own transaction so one bad row can't roll back the batch.
     *
     * @return array{imported: int, skipped_duplicate: int, failed: int}
     */
    public function import(string $token, User $actor): array
    {
        $stored = session("patient-import.{$token}");

        if (! is_array($stored) || ! isset($stored['rows']) || ! ($stored['expires'] ?? null) instanceof \DateTimeInterface || now()->greaterThan($stored['expires'])) {
            throw new InvalidArgumentException(
                'This import session is invalid or has expired. Please upload the file again.'
            );
        }

        $counts = ['imported' => 0, 'skipped_duplicate' => 0, 'failed' => 0];

        foreach ($stored['rows'] as $row) {
            if (($row['status'] ?? '') === 'invalid') {
                continue;
            }

            if ($this->isDuplicate($row['data'] ?? [])) {
                $counts['skipped_duplicate']++;
                continue;
            }

            try {
                DB::transaction(fn () => $this->register->handle($row['data'], $actor));
                $counts['imported']++;
            } catch (Throwable) {
                $counts['failed']++;
            }
        }

        session()->forget("patient-import.{$token}");

        activity()
            ->causedBy($actor)
            ->withProperties($counts)
            ->log('patients.imported');

        return $counts;
    }

    /**
     * @param  array<string, mixed>  $row
     */
    private function isDuplicate(array $row): bool
    {
        return Patient::query()
            ->whereRaw('LOWER(first_name) = ?', [mb_strtolower((string) ($row['first_name'] ?? ''))])
            ->whereRaw('LOWER(last_name) = ?', [mb_strtolower((string) ($row['last_name'] ?? ''))])
            ->whereDate('birth_date', $row['birth_date'] ?? '')
            ->exists();
    }

    private function normalizeHeader(string $header): string
    {
        return str_replace(' ', '_', strtolower(trim(str_replace("\xEF\xBB\xBF", '', $header))));
    }
}
