<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('medical_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('hypertension')->default('no');
            $table->string('diabetes')->default('no');
            $table->string('tuberculosis')->default('no');
            $table->string('heart_disease')->default('no');
            $table->string('pregnancy')->default('no');
            $table->string('allergies')->default('no');
            $table->string('medications')->default('no');
            $table->string('smoking_history')->default('no');
            $table->string('alcohol_consumption')->default('no');
            $table->string('previous_surgeries')->default('no');
            $table->text('allergies_details')->nullable();
            $table->text('medications_details')->nullable();
            $table->text('smoking_details')->nullable();
            $table->text('alcohol_details')->nullable();
            $table->text('surgeries_details')->nullable();
            $table->text('remarks')->nullable();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medical_histories');
    }
};
