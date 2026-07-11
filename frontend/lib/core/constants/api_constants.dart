class ApiConstants {
  // Physical device on the same Wi-Fi → use the laptop's LAN IP + port.
  // Android emulator → use http://10.0.2.2:3000/api
  // Desktop/web on the laptop itself → use http://localhost:3000/api
  static const String baseUrl = 'http://localhost:3000/api';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';
}
