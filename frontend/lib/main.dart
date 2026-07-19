import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemora/app.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/services/auth_service.dart';
import 'package:cinemora/features/discover/repositories/discover_repository.dart';
import 'package:cinemora/features/franchise/repositories/franchise_repository.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/notifications/repositories/notifications_repository.dart';
import 'package:cinemora/features/rankings/repositories/rankings_repository.dart';
import 'package:cinemora/core/services/secure_storage_service.dart';
import 'package:cinemora/core/viewmodels/theme_mode_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/firebase_options.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final storage = SecureStorageService();
  final apiClient = ApiClient(storage);
  final authService = AuthService(apiClient, storage);
  final authCubit = AppAuthCubit(authService);
  final userRepository = UserRepository(apiClient);
  final homeRepository = HomeRepository(apiClient);
  final libraryRepository = LibraryRepository(apiClient);
  final rankingsRepository = RankingsRepository(apiClient);
  final discoverRepository = DiscoverRepository(apiClient);
  final franchiseRepository = FranchiseRepository(apiClient);
  final notificationsRepository = NotificationsRepository(apiClient);
  final prefs = await SharedPreferences.getInstance();
  final themeModeCubit = ThemeModeCubit(prefs);

  FlutterNativeSplash.remove();
  runApp(CinemoraApp(
    authCubit: authCubit,
    userRepository: userRepository,
    homeRepository: homeRepository,
    libraryRepository: libraryRepository,
    rankingsRepository: rankingsRepository,
    discoverRepository: discoverRepository,
    franchiseRepository: franchiseRepository,
    notificationsRepository: notificationsRepository,
    themeModeCubit: themeModeCubit,
    prefs: prefs,
  ));
}
