<?php

namespace App\Enums;

enum AttachmentCategory: string
{
    use HasMeta;

    case Image = 'image';
    case Pdf = 'pdf';
    case Xray = 'xray';
    case Prescription = 'prescription';
    case Laboratory = 'laboratory';
    case Document = 'document';
    case Other = 'other';

    /** PDA Page 3 X-ray types — used when category === xray. */
    public const XRAY_TYPES = ['periapical', 'panoramic', 'cephalometric', 'occlusal', 'others'];

    public static function meta(): array
    {
        return [
            'image' => ['label' => 'Image', 'icon' => 'image'],
            'pdf' => ['label' => 'PDF', 'icon' => 'file'],
            'xray' => ['label' => 'X-ray', 'icon' => 'scan'],
            'prescription' => ['label' => 'Prescription', 'icon' => 'file-text'],
            'laboratory' => ['label' => 'Laboratory', 'icon' => 'flask'],
            'document' => ['label' => 'Document', 'icon' => 'folder'],
            'other' => ['label' => 'Other', 'icon' => 'paperclip'],
        ];
    }
}
