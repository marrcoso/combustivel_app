import 'package:combustivel_ap/components/custom_button.dart';
import 'package:combustivel_ap/features/auth/cubit/auth_cubit.dart';
import 'package:combustivel_ap/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileDialogs {
  Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sair',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
              },
              text: 'Cancelar',
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),
            CustomButton(
              onPressed: () {
                context.read<AuthCubit>().signOut();
                Navigator.pop(context);
              },
              text: 'Sair',
              backgroundColor: AppColors.negative,
              textColor: Colors.white,
            ),
          ],
        );
      },
    );
  }
}
