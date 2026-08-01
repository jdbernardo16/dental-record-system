# 16 — ERD & State Machines

## Master ERD

```mermaid
erDiagram
    users ||--o{ patients : creates
    users ||--o{ appointments : dentist_for
    users ||--o{ consultations : authored_by
    users ||--o{ dental_chart_entries : recorded_by
    users ||--o{ treatments : performed_by
    users ||--o{ attachments : uploaded_by
    users ||--o{ consent_forms : dentist_for

    patients ||--|| medical_histories : has
    patients ||--o{ appointments : attends
    patients ||--o{ consultations : receives
    patients ||--o{ dental_chart_entries : charted_in
    patients ||--o{ treatments : treated_with
    patients ||--o{ attachments : holds
    patients ||--o{ consent_forms : signs

    consultations ||--o{ treatments : plans
```

## Domain Island: Clinical Core

```mermaid
erDiagram
    patients ||--o{ consultations : has
    patients ||--o{ dental_chart_entries : has
    patients ||--o{ treatments : has
    consultations ||--o{ treatments : plans
    dental_chart_entries {
        int id PK
        int patient_id FK
        int tooth_number
        string dentition "adult|primary"
        string condition "caries|filling|missing|..."
        string surface "null|occlusal|buccal|lingual|mesial|distal"
        date recorded_at
        int recorded_by FK
    }
    treatments {
        int id PK
        int patient_id FK
        int consultation_id FK "nullable"
        int tooth_number "nullable"
        string procedure_name
        string signature_path "nullable"
        timestamp signed_at "nullable"
    }
```

## Domain Island: Consents (legal chain)

```mermaid
erDiagram
    patients ||--o{ consent_forms : signs
    consent_forms {
        int id PK
        int patient_id FK
        string version "1.0"
        text consent_text "snapshot"
        string patient_signature_path
        string guardian_name "nullable"
        string guardian_signature_path "nullable"
        int dentist_id FK
        string dentist_signature_path "nullable"
        timestamp patient_signed_at
        timestamp dentist_signed_at
        string status "unsigned|patient_signed|signed|voided"
    }
```

## State Machine: Appointment (spec §7 statuses)

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Confirmed : confirm
    Pending --> Cancelled : cancel (reason)
    Confirmed --> Completed : mark attendance
    Confirmed --> NoShow : mark attendance
    Confirmed --> Cancelled : cancel (reason)
    Completed --> [*]
    NoShow --> [*]
    Cancelled --> [*]
```

## State Machine: Consent

```mermaid
stateDiagram-v2
    [*] --> Unsigned
    Unsigned --> PatientSigned : patient signs (tablet)
    PatientSigned --> Signed : dentist countersigns
    Unsigned --> Voided : superseded
    PatientSigned --> Voided : superseded
```

## Module Dependency

```mermaid
flowchart LR
    Auth --> Dashboard
    Auth --> Patients
    Auth --> Appointments
    Auth --> Settings
    Patients --> MedicalHistory
    Patients --> Consultations
    Patients --> DentalChart
    Patients --> Treatments
    Patients --> Attachments
    Patients --> Consents
    Consultations --> Treatments
    Dashboard --> Appointments
    Dashboard --> Treatments
    Dashboard --> Patients
    Reports --> Patients
    Reports --> Appointments
    Reports --> Treatments
    Reports --> DentalChart
```

## Permission Hierarchy

```mermaid
flowchart TD
    R["guard: web"] --> Modules["10 modules"]
    Modules --> M1["users.*  (admin)"]
    Modules --> M2["patients.*"]
    M2 --> P1["view: 4 roles"]
    M2 --> P2["create: admin|dentist|receptionist"]
    M2 --> P3["update: admin|dentist|assistant"]
    M2 --> P4["delete: admin only"]
    Modules --> M3["dental-chart.update: admin|dentist"]
    Modules --> M4["treatments.sign: admin|dentist"]
    Modules --> M5["reports.view: admin only"]
```
