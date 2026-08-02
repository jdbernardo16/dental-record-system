<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consent_forms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->string('version', 10)->default('1.0');
            $table->text('consent_text');                            // snapshot of the section texts JSON
            $table->string('patient_name');                          // captured, not derived
            $table->string('patient_signature_path')->nullable();
            $table->string('guardian_name')->nullable();             // required when patient.age < 18 (Q4)
            $table->string('guardian_signature_path')->nullable();
            $table->foreignId('dentist_id')->constrained('users')->cascadeOnDelete();
            $table->string('dentist_signature_path')->nullable();
            $table->timestamp('patient_signed_at')->nullable();
            $table->timestamp('dentist_signed_at')->nullable();
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->string('status')->default('unsigned');
            $table->timestamps();

            $table->index(['patient_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consent_forms');
    }
};
