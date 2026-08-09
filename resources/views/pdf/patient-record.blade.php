@php
    $sexLabels = ['male' => 'Male', 'female' => 'Female'];
    $answerLabels = ['no' => 'No', 'yes' => 'Yes', 'not_applicable' => 'N/A'];
    $pdaAnswerLabels = ['no' => 'No', 'yes' => 'Yes'];

    $questions = [
        ['key' => 'hypertension', 'label' => 'Hypertension', 'details' => null],
        ['key' => 'diabetes', 'label' => 'Diabetes', 'details' => null],
        ['key' => 'tuberculosis', 'label' => 'Tuberculosis', 'details' => null],
        ['key' => 'heart_disease', 'label' => 'Heart disease', 'details' => null],
        ['key' => 'pregnancy', 'label' => 'Pregnancy', 'details' => null],
        ['key' => 'allergies', 'label' => 'Allergies', 'details' => 'allergies_details'],
        ['key' => 'medications', 'label' => 'Medications', 'details' => 'medications_details'],
        ['key' => 'smoking_history', 'label' => 'Smoking history', 'details' => 'smoking_details'],
        ['key' => 'alcohol_consumption', 'label' => 'Alcohol consumption', 'details' => 'alcohol_details'],
        ['key' => 'previous_surgeries', 'label' => 'Previous surgeries', 'details' => 'surgeries_details'],
    ];

    $pdaConditionLabels = [
        'high_blood_pressure' => 'High blood pressure', 'low_blood_pressure' => 'Low blood pressure',
        'epilepsy' => 'Epilepsy', 'aids_hiv' => 'AIDS or HIV infection',
        'sexually_transmitted_disease' => 'Sexually transmitted disease', 'stomach_ulcers' => 'Stomach ulcers',
        'fainting_seizure' => 'Fainting seizure', 'rapid_weight_loss' => 'Rapid weight loss',
        'radiation_therapy' => 'Radiation therapy', 'joint_replacement' => 'Joint replacement',
        'heart_surgery' => 'Heart surgery', 'heart_attack' => 'Heart attack',
        'thyroid_problem' => 'Thyroid problem', 'heart_disease' => 'Heart disease',
        'heart_murmur' => 'Heart murmur', 'hepatitis_liver_disease' => 'Hepatitis or liver disease',
        'rheumatic_fever' => 'Rheumatic fever', 'hay_fever' => 'Hay fever',
        'respiratory_problems' => 'Respiratory problems', 'hepatitis_jaundice' => 'Hepatitis or jaundice',
        'tuberculosis' => 'Tuberculosis', 'swollen_ankles' => 'Swollen ankles',
        'kidney_disease' => 'Kidney disease', 'diabetes' => 'Diabetes',
        'chest_pain' => 'Chest pain', 'stroke' => 'Stroke', 'cancer_tumors' => 'Cancer or tumors',
        'anemia' => 'Anemia', 'angina' => 'Angina', 'asthma' => 'Asthma',
        'emphysema' => 'Emphysema', 'bleeding_disorders' => 'Bleeding disorders',
        'blood_diseases' => 'Blood diseases', 'head_injuries' => 'Head injuries',
        'arthritis' => 'Arthritis', 'others' => 'Others',
    ];

    $fullName = collect([$patient->first_name, $patient->middle_name, $patient->last_name])
        ->filter()->implode(' ');
    $age = $patient->birth_date ? $patient->birth_date->age : null;
    // Chart entries carry backed enums (ToothCondition etc.) — normalize to raw values.
    $enumValue = fn ($value) => $value instanceof \BackedEnum ? $value->value : $value;
    $conditionLabel = fn ($key) => $options['conditions'][$enumValue($key)]['label'] ?? $enumValue($key);
    $restorationLabel = fn ($key) => $options['restorations'][$enumValue($key)]['label'] ?? $enumValue($key);
    $surfaceLabel = fn ($key) => $options['surfaces'][$enumValue($key)]['label'] ?? $enumValue($key);
    $statusLabel = fn ($key) => [
        'pending' => 'Pending', 'confirmed' => 'Confirmed', 'completed' => 'Completed',
        'cancelled' => 'Cancelled', 'no_show' => 'No-show', 'voided' => 'Voided',
        'unsigned' => 'Unsigned', 'patient_signed' => 'Patient signed', 'signed' => 'Signed',
    ][$key] ?? $key;
@endphp

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Patient Record — {{ $fullName }}</title>
    <style>
        @page { size: A4; margin: 16mm 14mm 18mm 14mm; }
        body { font-family: DejaVu Sans, sans-serif; font-size: 10pt; color: #1f2937; line-height: 1.45; }
        .letterhead { border-bottom: 2px solid #0f766e; padding-bottom: 8px; margin-bottom: 14px; }
        .clinic-name { font-size: 16pt; font-weight: bold; color: #0f766e; margin: 0; }
        .clinic-address { font-size: 8.5pt; color: #6b7280; margin: 2px 0 0; }
        .doc-title { font-size: 13pt; font-weight: bold; color: #111827; margin: 10px 0 2px; }
        .doc-meta { font-size: 8.5pt; color: #6b7280; margin: 0 0 12px; }
        .section { margin: 14px 0 6px; font-size: 11pt; font-weight: bold; color: #0f766e;
                    border-bottom: 1px solid #d1d5db; padding-bottom: 3px; }
        table { width: 100%; border-collapse: collapse; margin: 4px 0 10px; }
        th, td { border: 1px solid #d1d5db; padding: 4px 6px; text-align: left; vertical-align: top; }
        th { background: #f3f4f6; font-size: 9pt; color: #374151; }
        td { font-size: 9.5pt; }
        .label-cell { width: 30%; color: #6b7280; font-size: 9pt; }
        .empty { color: #9ca3af; font-style: italic; }
        .footer { position: fixed; bottom: -12mm; left: 0; right: 0; text-align: center;
                  font-size: 8pt; color: #9ca3af; border-top: 1px solid #e5e7eb; padding-top: 3px; }
        .two-col { width: 50%; }
    </style>
</head>
<body>
    <div class="letterhead">
        <p class="clinic-name">{{ $clinic['name'] }}</p>
        @if ($clinic['address'])
            <p class="clinic-address">{{ $clinic['address'] }}</p>
        @endif
    </div>

    <p class="doc-title">Patient Record</p>
    <p class="doc-meta">
        Patient number: <strong>{{ $patient->patient_number }}</strong>
        &nbsp;·&nbsp; Exported {{ $exportedAt }}
    </p>

    <div class="section">Patient Information</div>
    <table>
        <tr>
            <td class="label-cell">Full name</td>
            <td class="two-col"><strong>{{ $fullName }}</strong></td>
            <td class="label-cell">Patient number</td>
            <td>{{ $patient->patient_number }}</td>
        </tr>
        <tr>
            <td class="label-cell">Birth date</td>
            <td>{{ $patient->birth_date?->format('F j, Y') }}{{ $age !== null ? " ({$age} yrs old)" : '' }}</td>
            <td class="label-cell">Sex</td>
            <td>{{ $sexLabels[$patient->sex?->value] ?? $patient->sex?->value ?? '—' }}</td>
        </tr>
        <tr>
            <td class="label-cell">Civil status</td>
            <td>{{ \Illuminate\Support\Str::title(str_replace('_', ' ', $patient->civil_status?->value ?? '')) ?: '—' }}</td>
            <td class="label-cell">Nationality</td>
            <td>{{ $patient->nationality }}</td>
        </tr>
        <tr>
            <td class="label-cell">Contact number</td>
            <td>{{ $patient->contact_number }}</td>
            <td class="label-cell">Email</td>
            <td>{{ $patient->email_address ?: '—' }}</td>
        </tr>
        <tr>
            <td class="label-cell">Address</td>
            <td colspan="3">{{ $patient->address ?: '—' }}</td>
        </tr>
        <tr>
            <td class="label-cell">Occupation</td>
            <td>{{ $patient->occupation ?: '—' }}</td>
            <td class="label-cell">Dental insurance</td>
            <td>{{ $patient->dental_insurance ?: '—' }}</td>
        </tr>
    </table>

    @if ($canViewClinical['medical-history'] && $medicalHistory)
        <div class="section">Medical History</div>
        <table>
            @foreach ($questions as $q)
                @php $answer = $medicalHistory[$q['key']] ?? null; @endphp
                <tr>
                    <td class="label-cell">{{ $q['label'] }}</td>
                    <td>{{ $answerLabels[$answer] ?? ($answer ?: '—') }}</td>
                    @if ($q['details'])
                        <td class="label-cell">Details</td>
                        <td>{{ $medicalHistory[$q['details']] ?: '—' }}</td>
                    @else
                        <td class="label-cell"></td>
                        <td></td>
                    @endif
                </tr>
            @endforeach
            <tr>
                <td class="label-cell">Good health</td>
                <td>{{ $pdaAnswerLabels[$medicalHistory['good_health'] ?? null] ?? '—' }}</td>
                <td class="label-cell">Blood type</td>
                <td>{{ $medicalHistory['blood_type'] ?: '—' }}</td>
            </tr>
        </table>

        @php
            $checkedConditions = collect($medicalHistory['conditions_checklist'] ?? [])
                ->map(fn ($key) => $pdaConditionLabels[$key] ?? $key);
        @endphp
        @if ($checkedConditions->isNotEmpty())
            <p style="font-size:9.5pt;"><strong>Conditions checklist:</strong>
                {{ $checkedConditions->implode(', ') }}</p>
        @endif
    @endif

    @if ($canViewClinical['consultations'] && $consultations->isNotEmpty())
        <div class="section">Consultations</div>
        <table>
            <thead>
                <tr><th style="width:16%">Date</th><th>Chief complaint / notes</th><th style="width:22%">Dentist</th></tr>
            </thead>
            <tbody>
                @foreach ($consultations as $consultation)
                    <tr>
                        <td>{{ $consultation->consultation_date?->format('M j, Y') }}</td>
                        <td>{{ $consultation->chief_complaint ?: '—' }}</td>
                        <td>{{ $consultation->dentist?->name ?? '—' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif

    @if ($canViewClinical['chart'] && $chartHistory->isNotEmpty())
        <div class="section">Dental Chart</div>
        <table>
            <thead>
                <tr><th style="width:12%">Tooth</th><th>Condition</th><th>Restoration</th><th style="width:14%">Surface</th><th style="width:14%">Recorded</th></tr>
            </thead>
            <tbody>
                @foreach ($chartHistory as $entry)
                    <tr>
                        <td>{{ $entry['tooth_number'] }}</td>
                        <td>{{ $conditionLabel($entry['condition']) }}</td>
                        <td>{{ $entry['restoration_type'] ? $restorationLabel($entry['restoration_type']) : '—' }}</td>
                        <td>{{ $entry['surface'] ? $surfaceLabel($entry['surface']) : '—' }}</td>
                        <td>{{ isset($entry['recorded_at']) ? \Illuminate\Support\Carbon::parse($entry['recorded_at'])->format('M j, Y') : '—' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif

    @if ($canViewClinical['treatments'] && $treatments->isNotEmpty())
        <div class="section">Treatments</div>
        <table>
            <thead>
                <tr><th style="width:12%">Date</th><th>Procedure</th><th style="width:10%">Tooth</th><th style="width:20%">Dentist</th><th style="width:12%">Status</th></tr>
            </thead>
            <tbody>
                @foreach ($treatments as $treatment)
                    <tr>
                        <td>{{ $treatment->treatment_date?->format('M j, Y') }}</td>
                        <td>{{ $treatment->procedure_name }}</td>
                        <td>{{ $treatment->tooth_number ?: '—' }}</td>
                        <td>{{ $treatment->dentist?->name ?? '—' }}</td>
                        <td>{{ $treatment->signed_at ? 'Signed' : 'Pending' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif

    @if ($canViewClinical['consents'] && $consentForms->isNotEmpty())
        <div class="section">Consent Forms</div>
        <table>
            <thead>
                <tr><th style="width:16%">Date</th><th style="width:10%">Version</th><th>Status</th><th style="width:22%">Dentist</th></tr>
            </thead>
            <tbody>
                @foreach ($consentForms as $consent)
                    <tr>
                        <td>{{ $consent->created_at?->format('M j, Y') }}</td>
                        <td>v{{ $consent->version }}</td>
                        <td>{{ $statusLabel($enumValue($consent->status)) }}</td>
                        <td>{{ $consent->dentist?->name ?? '—' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif

    <div class="footer">Generated by {{ $clinic['name'] }} — {{ $exportedAt }}</div>
</body>
</html>
