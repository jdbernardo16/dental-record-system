<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consultations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->foreignId('dentist_id')->constrained('users')->cascadeOnDelete();
            $table->date('consultation_date');
            $table->text('chief_complaint');
            $table->text('examination_findings')->nullable();
            $table->text('diagnosis')->nullable();
            $table->text('treatment_plan')->nullable();
            $table->text('recommendations')->nullable();
            $table->text('notes')->nullable();
            // PDA Page 3 — Intraoral Examination (all nullable, string single-select or free text)
            $table->string('periodontal_screening')->nullable();   // gingivitis|early_periodontitis|moderate_periodontitis|advanced_periodontitis
            $table->string('occlusion_class')->nullable();         // class_i|class_ii|class_iii
            $table->string('overjet')->nullable();                 // free text e.g. "2mm"
            $table->string('overbite')->nullable();                // free text
            $table->string('midline_deviation')->nullable();       // free text
            $table->string('crossbite')->nullable();               // free text
            $table->json('appliances')->nullable();                // array of orthodontic|stayplate|others
            $table->json('tmd_findings')->nullable();              // array of clenching|clicking|trismus|muscle_spasm
            $table->timestamps();

            $table->index(['patient_id', 'consultation_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consultations');
    }
};
