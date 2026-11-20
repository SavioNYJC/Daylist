# Daylist

Daylist is a Flutter app backed by Supabase. It currently supports email-and-password signup and login, and lets a signed-in user view their account information and sign out. Event and playlist screens are not built yet.

## Run the app

```powershell
flutter pub get
flutter run -d chrome
```

## Supabase

The Supabase project URL and publishable key are configured in `lib/main.dart`. A publishable key is intended for client apps. Never put a Supabase `service_role` key or other secret in Flutter code.

For local Chrome testing, run the app on a stable port:

```powershell
flutter run -d chrome --web-port 7357
```

Add `http://localhost:7357` to the Supabase project's allowed redirect URLs so email confirmation can return to the running app.

The database contains:

- `profiles`: app profile for each user, including an optional username
- `events`: events owned by users
- `playlists`: playlists owned by users
- `playlist_items`: ordered event entries in playlists
- `blends`: invitations and accepted connections between users

Row Level Security (RLS) is enabled on these tables. Their policies are intended for authenticated users; accepted blends allow users to read some of each other's events and playlists.

On signup, Supabase creates the auth user and the `on_auth_user_created` trigger inserts a matching `profiles` row. The current trigger inserts only `user_id`; it does not yet copy the submitted username into `profiles.username`.

The schema, trigger, and RLS policies currently exist in the Supabase project, but there are no database migrations in this repository yet. Dashboard changes are not automatically saved to GitHub; migrations should be added when you want the backend setup to be reproducible.
