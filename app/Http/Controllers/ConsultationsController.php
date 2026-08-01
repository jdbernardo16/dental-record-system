<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreConsultationRequest;
use App\Models\Consultation;
use App\Models\Patient;
use App\Services\ConsultationService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Redirect;

class ConsultationsController extends Controller
{
    public function __construct(private readonly ConsultationService $service) {}

    public function store(StoreConsultationRequest $request, Patient $patient): RedirectResponse
    {
        $this->authorize('create', Consultation::class);

        $this->service->create([...$request->validated(), 'patient_id' => $patient->id], $request->user());

        return Redirect::back();
    }

    public function update(StoreConsultationRequest $request, Consultation $consultation): RedirectResponse
    {
        $this->authorize('update', $consultation);

        $this->service->update($consultation, $request->validated(), $request->user());

        return Redirect::back();
    }
}
