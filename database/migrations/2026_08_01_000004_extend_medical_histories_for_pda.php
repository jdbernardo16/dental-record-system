<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('medical_histories', function (Blueprint $table) {
            $table->string('good_health')->nullable();                       // no/yes
            $table->string('under_medical_treatment')->nullable();           // no/yes
            $table->text('medical_treatment_details')->nullable();
            $table->string('hospitalized')->nullable();                      // no/yes
            $table->text('hospitalization_details')->nullable();
            $table->string('nursing')->nullable();                           // no/yes (women only)
            $table->string('birth_control_pills')->nullable();               // no/yes (women only)
            $table->string('bleeding_time')->nullable();                     // free text
            $table->string('blood_type')->nullable();                        // A+ A- B+ B- AB+ AB- O+ O-
            $table->string('blood_pressure')->nullable();                    // free text e.g. "120/80"
            $table->json('conditions_checklist')->nullable();                // array of PDA 36 condition keys
            $table->string('physician_name')->nullable();
            $table->string('physician_specialty')->nullable();
            $table->string('physician_address')->nullable();
            $table->string('physician_phone')->nullable();
            $table->string('dental_history_previous_dentist')->nullable();
            $table->date('dental_history_last_visit')->nullable();
            $table->string('referral_source')->nullable();
            $table->string('drug_use')->nullable();                          // no/yes (PDA Q7)
            $table->text('drug_use_details')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('medical_histories', function (Blueprint $table) {
            $table->dropColumn([
                'good_health', 'under_medical_treatment', 'medical_treatment_details',
                'hospitalized', 'hospitalization_details', 'nursing', 'birth_control_pills',
                'bleeding_time', 'blood_type', 'blood_pressure', 'conditions_checklist',
                'physician_name', 'physician_specialty', 'physician_address', 'physician_phone',
                'dental_history_previous_dentist', 'dental_history_last_visit',
                'referral_source', 'drug_use', 'drug_use_details',
            ]);
        });
    }
};
