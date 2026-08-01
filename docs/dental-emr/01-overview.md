# 01 — Overview

## Executive Summary

DCPRS is an internal electronic medical record (EMR) platform that replaces the paper-based Philippine Dental Association (PDA) dental chart. It runs on **tablets (≥10″) and desktop browsers** (Chrome, Safari, Edge) inside the clinic, and is used by dentists, assistants, and receptionists to manage patient information, appointments, treatment records, dental charts, attachments, and informed consent forms.

This is a **single-clinic, single-tenant** system. No branches, no billing/payments, no patient portal — the clinic staff are the only users; patients only interact with the device through the signature pad during consent.

## Module Map

| # | Module | Source (§) | Tables | Primary Roles |
|---|---|---|---|---|
| 1 | Auth | Phase 1 | `users`, RBAC | Admin |
| 2 | Patients | §5 | `patients` | Receptionist (register), Dentist, Assistant |
| 3 | Medical History | §6 | `medical_histories` | Dentist |
| 4 | Appointments | §7 | `appointments` | Receptionist, Assistant |
| 5 | Consultations | §8 | `consultations` | Dentist |
| 6 | Dental Chart | §9 | `dental_chart_entries` | Dentist |
| 7 | Treatments | §10 | `treatments` | Dentist |
| 8 | Attachments | §11 | `attachments` | Assistant, Dentist |
| 9 | Waiver & Consent | §12, §14 | `consent_forms` | Dentist, Assistant (patient signs) |
| 10 | Dashboard / Reports / Settings | §4, §3 | `settings` | Admin (reports), All (dashboard) |

## Roles and Scope

| Role | Scope |
|---|---|
| **Administrator** | Create users, manage settings, view reports, manage records (full CRUD incl. delete) |
| **Dentist** | Create patient records, create consultations, update dental charts, create treatment records, sign treatment forms + consent forms |
| **Assistant** | Upload attachments, manage appointments, update patient records |
| **Receptionist** | Register patients, schedule appointments, search patient records |

## Key Architectural Decisions

1. **Single tenant, single clinic** — no `branch_id` scoping anywhere.
2. **Wizard-style intake flow** on tablet: Patient → Medical history → Waiver → Signature → Consultation → Dental chart → Treatment record. Each step persists independently so a tablet crash never loses prior steps.
3. **Append-only dental chart log** — every chart edit inserts a new `dental_chart_entries` row (immutable, timestamped, user-attributed). The rendered chart is the latest state per tooth/surface; history is filterable by date. This satisfies the *historical records* requirement with a full audit trail.
4. **Electronic signatures stored as vector SVG** (small, zoomable, legally reproducible) via `szimek/signature_pad` (`vue-signature-pad` wrapper for Vue 3).
5. **Consent text snapshotted** per form — the exact waiver wording is copied into the row at signing time so later template edits never invalidate signed forms.
6. **No billing** — fees/payments are explicitly out of scope (see Open Questions).
7. **RBAC via Spatie Laravel Permission** with an installable `config/permissions.php` catalogue; role seeding matches the four roles above.
8. **Reports are admin-only** per spec §3 (*Administrator — View reports*). Other roles read dashboards only.
9. **Online-only** — no offline sync. Open question with default "out of scope v1".
10. **No patient-facing portal** — patients never get accounts; they only sign the tablet.

## Development Phases (from spec §16, unchanged)

| Phase | Scope |
|---|---|
| 1 | Authentication, patient registration, appointments |
| 2 | Dental chart, consultations, treatments |
| 3 | Electronic signatures, file uploads, reports |
| 4 | Backup and archiving |

## System Boundary

- **In:** patient data, medical history, appointments, consultations, dental chart, treatments, attachments, e-signatures, consent, reports, settings, users.
- **Out (v1):** payments/billing, insurance, SMS/email reminders, patient portal, lab integration, offline mode, multi-branch.

## Glossary

| Term | Meaning |
|---|---|
| EMR | Electronic Medical Record |
| PDA | Philippine Dental Association |
| FDI | FDI World Dental Federation tooth numbering (ISO 3950) |
| Dentition | Adult (permanent) vs Primary (deciduous/baby teeth) |
| Pontic | Artificial tooth on a bridge replacing a missing tooth |
| Attended / No-show | Appointment attendance outcomes recorded by receptionist |
