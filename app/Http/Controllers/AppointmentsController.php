<?php

namespace App\Http\Controllers;

use App\Enums\AppointmentStatus;
use App\Http\Requests\CancelAppointmentRequest;
use App\Http\Requests\RescheduleAppointmentRequest;
use App\Http\Requests\StoreAppointmentRequest;
use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use App\Services\AppointmentService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class AppointmentsController extends Controller
{
    public function __construct(private readonly AppointmentService $service) {}

    /**
     * Display the day view of appointments.
     */
    public function index(Request $request): Response
    {
        $this->authorize('viewAny', Appointment::class);

        $date = preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $request->query('date', ''))
            ? $request->query('date')
            : now()->toDateString();

        $patientId = $this->resolveBackToPatientId($request->query('patient'), $request);

        $props = [
            'appointments' => Appointment::with([
                'patient:id,first_name,middle_name,last_name,patient_number',
                'dentist:id,name',
            ])
                ->whereDate('appointment_date', $date)
                ->orderBy('start_time')
                ->get(),
            'date' => $date,
            // The modal picker only covers recent patients; full search lives on the patients index page.
            'patients' => Patient::orderByDesc('id')
                ->limit(50)
                ->get(['id', 'first_name', 'middle_name', 'last_name', 'patient_number']),
            'dentists' => User::role('Dentist')->orderBy('name')->get(['id', 'name']),
            'statusOptions' => AppointmentStatus::meta(),
            'can' => [
                'create' => $request->user()->can('appointments.create'),
                'update' => $request->user()->can('appointments.update'),
                'cancel' => $request->user()->can('appointments.cancel'),
                'attendance' => $request->user()->can('appointments.attendance'),
            ],
        ];

        if ($patientId !== null) {
            $props['backToPatient'] = ['id' => $patientId];
        }

        return Inertia::render('Appointments/Index', $props);
    }

    /**
     * Store a newly created appointment.
     */
    public function store(StoreAppointmentRequest $request): RedirectResponse
    {
        $this->authorize('create', Appointment::class);

        $this->service->create($request->validated(), $request->user());

        $redirect = ['date' => $request->validated()['appointment_date']];

        // The calendar form carries ?patient= for patient-originated sessions;
        // keep it on the redirect so the back link survives the round trip.
        $patientId = $this->resolveBackToPatientId($request->input('patient'), $request);

        if ($patientId !== null) {
            $redirect['patient'] = $patientId;
        }

        return Redirect::route('appointments.index', $redirect);
    }

    /**
     * Resolve a patient reference (query param or form field) to a patient id
     * the current user may view, or null when absent/invalid.
     */
    private function resolveBackToPatientId(mixed $patientParam, Request $request): ?int
    {
        if (! is_string($patientParam) && ! is_int($patientParam)) {
            return null;
        }

        $value = trim((string) $patientParam);

        if (! preg_match('/^\d+$/', $value)) {
            return null;
        }

        $patientId = (int) $value;

        return Patient::whereKey($patientId)->exists() && $request->user()->can('patients.view')
            ? $patientId
            : null;
    }

    /**
     * Reschedule the given appointment.
     */
    public function update(RescheduleAppointmentRequest $request, Appointment $appointment): RedirectResponse
    {
        $this->authorize('update', $appointment);

        $this->service->reschedule($appointment, $request->validated(), $request->user());

        return Redirect::back();
    }

    /**
     * Confirm the given appointment.
     */
    public function confirm(Request $request, Appointment $appointment): RedirectResponse
    {
        $this->authorize('update', $appointment);

        $this->service->confirm($appointment, $request->user());

        return Redirect::back();
    }

    /**
     * Cancel the given appointment with a reason.
     */
    public function cancel(CancelAppointmentRequest $request, Appointment $appointment): RedirectResponse
    {
        $this->authorize('cancel', $appointment);

        $this->service->cancel($appointment, $request->validated('reason'), $request->user());

        return Redirect::back();
    }

    /**
     * Record attendance for the given appointment.
     */
    public function attendance(Request $request, Appointment $appointment): RedirectResponse
    {
        $this->authorize('markAttendance', $appointment);

        $this->service->markAttendance($appointment, $request->boolean('present'), $request->user());

        return Redirect::back();
    }
}
