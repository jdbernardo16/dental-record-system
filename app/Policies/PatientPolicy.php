<?php

namespace App\Policies;

use App\Models\Patient;
use App\Models\User;

class PatientPolicy
{
    /**
     * Determine whether the user can view the patient list.
     */
    public function viewAny(User $user): bool
    {
        return $user->can('patients.view');
    }

    /**
     * Determine whether the user can view the given patient.
     */
    public function view(User $user, Patient $patient): bool
    {
        return $user->can('patients.view');
    }

    /**
     * Determine whether the user can create patients.
     */
    public function create(User $user): bool
    {
        return $user->can('patients.create');
    }

    /**
     * Determine whether the user can update the given patient.
     */
    public function update(User $user, Patient $patient): bool
    {
        return $user->can('patients.update');
    }

    /**
     * Determine whether the user can delete the given patient.
     */
    public function delete(User $user, Patient $patient): bool
    {
        return $user->can('patients.delete');
    }
}
