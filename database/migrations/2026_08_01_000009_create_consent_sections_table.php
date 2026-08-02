<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consent_sections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('consent_form_id')->constrained()->cascadeOnDelete();
            $table->string('key');                                   // snake of PDA section name
            $table->string('label');
            $table->string('initial_svg_path')->nullable();
            $table->timestamp('initialed_at')->nullable();
            $table->timestamps();

            $table->unique(['consent_form_id', 'key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consent_sections');
    }
};
