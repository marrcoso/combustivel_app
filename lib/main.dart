import 'package:combustivel_ap/cubit/app_cubit.dart';
import 'package:combustivel_ap/pages/login_page.dart';
import 'package:combustivel_ap/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => AppCubit(),
      child: MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final Map<String, WidgetBuilder> routes = {
    "/register": (context) => const RegisterPage(),
    "/login": (context) => const LoginPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      initialRoute: "/register",
    );
  }
}
