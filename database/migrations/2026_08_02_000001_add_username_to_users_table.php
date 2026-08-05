<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('username', 50)->nullable()->after('name');
        });

        // Backfill existing users from their email prefix (collision-safe).
        $taken = [];
        DB::table('users')->orderBy('id')->get()->each(function ($user) use (&$taken) {
            $base = strtolower((string) strstr((string) $user->email, '@', true));
            $username = $base;
            $i = 1;
            while (isset($taken[$username])) {
                $username = $base.$i++;
            }
            $taken[$username] = true;
            DB::table('users')->where('id', $user->id)->update(['username' => $username]);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->string('username', 50)->nullable(false)->unique()->change();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['username']);
            $table->dropColumn('username');
        });
    }
};
