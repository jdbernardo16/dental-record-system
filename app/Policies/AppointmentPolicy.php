<?php

namespace App\Policies;

use App\Models\Appointment;
use App\Models\User;

class AppointmentPolicy
{
    /**
     * Determine whether the user can view the appointment list.
     */
    public function viewAny(User $user): bool
    {
        return $user->can('appointments.view');
    }

    /**
     * Determine whether the user can create appointments.
     */
    public function create(User $user): bool
    {
        return $user->can('appointments.create');
    }

    /**
     * Determine whether the user can reschedule the given appointment.
     */
    public function update(User $user, Appointment $appointment): bool
    {
        return $user->can('appointments.update');
    }

    /**
     * Determine whether the user can cancel the given appointment.
     */
    public function cancel(User $user, Appointment $appointment): bool
    {
        return $user->can('appointments.cancel');
    }

    /**
     * Determine whether the user can record attendance for the given appointment.
     */
    public function markAttendance(User $user, Appointment $appointment): bool
    {
        return $user->can('appointments.attendance');
    }
}
