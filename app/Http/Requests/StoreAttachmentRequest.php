<?php

namespace App\Http\Requests;

use App\Enums\AttachmentCategory;
use App\Services\SettingsService;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAttachmentRequest extends FormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        $maxMb = (int) app(SettingsService::class)->get('attachment.max_size_mb', 25);

        return [
            'file' => ['required', 'file', 'mimes:jpeg,png,gif,webp,pdf', 'max:'.($maxMb * 1024)],
            'category' => ['required', Rule::in(array_map(fn ($c) => $c->value, AttachmentCategory::cases()))],
            'xray_type' => ['nullable', 'required_if:category,xray', Rule::in(AttachmentCategory::XRAY_TYPES)],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
