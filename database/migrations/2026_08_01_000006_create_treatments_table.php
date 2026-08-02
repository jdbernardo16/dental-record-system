<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('treatments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->foreignId('consultation_id')->nullable()->constrained()->nullOnDelete();
            $table->unsignedTinyInteger('tooth_number')->nullable();   // FDI; null = non-tooth procedure
            $table->string('procedure_name');
            $table->text('description')->nullable();
            $table->text('notes')->nullable();
            $table->foreignId('dentist_id')->constrained('users')->cascadeOnDelete();
            $table->date('treatment_date');
            $table->string('signature_path')->nullable();
            $table->timestamp('signed_at')->nullable();
            $table->timestamps();

            $table->index(['patient_id', 'treatment_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('treatments');
    }
};
