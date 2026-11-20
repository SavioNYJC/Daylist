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

  test('does not show raw authentication errors', () {
    const error = AuthException('Invalid login credentials');

    expect(
      userFacingError(error),
      'The email or password is incorrect. Please try again.',
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
