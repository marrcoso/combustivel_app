import 'package:combustivel_ap/components/custom_button.dart';
import 'package:combustivel_ap/components/custom_snack_bar.dart';
import 'package:combustivel_ap/components/input_text.dart';
import 'package:combustivel_ap/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _authenticateWithEmailAndPassword(BuildContext context) {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      BlocProvider.of<AuthCubit>(context).signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      CustomSnackBar.error(context, 'Preencha os campos de e-mail e senha.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            CustomSnackBar.error(context, state.message);
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container(
              color: AppColors.background,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 62),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_gas_station,
                          size: 42,
                          color: AppColors.primary,
                        ),
                        const Text(
                          'Combustível App',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      spacing: 20,
                      children: [
                        InputText(
                          controller: _emailController,
                          labelText: 'E-mail',
                          hintText: 'E-mail',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        InputText(
                          controller: _passwordController,
                          labelText: 'Senha',
                          hintText: 'Senha',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        Column(
                          spacing: 5,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: CustomButton(
                                text: 'Entrar',
                                fontSize: 18,
                                backgroundColor: AppColors.primary,
                                textColor: Colors.white,
                                onPressed: () => _authenticateWithEmailAndPassword(context)
                              ),
                            ),
                            const Text("ou", style: TextStyle(fontSize: 18, color: AppColors.primary)),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: CustomButton(
                                text: 'Cadastrar',
                                fontSize: 18,
                                backgroundColor: Colors.white,
                                textColor: AppColors.primary,
                                borderColor: AppColors.primary,
                                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterScreen()))
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
