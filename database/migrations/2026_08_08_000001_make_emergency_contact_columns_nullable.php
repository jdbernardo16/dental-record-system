<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('patients', function (Blueprint $table) {
            $table->string('emergency_contact_person')->nullable()->change();
            $table->string('emergency_contact_number')->nullable()->change();
        });
    }

    public function down(): void
    {
        DB::table('patients')->whereNull('emergency_contact_person')->update(['emergency_contact_person' => '']);
        DB::table('patients')->whereNull('emergency_contact_number')->update(['emergency_contact_number' => '']);

        Schema::table('patients', function (Blueprint $table) {
            $table->string('emergency_contact_person')->nullable(false)->change();
            $table->string('emergency_contact_number')->nullable(false)->change();
        });
    }
};
