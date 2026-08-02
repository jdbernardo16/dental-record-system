<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->string('religion')->nullable();
            $table->string('nickname')->nullable();
            $table->string('home_phone')->nullable();
            $table->string('office_phone')->nullable();
            $table->string('fax_number')->nullable();
            $table->string('dental_insurance')->nullable();
            $table->date('effective_date')->nullable();
            $table->string('guardian_name')->nullable();
            $table->string('guardian_occupation')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->dropColumn([
                'religion', 'nickname', 'home_phone', 'office_phone', 'fax_number',
                'dental_insurance', 'effective_date', 'guardian_name', 'guardian_occupation',
            ]);
        });
    }
};
