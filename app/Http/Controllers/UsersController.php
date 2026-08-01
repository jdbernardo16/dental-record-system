<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class UsersController extends Controller
{
    /**
     * Display a listing of users.
     */
    public function index(Request $request): Response
    {
        $this->authorize('viewAny', User::class);

        return Inertia::render('Users/Index', [
            'users' => User::with('roles')->orderBy('name')->get(),
            'can' => [
                'create' => $request->user()->can('users.create'),
                'delete' => $request->user()->can('users.delete'),
            ],
        ]);
    }

    /**
     * Show the form for creating a new user.
     */
    public function create(Request $request): Response
    {
        $this->authorize('create', User::class);

        return Inertia::render('Users/Create', [
            'roles' => $this->roleNames(),
        ]);
    }

    /**
     * Store a newly created user.
     */
    public function store(StoreUserRequest $request): RedirectResponse
    {
        $this->authorize('create', User::class);

        $user = User::create($request->validated());
        $user->assignRole($request->validated('role'));

        activity()->log('users.created');

        return Redirect::route('users.index');
    }

    /**
     * Show the form for editing the given user.
     */
    public function edit(Request $request, User $user): Response
    {
        $this->authorize('update', $user);

        return Inertia::render('Users/Edit', [
            'user' => $user->load('roles'),
            'roles' => $this->roleNames(),
            'can' => [
                'delete' => $request->user()->can('users.delete'),
            ],
        ]);
    }

    /**
     * Update the given user.
     */
    public function update(UpdateUserRequest $request, User $user): RedirectResponse
    {
        $this->authorize('update', $user);

        $data = $request->validated();

        if (blank($data['password'])) {
            unset($data['password']);
        }

        $user->update($data);
        $user->syncRoles($request->validated('role'));

        activity()->log('users.updated');

        return Redirect::route('users.index');
    }

    /**
     * Remove the given user.
     */
    public function destroy(Request $request, User $user): RedirectResponse
    {
        $this->authorize('delete', $user);

        abort_if($user->id === $request->user()->id, 403, 'You cannot delete your own account.');

        $user->delete();

        activity()->log('users.deleted');

        return Redirect::route('users.index');
    }

    /**
     * @return list<string>
     */
    private function roleNames(): array
    {
        return \Spatie\Permission\Models\Role::orderBy('name')->pluck('name')->all();
    }
}
