import 'package:combustivel_ap/components/custom_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter, 
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Login", 
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              CustomButton(
                text: "Login",
                onPressed: () {},
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 24,
              )
            ],
          )
        ),
      ),
    );
  }
}