<?php

namespace App\Http\Middleware;

use App\Services\SettingsService;
use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that is loaded on the first page visit.
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determine the current asset version.
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        return [
            ...parent::share($request),
            'auth' => [
                'user' => $request->user(),
                'can' => [
                    'manageUsers' => $request->user()?->can('users.view') ?? false,
                    'managePatients' => $request->user()?->can('patients.view') ?? false,
                    'manageAppointments' => $request->user()?->can('appointments.view') ?? false,
                    'reports' => $request->user()?->can('reports.view') ?? false,
                    'settings' => $request->user()?->can('settings.view') ?? false,
                ],
            ],
            'clinic' => [
                'name' => app(SettingsService::class)->get('clinic.name', 'Dental Clinic'),
                'address' => app(SettingsService::class)->get('clinic.address', ''),
            ],
        ];
    }
}
