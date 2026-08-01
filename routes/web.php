<?php

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

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

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

require __DIR__.'/auth.php';
