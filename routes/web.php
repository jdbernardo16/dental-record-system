<?php

use App\Http\Controllers\AppointmentsController;
use App\Http\Controllers\ConsultationsController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\MedicalHistoriesController;
use App\Http\Controllers\PatientsController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\UsersController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::middleware(['auth', 'verified'])->get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::middleware(['auth', 'verified', 'permission:users.view'])->prefix('users')->group(function () {
    Route::get('/', [UsersController::class, 'index'])->name('users.index');
});
Route::middleware(['auth', 'verified', 'permission:users.create'])->get('/users/create', [UsersController::class, 'create'])->name('users.create');
Route::middleware(['auth', 'verified', 'permission:users.update'])->get('/users/{user}/edit', [UsersController::class, 'edit'])->name('users.edit');
Route::middleware(['auth', 'verified', 'permission:users.create'])->post('/users', [UsersController::class, 'store'])->name('users.store');
Route::middleware(['auth', 'verified', 'permission:users.update'])->patch('/users/{user}', [UsersController::class, 'update'])->name('users.update');
Route::middleware(['auth', 'verified', 'permission:users.delete'])->delete('/users/{user}', [UsersController::class, 'destroy'])->name('users.destroy');

Route::middleware(['auth', 'verified', 'permission:patients.view'])->get('/patients', [PatientsController::class, 'index'])->name('patients.index');
Route::middleware(['auth', 'verified', 'permission:patients.create'])->get('/patients/create', [PatientsController::class, 'create'])->name('patients.create');
Route::middleware(['auth', 'verified', 'permission:patients.view'])->get('/patients/{patient}', [PatientsController::class, 'show'])->name('patients.show');
Route::middleware(['auth', 'verified', 'permission:patients.create'])->post('/patients', [PatientsController::class, 'store'])->name('patients.store');
Route::middleware(['auth', 'verified', 'permission:patients.update'])->get('/patients/{patient}/edit', [PatientsController::class, 'edit'])->name('patients.edit');
Route::middleware(['auth', 'verified', 'permission:patients.update'])->patch('/patients/{patient}', [PatientsController::class, 'update'])->name('patients.update');
Route::middleware(['auth', 'verified', 'permission:patients.delete'])->delete('/patients/{patient}', [PatientsController::class, 'destroy'])->name('patients.destroy');

Route::middleware(['auth', 'verified', 'permission:medical-histories.create'])->post('/patients/{patient}/medical-history', [MedicalHistoriesController::class, 'store'])->name('medical-histories.store');

Route::middleware(['auth', 'verified', 'permission:appointments.view'])->get('/appointments', [AppointmentsController::class, 'index'])->name('appointments.index');
Route::middleware(['auth', 'verified', 'permission:appointments.create'])->post('/appointments', [AppointmentsController::class, 'store'])->name('appointments.store');
Route::middleware(['auth', 'verified', 'permission:appointments.update'])->patch('/appointments/{appointment}', [AppointmentsController::class, 'update'])->name('appointments.update');
Route::middleware(['auth', 'verified', 'permission:appointments.update'])->post('/appointments/{appointment}/confirm', [AppointmentsController::class, 'confirm'])->name('appointments.confirm');
Route::middleware(['auth', 'verified', 'permission:appointments.cancel'])->post('/appointments/{appointment}/cancel', [AppointmentsController::class, 'cancel'])->name('appointments.cancel');
Route::middleware(['auth', 'verified', 'permission:appointments.attendance'])->post('/appointments/{appointment}/attendance', [AppointmentsController::class, 'attendance'])->name('appointments.attendance');

Route::middleware(['auth', 'verified', 'permission:consultations.create'])
    ->post('/patients/{patient}/consultations', [ConsultationsController::class, 'store'])
    ->name('consultations.store');
Route::middleware(['auth', 'verified', 'permission:consultations.update'])
    ->patch('/consultations/{consultation}', [ConsultationsController::class, 'update'])
    ->name('consultations.update');

require __DIR__.'/auth.php';
