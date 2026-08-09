<?php

use App\Models\Attachment;
use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
    Storage::fake('local');
});

it('lets an assistant upload an X-ray with a PDA type', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post("/patients/{$patient->id}/attachments", [
        'file' => UploadedFile::fake()->image('pano.jpg', 800, 400),
        'category' => 'xray',
        'xray_type' => 'panoramic',
        'notes' => 'Full mouth pano',
    ])->assertRedirect();

    $attachment = Attachment::first();
    expect($attachment)->not->toBeNull();
    expect($attachment->xray_type)->toBe('panoramic');
    expect($attachment->category->value)->toBe('xray');
    Storage::disk('local')->assertExists($attachment->file_path);
});

it('requires an xray type when category is xray', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post("/patients/{$patient->id}/attachments", [
        'file' => UploadedFile::fake()->image('x.jpg'),
        'category' => 'xray',
    ])->assertSessionHasErrors(['xray_type']);
});

it('rejects wrong file types', function () {
    $assistant = User::factory()->create()->assignRole('Assistant');
    $patient = Patient::factory()->create();

    $this->actingAs($assistant)->post("/patients/{$patient->id}/attachments", [
        'file' => UploadedFile::fake()->create('evil.exe', 10),
        'category' => 'document',
    ])->assertSessionHasErrors(['file']);
});

