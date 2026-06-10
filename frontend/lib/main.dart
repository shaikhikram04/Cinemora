import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:watchary/app.dart';
import 'package:watchary/core/network/api_client.dart';
import 'package:watchary/core/repositories/user_repository.dart';
import 'package:watchary/core/services/auth_service.dart';
import 'package:watchary/core/services/secure_storage_service.dart';
import 'package:watchary/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:watchary/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final storage = SecureStorageService();
  final apiClient = ApiClient(storage);
  final authService = AuthService(apiClient, storage);
  final authCubit = AppAuthCubit(authService);
  final userRepository = UserRepository(apiClient);

  runApp(WatcharyApp(authCubit: authCubit, userRepository: userRepository));
}
