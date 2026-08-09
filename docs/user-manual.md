# DCPRS User Manual — Dental Clinic Patient Record System

> **For clinic staff.** This manual explains how to use the DCPRS application day-to-day:
> registering patients, running the intake wizard, managing appointments, recording
> consultations and treatments, marking dental charts, capturing signatures and consents,
> uploading files, and reading reports. It includes complete sample scenarios with
> step-by-step walkthroughs for each role.
>
> The system replaces the paper **PDA dental chart** — every field on the paper form has a
> digital home in this application. Keep this manual next to the tablets during training.

---

## Table of Contents

1. [About the system](#1-about-the-system)
2. [Signing in](#2-signing-in)
3. [Roles & permissions](#3-roles--permissions)
4. [The dashboard](#4-the-dashboard)
5. [Patient intake wizard (new patient)](#5-patient-intake-wizard-new-patient)
6. [Patient records](#6-patient-records)
7. [Medical history](#7-medical-history)
8. [Appointments](#8-appointments)
9. [Consultations](#9-consultations)
10. [Dental chart](#10-dental-chart)
11. [Treatments & e-signature](#11-treatments--e-signature)
12. [Consent & waiver (signatures)](#12-consent--waiver-signatures)
13. [Attachments (X-rays, files)](#13-attachments-x-rays-files)
14. [Reports](#14-reports)
15. [Settings](#15-settings)
16. [User management](#16-user-management)
17. [Sample scenarios](#17-sample-scenarios)
18. [Frequently asked questions](#18-frequently-asked-questions)
19. [Backup & record retention (operator notes)](#19-backup--record-retention-operator-notes)

---

## 1. About the system

DCPRS is a **tablet-first electronic medical record** built for a single dental clinic. It
digitizes the full PDA patient chart:

| Paper PDA page | Digital home |
|---|---|
| Page 1 — Patient information + medical history | Patient registration + Medical history (Sections 5–7) |
| Page 2 — Informed consent (10 sections, initials, signatures) | Waiver + Signature wizard steps, Consents tab (Section 12) |
| Page 3 — Dental record chart (conditions, restorations, X-rays, exams) | Dental chart, Consultation exam fields, Attachments (Sections 9, 10, 13) |
| Page 4 — Treatment record | Treatments tab + e-signature (Section 11) |

**Key design rules you should know:**

- **Everything is saved as you go.** Each wizard step saves its own record — if the tablet
  dies mid-intake, nothing before the current step is lost. Re-open the wizard and it
  resumes where you left off.
- **The dental chart is append-only.** Every tap on a tooth writes a dated entry. You never
  "erase" — you record the new state on top (e.g., a tooth marked *Decayed* is later marked
  *Missing — caries*). The full history stays available.
- **Signatures are stored as vector images** (SVG) with the signer's name, date, time, and
  device info for medico-legal purposes.
- **Clinical records are never destroyed** by normal use. Only an Administrator can delete a
  patient (soft delete), and automated archival (Section 19) purges only after a full export.

---

## 2. Signing in

1. Open the app on the tablet's browser (Chrome, Safari, or Edge).
2. You will see the clinic's landing page. Tap **Sign in**.
3. Enter your **username** and **password** (provided by the Administrator).
4. Tap **Log in**.

**First-time tips**

- If you are the Administrator and this is a fresh installation, the seeded dev accounts are
  `admin` / `dentist` / `assistant` / `receptionist`, all with password `password`
  (emails are `admin@test.com`, `dentist@test.com`, `assistant@test.com`, `receptionist@test.com`) —
  **change them immediately** via Users (Section 16).
- A sleeping tablet may show *Session expired* — just sign in again; your place is kept.
- On the login screen, **Remember me** keeps you signed in on that tablet.
- If you forget your password, tap **Forgot your password?** and follow the email link
  (requires the clinic's mail settings; otherwise ask the Administrator to reset it).

---

## 3. Roles & permissions

Four roles control what you can see and do. Your role decides which menu items and buttons
appear — you will never see actions you are not allowed to perform.

| Capability | Administrator | Dentist | Assistant | Receptionist |
|---|:---:|:---:|:---:|:---:|
| Manage users (staff accounts) | ✅ | | | |
| View / register / edit patients | ✅ | ✅ | edit only | register |
| Delete (soft) patients | ✅ | | | |
| Medical history (view/edit) | ✅ | ✅ | | |
| Appointments (view / create / update / cancel / attendance) | ✅ | ✅ (no create) | ✅ | ✅ |
| Consultations | ✅ | ✅ | | |
| Dental chart (view / update) | ✅ | ✅ / view | view | |
| Treatments (create / sign) | ✅ | ✅ | | |
| Attachments (upload / view) | ✅ | ✅ | ✅ | |
| Consents (create / patient sign / dentist sign) | ✅ | ✅ | create + patient sign | |
| Reports | ✅ | | | |
| Settings | ✅ | | | |

> **Tip for shared tablets:** each staff member should sign in with their own account so the
> audit trail records *who* did *what*.

---

## 4. The dashboard

The dashboard is your day-start screen. It shows:

| Widget | What it shows |
|---|---|
| **Today's appointments** | Appointments for today that are *pending* or *confirmed*, in time order. Tap **View all** to open the full day. |
| **Recent patients** | The 10 most recently registered patients. Tap **View all** to search the registry. |
| **Pending procedures** | Treatments recorded but **not yet signed** by the dentist (dentist/admin view). |
| **Follow-ups** | Confirmed appointments in the next 7 days that were flagged as follow-ups. |
| **Monthly statistics** | A bar chart of new patients and new appointments over the last 6 months. |

Tap any widget's **View all** link to drill into the full list.

---

## 5. Patient intake wizard (new patient)

The intake wizard is the fastest way to register a walk-in patient and capture everything in
one sitting. It has **7 steps**; each step saves immediately, and the wizard resumes at the
first incomplete step if you leave midway.

> **Who:** Receptionist (steps 1–2, then hands the tablet to the clinical team), Dentist,
> or Assistant. Permission buttons appear only for steps you may perform.

### Step 1 — Patient

1. From the sidebar tap **New intake**.
2. Fill in the form:
   - **Identity:** first name, middle name (optional), last name, sex, birth date, civil
     status, nationality.
   - **Contact:** occupation, contact number, address, email (optional).
   - **Emergency contact:** contact person and number.
   - **PDA additional details** (optional): religion, nickname, home/office/fax numbers,
     dental insurance, effective date, and guardian name/occupation (for minors).
3. Tap **Register & continue**. The patient number (e.g. `2026-0001`) is assigned
   automatically.

### Step 2 — Medical history

1. Answer the 10 screening questions with the **No / Yes / N/A** pill buttons. For any
   **Yes**, a details box appears — fill it in.
2. Open the extra groups (optional but recommended for a complete record):
   - **General health** — good health, under medical treatment, hospitalizations, bleeding
     time, blood type, blood pressure, drug use.
   - **Physician** — name, specialty, address, phone.
   - **Dental history** — previous dentist, last dental visit, referral source.
   - **For women only** — nursing, birth control pills.
   - **Medical conditions checklist** — tap all that apply (36 conditions, e.g. high blood
     pressure, diabetes, asthma).
3. Tap **Save & continue**.

### Steps 3 & 4 — Waiver and signature (patient-facing)

Hand the tablet to the patient:

1. **Waiver:** the patient reads each of the 10 PDA consent statements and **draws their
   initials** in the box next to each one. The acknowledgment and authorization texts are
   shown. The button stays disabled until **all 10 sections** are initialed.
2. Tap **Save & continue**.
3. **Signature:** the patient draws their full signature on the pad, then taps **Accept
   signature**, then **Sign & continue**.
   - **If the patient is under 18:** a guardian name field and a second signature pad appear.
     The guardian must sign — the step cannot continue without it.

### Step 5 — Consultation

1. Enter the **consultation date** (defaults to today) and the **chief complaint**
   (required — the patient's own words).
2. Add examination findings, diagnosis, treatment plan, recommendations, and notes as
   needed.
3. Under **Intraoral examination** (PDA Page 3), record:
   - **Periodontal screening** — Gingivitis / Early / Moderate / Advanced periodontitis.
   - **Occlusion class** — Class I / II / III.
   - **Overjet, overbite, midline deviation, crossbite** (free text, e.g. "2mm").
   - **Appliances** — Orthodontic / Stayplate / Others (tick all that apply).
   - **TMD findings** — Clenching / Clicking / Trismus / Muscle spasm.
4. Tap **Save consultation**.

### Step 6 — Dental chart

1. Pick a **condition** or **restoration** from the legend (see Section 10 for the codes).
2. Tap the **tooth** (whole tooth) or a **surface zone** on the tooth.
3. The chart saves instantly — you will see a confirmation toast and the tooth is colored.
4. When done, tap **Continue to treatment**.
   - *You may also skip to treatment if the chart is clean — every visit documents what was
     found, even "no findings".*

### Step 7 — Treatment record

1. Enter the **treatment date** (defaults to today), select the **tooth** (or "Non-tooth
   procedure"), the **procedure** (choose from the suggestion list or type your own), and
   optionally link the **consultation** it came from.
2. Add a description/notes if useful and tap **Save treatment**.
3. The record appears in the list as **Pending**. Tap **Sign now** to capture the dentist's
   signature (Section 11).
4. Tap **Finish** — you land on the patient's full record.

> **Resuming later:** open **New intake** and pick the patient, or open the patient record —
> the wizard re-enters at the first incomplete step.

---

## 6. Patient records

### Finding a patient

1. Sidebar → **Patients**.
2. Type in the **Search** box — it matches **name, patient number, or contact number** as
   you type.
3. Tap a row to open the record.

### The record page

- **Header card:** initials, full name, age, sex, civil status; **Edit** and **Delete**
  (admin) buttons.
- **Identity / Contact / Emergency contact** cards, including the PDA details.
- **Medical history** card — see Section 7.
- **Consultations** card — newest first; tap a row to expand full findings including the
  intraoral exam.
- **Tabs:**
  - **Appointments** — this patient's appointments (date, time, dentist, status).
  - **Chart** — opens the full dental chart (Section 10).
  - **Treatments** — list + add + sign (Section 11).
  - **Files** — attachments (Section 13).
  - **Consents** — consent forms + countersign (Section 12).

### Editing a patient

Tap **Edit**, change the fields, and save. Only roles with `patients.update` see the button.

### Deleting a patient (Administrator only)

Tap **Delete** and confirm. This is a **soft delete** — the record can be restored by an
administrator, and clinical history is retained until archival (Section 19).

---

## 7. Medical history

Open a patient record → **Medical history** → **Edit**.

- Use the **No / Yes / N/A** pills for the 10 screening questions; **Yes** reveals a details
  textarea.
- The PDA groups (general health, physician, dental history, women's health, and the
  36-condition checklist) live in collapsible sections.
- **Remarks** is a free-text area at the bottom.
- Tap **Save** — the display view shows badges for every answer and details under each
  **Yes**.

> Only the Dentist and Administrator can view/edit medical history.

---

## 8. Appointments

Sidebar → **Appointments** opens the **day view** — one day at a time, tablet-friendly.

### Navigating the day

- **← / → chevrons** move to the previous/next day. **Today** jumps back to today.
- The header shows the selected date; the list shows each appointment's time range, patient
  name, reason, dentist, and status badge.

### Creating an appointment

1. Tap **New appointment**.
2. **Patient:** type to search by name or patient number, then tap the patient.
3. **Dentist:** optional — pick from the clinic's dentists.
4. **Date / Start / End:** defaults to today; pick a time window.
5. **Reason:** optional note (e.g. "Follow-up after composite restoration").
6. Tap **Create appointment** — it appears as **Pending**.
   - If the same dentist already has an overlapping appointment, you'll get a conflict
     message and must pick another time.

### The appointment lifecycle

| Status | How it gets there | What you can do |
|---|---|---|
| **Pending** | Created | **Confirm**, **Reschedule**, **Cancel** |
| **Confirmed** | Confirmed | **Mark attended**, **Mark no-show**, Reschedule, Cancel |
| **Completed** | Mark attended | nothing (closed) |
| **No-show** | Mark no-show | nothing (closed) |
| **Cancelled** | Cancelled (reason required) | nothing (closed) |

- **Confirm** — tap the appointment, then **Confirm**.
- **Mark attended / no-show** — on the appointment day, tap the appointment then the
  appropriate button. This records attendance time in the audit trail.
- **Reschedule** — tap the appointment → **Reschedule**, pick the new date/time. The
  appointment returns to **Pending** so the patient can be re-confirmed.
- **Cancel** — tap the appointment → **Cancel**, and enter the **reason** (required).

> **Follow-ups:** tick the **Follow-up appointment** checkbox in the New appointment form to
> flag an appointment as a follow-up — the dashboard's Follow-ups widget lists confirmed
> follow-ups in the next 7 days.

---

## 9. Consultations

Consultations capture the clinical findings of a visit (wizard step 5, or standalone from
the patient record's **Consultations** card → **Add consultation**).

1. Fill in the **chief complaint** (required) and any of: examination findings, diagnosis,
   treatment plan, recommendations, notes.
2. Record the **intraoral examination** (PDA Page 3) — periodontal screening, occlusion
   class, overjet/overbite/midline/crossbite, appliances, TMD findings.
3. Tap **Save consultation** — it appears in the patient's timeline, newest first.

**Editing:** only the dentist who wrote the consultation (or the Administrator) can edit it —
tap the expanded row's edit action. Corrections are recorded in the audit trail.

---

## 10. Dental chart

Sidebar or patient record → **Chart** opens the interactive twin-arch chart.

### The two arches

- **Adult:** upper `18…11 | 21…28`, lower `48…41 | 31…38` (FDI numbering — the left side of
  the chart is the patient's right, as on the paper chart).
- **Primary:** upper `55…51 | 61…65`, lower `85…81 | 71…75`.
- Switch dentition with the **Adult / Primary** segmented control.

### Tooth anatomy (tap targets)

Each tooth has **5 surface zones** — Occlusal (top), Mesial (left), Distal (right), Buccal
(bottom-left), Lingual (bottom-right) — plus the whole tooth. Tap a zone for a surface
finding, or the tooth body for a whole-tooth finding.

### Conditions (PDA legend)

| Code | Meaning | Applies to |
|---|---|---|
| ✓ | Present (healthy, marked explicitly) | whole tooth or surface |
| D | Decayed (caries) | whole tooth or surface |
| M | Missing due to caries | whole tooth only |
| MO | Missing due to other causes | whole tooth only |
| Im | Impacted tooth | whole tooth only |
| Sp | Supernumerary tooth | whole tooth only |
| Rf | Root fragment | whole tooth or surface |
| Un | Unerupted | whole tooth only |

### Restorations & prosthetics (PDA codes)

`Am` Amalgam · `Co` Composite · `JC` Jacket crown · `Ab` Abutment · `Att` Attachment ·
`P` Pontic · `In` Inlay · `Imp` Implant · `S` Sealant · `Rm` Removable denture.

### Recording a finding

1. Tap a **condition** or **restoration** chip (selected chips highlight; tap again to
   deselect).
2. Tap the **tooth** (whole) or a **surface zone**.
3. The entry saves instantly (toast confirms; the tooth/surface colors in).
   - Whole-tooth-only conditions (M, MO, Im, Sp, Un) disable the surface zones and show a
     hint.
   - A tooth can hold both a condition and a restoration (e.g. decay on a crowned tooth).

### History

Tap **History** to open the drawer: every entry ever recorded (date, tooth, condition,
recorded by). Tap a date to render the chart **as of that date** — great for showing
progress. Use **Back to current** to return.

> The chart never erases — new entries supersede older ones by date. This is the audit
> trail and matches the paper chart's intent.

---

## 11. Treatments & e-signature

Treatments are the procedures performed for a patient (wizard step 7, or the patient
record's **Treatments** tab).

### Creating a treatment

1. **Treatments** tab → **Add treatment**.
2. **Treatment date** (defaults today), **Tooth** (FDI number or "Non-tooth procedure"),
   **Procedure** (pick from the suggestions: Scaling and polishing, Composite restoration,
   Amalgam filling, Extraction, Root canal treatment, Crown placement, Denture fitting,
   Sealant application — or type your own).
3. Optionally **link the consultation** it belongs to, add a **description**/**notes**.
4. **Save treatment** — it appears with a **Pending** badge.

### Signing a treatment (dentist)

A treatment record is complete once the dentist signs it:

1. Tap **Sign now** on the pending treatment.
2. On the signature pad, **draw your signature** with your finger/stylus.
3. **Clear** starts over; **Accept signature** locks it in.
4. The badge flips to **Signed**, and the embedded signature appears in the record detail
   (with signer, date, and time).

> Only the dentist who created the treatment (or the Administrator) can sign it.

---

## 12. Consent & waiver (signatures)

The consent module implements **PDA Page 2** exactly: ten statements, each requiring the
patient's **initial**, plus acknowledgment and authorization, then full signatures.

### During intake (wizard steps 3–4)

1. **Waiver:** patient reads each statement and initials each box (10 pads). Save is locked
   until all 10 are initialed.
2. **Signature:** patient draws the full signature and accepts.
   - **Minors (under 18):** guardian name + guardian signature are required.
3. The form is stored with the patient's name, the template version, IP address, and device
   information.

### Dentist countersign

1. Patient record → **Consents** tab.
2. Find the form (status **Patient signed**) → **Dentist sign**.
3. Draw your signature and accept — the status becomes **Signed**.

### Viewing / printing the form

1. **Consents** tab → **View** on a form.
2. The printable A4-style layout shows every section, initial, both signatures, names,
   timestamps, and the IP/device footer.
3. Tap **Print** to send it to a printer or PDF.

### Re-signing

If a patient needs to re-consent (new template version), an administrator voids the old
form and creates a fresh draft — the old one stays in the record as **Voided** for the
audit trail.

---

## 13. Attachments (X-rays, files)

The **Files** tab on a patient record holds images, PDFs, X-rays, prescriptions, lab
results, and documents.

### Uploading

1. **Files** tab → **Upload file**.
2. Choose a **category**:
   - **Image** · **PDF** · **X-ray** · **Prescription** · **Laboratory** · **Document** ·
     **Other**
3. If the category is **X-ray**, also pick the **X-ray type** (PDA Page 3): Periapical,
   Panoramic, Cephalometric, Occlusal, or Others.
4. Pick the file (JPG, PNG, GIF, WebP, or PDF; up to the clinic's size limit — 25 MB by
   default) and add notes if needed.
5. Watch the progress bar during upload; a thumbnail/tile appears when done.

### Viewing

- **Images & X-rays:** tap the thumbnail → full-screen dark viewer. Use **+ / −** to zoom
  (0.5×–3×) and tap outside or press **Esc** to close.
- **PDFs:** tap the tile → inline preview.
- Filter the list with the **category chips** above the grid.

### Deleting (Administrator only)

Tap the file → **Delete** and confirm. Deletion is soft (medico-legal) and audited.

---

## 14. Reports

Sidebar → **Reports** (Administrator only). Reports summarize the whole clinic over a date
range.

1. Set **From / To** dates (default: last 30 days) and tap **Apply**.
2. Metric cards at the top: new patients, appointments, procedures, and average attendance.
3. Five charts:
   - **Patient growth** — new patients per month.
   - **Appointment summary** — appointments by status per month (attendance rate included).
   - **Procedure summary** — most common procedures.
   - **Condition summary** — most recorded chart conditions (clinical audit).
   - **Dentist workload** — treatments per dentist.
4. **CSV** next to each chart downloads that chart's data as a spreadsheet file.
5. **Print** prints the whole report (browser print → save as PDF).

---

## 15. Settings

Sidebar → **Settings** (Administrator only). Six groups of clinic-wide values:

| Group | Keys | Example |
|---|---|---|
| General | clinic name, address | appears on the landing page, consent footer |
| Scheduling | allow overlapping appointments | Yes/No |
| Patient records | patient number scheme | Year-based (`YYYY-NNNN`) |
| Consent | template version | 1.0 |
| Uploads | max attachment size (MB) | 25 |
| Archiving | inactivity years before archival | 5 |

Edit any value and tap **Save settings**. Changes apply immediately (landing page, upload
limits, archival schedule).

---

## 16. User management

Sidebar → **Users** (Administrator only).

- **Add user:** name, username, email, password, and role (Administrator / Dentist / Assistant /
  Receptionist).
- **Edit:** change name/username/email/role; **deactivate** a user to block their sign-in without
  deleting them (useful for departed staff). You cannot deactivate your own account.
- **Delete:** removes the account (audited).

---

## 17. Sample scenarios

### Scenario A — Walk-in patient, full intake (Receptionist + clinical staff)

*Mrs. Dela Cruz walks in without an appointment.*

1. **Receptionist** taps **New intake** (sidebar).
2. Step 1 — registers: *Liza Dela Cruz, Female, born 1990-05-15, Married, Filipino,
   0917-123-4567, QC address*, emergency contact *Juan Dela Cruz*. Taps **Register &
   continue**. Patient number `2026-0001` assigned.
3. Step 2 — medical history: answers the 10 questions (allergies **Yes** → types
   *Penicillin*), opens **General health** and records blood type *O+*, blood pressure
   *120/80*, ticks *High blood pressure* + *Diabetes* in the conditions checklist. Saves.
4. Receptionist hands the tablet to **Mrs. Dela Cruz** for steps 3–4: she reads the 10
   waiver statements and initials each, accepts, draws her signature, and taps **Sign &
   continue**.
5. The **Dentist** takes over at step 5 — chief complaint: *"Pain on my upper left when
   drinking cold water."* Exam findings recorded; periodontal screening *Gingivitis*;
   occlusion *Class I*. Saves.
6. Step 6 — chart: selects **Decayed (D)** and taps the **occlusal** zone of tooth **26**
   (the tooth fills red instantly). Also marks tooth **16** whole-tooth **Co** (composite).
   Continues.
7. Step 7 — treatment: *Composite restoration* on tooth 26, linked to the consultation,
   saved. **Sign now** → draws signature → **Signed**. **Finish** lands on the record.
8. **Receptionist** books a follow-up: **Appointments** → **New appointment** → search
   *Dela Cruz* → date next week 09:00–09:30 → reason *"Follow-up after composite
   restoration"* → **Create**.

### Scenario B — Returning patient with an appointment (Receptionist + Dentist)

*Mr. Santos has a confirmed 09:00 appointment.*

1. **Receptionist** opens **Appointments** (today). The 09:00 row shows **Confirmed**.
2. At the front desk, taps the row → **Mark attended** → status **Completed**.
3. **Dentist** opens the patient record → **Consultations** → **Add consultation** (chief
   complaint, findings). Saves.
4. **Dentist** opens **Chart**, switches to **History**, picks last visit's date to compare
   — then records the new state (e.g. **M** on tooth 16: selects *Missing — caries (M)* and
   taps the whole tooth).
5. **Dentist** adds a treatment (*Extraction* on 16), links the consultation, saves, and
   **signs** it.
6. Done — the record shows the full visit history.

### Scenario C — Assistant: appointments + X-rays + minor consent

*An assistant manages the day and supports the dentist.*

1. **Appointments:** creates a *Scaling and polishing* appointment for a patient, confirms
   a pending one, reschedules another (returns to Pending), and marks a no-show with the
   **Mark no-show** button.
2. **Files:** opens the patient → **Files** tab → **Upload file** → category **X-ray** →
   type **Panoramic** → selects the exported PANO image → progress bar completes →
   thumbnail appears → taps it to zoom and verify quality.
3. **Consents:** for a 12-year-old patient, runs the wizard: helps the patient initial the
   10 sections, then the **guardian** name field + guardian signature pad appear — the
   guardian signs. The form is saved as **Patient signed** for the dentist to countersign.

### Scenario D — Administrator: daily administration

1. **Dashboard** → checks today's appointments, recent patients, pending procedures.
2. **Users** → adds a new Assistant (name, email, password, role), later deactivates the
   account of a departing staff member.
3. **Settings** → updates the clinic name (appears on the landing page immediately) and
   raises the upload limit to 40 MB.
4. **Reports** → month-to-date range → reviews patient growth and dentist workload →
   downloads **CSV** for the monthly meeting → **Print** to PDF.
5. **Backup check** (weekly): confirms `storage/app/backups/dcprs-backup/` has a fresh
   nightly zip (Section 19).

---

## 18. Frequently asked questions

**Q: I made a mistake on the dental chart — how do I erase it?**
A: You don't erase — you record the correct state on top (e.g., re-mark the tooth with ✓ if
it's actually healthy). The history keeps every step; that's the audit trail.

**Q: The tablet said "Session expired". Did I lose data?**
A: No. Every step saved as you went. Sign in again and reopen the patient — the wizard
resumes at the first incomplete step.

**Q: Why can't I see the Reports/Settings/Users menu?**
A: Those are Administrator-only. Your role determines what appears.

**Q: The "Save" button is greyed out on the waiver step.**
A: All 10 sections must be initialed first. The counter shows "X of 10 sections initialed".

**Q: I can't sign a treatment.**
A: Only the dentist who created it (or the Administrator) can sign. If the dentist changed,
ask the Administrator.

**Q: The appointment says it conflicts.**
A: The selected dentist already has an overlapping appointment (unless overlapping is
allowed in Settings). Pick another time or dentist.

**Q: Can I undo a soft-deleted patient?**
A: An Administrator restores it from the database (or from the archive if past the grace
period — see Section 19). Act quickly; archival is automatic.

**Q: What file types can I upload?**
A: JPG, PNG, GIF, WebP, and PDF, up to the size limit in Settings (default 25 MB). X-rays
larger than the limit should be compressed or exported as JPEG/PNG per clinic policy.

**Q: Do I need to print and file the consent forms?**
A: No — the digital form (with initials, signatures, timestamps, and device info) is the
legal record. **Print** exists only when the clinic wants a paper copy.

---

## 19. Backup & record retention (operator notes)

**Nightly automated backups** (Laravel scheduler):

| Time | Job | What it does |
|---|---|---|
| 02:00 | `backup:run` | Full backup: MySQL dump + all uploaded files/signatures → `storage/app/backups/dcprs-backup/`, retention 30 days / 12 months / 3 years |
| 03:00 | `patients:archive` | Archival pipeline (below) |

The scheduler must be running on the server (`* * * * * php artisan schedule:run`).
Production deployments point `BACKUP_DESTINATION` to S3; the local disk is the v1 default
(blueprint Q14). Restore instructions, manual commands, and the monthly restore drill live
in **`docs/ops/backup-restore.md`**.

**Patient archival** (3 stages, all audited):

1. **Soft delete** — patients with **no activity** (consultations, treatments,
   appointments, chart entries, attachments, consents) for `archive.inactivity_years`
   (default **5 years**; editable in Settings) are soft-deleted nightly.
2. **Grace window** — soft-deleted patients stay for `grace_days` (default **30**) so
   mistakes can be reverted.
3. **Purge** — after the grace window, the full record is exported to the archive disk
   (`archive/{patient_number}-{patient_id}/patient.json` + copies of every file), an audit
   entry is written, then the patient is permanently removed.

Administrators can run the pipeline manually with `php artisan patients:archive` and can
tune the years in **Settings → Archiving**.
