@component('mail::message')
# Welcome to {{ $clinicName }}!

Hi {{ $name }},

Your staff account for the clinic's patient record system is ready.

- **Email:** {{ $email }}
- **Role:** {{ $role }}

Your administrator will provide your initial password. After signing in, change it from your profile page.

@component('mail::button', ['url' => url('/login')])
Sign in
@endcomponent

Thanks,<br>
{{ $clinicName }}
@endcomponent
