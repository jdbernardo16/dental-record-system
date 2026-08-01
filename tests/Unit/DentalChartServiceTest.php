<?php

use App\Enums\DentitionType;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\User;
use App\Services\DentalChartService;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

uses(TestCase::class, RefreshDatabase::class);

it('projects the latest entry per tooth and surface', function () {
    $patient = Patient::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => 'occlusal', 'recorded_at' => now()->toDateString(),
        'recorded_by' => User::factory()->create()->id,
    ]);
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 16, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => null, 'restoration_type' => 'filling_composite',
        'recorded_at' => now()->toDateString(), 'recorded_by' => User::factory()->create()->id,
    ]);

    $state = app(DentalChartService::class)->currentState($patient->id, 'adult');

    expect($state[16]['whole']['condition'])->toBe('caries');
    expect($state[16]['whole']['restoration'])->toBe('filling_composite');
    expect($state[16]['surfaces']['occlusal']['condition'])->toBe('caries');
    expect($state[16]['surfaces']['occlusal']['restoration'])->toBeNull();
});

it('supersedes by recency (latest recorded_at wins)', function () {
    $patient = Patient::factory()->create();
    $actor = User::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 11, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => null, 'recorded_at' => '2026-07-01', 'recorded_by' => $actor->id,
    ]);
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 11, 'dentition' => 'adult',
        'condition' => 'missing_caries', 'surface' => null, 'recorded_at' => '2026-07-15', 'recorded_by' => $actor->id,
    ]);

    $state = app(DentalChartService::class)->currentState($patient->id, 'adult');

    expect($state[11]['whole']['condition'])->toBe('missing_caries');
});

it('returns state as of a past date and a full history log', function () {
    $patient = Patient::factory()->create();
    $actor = User::factory()->create();
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 21, 'dentition' => 'adult',
        'condition' => 'caries', 'surface' => null, 'recorded_at' => '2026-07-01', 'recorded_by' => $actor->id,
    ]);
    DentalChartEntry::create([
        'patient_id' => $patient->id, 'tooth_number' => 21, 'dentition' => 'adult',
        'condition' => 'missing_caries', 'surface' => null, 'recorded_at' => '2026-07-15', 'recorded_by' => $actor->id,
    ]);

    $service = app(DentalChartService::class);
    $asOf = $service->stateAsOf($patient->id, 'adult', Carbon::parse('2026-07-10'));

    expect($asOf[21]['whole']['condition'])->toBe('caries');

    $history = $service->history($patient->id);
    expect($history)->toHaveCount(2);
    expect($history->first()->tooth_number)->toBe(21);
});

it('validates FDI tooth ranges per dentition', function () {
    expect(DentitionType::isValidTooth(16, 'adult'))->toBeTrue();
    expect(DentitionType::isValidTooth(51, 'adult'))->toBeFalse();
    expect(DentitionType::isValidTooth(55, 'primary'))->toBeTrue();
    expect(DentitionType::isValidTooth(11, 'primary'))->toBeFalse();
    expect(DentitionType::isValidTooth(65, 'primary'))->toBeTrue();
});
