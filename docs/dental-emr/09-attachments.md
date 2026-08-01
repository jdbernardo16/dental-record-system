# 09 — File Attachments

## Purpose

Store per-patient documents (spec §11): images, PDFs, X-rays, prescriptions, laboratory results. Uploaded mainly by Assistant (*Upload attachments*).

## Database — `attachments`

```php
// 2026_01_01_000009_create_attachments_table.php
Schema::create('attachments', function (Blueprint $table) {
    $table->id();
    $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
    $table->foreignId('uploaded_by')->nullable()->constrained('users')->nullOnDelete();
    $table->string('category')->default('image');        // AttachmentCategory enum
    $table->string('original_name');
    $table->string('file_path');                          // storage path on local disk (default) / S3
    $table->string('mime_type');
    $table->unsignedBigInteger('file_size');              // bytes
    $table->text('notes')->nullable();
    $table->timestamps();

    $table->index(['patient_id', 'category']);
});
```

## Enum

```php
enum AttachmentCategory: string
{
    case Image        = 'image';
    case Pdf          = 'pdf';
    case Xray         = 'xray';
    case Prescription = 'prescription';
    case Laboratory   = 'laboratory';
    case Document     = 'document';
    case Other        = 'other';
    // meta(): label, icon
}
```

## Storage Strategy

- Default disk: `local` under `storage/app/uploads/{patient_id}/` — see cross-cutting (12) for S3 option + backup tie-in.
- File naming: `{uuid}.{ext}` — original name preserved only in `original_name`.
- Validation: `mimes:jpeg,png,gif,webp,pdf` + max 25 MB (Q9); X-ray category allows larger limit.
- Upload endpoint streams with progress (`axios` `onUploadProgress` in Pinia store) — tablet uploads of multi-MB X-rays need feedback.
- **No hard deletes** (medico-legal): `attachments.delete` permission → soft-delete flag? Decision: `deleted_at` column added via policy-enabled soft delete; only Administrator can delete, audit-logged.

## Service

```php
final class AttachmentService
{
    public function store(UploadedFile $file, array $data, User $uploader): Attachment
    {
        $path = $file->store("uploads/{$data['patient_id']}", 'local');
        $attachment = Attachment::create([...$data, 'file_path' => $path, 'uploaded_by' => $uploader->id]);
        activity()->performedOn($attachment)->causedBy($uploader)->log('attachment.uploaded');
        return $attachment;
    }

    public function stream(Attachment $attachment): StreamedResponse   // inline view for X-ray/DICOM-ish display
}
```

## Permissions

| Permission | Roles |
|---|---|
| `attachments.view` | administrator, dentist, assistant |
| `attachments.upload` | administrator, dentist, assistant |
| `attachments.delete` | administrator |

## UI Elements (improvised)

- **File list tab** on patient record: category icon chips, thumbnail grid for images/X-rays, tap → lightbox/preview modal (PDF → iframe embed).
- **Upload button** (≥44px): file picker with category selector before confirm; progress bar during upload.
- X-ray viewing: full-screen dark mode viewer with pinch-zoom (tablet).
