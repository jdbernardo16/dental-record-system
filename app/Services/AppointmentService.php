<?php

namespace App\Services;

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\User;
use Illuminate\Support\Arr;

final class AppointmentService
{
    /**
     * Allowed transitions per appointment status (blueprint 05 state machine).
     *
     * @var array<string, list<string>>
     */
    private const TRANSITIONS = [
        'pending' => ['confirmed', 'cancelled', 'rescheduled'],
        'confirmed' => ['completed', 'no_show', 'cancelled', 'rescheduled'],
        'completed' => [],
        'no_show' => [],
        'cancelled' => [],
    ];

    public function __construct(private readonly SettingsService $settings) {}

    public function create(array $data, User $actor): Appointment
    {
        $this->ensureNoOverlap($data);

        $appointment = Appointment::create([
            ...$data,
            'status' => AppointmentStatus::Pending->value,
            'created_by' => $actor->id,
        ]);

        activity()->performedOn($appointment)
            ->withProperties(['changes' => $appointment->getChanges()])
            ->causedBy($actor)
            ->log('appointment.created');

        return $appointment;
    }

    public function reschedule(Appointment $appointment, array $data, User $actor): Appointment
    {
        $allowed = Arr::get(self::TRANSITIONS, $appointment->status->value, []);

        throw_unless(in_array('rescheduled', $allowed, true), InvalidTransitionException::class,
            "Cannot reschedule an appointment with status {$appointment->status->value}.");

        $this->ensureNoOverlap([
            ...$data,
            'id' => $appointment->id,
            'dentist_id' => $appointment->dentist_id,
        ]);

        $appointment->update([
            'appointment_date' => $data['appointment_date'],
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'] ?? $appointment->end_time,
            'status' => AppointmentStatus::Pending->value,
        ]);

        activity()->performedOn($appointment)
            ->withProperties(['changes' => $appointment->getChanges()])
            ->causedBy($actor)
            ->log('appointment.rescheduled');

        return $appointment;
    }

    public function confirm(Appointment $appointment, User $actor): Appointment
    {
        return $this->transition($appointment, 'confirmed', $actor);
    }

    public function cancel(Appointment $appointment, string $reason, User $actor): Appointment
    {
        if (trim($reason) === '') {
            throw new InvalidTransitionException('A cancellation reason is required.');
        }

        return $this->transition($appointment, 'cancelled', $actor, [
            'notes' => trim(($appointment->notes ?? '').PHP_EOL."Cancelled: {$reason}"),
        ], ['reason' => $reason]);
    }

    public function markAttendance(Appointment $appointment, bool $present, User $actor): Appointment
    {
        return $this->transition($appointment, $present ? 'completed' : 'no_show', $actor, [
            'attended_at' => now(),
        ]);
    }

    private function transition(Appointment $appointment, string $event, User $actor, array $extra = [], array $properties = []): Appointment
    {
        $allowed = Arr::get(self::TRANSITIONS, $appointment->status->value, []);

        throw_unless(in_array($event, $allowed, true), InvalidTransitionException::class,
            "Cannot {$event} an appointment with status {$appointment->status->value}.");

        $appointment->update([...$extra, 'status' => $event]);

        activity()->performedOn($appointment)
            ->withProperties(['changes' => $appointment->getChanges(), ...$properties])
            ->causedBy($actor)
            ->log("appointment.{$event}");

        return $appointment;
    }

    private function ensureNoOverlap(array $data): void
    {
        if ($this->settings->get('appointment.overlap') === 'true') {
            return;
        }

        if (($data['dentist_id'] ?? null) === null || ($data['start_time'] ?? null) === null) {
            return;
        }

        $overlap = Appointment::where('dentist_id', $data['dentist_id'])
            ->whereDate('appointment_date', $data['appointment_date'])
            ->whereIn('status', [AppointmentStatus::Pending->value, AppointmentStatus::Confirmed->value])
            ->get()
            ->filter(fn (Appointment $a) => $a->id !== ($data['id'] ?? null) && $this->overlaps($a, $data))
            ->isNotEmpty();

        throw_if($overlap, InvalidTransitionException::class, 'The dentist already has an appointment in this time window.');
    }

    public function overlaps(Appointment $a, array $b): bool
    {
        $aStart = strtotime($a->start_time);
        $aEnd = strtotime($a->end_time ?? $a->start_time);
        $bStart = strtotime($b['start_time']);
        $bEnd = strtotime($b['end_time'] ?? $b['start_time']);

        return $aStart < $bEnd && $bStart < $aEnd;
    }
}
