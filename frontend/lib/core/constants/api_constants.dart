class ApiConstants {
  // TODO(deploy): point this at the production HTTPS origin before shipping.
  // A release build with a localhost URL resolves to the *phone's* loopback and
  // can never reach the server. Prefer wiring it through the build rather than
  // editing this line per-environment:
  //
  //   static const String baseUrl =
  //       String.fromEnvironment('API_BASE_URL', defaultValue: _devBaseUrl);
  //   flutter build appbundle --dart-define=API_BASE_URL=https://api.example.com/api
  //
  // Two other things move with it, both currently set for cleartext LAN dev:
  //   - android:usesCleartextTraffic + res/xml/network_security_config.xml
  //     (already removed — an http:// URL will now be blocked on Android)
  //   - iOS ATS, if the production origin is ever not HTTPS
  //
  // Physical device on the same Wi-Fi → use the laptop's LAN IP + port.
  // Android emulator → use http://10.0.2.2:3000/api
  // Desktop/web on the laptop itself → use http://localhost:3000/api
  static const String baseUrl = 'http://localhost:3000/api';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';
}
