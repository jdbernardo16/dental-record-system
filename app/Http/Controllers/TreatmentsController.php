<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTreatmentRequest;
use App\Models\Patient;
use App\Models\Treatment;
use App\Services\TreatmentService;
use App\Support\SvgCodec;
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

        $validated = $request->validate([
            'signature_svg' => ['required', 'string'],
        ]);

        // Signatures arrive base64-encoded from the frontend (the CDN WAF
        // rejects the literal `<svg` tag in POST bodies); decode first so the
        // stored format stays raw SVG.
        $this->service->sign($treatment, SvgCodec::decode($validated['signature_svg']), $request->user());

        return Redirect::back();
    }
}
