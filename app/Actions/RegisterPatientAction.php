<?php

namespace App\Actions;

use App\Models\Patient;
use App\Models\User;
use App\Repositories\PatientRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

final class RegisterPatientAction
{
    public function __construct(private PatientRepository $patients) {}

    public function handle(array $data, User $actor): Patient
    {
        try {
            return $this->createPatient($data, $actor);
        } catch (QueryException $e) {
            if (($e->errorInfo[0] ?? null) !== '23000') {
                throw $e;
            }

            return $this->createPatient($data, $actor);
        }
    }

    private function createPatient(array $data, User $actor): Patient
    {
        return DB::transaction(function () use ($data, $actor) {
            $patient = Patient::create([
                ...$data,
                'patient_number' => $this->patients->nextPatientNumber(now()->year),
                'created_by' => $actor->id,
            ]);

            activity()->performedOn($patient)->causedBy($actor)->log('patient.registered');

            return $patient;
        });
    }
}
