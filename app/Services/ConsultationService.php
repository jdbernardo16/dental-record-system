<?php

namespace App\Services;

use App\Models\Consultation;
use App\Models\User;
use Illuminate\Support\Facades\DB;

final class ConsultationService
{
    public function create(array $data, User $dentist): Consultation
    {
        return DB::transaction(function () use ($data, $dentist) {
            $consultation = Consultation::create([...$data, 'dentist_id' => $dentist->id]);
            activity()->performedOn($consultation)->causedBy($dentist)->log('consultation.created');

            return $consultation;
        });
    }

    public function update(Consultation $consultation, array $data, User $actor): Consultation
    {
        $consultation->update($data);
        activity()->performedOn($consultation)->causedBy($actor)->log('consultation.updated');

        return $consultation;
    }
}
