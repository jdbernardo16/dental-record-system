<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateSettingsRequest;
use App\Models\Setting;
use App\Services\SettingsService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class SettingsController extends Controller
{
    public function index(Request $request): Response
    {
        abort_unless($request->user()->can('settings.view'), 403);

        return Inertia::render('Settings/Index', [
            'settings' => Setting::pluck('value', 'key'),
            'can' => [
                'update' => $request->user()->can('settings.update'),
            ],
        ]);
    }

    public function update(UpdateSettingsRequest $request): RedirectResponse
    {
        $service = app(SettingsService::class);

        // The request sends nested groups (clinic.name, consent.version, …); flatten
        // them back to dotted keys for the key-value store.
        foreach (Arr::dot($request->validated()) as $key => $value) {
            $service->set($key, is_bool($value) ? ($value ? 'true' : 'false') : $value);
        }

        return Redirect::back();
    }
}
