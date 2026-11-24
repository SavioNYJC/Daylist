# Daylist

Daylist is a Flutter app backed by Supabase. It currently supports email-and-password signup and login, and lets a signed-in user view their account information, sign out, or request account deletion. Event and playlist screens are not built yet.

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

On Android, add `daylist://login-callback` to the Supabase project's allowed redirect URLs. The confirmation link opens Daylist and displays a confirmation message; the user logs in manually. Supabase URI session detection is disabled so the confirmation code is not exchanged for a signed-in session.

The database contains:

- `profiles`: app profile for each user, including an optional username
- `events`: events owned by users
- `playlists`: playlists owned by users
- `playlist_items`: ordered event entries in playlists
- `blends`: invitations and accepted connections between users

Row Level Security (RLS) is enabled on these tables. Their policies are intended for authenticated users; accepted blends allow users to read some of each other's events and playlists.

On signup, Supabase creates the auth user and the `on_auth_user_created` trigger inserts a matching `profiles` row. Apply `supabase/migrations/20261120234000_username_uniqueness.sql` in the Supabase SQL Editor to save the submitted username, enforce case-insensitive uniqueness, and enable the signup page's username-availability check.

The original schema and RLS policies were configured in the Supabase project. Dashboard changes are not automatically saved to GitHub, so keep applying and saving future database changes as migrations in this repository.

### Blends

The Home screen loads accepted blends and pending invitations from `public.blends`. Users can create a blend invitation with another account's username, select dates, and add an optional description. The recipient can accept or decline. Accepted blends open a side-by-side comparison of both users' events on the selected dates, using the device's local time.

The bottom-right plus button expands to quick actions for new playlists, pending blends, and new blends. Pending blends opens a dedicated page where incoming invitations can be accepted or declined and sent invitations can be reviewed.

Apply `supabase/migrations/20261124144000_blend_invitation_details.sql` in the Supabase SQL Editor to add the selected dates and description columns before using the updated invitation form. In debug builds, **Preview sample blend** opens a sample schedule without writing to Supabase or requiring a second account.

### Account deletion

The Account Details screen calls the `delete-account` Edge Function after the user confirms deletion. The function verifies the signed-in user and deletes only that user's Supabase Auth account; the service-role key stays on Supabase and must never be added to Flutter.

Deploy it to the linked Supabase project with the Supabase CLI:

```powershell
supabase init
supabase login
supabase link --project-ref <your-project-ref>
supabase functions deploy delete-account
```

Run `supabase init` only if this repository has not already been initialized with the Supabase CLI. The function deletes the Auth user, so configure foreign keys in the ownership chain (for example, user-owned tables to `auth.users(id)`) with `ON DELETE CASCADE` if those rows should be removed too. The Edge Function logs an error and does not report success if Supabase refuses the deletion.
