<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dental_chart_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('tooth_number');               // FDI: adult 11–48, primary 51–85
            $table->string('dentition')->default('adult');             // DentitionType
            $table->string('condition');                               // ToothCondition (PDA legend)
            $table->string('restoration_type')->nullable();            // RestorationType (PDA codes)
            $table->string('surface')->nullable();                     // ToothSurface; null = whole tooth
            $table->string('color_code', 32)->nullable();              // denorm snapshot of condition color token
            $table->text('notes')->nullable();
            $table->date('recorded_at');                               // clinical date
            $table->foreignId('recorded_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->index(['patient_id', 'tooth_number', 'surface', 'recorded_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dental_chart_entries');
    }
};
