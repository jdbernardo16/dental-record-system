# 18 — Open Questions, Assumptions & Risks

Every assumption is explicit. Defaults marked **(DEFAULT)** — implement unless client answers otherwise.

## Open Questions

### Q1 — Tooth numbering system
Spec §9 does not name a numbering system. FDI (ISO 3950) assumed: adult 11–48, primary 51–85. **(DEFAULT: FDI)** — some PH clinics use Universal (1–32) or Palmer. Validated against the clinic's actual PDA chart.

### Q2 — `sex` field values
Spec says "Sex" with no options. **(DEFAULT: male/female)**. PHP Registry of Birth uses male/female; add "Other" if the clinic wants it.

### Q3 — Patient number format
Spec: "Patient number" field only. **(DEFAULT: `YYYY-NNNN` e.g. `2026-0001`, per-year sequence, stored in `patients.patient_number`)**. Alternative: 6-digit running number with year prefix (e.g., `260001`). Must be decided before Phase 1.

### Q4 — Minor consent / guardian handling
Spec's signature section includes "Parent/guardian" line but no age rule. **(DEFAULT: guardian required when patient age < 18 at signing; guardian name + signature stored)**. Confirm PH legal age (18) matches clinic policy.

### Q5 — Medical history: fixed columns vs dynamic question bank
Spec lists 10 fixed questions. **(DEFAULT: fixed columns per spec — simplest wizard)**. If the clinic edits question sets over time, a `questions` + `history_answers` pair is the fallback design (breaking change flagged).

### Q6 — Password policy
**(DEFAULT: Breeze default, min 8 chars)**. Clinic staff on tablets may want simpler; keep default for security, note it in training.

### Q7 — Appointment dentist assignment & overlap rule
Spec doesn't state single-dentist scheduling. **(DEFAULT: optional `dentist_id`; overlap forbidden when set)**. If multiple dentists share the tablet calendar, revisit the rule.

### Q8 — Billing / fees
Spec §10 has no fee field and no payments module. **(DEFAULT: out of scope v1)** — confirmed so the schema doesn't need a fee column. If the clinic bills later, a `billing` module would add `fees` + `payments` tables.

### Q9 — Attachment size limits
Spec lists accepted types only. **(DEFAULT: images 10 MB, PDFs/X-rays 25 MB, total per patient unlimited)**. Confirmed against clinic X-ray file sizes (PANO DICOM exports can exceed 25 MB — see Q18).

### Q10 — Visual design
No Figma exists. All colors/UI in 02-tech-stack are **improvised tokens**. **(DEFAULT: dental-teal palette + condition color map as proposed)**. Flag: replace with real Figma tokens when design is produced; all tokens centralized in `@theme` so swap is cheap.

### Q11 — Follow-up appointments widget
Spec §4 lists "Follow-up appointments" but §7 has no follow-up flag. **(DEFAULT: `is_follow_up` boolean on `appointments`, default false)**. Alternatively infer from `reason` text ("follow-up") — fragile; boolean preferred.

### Q12 — PDF export library
Reports print via browser print in v1. **(DEFAULT: browser print)**. DomPDF/laravel-snappy as upgrade path for server-side PDFs (consent forms might need server PDFs for archival — revisit at Phase 3).

### Q13 — Charting library for reports
**(DEFAULT: chart.js + vue-chartjs)** — battle-tested, small bundle. Alternatives: lightweight SVG hand-rolled (no dep) if bundle size matters on tablets.

### Q14 — Storage: local vs S3
**(DEFAULT: local disk in v1; `s3` disk config ready)**. Production deployment decides; uploads/signatures sit behind the backup pipeline either way.

### Q15 — Archival retention
Phase 4: **(DEFAULT: patients inactive 5 years → archive + soft delete; backup retention 30 daily / 12 monthly / 3 yearly)**. Clinico-legal requirement: PH records retention law (RA 10173 / professional practice) — confirm exact retention years with clinic.

### Q16 — Shared tablets / multi-session
Assumption: each staff member logs in on their own device. **(DEFAULT: one session per user, long-lived)**. If tablets are shared with one generic account, sessions collide — revisit `is_active`/single-session policy.

### Q17 — Offline mode
Clinic Wi-Fi assumed reliable. **(DEFAULT: online-only v1)**. Offline-first (service worker + local queue) is a significant v2 feature — confirm during Phase 1 deployment at the clinic.

### Q18 — X-ray handling
X-rays are images (JPEG/PNG) in spec §11. True DICOM/PANO viewers are **out of scope**. **(DEFAULT: image upload + full-screen zoom viewer)**. Confirm the clinic's X-ray equipment exports standard image formats.

## Assumptions & Risks

| # | Assumption | Risk if wrong | Mitigation |
|---|---|---|---|
| A1 | Single clinic, single tenant | Multi-branch expansion requires `branch_id` migration across 12 tables | Keep tenancy decision at top of overview; schema has no tenant leaks |
| A2 | Patients never log in | Clinic wants patient portal (view records online) | Out of scope; consent forms state collection purpose — covered |
| A3 | Append-only chart is acceptable UX (corrections create new entries) | Dentist expects to erase mistakes silently | Audit trail is the point of the system; training + history view |
| A4 | Wizard steps persist independently | Partial intake data when flow abandoned | Status-free draft rows acceptable; "incomplete intake" list on dashboard (nice-to-have) |
| A5 | Tablet browsers: Chrome/Safari/Edge only | An Android WebView or older browser is used | Feature-test SVG signature + `pointer events` at login (browser check screen) |
| A6 | Electronic signature is legally sufficient | Clinic lawyer requires biometric/notarized consent | SVG + ip/user_agent + timestamp snapshot is the documented defense; signature metadata kept immutable |
| A7 | PHP 8.3 + MySQL 8 available at hosting | Shared hosting with MySQL 5.7 | Migrations avoid newer MySQL features; require 8.0+ in composer platform check |

## Validation Questions for the Client

1. Which tooth numbering does the physical PDA chart use? (Q1)
2. Exact patient number scheme desired? (Q3)
3. Fee/payment fields needed anywhere? (Q8)
4. Average X-ray file size? (Q9, Q18)
5. Does the clinic require a patient portal or only staff access? (A2)
6. Records retention period per PH law/practice? (Q15)
7. Will tablets be shared or per-user? (Q16)

## Sample API Workflow (end-to-end intake)

```
POST /wizard/patients            → { patient_id: 41 }
POST /wizard/medical-histories   → { history_id: 12 }
POST /consents                   → { consent_id: 7, status: "unsigned" }
POST /consents/7/patient-sign    → { status: "patient_signed" }      (SVG payload)
POST /wizard/consultations       → { consultation_id: 9 }
POST /dental-chart/entries       → { entry_id: 88 }                   (tooth 26, caries, occlusal)
POST /wizard/treatments          → { treatment_id: 3 }
POST /treatments/3/sign          → { signed_at: "2026-08-01T10:12:33Z", path: "signatures/..." }
```
