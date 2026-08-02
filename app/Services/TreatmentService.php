<?php

namespace App\Services;

use App\Models\Treatment;
use App\Models\User;

final class TreatmentService
{
    public function __construct(private readonly SignatureStorageService $signatures) {}

    public function create(array $data, User $dentist): Treatment
    {
        $treatment = Treatment::create([...$data, 'dentist_id' => $dentist->id]);
        activity()->performedOn($treatment)->causedBy($dentist)->log('treatment.created');

        return $treatment;
    }

    public function sign(Treatment $treatment, string $signatureSvg, User $dentist): Treatment
    {
        $path = $this->signatures->store($signatureSvg, "signatures/treatments/{$treatment->id}.svg");
        $treatment->update(['signature_path' => $path, 'signed_at' => now()]);
        activity()->performedOn($treatment)->causedBy($dentist)->log('treatment.signed');

        return $treatment;
    }
}
