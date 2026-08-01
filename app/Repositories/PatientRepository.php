<?php

namespace App\Repositories;

use App\Models\Patient;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PatientRepository
{
    public function search(?string $term): LengthAwarePaginator
    {
        return Patient::query()
            ->when($term, fn ($query) => $query->where(fn ($query) => $query->where('patient_number', 'like', "%{$term}%")
                ->orWhere('last_name', 'like', "%{$term}%")
                ->orWhere('first_name', 'like', "%{$term}%")
                ->orWhere('contact_number', 'like', "%{$term}%")
            ))
            ->orderByDesc('created_at')
            ->paginate(20);
    }

    public function nextPatientNumber(int $year): string
    {
        $next = Patient::withTrashed()
            ->whereYear('created_at', $year)
            ->count() + 1;

        return sprintf('%d-%04d', $year, $next);
    }
}
