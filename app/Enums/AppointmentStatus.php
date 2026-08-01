<?php

namespace App\Enums;

enum AppointmentStatus: string
{
    use HasMeta;

    case Pending = 'pending';
    case Confirmed = 'confirmed';
    case Completed = 'completed';
    case Cancelled = 'cancelled';
    case NoShow = 'no_show';

    /**
     * @return array<string, array<string, string>>
     */
    public static function meta(): array
    {
        return [
            'pending' => ['label' => 'Pending', 'color' => 'status-pending'],
            'confirmed' => ['label' => 'Confirmed', 'color' => 'status-confirmed'],
            'completed' => ['label' => 'Completed', 'color' => 'status-completed'],
            'cancelled' => ['label' => 'Cancelled', 'color' => 'status-cancelled'],
            'no_show' => ['label' => 'No-show', 'color' => 'status-no-show'],
        ];
    }
}
