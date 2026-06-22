import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/home/ui/screens/home_screen.dart';
import 'features/stations/repositories/station_repository.dart';
import 'features/stations/cubit/station_cubit.dart';
import 'features/home/cubit/filter_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => StationRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            )..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) => StationCubit(
              stationRepository: RepositoryProvider.of<StationRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => FilterCubit(),
          ),
        ],
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combustível App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthInitial() || AuthLoading() => const Scaffold(body: Center(child: CircularProgressIndicator())),
            Authenticated() => const HomeScreen(),
            _ => const LoginScreen(),
          };
        },
      ),
    );
  }
}
