<?php

namespace App\Policies;

use App\Models\Treatment;
use App\Models\User;

class TreatmentPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('treatments.view');
    }

    public function view(User $user, Treatment $treatment): bool
    {
        return $user->can('treatments.view');
    }

    public function create(User $user): bool
    {
        return $user->can('treatments.create');
    }

    /** Authoring dentist or admin only (blueprint 08). */
    public function update(User $user, Treatment $treatment): bool
    {
        return $user->can('treatments.update')
            && ($user->hasRole('Administrator') || $treatment->dentist_id === $user->id);
    }

    /** Authoring dentist or admin only. */
    public function sign(User $user, Treatment $treatment): bool
    {
        return $user->can('treatments.sign')
            && ($user->hasRole('Administrator') || $treatment->dentist_id === $user->id);
    }
}
