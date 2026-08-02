<?php

namespace App\Services;

use App\Models\Patient;
use Carbon\Carbon;
use Illuminate\Support\Facades\Storage;
use Spatie\Activitylog\Models\Activity;

final class ArchiveService
{
    private const RELATIONS_WITH_ACTIVITY = ['consultations', 'treatments', 'appointments', 'chartEntries', 'attachments', 'consentForms'];

    /**
     * Run the full pipeline.
     *
     * @return array{soft_deleted: int, purged: int}
     */
    public function run(): array
    {
        $years = (int) app(SettingsService::class)->get('archive.inactivity_years', config('archive.inactivity_years', 5));

        return [
            'soft_deleted' => $this->softDeleteInactive(now()->subYears($years)),
            'purged' => $this->archiveSoftDeleted(now()->subDays((int) config('archive.grace_days', 30))),
        ];
    }

    /**
     * Soft-delete patients with no activity in any clinical module since $cutoff.
     */
    public function softDeleteInactive(Carbon $cutoff): int
    {
        $query = Patient::query()
            ->whereNull('deleted_at')
            ->where('created_at', '<', $cutoff);

        foreach (self::RELATIONS_WITH_ACTIVITY as $relation) {
            $query->whereDoesntHave($relation, fn ($q) => $q->where('created_at', '>=', $cutoff));
        }

        $count = 0;

        foreach ($query->get() as $patient) {
            $patient->delete(); // soft delete (audited by LogsActivity)
            activity()->performedOn($patient)->log('patient.archived_soft_delete');
            $count++;
        }

        return $count;
    }

    /**
     * Export and hard-delete patients whose soft delete is past the grace window.
     */
    public function archiveSoftDeleted(Carbon $graceCutoff): int
    {
        $count = 0;

        Patient::onlyTrashed()
            ->where('deleted_at', '<', $graceCutoff)
            ->get()
            ->each(function (Patient $patient) use (&$count): void {
                $this->exportPatient($patient);
                $this->deletePatientFiles($patient);
                activity()->performedOn($patient)->log('patient.archived');
                $patient->forceDelete(); // DB cascade removes clinical child rows
                $count++;
            });

        return $count;
    }

    /**
     * Export the full patient record (JSON + copied files) to the archive disk.
     *
     * @return string relative directory on the archive disk
     */
    public function exportPatient(Patient $patient): string
    {
        $dir = 'archive/'.$patient->patient_number.'-'.$patient->id;

        $payload = [
            'patient' => $patient->attributesToArray(),
            'medical_history' => $patient->medicalHistory?->attributesToArray(),
            'appointments' => $patient->appointments()->get()->toArray(),
            'consultations' => $patient->consultations()->get()->toArray(),
            'chart_entries' => $patient->chartEntries()->get()->toArray(),
            'treatments' => $patient->treatments()->get()->toArray(),
            'attachments' => $patient->attachments()->withTrashed()->get()->toArray(),
            'consent_forms' => $patient->consentForms()->with('sections')->get()->toArray(),
            'archived_at' => now()->toISOString(),
        ];

        Storage::disk(config('archive.disk'))->put(
            "{$dir}/patient.json",
            json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)
        );

        $index = 0;

        foreach ($this->patientFilePaths($patient) as $path) {
            if (! Storage::disk('local')->exists($path)) {
                continue;
            }
            Storage::disk(config('archive.disk'))->put(
                "{$dir}/files/{$index}-".basename($path),
                Storage::disk('local')->get($path)
            );
            $index++;
        }

        return $dir;
    }

    /**
     * Delete the patient's files from the local disk (uploads dir + signature files).
     */
    public function deletePatientFiles(Patient $patient): void
    {
        Storage::disk('local')->deleteDirectory("uploads/{$patient->id}");

        foreach ($this->patientFilePaths($patient) as $path) {
            Storage::disk('local')->delete($path);
        }
    }

    /**
     * All file paths referenced by the patient's clinical rows.
     *
     * @return array<int, string>
     */
    private function patientFilePaths(Patient $patient): array
    {
        $paths = [];

        foreach ($patient->attachments()->withTrashed()->pluck('file_path') as $path) {
            $paths[] = $path;
        }
        foreach ($patient->treatments()->pluck('signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->pluck('patient_signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->pluck('guardian_signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->pluck('dentist_signature_path')->filter() as $path) {
            $paths[] = $path;
        }
        foreach ($patient->consentForms()->with('sections')->get() as $form) {
            foreach ($form->sections->pluck('initial_svg_path')->filter() as $path) {
                $paths[] = $path;
            }
        }

        return array_values(array_unique($paths));
    }
}
