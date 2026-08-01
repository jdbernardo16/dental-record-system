<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreMedicalHistoryRequest;
use App\Models\MedicalHistory;
use App\Models\Patient;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Redirect;

class MedicalHistoriesController extends Controller
{
    /**
     * Store the given patient's medical history, creating or updating the single row.
     */
    public function store(Patient $patient, StoreMedicalHistoryRequest $request): RedirectResponse
    {
        $history = MedicalHistory::updateOrCreate(
            ['patient_id' => $patient->id],
            [...$request->validated(), 'recorded_by' => $request->user()->id],
        );

        activity()
            ->performedOn($history)
            ->causedBy($request->user())
            ->withProperties([
                'changes' => $history->getChanges(),
                'recorded_by' => $request->user()->id,
            ])
            ->log('medical_history.saved');

        return Redirect::back();
    }
}
