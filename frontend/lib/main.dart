import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cinemora/app.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/services/auth_service.dart';
import 'package:cinemora/core/services/secure_storage_service.dart';
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

  FlutterNativeSplash.remove();
  runApp(WatcharyApp(authCubit: authCubit, userRepository: userRepository));
}
