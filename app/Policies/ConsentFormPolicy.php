<?php

namespace App\Policies;

use App\Models\ConsentForm;
use App\Models\User;

class ConsentFormPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('consents.view');
    }

    public function view(User $user, ConsentForm $consentForm): bool
    {
        return $user->can('consents.view');
    }

    public function create(User $user): bool
    {
        return $user->can('consents.create');
    }

    public function signPatient(User $user, ConsentForm $consentForm): bool
    {
        return $user->can('consents.sign-patient');
    }

    public function signDentist(User $user, ConsentForm $consentForm): bool
    {
        return $user->can('consents.sign-dentist');
    }
}
