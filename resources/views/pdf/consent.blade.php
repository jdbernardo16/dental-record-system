@php
    $statusLabel = [
        'unsigned' => 'Unsigned',
        'patient_signed' => 'Patient signed',
        'signed' => 'Signed',
        'voided' => 'Voided',
    ][$consent->status->value] ?? $consent->status->value;

    $patientSvg = \App\Support\PdfExport::svgFile($consent->patient_signature_path, 'dcprs-sig-');
    $guardianSvg = \App\Support\PdfExport::svgFile($consent->guardian_signature_path, 'dcprs-sig-');
    $dentistSvg = \App\Support\PdfExport::svgFile($consent->dentist_signature_path, 'dcprs-sig-');

    $signedFrom = $consent->ip_address
        ? 'Signed from IP '.$consent->ip_address
        : null;
    $agent = $consent->user_agent ? trim(preg_replace('/\s+/', ' ', $consent->user_agent)) : null;
@endphp

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Informed Consent — {{ $consent->patient_name }}</title>
    <style>
        @page { size: A4; margin: 15mm 14mm 18mm 14mm; }
        body { font-family: DejaVu Sans, sans-serif; font-size: 10pt; color: #1f2937; line-height: 1.5; }

        .letterhead { border-bottom: 2.5px solid #0f766e; padding-bottom: 8px; margin-bottom: 14px; }
        .clinic-name { font-size: 15pt; font-weight: bold; color: #0f766e; margin: 0; }
        .clinic-address { font-size: 8.5pt; color: #6b7280; margin: 2px 0 0; }
        .doc-ref { position: absolute; top: 0; right: 0; font-size: 8pt; color: #9ca3af; }

        .doc-title { font-size: 14pt; font-weight: bold; color: #111827; margin: 0 0 2px; }
        .doc-subtitle { font-size: 9pt; color: #6b7280; margin: 0 0 10px; }

        .meta-table { width: 100%; border-collapse: collapse; margin: 0 0 12px; }
        .meta-table td { border: 1px solid #e5e7eb; padding: 5px 8px; font-size: 9pt; }
        .meta-table .k { background: #f9fafb; color: #6b7280; width: 16%; }
        .meta-table .v { font-weight: bold; color: #111827; }

        .section-head { font-size: 10.5pt; font-weight: bold; color: #0f766e;
                        border-bottom: 1px solid #d1d5db; padding-bottom: 3px; margin: 16px 0 8px; }

        .sec { margin: 0 0 10px; page-break-inside: avoid; }
        .sec-label { font-size: 9.5pt; font-weight: bold; color: #374151; margin: 0 0 1px; }
        .sec-text { font-size: 9.5pt; color: #1f2937; margin: 0; }
        .sec-initial { text-align: right; margin-top: 2px; }

        .quote { font-size: 9.5pt; font-style: italic; color: #374151;
                 border-left: 3px solid #0f766e; background: #f9fafb;
                 padding: 6px 10px; margin: 0 0 8px; page-break-inside: avoid; }
        .quote .q-label { font-style: normal; font-weight: bold; font-size: 8.5pt;
                          color: #0f766e; text-transform: uppercase; letter-spacing: 0.4pt; }

        .sig-area { margin-top: 18px; }
        .sig-table { width: 100%; border-collapse: collapse; }
        .sig-table td { width: 33%; vertical-align: top; text-align: center; padding: 0 8px; }
        .sig-box { border: 1px solid #e5e7eb; border-radius: 4px; padding: 12px 10px 10px; }
        .sig-label { font-size: 8pt; font-weight: bold; color: #6b7280;
                     text-transform: uppercase; letter-spacing: 0.5pt; margin: 0 0 8px; }
        .sig-name { font-size: 9.5pt; font-weight: bold; color: #111827; margin: 8px 0 1px; }
        .sig-date { font-size: 8pt; color: #6b7280; margin: 0; }
        .sig-note { font-size: 7.5pt; color: #9ca3af; margin-top: 8px; line-height: 1.4; }

        .footer { position: fixed; bottom: -13mm; left: 0; right: 0; text-align: center;
                  font-size: 8pt; color: #9ca3af; border-top: 1px solid #e5e7eb; padding-top: 3px; }
    </style>
</head>
<body>
    <div class="letterhead">
        <span class="doc-ref">Consent #{{ $consent->id }} · v{{ $consent->version }}</span>
        <p class="clinic-name">{{ $clinic['name'] }}</p>
        @if ($clinic['address'])
            <p class="clinic-address">{{ $clinic['address'] }}</p>
        @endif
    </div>

    <p class="doc-title">Patient Informed Consent and Waiver</p>
    <p class="doc-subtitle">
        Version {{ $consent->version }} · {{ $consent->created_at?->format('F j, Y') }}
    </p>

    <table class="meta-table">
        <tr>
            <td class="k">Status</td>
            <td class="v">{{ $statusLabel }}</td>
            <td class="k">Dentist</td>
            <td class="v">{{ $consent->dentist?->name ?? '—' }}</td>
        </tr>
        <tr>
            <td class="k">Patient</td>
            <td class="v">{{ $consent->patient_name }}</td>
            <td class="k">Birth date / Age</td>
            <td class="v">
                {{ $consent->patient?->birth_date?->format('F j, Y') }}
                @if ($consent->patient?->age !== null)
                    ({{ $consent->patient->age }} years)
                @endif
            </td>
        </tr>
    </table>

    <div class="section-head">Consent Sections</div>

    @foreach ($consent->sections as $section)
        <div class="sec">
            <p class="sec-label">{{ $loop->iteration }}. {{ $section->label }}</p>
            <p class="sec-text">{{ $section->text }}</p>
            @php $initialFile = \App\Support\PdfExport::svgFile($section->initial_svg_path, 'dcprs-init-'); @endphp
            @if ($initialFile)
                <p class="sec-initial"><img src="{{ $initialFile }}" style="width: 120px; height: 22px;" /></p>
            @endif
        </div>
    @endforeach

    <div class="section-head">Acknowledgment &amp; Authorization</div>

    <div class="quote">
        <p class="q-label">Acknowledgment</p>
        <p>“{{ $consent->consent_text['acknowledgment'] ?? '—' }}”</p>
    </div>
    <div class="quote">
        <p class="q-label">Authorization</p>
        <p>“{{ $consent->consent_text['authorization'] ?? '—' }}”</p>
    </div>

    @if ($patientSvg || $guardianSvg || $dentistSvg)
        <div class="sig-area">
            <table class="sig-table">
                <tr>
                    @if ($patientSvg)
                        <td>
                            <div class="sig-box">
                                <p class="sig-label">Patient signature</p>
                                <img src="{{ $patientSvg }}" style="width: 210px; height: 35px;" />
                                <p class="sig-name">{{ $consent->patient_name }}</p>
                                <p class="sig-date">{{ $consent->patient_signed_at?->format('M j, Y g:i A') }}</p>
                            </div>
                        </td>
                    @endif
                    @if ($guardianSvg)
                        <td>
                            <div class="sig-box">
                                <p class="sig-label">Parent / guardian signature</p>
                                <img src="{{ $guardianSvg }}" style="width: 210px; height: 35px;" />
                                <p class="sig-name">{{ $consent->guardian_name }}</p>
                                <p class="sig-date">{{ $consent->patient_signed_at?->format('M j, Y g:i A') }}</p>
                            </div>
                        </td>
                    @endif
                    @if ($dentistSvg)
                        <td>
                            <div class="sig-box">
                                <p class="sig-label">Dentist signature</p>
                                <img src="{{ $dentistSvg }}" style="width: 210px; height: 35px;" />
                                <p class="sig-name">{{ $consent->dentist?->name ?? '—' }}</p>
                                <p class="sig-date">{{ $consent->dentist_signed_at?->format('M j, Y g:i A') }}</p>
                            </div>
                        </td>
                    @endif
                </tr>
            </table>
            @if ($signedFrom || $agent)
                <p class="sig-note">
                    {{ $signedFrom }}{{ $signedFrom && $agent ? ' · ' : '' }}{{ $agent }}
                </p>
            @endif
        </div>
    @endif

    <div class="footer">
        {{ $clinic['name'] }} — {{ $exportedAt }}
    </div>
</body>
</html>
