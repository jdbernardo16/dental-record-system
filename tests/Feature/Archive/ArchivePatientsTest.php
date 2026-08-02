<?php

use App\Jobs\ArchivePatientsJob;
use App\Models\Attachment;
use App\Models\Consultation;
use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Spatie\Activitylog\Models\Activity;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
    Storage::fake('local');
    Storage::fake('archive');
});

it('soft-deletes patients with no activity for the configured period', function () {
    config()->set('archive.inactivity_years', 5);
    $inactive = Patient::factory()->create(['created_at' => now()->subYears(6)]);
    $active = Patient::factory()->create([
        'created_at' => now()->subYears(6),
        'updated_at' => now()->subYears(6),
    ]);
    Consultation::factory()->create([
        'patient_id' => $active->id,
        'consultation_date' => now()->subMonths(6)->toDateString(),
        'created_at' => now()->subMonths(6),
    ]);

    dispatch_sync(new ArchivePatientsJob);

    expect($inactive->fresh()->trashed())->toBeTrue();
    expect($active->fresh()->trashed())->toBeFalse();
});

it('keeps recently registered patients', function () {
    config()->set('archive.inactivity_years', 5);
    $recent = Patient::factory()->create(['created_at' => now()->subYear()]);

    dispatch_sync(new ArchivePatientsJob);

    expect($recent->fresh()->trashed())->toBeFalse();
});

it('exports and hard-deletes archived patients past the grace period', function () {
    config()->set('archive.grace_days', 30);
    $actor = User::factory()->create();
    $patient = Patient::factory()->create(['patient_number' => '2020-0042']);
    $patient->delete();
    $patient->update(['deleted_at' => now()->subDays(60)]);

    $attachment = Attachment::factory()->create([
        'patient_id' => $patient->id,
        'file_path' => 'uploads/'.$patient->id.'/photo.jpg',
    ]);
    Storage::disk('local')->put($attachment->file_path, 'jpg-bytes');

    $treatment = Treatment::factory()->create([
        'patient_id' => $patient->id,
        'signature_path' => 'signatures/treatments/99.svg',
    ]);
    Storage::disk('local')->put($treatment->signature_path, '<svg/>');

    dispatch_sync(new ArchivePatientsJob);

    $dir = "archive/{$patient->patient_number}-{$patient->id}";
    expect(Storage::disk('archive')->exists("{$dir}/patient.json"))->toBeTrue();
    expect(Storage::disk('archive')->exists("{$dir}/files/0-photo.jpg"))->toBeTrue();
    expect(Storage::disk('archive')->exists("{$dir}/files/1-99.svg"))->toBeTrue();
    expect(Storage::disk('local')->missing($attachment->file_path))->toBeTrue();
    expect(Storage::disk('local')->missing($treatment->signature_path))->toBeTrue();
    expect(Patient::withTrashed()->find($patient->id))->toBeNull();
    expect(Activity::forSubject($patient)->where('description', 'patient.archived')->exists())->toBeTrue();
});

it('does not purge patients within the grace period', function () {
    config()->set('archive.grace_days', 30);
    $patient = Patient::factory()->create();
    $patient->delete();
    $patient->update(['deleted_at' => now()->subDays(5)]);

    dispatch_sync(new ArchivePatientsJob);

    expect(Patient::withTrashed()->find($patient->id))->not->toBeNull();
});
