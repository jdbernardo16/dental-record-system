<?php

// config/consent.php — PDA informed-consent template (docs/reference/pda-dental-chart.md Page 2).
return [

    'version' => '1.0',

    // 10 sections, each with PDA-verbatim text + its own patient initial.
    'sections' => [
        'treatment_to_be_done' => [
            'label' => 'Treatment to be done',
            'text' => 'I understand and consent to the treatment proposed by the dentist.',
        ],
        'drugs_and_medications' => [
            'label' => 'Drugs and medications',
            'text' => 'I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.',
        ],
        'changes_in_treatment_plan' => [
            'label' => 'Changes in treatment plan',
            'text' => 'I understand that changes in treatment may become necessary as new conditions are discovered during treatment.',
        ],
        'radiographs' => [
            'label' => 'Radiographs',
            'text' => 'I understand that radiographs may be necessary for diagnosis and treatment planning.',
        ],
        'removal_of_teeth' => [
            'label' => 'Removal of teeth',
            'text' => 'I understand the risks, alternatives, and possible complications associated with tooth extraction.',
        ],
        'crowns_caps_and_bridges' => [
            'label' => 'Crowns, caps, and bridges',
            'text' => 'I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.',
        ],
        'endodontics' => [
            'label' => 'Endodontics (root canal treatment)',
            'text' => 'I understand that root canal treatment does not guarantee that a tooth will be saved.',
        ],
        'periodontal_disease' => [
            'label' => 'Periodontal disease',
            'text' => 'I understand the risks associated with periodontal disease and its treatment.',
        ],
        'fillings' => [
            'label' => 'Fillings',
            'text' => 'I understand the risks associated with dental fillings.',
        ],
        'dentures' => [
            'label' => 'Dentures',
            'text' => 'I understand the possible complications and limitations associated with dentures.',
        ],
    ],

    // Acknowledgment + authorization blocks (PDA Page 2).
    'acknowledgment' => 'I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.',
    'authorization' => 'I authorize the dentist and dental personnel to perform the necessary procedures and treatments.',
];
