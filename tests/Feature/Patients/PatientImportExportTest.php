<?php

use App\Models\Patient;
use App\Models\User;
use Database\Seeders\RolePermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->seed(RolePermissionSeeder::class);
});

it('exports patients as a csv with headers and data', function () {
    $user = User::factory()->create()->assignRole('Assistant');
    Patient::factory()->create(['first_name' => 'Juan', 'middle_name' => null, 'last_name' => 'Dela Cruz']);
    Patient::factory()->create(['first_name' => 'Maria', 'middle_name' => null, 'last_name' => 'Santos']);

    $response = $this->actingAs($user)->get('/patients/export');

    $response->assertOk();
    $response->assertHeader('Content-Type', 'text/csv; charset=utf-8');

    $content = $response->streamedContent();

    expect($content)->toStartWith("\xEF\xBB\xBF")
        ->and($content)->toContain('patient_number,first_name,middle_name,last_name,sex,birth_date,civil_status,nationality,occupation,contact_number,address,email_address')
        ->and($content)->toContain('Juan')
        ->and($content)->toContain('Maria');
});

it('exports only search-filtered patients', function () {
    $user = User::factory()->create()->assignRole('Assistant');
    Patient::factory()->create(['first_name' => 'Zeta', 'middle_name' => null, 'last_name' => 'Reyes']);
    Patient::factory()->create(['first_name' => 'Rosa', 'middle_name' => null, 'last_name' => 'Lim']);

    $response = $this->actingAs($user)->get('/patients/export?search=Zeta');

    $response->assertOk();
    $content = $response->streamedContent();

    expect($content)->toContain('Zeta')
        ->and($content)->not->toContain('Rosa');
});

it('denies export without the patients.view permission', function () {
    $user = User::factory()->create();

    $this->actingAs($user)->get('/patients/export')->assertForbidden();
});

it('downloads an import template with only the header row', function () {
    $user = User::factory()->create()->assignRole('Assistant');

    $response = $this->actingAs($user)->get('/patients/import/template');

    $response->assertOk();
    $content = $response->streamedContent();

    expect($content)->toContain('first_name,middle_name,last_name,sex,birth_date,civil_status,nationality,occupation,contact_number,address,email_address')
        ->and($content)->not->toContain('patient_number')
        ->and(count(array_filter(explode("\n", trim($content)))))->toBe(1);
});

it('previews rows and flags duplicates and invalid rows', function () {
    $user = User::factory()->create()->assignRole('Assistant');
    Patient::factory()->create([
        'first_name' => 'Juan', 'middle_name' => null, 'last_name' => 'Dela Cruz', 'birth_date' => '1990-01-01',
    ]);

    $csv = implode("\n", [
        'first_name,middle_name,last_name,sex,birth_date,civil_status,nationality,occupation,contact_number,address,email_address',
        'Maria,,Santos,female,1992-05-05,single,Filipino,,09171234567,Manila,maria@example.com',
        'Juan,,Dela Cruz,male,1990-01-01,married,Filipino,,09179876543,Quezon City,',
        ',Cruz,Dela Cruz,male,1995-03-03,single,Filipino,,09170000000,Makati,',
    ]);

    $this->actingAs($user)->post('/patients/import/preview', [
        'file' => UploadedFile::fake()->createWithContent('patients.csv', $csv),
    ])->assertOk()
        ->assertInertia(fn ($page) => $page
            ->component('Patients/Index')
            ->where('importPreview.summary', ['new' => 1, 'duplicate' => 1, 'invalid' => 1])
            ->where('importPreview.total', 3)
            ->where('importPreview.rows.0.status', 'new')
            ->where('importPreview.rows.1.status', 'duplicate')
            ->where('importPreview.rows.2.status', 'invalid')
            ->where('importPreview.token', fn ($token) => is_string($token) && strlen($token) === 40));
});

it('rejects an oversized or wrongly-typed import file', function () {
    $user = User::factory()->create()->assignRole('Assistant');

    $this->actingAs($user)->post('/patients/import/preview', [
        'file' => UploadedFile::fake()->create('patients.pdf', 100),
    ])->assertSessionHasErrors('file');

    $tooManyRows = str_repeat("Juan,,Santos,female,1992-05-05,single,Filipino,,09171234567,Manila,\n", 600);
    $this->actingAs($user)->post('/patients/import/preview', [
        'file' => UploadedFile::fake()->createWithContent(
            'patients.csv',
            "first_name,middle_name,last_name,sex,birth_date,civil_status,nationality,occupation,contact_number,address,email_address\n{$tooManyRows}"
        ),
    ])->assertSessionHasErrors('file');
});

it('imports valid rows and skips duplicates and invalid rows', function () {
    $user = User::factory()->create()->assignRole('Assistant');
    Patient::factory()->create([
        'first_name' => 'Juan', 'middle_name' => null, 'last_name' => 'Dela Cruz', 'birth_date' => '1990-01-01',
    ]);

    $csv = implode("\n", [
        'first_name,middle_name,last_name,sex,birth_date,civil_status,nationality,occupation,contact_number,address,email_address',
        'Maria,,Santos,female,1992-05-05,single,Filipino,,09171234567,Manila,maria@example.com',
        'Juan,,Dela Cruz,male,1990-01-01,married,Filipino,,09179876543,Quezon City,',
        ',Cruz,Dela Cruz,male,1995-03-03,single,Filipino,,09170000000,Makati,',
    ]);

    $this->actingAs($user)->post('/patients/import/preview', [
        'file' => UploadedFile::fake()->createWithContent('patients.csv', $csv),
    ])->assertOk();

    $token = array_key_first(session('patient-import') ?? []);
    expect($token)->toBeString();

    $this->actingAs($user)->post('/patients/import', ['token' => $token])
        ->assertRedirect()
        ->assertSessionHas('importResult', ['imported' => 1, 'skipped_duplicate' => 1, 'failed' => 0]);

    expect(Patient::count())->toBe(2);

    $maria = Patient::where('first_name', 'Maria')->first();
    expect($maria)->not->toBeNull();
    expect($maria->patient_number)->toMatch('/^\d{4}-\d{4}$/');

    expect(Patient::where('first_name', 'Juan')->count())->toBe(1);
});

it('rejects import with an unknown or expired token', function () {
    $user = User::factory()->create()->assignRole('Assistant');

    $this->actingAs($user)->post('/patients/import', ['token' => 'nope'])
        ->assertSessionHasErrors('token');

    $csv = implode("\n", [
        'first_name,middle_name,last_name,sex,birth_date,civil_status,nationality,occupation,contact_number,address,email_address',
        'Maria,,Santos,female,1992-05-05,single,Filipino,,09171234567,Manila,maria@example.com',
    ]);

    $this->actingAs($user)->post('/patients/import/preview', [
        'file' => UploadedFile::fake()->createWithContent('patients.csv', $csv),
    ])->assertOk();

    $token = array_key_first(session('patient-import') ?? []);
    expect($token)->toBeString();

    session()->put("patient-import.{$token}.expires", now()->subMinute());

    $this->actingAs($user)->post('/patients/import', ['token' => $token])
        ->assertSessionHasErrors('token');
});

it('denies preview and import without the patients.create permission', function () {
    $user = User::factory()->create();

    $this->actingAs($user)->get('/patients/import/template')->assertForbidden();
    $this->actingAs($user)->post('/patients/import/preview', [
        'file' => UploadedFile::fake()->createWithContent('patients.csv', 'first_name,last_name'),
    ])->assertForbidden();
    $this->actingAs($user)->post('/patients/import', ['token' => 'x'])->assertForbidden();
});
