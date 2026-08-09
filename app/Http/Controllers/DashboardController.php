<?php

namespace App\Http\Controllers;

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\Patient;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    /**
     * Display the dashboard widgets.
     */
    public function index(Request $request): Response
    {
        $user = $request->user();

        $todayAppointments = Appointment::with([
            'patient:id,first_name,middle_name,last_name,patient_number',
            'dentist:id,name',
        ])
            ->whereDate('appointment_date', now())
            ->whereIn('status', [AppointmentStatus::Pending->value, AppointmentStatus::Confirmed->value])
            ->orderBy('start_time')
            ->get();

        $recentPatients = Patient::orderByDesc('created_at')
            ->limit(10)
            ->get(['id', 'first_name', 'middle_name', 'last_name', 'patient_number']);

        $months = collect(range(5, 0))
            ->map(fn (int $offset) => now()->copy()->subMonths($offset)->startOfMonth());

        $monthlyStats = [
            'patients' => Patient::whereBetween('created_at', [now()->startOfMonth(), now()->endOfMonth()])->count(),
            'appointments' => Appointment::whereBetween('created_at', [now()->startOfMonth(), now()->endOfMonth()])->count(),
            'series' => [
                'labels' => $months->map(fn (Carbon $month) => $month->format('M'))->all(),
                'patients' => $months->map(fn (Carbon $month) => Patient::whereBetween('created_at', [$month->copy()->startOfMonth(), $month->copy()->endOfMonth()])->count())->all(),
                'appointments' => $months->map(fn (Carbon $month) => Appointment::whereBetween('created_at', [$month->copy()->startOfMonth(), $month->copy()->endOfMonth()])->count())->all(),
            ],
        ];

        $followUps = $user->can('appointments.view')
            ? Appointment::with('patient:id,first_name,middle_name,last_name,patient_number')
                ->whereBetween('appointment_date', [now()->toDateString(), now()->addDays(7)->toDateString()])
                ->where('status', AppointmentStatus::Confirmed->value)
                ->where('is_follow_up', true)
                ->orderBy('appointment_date')
                ->orderBy('start_time')
                ->get()
            : collect();

        return Inertia::render('Dashboard/Index', [
            'todayAppointments' => $todayAppointments,
            'recentPatients' => $recentPatients,
            'monthlyStats' => $monthlyStats,
            'followUps' => $followUps,
            'can' => [
                'viewAppointments' => $user->can('appointments.view'),
                'viewPatients' => $user->can('patients.view'),
                'viewReports' => $user->can('reports.view'),
            ],
        ]);
    }
}
