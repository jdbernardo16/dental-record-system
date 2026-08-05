<?php

namespace App\Mail;

use App\Models\User;
use App\Services\SettingsService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class WelcomeMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(public User $user, public string $roleName) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: 'Welcome to '.app(SettingsService::class)->get('clinic.name', 'the clinic'));
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'emails.welcome',
            with: [
                'name' => $this->user->name,
                'email' => $this->user->email,
                'role' => $this->roleName,
                'clinicName' => app(SettingsService::class)->get('clinic.name', 'the clinic'),
            ],
        );
    }
}
