<?php

use App\Models\Appointment;
use App\Models\DentalChartEntry;
use App\Models\Patient;
use App\Models\Treatment;
use App\Models\User;
use App\Repositories\ReportRepository;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

uses(TestCase::class, RefreshDatabase::class);

beforeEach(function () {
    $this->from = Carbon::parse('2026-01-01');
    $this->to = Carbon::parse('2026-12-31');
});

it('counts new patients per month', function () {
    Patient::factory()->create(['created_at' => '2026-03-10']);
    Patient::factory()->create(['created_at' => '2026-03-20']);
    Patient::factory()->create(['created_at' => '2026-07-01']);

    $growth = app(ReportRepository::class)->patientGrowth($this->from, $this->to);

    expect($growth->where('month', '2026-03')->first()->count)->toBe(2);
    expect($growth->where('month', '2026-07')->first()->count)->toBe(1);
});

it('summarizes appointments by status with attendance rate', function () {
    Appointment::factory()->create(['appointment_date' => '2026-05-01', 'status' => 'completed']);
    Appointment::factory()->create(['appointment_date' => '2026-05-02', 'status' => 'completed']);
    Appointment::factory()->create(['appointment_date' => '2026-05-03', 'status' => 'no_show']);
    Appointment::factory()->create(['appointment_date' => '2026-06-01', 'status' => 'cancelled']);

    $summary = app(ReportRepository::class)->appointmentSummary($this->from, $this->to);

    $may = $summary->where('month', '2026-05')->first();
    expect($may->completed)->toBe(2);
    expect($may->no_show)->toBe(1);
    expect($may->attendance_rate)->toBe(66.67);
});

it('groups procedures and dentist workload', function () {
    $dentist = User::factory()->create();
    Treatment::factory()->count(3)->create([
        'dentist_id' => $dentist->id,
        'procedure_name' => 'Composite restoration',
        'treatment_date' => '2026-04-15',
    ]);
    Treatment::factory()->create([
        'dentist_id' => $dentist->id,
        'procedure_name' => 'Extraction',
        'treatment_date' => '2026-04-16',
    ]);

    $procedures = app(ReportRepository::class)->procedureSummary($this->from, $this->to);
    $workload = app(ReportRepository::class)->dentistWorkload($this->from, $this->to);

    expect($procedures->where('procedure_name', 'Composite restoration')->first()->count)->toBe(3);
    expect($workload->first()->count)->toBe(4);
});

it('summarizes top chart conditions', function () {
    $patient = Patient::factory()->create();
    $actor = User::factory()->create();
    foreach ([16, 26, 36] as $tooth) {
        DentalChartEntry::create([
            'patient_id' => $patient->id, 'tooth_number' => $tooth, 'dentition' => 'adult',
            'condition' => 'caries', 'recorded_at' => '2026-08-01', 'recorded_by' => $actor->id,
        ]);
    }

    $conditions = app(ReportRepository::class)->conditionSummary($this->from, $this->to);

    expect($conditions->where('condition', 'caries')->first()->count)->toBe(3);
});
