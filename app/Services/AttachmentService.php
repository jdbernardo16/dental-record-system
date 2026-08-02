<?php

namespace App\Services;

use App\Models\Attachment;
use App\Models\Patient;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;

final class AttachmentService
{
    public function store(UploadedFile $file, array $data, Patient $patient, mixed $uploader): Attachment
    {
        $extension = $file->getClientOriginalExtension() ?: 'bin';
        $path = $file->storeAs(
            "uploads/{$patient->id}",
            Str::uuid().'.'.$extension,
            'local'
        );

        $attachment = Attachment::create([
            'patient_id' => $patient->id,
            'uploaded_by' => $uploader?->id,
            'category' => $data['category'],
            'xray_type' => $data['xray_type'] ?? null,
            'original_name' => $file->getClientOriginalName(),
            'file_path' => $path,
            'mime_type' => $file->getMimeType(),
            'file_size' => $file->getSize(),
            'notes' => $data['notes'] ?? null,
        ]);

        activity()->performedOn($attachment)->causedBy($uploader)->log('attachment.uploaded');

        return $attachment;
    }

    public function delete(Attachment $attachment, mixed $actor): void
    {
        $attachment->delete();  // soft delete (Phase 4 archiving keeps the file)
        activity()->performedOn($attachment)->causedBy($actor)->log('attachment.deleted');
    }
}
