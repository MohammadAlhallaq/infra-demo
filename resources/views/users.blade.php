<!DOCTYPE html>
<html>
<head>
    <title>DB Test - Users</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-8">
    <div class="max-w-xl mx-auto">
        <h1 class="text-2xl font-bold mb-6">DB Test: Users</h1>

        <form method="POST" action="/users" class="bg-white p-6 rounded shadow mb-8">
            @csrf
            <div class="mb-4">
                <label class="block text-sm font-medium mb-1">Name</label>
                <input type="text" name="name" required
                       class="w-full border rounded px-3 py-2">
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium mb-1">Email</label>
                <input type="email" name="email" required
                       class="w-full border rounded px-3 py-2">
            </div>
            <button type="submit"
                    class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                Add User
            </button>
        </form>

        <div class="bg-white p-6 rounded shadow">
            <h2 class="text-lg font-semibold mb-4">Users ({{ $users->count() }})</h2>
            @if ($users->count())
                <table class="w-full text-left">
                    <thead>
                        <tr class="border-b">
                            <th class="pb-2">Name</th>
                            <th class="pb-2">Email</th>
                            <th class="pb-2">Created</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($users as $user)
                            <tr class="border-b last:border-0">
                                <td class="py-2">{{ $user->name }}</td>
                                <td class="py-2">{{ $user->email }}</td>
                                <td class="py-2">{{ $user->created_at->diffForHumans() }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @else
                <p class="text-gray-500">No users yet.</p>
            @endif
        </div>
    </div>
</body>
</html>
