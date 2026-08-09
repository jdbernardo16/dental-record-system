<?php

namespace App\Repositories;

use App\Enums\CivilStatus;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Builder;

class PatientRepository
{
    /**
     * Build a filtered, sortable query for the patient registry.
     *
     * All filters are optional; unset or invalid values are simply ignored.
     * Defaults preserve the original listing: created_at descending.
     *
     * @param  array<string, mixed>  $filters
     */
    public function query(array $filters): Builder
    {
        $sort = $filters['sort'] ?? 'created_at';
        $direction = $filters['direction'] ?? null;

        if (! in_array($sort, ['name', 'patient_number', 'sex', 'age', 'created_at'], true)) {
            $sort = 'created_at';
        }

        if (! in_array($direction, ['asc', 'desc'], true)) {
            $direction = $sort === 'created_at' ? 'desc' : 'asc';
        }

        $query = Patient::query()
            ->when(
                isset($filters['search']) && $filters['search'] !== '',
                fn (Builder $query) => $query->search($filters['search'])
            )
            ->when(
                isset($filters['sex']) && in_array($filters['sex'], ['male', 'female'], true),
                fn (Builder $query) => $query->where('sex', $filters['sex'])
            )
            ->when(
                isset($filters['civil_status'])
                    && in_array($filters['civil_status'], array_keys(CivilStatus::meta()), true),
                fn (Builder $query) => $query->where('civil_status', $filters['civil_status'])
            )
            ->when(
                isset($filters['age_min']),
                fn (Builder $query) => $query->whereDate(
                    'birth_date',
                    '<=',
                    now()->subYears((int) $filters['age_min'])->toDateString()
                )
            )
            ->when(
                isset($filters['age_max']),
                fn (Builder $query) => $query->whereDate(
                    'birth_date',
                    '>',
                    now()->subYears((int) $filters['age_max'] + 1)->toDateString()
                )
            )
            ->when(
                isset($filters['date_from']),
                fn (Builder $query) => $query->whereDate('created_at', '>=', $filters['date_from'])
            )
            ->when(
                isset($filters['date_to']),
                fn (Builder $query) => $query->whereDate('created_at', '<=', $filters['date_to'])
            );

        return match ($sort) {
            'name' => $query->orderBy('last_name', $direction)->orderBy('first_name', $direction),
            // Ascending age = youngest first = most recent birth dates first.
            'age' => $query->orderBy('birth_date', $direction === 'asc' ? 'desc' : 'asc'),
            'patient_number', 'sex', 'created_at' => $query->orderBy($sort, $direction),
            default => $query->orderByDesc('created_at'),
        };
    }

    public function nextPatientNumber(int $year): string
    {
        $next = Patient::withTrashed()
            ->whereYear('created_at', $year)
            ->count() + 1;

        return sprintf('%d-%04d', $year, $next);
    }
}
