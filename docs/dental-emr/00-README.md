# DCPRS — Backend Architecture Blueprint

**Dental Clinic Patient Record System (DCPRS)** — internal EMR replacing the paper-based PDA dental chart. Tablet-first web application.

**Stack:** Laravel 12 · Vue 3 · Inertia.js · Tailwind CSS v4 · MySQL 8

---

## Quick Nav

| File | Contents |
|---|---|
| [01-overview.md](01-overview.md) | Executive summary, module map, roles, key decisions |
| [02-tech-stack.md](02-tech-stack.md) | Stack, conventions, improvised design tokens, tablet-first rules |
| [03-auth.md](03-auth.md) | Users, login, RBAC seeding, session/security |
| [04-patients.md](04-patients.md) | Patients + Medical History |
| [05-appointments.md](05-appointments.md) | Appointments (schedule, reschedule, cancel, attendance) |
| [06-consultations.md](06-consultations.md) | Consultations |
| [07-dental-chart.md](07-dental-chart.md) | Dental chart (FDI numbering, surfaces, conditions, color coding) |
| [08-treatments.md](08-treatments.md) | Treatment records + dentist e-signature |
| [09-attachments.md](09-attachments.md) | File attachments (X-rays, prescriptions, lab results) |
| [10-consents.md](10-consents.md) | Waiver & informed consent with signature capture |
| [11-dashboard-reports-settings.md](11-dashboard-reports-settings.md) | Dashboard widgets, reports, settings |
| [12-cross-cutting.md](12-cross-cutting.md) | Audit trail, storage, backup/archiving, tablet considerations |
| [13-api-contracts.md](13-api-contracts.md) | Routes, request/response formats, errors, rate limits |
| [14-permissions.md](14-permissions.md) | Installable `config/permissions.php` + role matrix |
| [15-migration-order.md](15-migration-order.md) | 12 migrations in dependency order |
| [16-erd.md](16-erd.md) | Mermaid ERDs, state machines, dependency graph |
| [17-process-flows.md](17-process-flows.md) | 6 process flows as code skeletons |
| [18-open-questions.md](18-open-questions.md) | Assumptions, risks, validation questions |
| [99-master.md](99-master.md) | Full concatenated document |

## Key Numbers

- **10 modules** (auth, patients, medical history, appointments, consultations, dental chart, treatments, attachments, consents, dashboard/reports/settings)
- **12 database tables** + 4 Spatie RBAC tables
- **4 roles**: Administrator, Dentist, Assistant, Receptionist
- **35 permissions**
- **8 enums** (3 clinical: dentition, tooth condition, tooth surface; 5 operational: sex, civil status, appointment status, attachment category, consent status)
- **2 state machines**: appointment (5 states), consent (3 states)
- **6 process flows**

## Reviewer Checklist

- [ ] Every idea.md module has a table + permissions
- [ ] All 17 patient fields from spec §5 present in `patients`
- [ ] All 10 medical history questions from spec §6 present
- [ ] All 5 appointment statuses from spec §7 present
- [ ] All 5 tooth surfaces + 8 tooth conditions from spec §9 present
- [ ] Treatment "sign" flow (spec: *Sign treatment forms*) implemented
- [ ] Consent form text from spec §12 snapshot-able
- [ ] No MySQL `enum()` — all status columns are `string` + PHP BackedEnum
- [ ] Every API endpoint has a permission
- [ ] Every inference flagged in 18-open-questions.md
