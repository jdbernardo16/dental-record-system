<?php

namespace App\Policies;

use App\Models\User;

class DentalChartEntryPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->can('dental-chart.view');
    }

    public function create(User $user): bool
    {
        return $user->can('dental-chart.update');
    }
}
