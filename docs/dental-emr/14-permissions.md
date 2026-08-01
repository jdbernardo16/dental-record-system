# 14 — Permissions

Installable catalogue — copy to `config/permissions.php`. Seed via `RolePermissionSeeder` (see 03-auth.md).

## config/permissions.php

```php
<?php

// config/permissions.php — DCPRS RBAC catalogue
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
```

**Total: 35 permissions.**

## Role Matrix (seeder mapping)

| Permission | Admin | Dentist | Assistant | Receptionist |
|---|:---:|:---:|:---:|:---:|
| users.* (4) | ✓ | | | |
| patients.view | ✓ | ✓ | ✓ | ✓ |
| patients.create | ✓ | ✓ | | ✓ |
| patients.update | ✓ | ✓ | ✓ | |
| patients.delete | ✓ | | | |
| medical-histories.view | ✓ | ✓ | | |
| medical-histories.create/update | ✓ | ✓ | | |
| appointments.view | ✓ | ✓ | ✓ | ✓ |
| appointments.create | ✓ | | ✓ | ✓ |
| appointments.update | ✓ | | ✓ | ✓ |
| appointments.cancel | ✓ | | ✓ | ✓ |
| appointments.attendance | ✓ | | ✓ | ✓ |
| consultations.* (3) | ✓ | ✓ | | |
| dental-chart.view | ✓ | ✓ | ✓ | |
| dental-chart.update | ✓ | ✓ | | |
| treatments.* (4) | ✓ | ✓ | | |
| attachments.view | ✓ | ✓ | ✓ | |
| attachments.upload | ✓ | ✓ | ✓ | |
| attachments.delete | ✓ | | | |
| consents.view | ✓ | ✓ | ✓ | |
| consents.create | ✓ | ✓ | ✓ | |
| consents.sign-patient | ✓ | ✓ | ✓ | |
| consents.sign-dentist | ✓ | ✓ | | |
| reports.view | ✓ | | | |
| settings.* (2) | ✓ | | | |

## Mapping to Spec §3

| Spec statement | Implemented as |
|---|---|
| Admin: Create users | `users.create` |
| Admin: Manage settings | `settings.*` |
| Admin: View reports | `reports.view` |
| Admin: Manage records | all `*.*` (admin gets everything) |
| Dentist: Create patient records | `patients.create` |
| Dentist: Create consultations | `consultations.create` |
| Dentist: Update dental charts | `dental-chart.update` |
| Dentist: Create treatment records | `treatments.create` |
| Dentist: Sign treatment forms | `treatments.sign` (+ `consents.sign-dentist`) |
| Assistant: Upload attachments | `attachments.upload` |
| Assistant: Manage appointments | `appointments.*` |
| Assistant: Update patient records | `patients.update` |
| Receptionist: Register patients | `patients.create` |
| Receptionist: Schedule appointments | `appointments.create/update/cancel` |
| Receptionist: Search patient records | `patients.view` (search within list) |

## Policy Notes

- `patients.delete` is soft-delete only; clinical history (chart/consents/treatments) is never destroyed — Admin policy enforces this.
- `attachments.delete` → soft delete + audit (medico-legal).
- `ConsultationPolicy::update`, `TreatmentPolicy::update/sign` — author-scoped (authoring dentist or admin), enforced in addition to permission.
- Every JSON endpoint cross-checks permission + policy (defense in depth).
