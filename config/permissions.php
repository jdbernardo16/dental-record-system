<?php

// config/permissions.php — DCPRS RBAC catalogue
// Total: 35 permissions
return [

    'users' => ['users.view', 'users.create', 'users.update', 'users.delete'],

    'patients' => ['patients.view', 'patients.create', 'patients.update', 'patients.delete'],

    'medical-histories' => ['medical-histories.view', 'medical-histories.create', 'medical-histories.update'],

    'appointments' => [
        'appointments.view',
        'appointments.create',
        'appointments.update',       // reschedule / edit
        'appointments.cancel',
        'appointments.attendance',   // mark completed / no-show
    ],

    'consultations' => ['consultations.view', 'consultations.create', 'consultations.update'],

    'dental-chart' => ['dental-chart.view', 'dental-chart.update'],

    'treatments' => ['treatments.view', 'treatments.create', 'treatments.update', 'treatments.sign'],

    'attachments' => ['attachments.view', 'attachments.upload', 'attachments.delete'],

    'consents' => [
        'consents.view',
        'consents.create',
        'consents.sign-patient',
        'consents.sign-dentist',
    ],

    'reports' => ['reports.view'],

    'settings' => ['settings.view', 'settings.update'],
];
