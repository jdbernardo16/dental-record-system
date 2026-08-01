<?php

namespace App\Policies;

use App\Models\Consultation;
use App\Models\User;

class ConsultationPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('consultations.view');
    }

    public function view(User $user, Consultation $consultation): bool
    {
        return $user->can('consultations.view');
    }

    public function create(User $user): bool
    {
        return $user->can('consultations.create');
    }

    /** Only the authoring dentist (or Administrator) may edit (blueprint 06). */
    public function update(User $user, Consultation $consultation): bool
    {
        return $user->can('consultations.update')
            && ($user->hasRole('Administrator') || $consultation->dentist_id === $user->id);
    }
}
