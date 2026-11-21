import 'package:supabase_flutter/supabase_flutter.dart';

String userFacingError(Object? error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();

    if (message.contains('code verifier')) {
      return 'We could not finish email confirmation in this browser. Try logging '
          'in, or start signup again using the same browser and address.';
    }
    if (error.code == 'over_email_send_rate_limit' ||
        message.contains('email rate limit')) {
      return 'Too many confirmation emails have been requested. Please wait '
          'before trying again.';
    }
    if (error.code == 'user_already_exists' ||
        message.contains('already registered') ||
        message.contains('user already exists')) {
      return 'An account with this email already exists. Try logging in.';
    }
    if (error.code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'The email or password is incorrect. Please try again.';
    }
    if (error.code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'Please confirm your email using the link we sent before logging in.';
    }
    if (error.code == 'weak_password' ||
        message.contains('weak password') ||
        message.contains('password should be')) {
      return 'Please choose a stronger password.';
    }
    if (message.contains('username') &&
        (message.contains('already') ||
            message.contains('duplicate') ||
            message.contains('unique'))) {
      return 'That username is already taken. Please choose another.';
    }
    if (message.contains('database error saving new user')) {
      return 'We could not create your account. The username may have just been '
          'taken; please try another username or try again later.';
    }

    return 'We could not complete that request. Please check your details and '
        'try again.';
  }

  if (error is PostgrestException) {
    final details =
        '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'
            .toLowerCase();

    if (error.code == 'PGRST202' ||
        details.contains('is_username_available')) {
      return 'The username check is not set up in Supabase yet. Apply the '
          'username setup SQL, then try signing up again.';
    }
    if (error.code == '23505' && details.contains('username')) {
      return 'That username is already taken. Please choose another.';
    }
    if (error.code == '23505') {
      return 'That information is already in use. Please choose something else.';
    }
    if (error.code == '42501') {
      return 'You do not have permission to access that information.';
    }

    return 'We could not complete that request. Please try again.';
  }

  if (error is StateError &&
      error.message == 'You must be signed in to view your profile') {
    return 'Please log in to view your account information.';
  }

  return 'Something went wrong. Please try again.';
}
