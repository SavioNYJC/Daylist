import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:daylist/utils/user_facing_error.dart';

void main() {
  test('shows a friendly message for a duplicate username', () {
    const error = PostgrestException(
      message: 'duplicate key value violates unique constraint',
      code: '23505',
      details: 'Key (username)=(daylist_user) already exists.',
    );

    expect(
      userFacingError(error),
      'That username is already taken. Please choose another.',
    );
  });

  test('explains when the username availability function is missing', () {
    const error = PostgrestException(
      message: 'Could not find the function public.is_username_available',
      code: 'PGRST202',
    );

    expect(
      userFacingError(error),
      'The username check is not set up in Supabase yet. Apply the username '
      'setup SQL, then try signing up again.',
    );
  });

  test('explains when the Blend invitation database update is missing', () {
    const error = PostgrestException(
      message: "Could not find the 'selected_dates' column of 'blends'",
      code: 'PGRST204',
    );

    expect(
      userFacingError(error),
      'The Blend database update is missing. Run the blend invitation SQL '
      'migration in Supabase, then try again.',
    );
  });

  test('does not show raw authentication errors', () {
    const error = AuthException('Invalid login credentials');

    expect(
      userFacingError(error),
      'The email or password is incorrect. Please try again.',
    );
  });

  test('asks unverified users to confirm before logging in', () {
    const error = AuthException(
      'Email not confirmed',
      code: 'email_not_confirmed',
    );

    expect(
      userFacingError(error),
      'Please confirm your email using the link we sent before logging in.',
    );
  });

  test(
    'explains a signup trigger failure without exposing backend details',
    () {
      const error = AuthException('Database error saving new user');

      expect(
        userFacingError(error),
        'We could not create your account. The username may have just been '
        'taken; please try another username or try again later.',
      );
    },
  );
}
