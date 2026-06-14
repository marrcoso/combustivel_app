import 'package:combustivel_ap/components/custom_button.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
              Text("Registrar", 
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
              Column(
                children: [
                  CustomButton(
                    text: "Registrar",
                    onPressed: () {},
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Já possui uma conta? "),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, "/login"),
                        child: Text("Faça login aqui")
                      )
                    ],
                  )
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}