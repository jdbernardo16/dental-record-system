<?php

namespace Database\Seeders;

use App\Enums\ConsentStatus;
use App\Enums\ToothCondition;
use App\Models\Appointment;
use App\Models\Attachment;
use App\Models\ConsentForm;
use App\Models\ConsentSection;
use App\Models\Consultation;
use App\Models\DentalChartEntry;
use App\Models\MedicalHistory;
use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class DemoDataSeeder extends Seeder
{
    /**
     * Seed realistic demo content for every module (patients, medical histories,
     * appointments, consultations, dental chart, treatments, consents, attachments).
     */
    public function run(): void
    {
        if (Patient::count() > 0) {
            $this->command?->warn('Demo data skipped — patients already exist.');

            return;
        }

        $admin = User::where('username', 'admin')->first() ?? User::first();
        $dentist = User::where('username', 'dentist')->first() ?? $admin;
        $assistant = User::where('username', 'assistant')->first() ?? $admin;
        $receptionist = User::where('username', 'receptionist')->first() ?? $admin;

        DB::transaction(function () use ($admin, $dentist, $assistant, $receptionist): void {
            [$p1, $p2, $p3, $p4, $p5, $p6] = $this->createPatients($admin);

            $this->createMedicalHistories([$p1, $p2, $p3, $p4, $p6], $dentist);

            [$c1, $c2, $c3] = $this->createConsultations([$p1, $p4, $p3], $dentist);

            $this->createAppointments([$p1, $p2, $p3, $p4, $p5, $p6], $dentist, $receptionist);

            $this->createChartEntries([$p1, $p3, $p2, $p4], $dentist);

            $this->createTreatments([$p1, $p4, $p2, $p6], [$c1, $c2], $dentist);

            $this->createConsentForms([$p1, $p4], $dentist);

            $this->createAttachments([$p1, $p2, $p4], $assistant);
        });

        $this->command?->info(
            'Demo data seeded: 6 patients, 7 appointments, 3 consultations, '
            .'12 chart entries, 4 treatments, 2 consent forms, 3 attachments.'
        );
    }

    /**
     * @return array<int, Patient> 6 patients (0101–0106)
     */
    private function createPatients(User $admin): array
    {
        $patients = [
            [
                'patient_number' => '2026-0101',
                'first_name' => 'Maria Concepcion', 'middle_name' => 'Dizon', 'last_name' => 'Santos',
                'sex' => 'female', 'birth_date' => '1988-04-12', 'civil_status' => 'married',
                'nationality' => 'Filipino', 'occupation' => 'Accountant',
                'religion' => 'Roman Catholic', 'nickname' => 'Maricel',
                'contact_number' => '09171234567', 'home_phone' => '8123-4567', 'office_phone' => '8812-3456',
                'address' => '45 Sampaguita St., Brgy. San Lorenzo, Makati City',
                'email_address' => 'maria.santos@example.com',
                'dental_insurance' => 'PhilHealth', 'effective_date' => '2026-01-15',
                'emergency_contact_person' => 'Juan Santos', 'emergency_contact_number' => '09181234568',
            ],
            [
                'patient_number' => '2026-0102',
                'first_name' => 'Juan', 'middle_name' => null, 'last_name' => 'Dela Cruz',
                'sex' => 'male', 'birth_date' => '1975-09-30', 'civil_status' => 'married',
                'nationality' => 'Filipino', 'occupation' => 'Civil Engineer',
                'religion' => 'Roman Catholic', 'nickname' => null,
                'contact_number' => '09175551234', 'home_phone' => '8721-3344',
                'address' => '12 Katipunan Ave., Brgy. Bagumbayan, Quezon City',
                'email_address' => 'juan.delacruz@example.com',
                'dental_insurance' => 'Sun Life', 'effective_date' => '2025-06-01',
                'emergency_contact_person' => 'Maria Dela Cruz', 'emergency_contact_number' => '09175559876',
            ],
            [
                'patient_number' => '2026-0103',
                'first_name' => 'Angela', 'middle_name' => 'Ramos', 'last_name' => 'Fernandez',
                'sex' => 'female', 'birth_date' => '2014-03-15', 'civil_status' => 'single',
                'nationality' => 'Filipino', 'occupation' => null,
                'religion' => 'Roman Catholic', 'nickname' => 'Angel',
                'contact_number' => '09173334455', 'home_phone' => '8534-2211',
                'address' => '8 Ilang-Ilang St., Brgy. San Isidro, Parañaque City',
                'email_address' => null,
                'dental_insurance' => null, 'effective_date' => null,
                'guardian_name' => 'Elena Ramos', 'guardian_occupation' => 'Teacher',
                'emergency_contact_person' => 'Elena Ramos', 'emergency_contact_number' => '09173336677',
            ],
            [
                'patient_number' => '2026-0104',
                'first_name' => 'Antonio', 'middle_name' => 'Cruz', 'last_name' => 'Bautista',
                'sex' => 'male', 'birth_date' => '1950-01-22', 'civil_status' => 'widowed',
                'nationality' => 'Filipino', 'occupation' => 'Retired',
                'religion' => 'Iglesia ni Cristo', 'nickname' => 'Tonio',
                'contact_number' => '09178889900', 'home_phone' => '8231-7788', 'office_phone' => '8231-7799',
                'address' => '230 Taft Ave., Brgy. 700, Manila',
                'email_address' => 'antonio.bautista@example.com',
                'dental_insurance' => 'PhilHealth', 'effective_date' => '2024-03-10',
                'emergency_contact_person' => 'Lito Bautista', 'emergency_contact_number' => '09178884455',
            ],
            [
                'patient_number' => '2026-0105',
                'first_name' => 'Sofia', 'middle_name' => 'Lim', 'last_name' => 'Reyes',
                'sex' => 'female', 'birth_date' => '1995-07-08', 'civil_status' => 'single',
                'nationality' => 'Filipino', 'occupation' => 'Nurse',
                'religion' => 'Born Again', 'nickname' => 'Pia',
                'contact_number' => '09174445566', 'home_phone' => null,
                'address' => '5 Burgos Circle, Brgy. Poblacion, Makati City',
                'email_address' => 'sofia.reyes@example.com',
                'dental_insurance' => null, 'effective_date' => null,
                'emergency_contact_person' => 'Carmen Reyes', 'emergency_contact_number' => '09174447788',
            ],
            [
                'patient_number' => '2026-0106',
                'first_name' => 'Ramon', 'middle_name' => 'Salazar', 'last_name' => 'Villanueva',
                'sex' => 'male', 'birth_date' => '1980-11-17', 'civil_status' => 'separated',
                'nationality' => 'Filipino', 'occupation' => 'Business Owner',
                'religion' => 'Roman Catholic', 'nickname' => null,
                'contact_number' => '09175556677', 'home_phone' => '8644-9900',
                'address' => '22 Ortigas Ave., Brgy. San Antonio, Pasig City',
                'email_address' => 'ramon.villanueva@example.com',
                'dental_insurance' => 'Sun Life', 'effective_date' => '2026-02-01',
                'emergency_contact_person' => 'Rosa Villanueva', 'emergency_contact_number' => '09175559988',
            ],
        ];

        return array_map(
            fn (array $data) => Patient::create([...$data, 'created_by' => $admin->id]),
            $patients
        );
    }

    /**
     * @param  array<int, Patient>  $patients
     */
    private function createMedicalHistories(array $patients, User $dentist): void
    {
        $histories = [
            // Maria — penicillin allergy.
            array_merge($this->historyDefaults(), [
                'patient_id' => $patients[0]->id,
                'allergies' => 'yes',
                'allergies_details' => 'Penicillin — mild skin rash',
                'blood_type' => 'A+',
                'blood_pressure' => '110/70',
            ]),
            // Juan — diabetes.
            array_merge($this->historyDefaults(), [
                'patient_id' => $patients[1]->id,
                'diabetes' => 'yes',
                'blood_type' => 'B+',
                'blood_pressure' => '130/85',
            ]),
            // Angela (minor) — clean history.
            array_merge($this->historyDefaults(), [
                'patient_id' => $patients[2]->id,
                'blood_type' => 'O+',
            ]),
            // Antonio — multiple conditions + physician + dental history.
            array_merge($this->historyDefaults(), [
                'patient_id' => $patients[3]->id,
                'hypertension' => 'yes',
                'diabetes' => 'yes',
                'medications' => 'yes',
                'medications_details' => 'Losartan 50 mg daily, Metformin 500 mg twice daily',
                'conditions_checklist' => ['high_blood_pressure', 'diabetes', 'asthma'],
                'blood_type' => 'O+',
                'blood_pressure' => '120/80',
                'physician_name' => 'Dr. Lim',
                'physician_specialty' => 'Cardiologist',
                'physician_address' => '2nd Floor, Medical Plaza Manila, Ermita, Manila',
                'physician_phone' => '8231-9090',
                'dental_history_previous_dentist' => 'Dr. Cruz',
                'dental_history_last_visit' => '2025-11-02',
                'referral_source' => 'Friend',
                'good_health' => 'yes',
                'bleeding_time' => 'normal',
            ]),
            // Ramon — smoker, social drinker.
            array_merge($this->historyDefaults(), [
                'patient_id' => $patients[4]->id,
                'smoking_history' => 'yes',
                'smoking_details' => '1 pack/day for 12 years',
                'alcohol_consumption' => 'yes',
                'alcohol_details' => 'Social drinker, weekends only',
                'blood_type' => 'AB+',
                'blood_pressure' => '125/80',
            ]),
        ];

        foreach ($histories as $data) {
            MedicalHistory::create([...$data, 'recorded_by' => $dentist->id]);
        }
    }

    /**
     * @return array<string, string>
     */
    private function historyDefaults(): array
    {
        return [
            'hypertension' => 'no',
            'diabetes' => 'no',
            'tuberculosis' => 'no',
            'heart_disease' => 'no',
            'pregnancy' => 'no',
            'allergies' => 'no',
            'medications' => 'no',
            'smoking_history' => 'no',
            'alcohol_consumption' => 'no',
            'previous_surgeries' => 'no',
            'good_health' => 'yes',
            'under_medical_treatment' => 'no',
            'hospitalized' => 'no',
            'nursing' => 'no',
            'birth_control_pills' => 'no',
            'bleeding_time' => 'normal',
            'blood_type' => 'O+',
            'blood_pressure' => '120/80',
            'drug_use' => 'no',
        ];
    }

    /**
     * @param  array<int, Patient>  $patients  [Maria, Antonio, Angela]
     * @return array<int, Consultation>
     */
    private function createConsultations(array $patients, User $dentist): array
    {
        $consultations = [
            [
                'patient_id' => $patients[0]->id,
                'consultation_date' => '2026-07-15',
                'chief_complaint' => 'Pain when biting on the upper left molar for the past two weeks.',
                'examination_findings' => 'Deep occlusal caries on 26 with tenderness to percussion; mild generalized gingivitis; teeth 16 and 46 healthy.',
                'diagnosis' => 'Dental caries (moderate) — tooth 26; gingivitis.',
                'treatment_plan' => 'Composite restoration on 26; scaling and polishing; oral hygiene instructions.',
                'recommendations' => 'Avoid hard foods for 24 hours after restoration; schedule a 6-month recall.',
                'periodontal_screening' => 'gingivitis',
                'occlusion_class' => 'class_i',
                'overjet' => '2mm',
                'overbite' => '1mm',
                'appliances' => ['orthodontic'],
                'tmd_findings' => ['clicking'],
            ],
            [
                'patient_id' => $patients[1]->id,
                'consultation_date' => '2026-06-20',
                'chief_complaint' => 'Bleeding gums and loose lower front teeth.',
                'examination_findings' => 'Generalized moderate periodontitis with heavy calculus deposits; tooth 31 missing (other causes); deep pockets on lower anteriors.',
                'diagnosis' => 'Moderate periodontitis.',
                'treatment_plan' => 'Full-mouth scaling and polishing; review in 3 months; possible periodontal maintenance program.',
                'recommendations' => 'Quarterly prophylaxis; coordinate with cardiologist Dr. Lim before any surgical procedure.',
                'periodontal_screening' => 'moderate_periodontitis',
                'occlusion_class' => 'class_ii',
                'overjet' => '3mm',
                'overbite' => '2mm',
                'midline_deviation' => '1mm to the right',
                'appliances' => ['stayplate'],
                'tmd_findings' => ['clenching', 'muscle_spasm'],
            ],
            [
                'patient_id' => $patients[2]->id,
                'consultation_date' => '2026-07-28',
                'chief_complaint' => 'Decayed upper baby tooth (parent concern).',
                'examination_findings' => 'Occlusal caries on 55; tooth 65 unerupted; healthy gingiva.',
                'diagnosis' => 'Dental caries — tooth 55 (primary dentition).',
                'treatment_plan' => 'Composite filling on 55; fluoride varnish application.',
                'recommendations' => 'Parent to assist brushing twice daily; limit sugary snacks and drinks.',
                'occlusion_class' => 'class_i',
                'overjet' => '2mm',
                'overbite' => '1mm',
            ],
        ];

        return array_map(
            fn (array $data) => Consultation::create([...$data, 'dentist_id' => $dentist->id]),
            $consultations
        );
    }

    /**
     * @param  array<int, Patient>  $patients  [Maria, Juan, Angela, Antonio, Sofia, Ramon]
     */
    private function createAppointments(array $patients, User $dentist, User $receptionist): void
    {
        $appointments = [
            // Today — pending.
            ['patient_id' => $patients[0]->id, 'dentist_id' => null, 'appointment_date' => now()->toDateString(), 'start_time' => '09:00', 'end_time' => '09:30', 'reason' => 'Regular checkup', 'status' => 'pending'],
            // Today — confirmed.
            ['patient_id' => $patients[1]->id, 'dentist_id' => $dentist->id, 'appointment_date' => now()->toDateString(), 'start_time' => '10:00', 'end_time' => '10:30', 'reason' => 'Composite restoration', 'status' => 'confirmed'],
            // Today — completed.
            ['patient_id' => $patients[0]->id, 'dentist_id' => $dentist->id, 'appointment_date' => now()->toDateString(), 'start_time' => '11:00', 'end_time' => '11:30', 'reason' => 'Scaling and polishing', 'status' => 'completed', 'attended_at' => now()->setTime(11, 30)],
            // +2 days — confirmed follow-up.
            ['patient_id' => $patients[2]->id, 'dentist_id' => $dentist->id, 'appointment_date' => now()->addDays(2)->toDateString(), 'start_time' => '14:00', 'end_time' => '14:30', 'reason' => 'Follow-up after composite restoration', 'status' => 'confirmed', 'is_follow_up' => true],
            // +7 days — pending.
            ['patient_id' => $patients[4]->id, 'dentist_id' => null, 'appointment_date' => now()->addDays(7)->toDateString(), 'start_time' => '09:00', 'end_time' => '09:30', 'reason' => 'Initial consultation', 'status' => 'pending'],
            // -3 days — no-show.
            ['patient_id' => $patients[3]->id, 'dentist_id' => $dentist->id, 'appointment_date' => now()->subDays(3)->toDateString(), 'start_time' => '15:00', 'end_time' => '15:30', 'reason' => 'Root canal treatment', 'status' => 'no_show', 'attended_at' => now()->subDays(3)->setTime(15, 30)],
            // -10 days — cancelled.
            ['patient_id' => $patients[5]->id, 'dentist_id' => null, 'appointment_date' => now()->subDays(10)->toDateString(), 'start_time' => '10:00', 'end_time' => '10:30', 'reason' => 'Extraction', 'status' => 'cancelled'],
        ];

        foreach ($appointments as $data) {
            Appointment::create([...$data, 'created_by' => $receptionist->id]);
        }
    }

    /**
     * @param  array<int, Patient>  $patients  [Maria, Angela, Juan, Antonio]
     */
    private function createChartEntries(array $patients, User $dentist): void
    {
        $entries = [
            // Maria (adult).
            ['patient_id' => $patients[0]->id, 'tooth_number' => 16, 'dentition' => 'adult', 'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => '2026-07-10', 'notes' => 'Occlusal caries noted on examination'],
            ['patient_id' => $patients[0]->id, 'tooth_number' => 26, 'dentition' => 'adult', 'condition' => 'present', 'restoration_type' => 'filling_composite', 'surface' => null, 'recorded_at' => '2026-07-10', 'notes' => 'Composite restoration placed'],
            ['patient_id' => $patients[0]->id, 'tooth_number' => 36, 'dentition' => 'adult', 'condition' => 'missing_caries', 'surface' => null, 'recorded_at' => '2026-06-01', 'notes' => 'Extracted due to caries (2025)'],
            ['patient_id' => $patients[0]->id, 'tooth_number' => 46, 'dentition' => 'adult', 'condition' => 'present', 'surface' => null, 'recorded_at' => '2026-07-10'],
            // Angela (primary dentition).
            ['patient_id' => $patients[1]->id, 'tooth_number' => 55, 'dentition' => 'primary', 'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => '2026-07-28'],
            ['patient_id' => $patients[1]->id, 'tooth_number' => 65, 'dentition' => 'primary', 'condition' => 'unerupted', 'surface' => null, 'recorded_at' => '2026-07-28'],
            // Juan (adult).
            ['patient_id' => $patients[2]->id, 'tooth_number' => 11, 'dentition' => 'adult', 'condition' => 'present', 'surface' => null, 'recorded_at' => '2026-06-15'],
            ['patient_id' => $patients[2]->id, 'tooth_number' => 12, 'dentition' => 'adult', 'condition' => 'present', 'restoration_type' => 'crown', 'surface' => null, 'recorded_at' => '2026-06-15', 'notes' => 'Porcelain jacket crown'],
            ['patient_id' => $patients[2]->id, 'tooth_number' => 21, 'dentition' => 'adult', 'condition' => 'root_fragment', 'surface' => null, 'recorded_at' => '2026-06-15'],
            ['patient_id' => $patients[2]->id, 'tooth_number' => 47, 'dentition' => 'adult', 'condition' => 'impacted', 'surface' => null, 'recorded_at' => '2026-06-15'],
            // Antonio (adult).
            ['patient_id' => $patients[3]->id, 'tooth_number' => 31, 'dentition' => 'adult', 'condition' => 'missing_other', 'surface' => null, 'recorded_at' => '2026-05-20'],
            ['patient_id' => $patients[3]->id, 'tooth_number' => 44, 'dentition' => 'adult', 'condition' => 'present', 'restoration_type' => 'filling_amalgam', 'surface' => 'occlusal', 'recorded_at' => '2026-05-20', 'notes' => 'Amalgam filling (old)'],
        ];

        foreach ($entries as $data) {
            DentalChartEntry::create([
                ...$data,
                'color_code' => ToothCondition::meta()[$data['condition']]['color'] ?? null,
                'recorded_by' => $dentist->id,
            ]);
        }
    }

    /**
     * @param  array<int, Patient>  $patients  [Maria, Antonio, Juan, Ramon]
     * @param  array<int, Consultation>  $consultations  [Maria's, Antonio's]
     */
    private function createTreatments(array $patients, array $consultations, User $dentist): void
    {
        $treatments = [
            ['patient_id' => $patients[0]->id, 'consultation_id' => $consultations[0]->id, 'tooth_number' => 26, 'procedure_name' => 'Composite restoration', 'description' => 'Composite filling on tooth 26', 'treatment_date' => '2026-07-18', 'signed_at' => '2026-07-18 10:15:00'],
            ['patient_id' => $patients[1]->id, 'consultation_id' => $consultations[1]->id, 'tooth_number' => null, 'procedure_name' => 'Scaling and polishing', 'description' => 'Full-mouth scaling and polishing', 'treatment_date' => '2026-06-25', 'signed_at' => '2026-06-25 14:05:00'],
            ['patient_id' => $patients[2]->id, 'consultation_id' => null, 'tooth_number' => null, 'procedure_name' => 'Scaling and polishing', 'description' => 'Routine prophylaxis', 'treatment_date' => '2026-07-22', 'signed_at' => null],
            ['patient_id' => $patients[3]->id, 'consultation_id' => null, 'tooth_number' => 48, 'procedure_name' => 'Extraction', 'description' => 'Extraction of impacted lower right third molar', 'treatment_date' => '2026-07-05', 'signed_at' => null],
        ];

        foreach ($treatments as $data) {
            $treatment = Treatment::create([...$data, 'dentist_id' => $dentist->id]);

            if ($data['signed_at'] !== null) {
                $path = 'signatures/treatments/'.$treatment->id.'.svg';
                Storage::disk('local')->put($path, $this->signatureSvg($dentist->name));
                $treatment->update(['signature_path' => $path]);
            }
        }
    }

    /**
     * @param  array<int, Patient>  $patients  [Maria, Antonio]
     */
    private function createConsentForms(array $patients, User $dentist): void
    {
        $sections = config('consent.sections');

        // Maria — fully signed (patient + dentist), all 10 sections initialed.
        $form = ConsentForm::create([
            'patient_id' => $patients[0]->id,
            'version' => config('consent.version'),
            'consent_text' => [
                'acknowledgment' => config('consent.acknowledgment'),
                'authorization' => config('consent.authorization'),
                'sections' => $sections,
            ],
            'patient_name' => $patients[0]->fullName(),
            'patient_signature_path' => 'signatures/consents/'.$patients[0]->id.'-demo-patient.svg',
            'dentist_id' => $dentist->id,
            'dentist_signature_path' => 'signatures/consents/'.$patients[0]->id.'-demo-dentist.svg',
            'patient_signed_at' => '2026-07-15 09:40:00',
            'dentist_signed_at' => '2026-07-15 09:45:00',
            'ip_address' => '127.0.0.1',
            'user_agent' => 'Seeder',
            'status' => ConsentStatus::Signed->value,
        ]);

        Storage::disk('local')->put($form->patient_signature_path, $this->signatureSvg($patients[0]->fullName()));
        Storage::disk('local')->put($form->dentist_signature_path, $this->signatureSvg($dentist->name));

        foreach ($sections as $key => $section) {
            $initialPath = 'signatures/consents/'.$form->id.'-initial-'.$key.'.svg';
            Storage::disk('local')->put($initialPath, $this->signatureSvg(substr($patients[0]->first_name, 0, 1)));

            ConsentSection::create([
                'consent_form_id' => $form->id,
                'key' => $key,
                'label' => $section['label'],
                'initial_svg_path' => $initialPath,
                'initialed_at' => '2026-07-15 09:35:00',
            ]);
        }

        // Antonio — patient signed, awaiting dentist signature.
        $form = ConsentForm::create([
            'patient_id' => $patients[1]->id,
            'version' => config('consent.version'),
            'consent_text' => [
                'acknowledgment' => config('consent.acknowledgment'),
                'authorization' => config('consent.authorization'),
                'sections' => $sections,
            ],
            'patient_name' => $patients[1]->fullName(),
            'patient_signature_path' => 'signatures/consents/'.$patients[1]->id.'-demo-patient.svg',
            'dentist_id' => $dentist->id,
            'dentist_signature_path' => null,
            'patient_signed_at' => '2026-06-20 13:30:00',
            'dentist_signed_at' => null,
            'ip_address' => '127.0.0.1',
            'user_agent' => 'Seeder',
            'status' => ConsentStatus::PatientSigned->value,
        ]);

        Storage::disk('local')->put($form->patient_signature_path, $this->signatureSvg($patients[1]->fullName()));
    }

    /**
     * @param  array<int, Patient>  $patients  [Maria, Juan, Antonio]
     */
    private function createAttachments(array $patients, User $assistant): void
    {
        $png = base64_decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
            true
        );
        $pdf = "%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]>>endobj\nxref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000052 00000 n \n0000000101 00000 n \ntrailer<</Size 4/Root 1 0 R>>\nstartxref\n173\n%%EOF";

        $attachments = [
            ['patient_id' => $patients[0]->id, 'category' => 'xray', 'xray_type' => 'panoramic', 'original_name' => 'pano-2026-07-01.png', 'extension' => 'png', 'content' => $png, 'mime_type' => 'image/png', 'notes' => 'Pre-operative panoramic radiograph'],
            ['patient_id' => $patients[1]->id, 'category' => 'image', 'xray_type' => null, 'original_name' => 'intraoral-photo-2026-07-12.png', 'extension' => 'png', 'content' => $png, 'mime_type' => 'image/png', 'notes' => 'Intraoral photo — upper right arch'],
            ['patient_id' => $patients[2]->id, 'category' => 'pdf', 'xray_type' => null, 'original_name' => 'referral-letter-dr-lim.pdf', 'extension' => 'pdf', 'content' => $pdf, 'mime_type' => 'application/pdf', 'notes' => 'Referral letter from Dr. Lim (Cardiologist)'],
        ];

        foreach ($attachments as $data) {
            $path = 'uploads/'.$data['patient_id'].'/'.Str::uuid().'.'.$data['extension'];
            Storage::disk('local')->put($path, $data['content']);

            Attachment::create([
                'patient_id' => $data['patient_id'],
                'uploaded_by' => $assistant->id,
                'category' => $data['category'],
                'xray_type' => $data['xray_type'],
                'original_name' => $data['original_name'],
                'file_path' => $path,
                'mime_type' => $data['mime_type'],
                'file_size' => strlen($data['content']),
                'notes' => $data['notes'],
            ]);
        }
    }

    private function signatureSvg(string $name): string
    {
        $escaped = htmlspecialchars($name, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');

        return sprintf(
            '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="120" viewBox="0 0 400 120">'
            .'<rect width="400" height="120" fill="#ffffff"/>'
            .'<text x="20" y="70" font-family="cursive, serif" font-size="36" fill="#1f2937">%s</text>'
            .'</svg>',
            $escaped
        );
    }
}
