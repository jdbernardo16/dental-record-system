# Philippine Dental Association (PDA) Dental Chart — Reference Template

> **Source of truth for the paper chart DCPRS replaces.** Converted to structured Markdown from the clinic's PDA dental chart (4 pages). Every field maps to a DCPRS model/column; gaps vs our blueprint are tracked in `docs/superpowers/plans/2026-08-01-dcprs-master-plan.md` (Phase 2/3 outlines) and were validated against `docs/dental-emr/`.
>
> **Key validations:** FDI tooth numbering confirmed (permanent 18–11|21–28 / 48–41|31–38; primary 55–51|61–65 / 85–81|71–75). Billing columns (Amount Charged/Paid/Balance) remain OUT OF SCOPE (blueprint Q8 default).

---

# Philippine Dental Association (PDA) Dental Chart

---

# Page 1 – Patient Information Record

## Patient Information

| Field            | Value |
| ---------------- | ----- |
| Last Name        |       |
| First Name       |       |
| Middle Name      |       |
| Birthdate        |       |
| Age              |       |
| Sex              |       |
| Religion         |       |
| Nationality      |       |
| Nickname         |       |
| Home Address     |       |
| Home Number      |       |
| Occupation       |       |
| Office Number    |       |
| Dental Insurance |       |
| Fax Number       |       |
| Effective Date   |       |
| Mobile Number    |       |
| Email Address    |       |

---

### For minors

| Field                | Value |
| -------------------- | ----- |
| Parent/Guardian Name |       |
| Occupation           |       |

---

### Referral Information

**Who may we thank for referring you?**

---

**What is your reason for dental consultation?**

---

## Dental History

| Field             | Value |
| ----------------- | ----- |
| Previous Dentist  |       |
| Last Dental Visit |       |

---

## Medical History

### Physician Information

| Field          | Value |
| -------------- | ----- |
| Physician Name |       |
| Specialty      |       |
| Office Address |       |
| Office Number  |       |

---

### Questionnaire

#### 1. Are you in good health?

- [ ] Yes
- [ ] No

---

#### 2. Are you under medical treatment now?

- [ ] Yes
- [ ] No

If yes:

---

#### 3. Have you ever had a serious illness or surgical operation?

- [ ] Yes
- [ ] No

If yes:

---

#### 4. Have you ever been hospitalized?

- [ ] Yes
- [ ] No

If yes:

---

#### 5. Are you taking any prescription or non-prescription medication?

- [ ] Yes
- [ ] No

If yes:

---

#### 6. Do you use tobacco products?

- [ ] Yes
- [ ] No

---

#### 7. Do you use alcohol, cocaine, or dangerous drugs?

- [ ] Yes
- [ ] No

---

#### 8. Are you allergic to any of the following?

- [ ] Local anesthetics
- [ ] Penicillin
- [ ] Antibiotics
- [ ] Sulfa drugs
- [ ] Aspirin
- [ ] Latex
- [ ] Others

---

#### 9. Bleeding time

---

#### 10. For women only

**Are you pregnant?**

- [ ] Yes
- [ ] No

**Are you nursing?**

- [ ] Yes
- [ ] No

**Are you taking birth control pills?**

- [ ] Yes
- [ ] No

---

#### 11. Blood type

---

#### 12. Blood pressure

---

#### 13. Medical conditions

- [ ] High blood pressure
- [ ] Low blood pressure
- [ ] Epilepsy
- [ ] AIDS or HIV infection
- [ ] Sexually transmitted disease
- [ ] Stomach ulcers
- [ ] Fainting seizure
- [ ] Rapid weight loss
- [ ] Radiation therapy
- [ ] Joint replacement
- [ ] Heart surgery
- [ ] Heart attack
- [ ] Thyroid problem
- [ ] Heart disease
- [ ] Heart murmur
- [ ] Hepatitis or liver disease
- [ ] Rheumatic fever
- [ ] Hay fever
- [ ] Respiratory problems
- [ ] Hepatitis or jaundice
- [ ] Tuberculosis
- [ ] Swollen ankles
- [ ] Kidney disease
- [ ] Diabetes
- [ ] Chest pain
- [ ] Stroke
- [ ] Cancer or tumors
- [ ] Anemia
- [ ] Angina
- [ ] Asthma
- [ ] Emphysema
- [ ] Bleeding disorders
- [ ] Blood diseases
- [ ] Head injuries
- [ ] Arthritis
- [ ] Others

---

**Patient signature**

---

# Page 2 – Informed Consent

## Treatment to be done

I understand and consent to the treatment proposed by the dentist.

Initial: ****\_\_****

---

## Drugs and medications

I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.

Initial: ****\_\_****

---

## Changes in treatment plan

I understand that changes in treatment may become necessary as new conditions are discovered during treatment.

Initial: ****\_\_****

---

## Radiographs

I understand that radiographs may be necessary for diagnosis and treatment planning.

Initial: ****\_\_****

---

## Removal of teeth

I understand the risks, alternatives, and possible complications associated with tooth extraction.

Initial: ****\_\_****

---

## Crowns, caps, and bridges

I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.

Initial: ****\_\_****

---

## Endodontics (root canal treatment)

I understand that root canal treatment does not guarantee that a tooth will be saved.

Initial: ****\_\_****

---

## Periodontal disease

I understand the risks associated with periodontal disease and its treatment.

Initial: ****\_\_****

---

## Fillings

I understand the risks associated with dental fillings.

Initial: ****\_\_****

---

## Dentures

I understand the possible complications and limitations associated with dentures.

Initial: ****\_\_****

---

### Acknowledgment

> I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.

---

### Authorization

I authorize the dentist and dental personnel to perform the necessary procedures and treatments.

---

### Signatures

| Field                                 | Value |
| ------------------------------------- | ----- |
| Patient / Parent / Guardian Signature |       |
| Dentist Signature                     |       |
| Date                                  |       |

---

# Page 3 – Dental Record Chart

## Intraoral Examination

| Field | Value |
| ----- | ----- |
| Name  |       |
| Age   |       |
| Sex   |       |
| Date  |       |

---

## Permanent teeth

```text
18 17 16 15 14 13 12 11 | 21 22 23 24 25 26 27 28
48 47 46 45 44 43 42 41 | 31 32 33 34 35 36 37 38
```

---

## Primary teeth

```text
55 54 53 52 51 | 61 62 63 64 65
85 84 83 82 81 | 71 72 73 74 75
```

---

## Condition legend

| Code | Description                 |
| ---- | --------------------------- |
| ✓    | Present                     |
| D    | Decayed                     |
| M    | Missing due to caries       |
| MO   | Missing due to other causes |
| Im   | Impacted tooth              |
| Sp   | Supernumerary tooth         |
| Rf   | Root fragment               |
| Un   | Unerupted                   |

---

## Restorations and prosthetics

| Code | Description       |
| ---- | ----------------- |
| Am   | Amalgam filling   |
| Co   | Composite filling |
| JC   | Jacket crown      |
| Ab   | Abutment          |
| Att  | Attachment        |
| P    | Pontic            |
| In   | Inlay             |
| Imp  | Implant           |
| S    | Sealant           |
| Rm   | Removable denture |

---

## Surgery

| Code | Description                    |
| ---- | ------------------------------ |
| X    | Extraction due to caries       |
| XO   | Extraction due to other causes |

---

## X-rays

- [ ] Periapical
- [ ] Panoramic
- [ ] Cephalometric
- [ ] Occlusal
- [ ] Others

---

## Periodontal screening

- Gingivitis
- Early periodontitis
- Moderate periodontitis
- Advanced periodontitis

---

## Occlusion

- Class (molar)
- Overjet
- Overbite
- Midline deviation
- Crossbite

---

## Appliances

- Orthodontic
- Stayplate
- Others

---

## Temporomandibular disorder (TMD)

- Clenching
- Clicking
- Trismus
- Muscle spasm

---

# Page 4 – Treatment Record

| Date | Tooth Number | Procedure | Dentist | Amount Charged | Amount Paid | Balance | Next Appointment |
| ---- | ------------ | --------- | ------- | -------------- | ----------- | ------- | ---------------- |
|      |              |           |         |                |             |         |                  |
