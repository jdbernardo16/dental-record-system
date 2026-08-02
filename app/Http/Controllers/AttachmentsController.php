<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreAttachmentRequest;
use App\Models\Attachment;
use App\Models\Patient;
use App\Services\AttachmentService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

class AttachmentsController extends Controller
{
    public function __construct(private readonly AttachmentService $service) {}

    public function store(StoreAttachmentRequest $request, Patient $patient): RedirectResponse
    {
        $this->authorize('create', Attachment::class);

        $this->service->store(
            $request->file('file'),
            $request->safe()->only(['category', 'xray_type', 'notes']),
            $patient,
            $request->user()
        );

        return Redirect::back();
    }

    public function destroy(Request $request, Attachment $attachment): RedirectResponse
    {
        $this->authorize('delete', $attachment);

        $this->service->delete($attachment, $request->user());

        return Redirect::back();
    }
}
