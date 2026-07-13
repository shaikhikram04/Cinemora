abstract class AppException implements Exception {
  final String code;
  final String? devMessage;

  const AppException(this.code, [this.devMessage]);

  String get userMessage;

  @override
  String toString() => 'AppException[$code]: ${devMessage ?? userMessage}';
}

/// Error returned by our own backend as { error: { code, message } }.
class BackendException extends AppException {
  const BackendException(super.code, [super.devMessage]);

  @override
  String get userMessage => switch (code) {
        // Auth
        'AUTH_INVALID_FIREBASE_TOKEN' =>
          'Authentication failed. Please try again.',
        'AUTH_TOKEN_EXPIRED' =>
          'Your session has expired. Please sign in again.',
        'AUTH_NO_TOKEN' => 'Please sign in to continue.',
        'AUTH_USER_NOT_FOUND' => 'Account not found.',
        'AUTH_INVALID_REFRESH_TOKEN' =>
          'Your session has expired. Please sign in again.',
        // Library
        'LIBRARY_ALREADY_EXISTS' => 'This title is already in your library.',
        'LIBRARY_ENTRY_NOT_FOUND' => 'This title is not in your library.',
        'LIBRARY_MISSING_FIELDS' => 'Missing required fields.',
        // Rankings
        'RANKING_LIST_NOT_FOUND' => 'Ranking list not found.',
        'RANKING_ALREADY_IN_LIST' => 'This title is already in this list.',
        'RANKING_ENTRY_NOT_FOUND' => 'Entry not found in this list.',
        'RANKING_TITLE_REQUIRED' => 'Please enter a list title.',
        'RANKING_MISSING_FIELDS' => 'Missing required fields.',
        // Watch Together
        'SESSION_NOT_FOUND' => 'Watch session not found or has expired.',
        'SESSION_ENDED' => 'This watch session has already ended.',
        'SESSION_FORBIDDEN' => 'Only the host can end the session.',
        'SESSION_MISSING_FIELDS' => 'Missing required session fields.',
        // Users
        'USER_NOT_FOUND' => 'Account not found.',
        // Profile images
        'IMAGE_INVALID_TYPE' => 'Please pick a JPEG, PNG or WebP image.',
        'IMAGE_TOO_LARGE' => 'That image is too large — pick one under 5 MB.',
        'IMAGE_REQUIRED' => 'No image was selected.',
        'IMAGE_UPLOAD_FAILED' =>
          'Could not upload the image. Please try again.',
        // Notifications
        'NOTIFICATION_NOT_FOUND' => 'Notification not found.',
        // Mood chat — the recommender sends a specific user-facing reason
        // (rate limit, not configured) in devMessage.
        'MOOD_CHAT_ERROR' =>
          devMessage ?? 'Mood chat is unavailable right now.',
        // Fallback
        _ => 'Something went wrong. Please try again.',
      };
}

/// Network connectivity or timeout error.
class NetworkException extends AppException {
  const NetworkException([super.code = 'NETWORK_ERROR', super.devMessage]);

  @override
  String get userMessage => switch (code) {
        'NETWORK_TIMEOUT' =>
          'Request timed out. Check your connection and try again.',
        'NETWORK_NO_CONNECTION' => 'No internet connection.',
        _ => 'Network error. Check your connection and try again.',
      };
}

/// Firebase Authentication error — code matches FirebaseAuthException.code.
class AuthException extends AppException {
  const AuthException(super.code, [super.devMessage]);

  @override
  String get userMessage => switch (code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'email-already-in-use' => 'An account with this email already exists.',
        'invalid-email' => 'Invalid email address.',
        'user-disabled' => 'This account has been disabled. Contact support.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => 'Authentication failed. Please try again.',
      };
}

/// Google / Apple platform sign-in error — code matches PlatformException.code.
class PlatformSignInException extends AppException {
  const PlatformSignInException(super.code, [super.devMessage]);

  @override
  String get userMessage => switch (code) {
        'sign_in_cancelled' ||
        'SIGN_IN_CANCELLED' ||
        'cancelled' ||
        'com.apple.AuthenticationServices.AuthorizationError.1001' =>
          'Sign-in was cancelled.',
        'network_error' ||
        'NETWORK_ERROR' =>
          'Network error. Check your connection.',
        'sign_in_failed' ||
        'SIGN_IN_FAILED' =>
          'Sign-in failed. Please try again.',
        _ => 'Sign-in failed. Please try again.',
      };
}
