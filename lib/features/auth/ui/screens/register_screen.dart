import 'package:combustivel_ap/components/custom_button.dart';
import 'package:combustivel_ap/components/custom_snack_bar.dart';
import 'package:combustivel_ap/components/input_text.dart';
import 'package:combustivel_ap/features/auth/ui/screens/login_screen.dart';
import 'package:combustivel_ap/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _authenticateWithEmailAndPassword(BuildContext context) {
    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackBar.error(context, 'As senhas não coincidem.');
      return;
    }

    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      BlocProvider.of<AuthCubit>(context).signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      CustomSnackBar.error(context, 'Preencha todos os campos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            CustomSnackBar.success(context, 'Conta criada com sucesso!');
          }
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
                        const SizedBox(width: 8),
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
                          labelText: 'E-mail',
                          hintText: 'E-mail',
                          icon: Icons.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        InputText(
                          labelText: 'Senha',
                          hintText: 'Senha',
                          icon: Icons.lock,
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        InputText(
                          labelText: 'Confirmar Senha',
                          hintText: 'Confirmar Senha',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          controller: _confirmPasswordController,
                        ),
                        Column(
                          spacing: 5,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: CustomButton(
                                text: 'Cadastrar',
                                fontSize: 18,
                                backgroundColor: AppColors.primary,
                                textColor: Colors.white,
                                onPressed: () => _authenticateWithEmailAndPassword(context),
                              ),
                            ),
                            const Text("ou", style: TextStyle(fontSize: 18, color: AppColors.primary)),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: CustomButton(
                                text: 'Entrar',
                                fontSize: 18,
                                backgroundColor: Colors.white,
                                textColor: AppColors.primary,
                                borderColor: AppColors.primary,
                                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
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

