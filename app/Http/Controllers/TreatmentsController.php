<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTreatmentRequest;
use App\Models\Patient;
use App\Models\Treatment;
use App\Services\TreatmentService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

class TreatmentsController extends Controller
{
    public function __construct(private readonly TreatmentService $service) {}

    public function store(StoreTreatmentRequest $request, Patient $patient): RedirectResponse
    {
        $this->authorize('create', Treatment::class);

        $this->service->create([...$request->validated(), 'patient_id' => $patient->id], $request->user());

        return Redirect::back();
    }

    public function sign(Request $request, Treatment $treatment): RedirectResponse
    {
        $this->authorize('sign', $treatment);

        $request->validate([
            'signature_svg' => ['required', 'string'],
        ]);

        $this->service->sign($treatment, $request->string('signature_svg'), $request->user());

        return Redirect::back();
    }
}
