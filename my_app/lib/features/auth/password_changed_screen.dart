import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordChangedScreen extends StatelessWidget {

  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

              const Icon(
                Icons.check_circle,
                size: 140,
                color: Colors.teal,
              ),

              const SizedBox(height: 40),

              const Text(

                "Password Changed",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(

                "Your password has been updated successfully.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(

                width: double.infinity,
                height: 60,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),

                  onPressed: () {

                    context.go('/login');

                  },

                  child: const Text(
                    "Back to Login",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}