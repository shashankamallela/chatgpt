import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerificationSuccessScreen extends StatelessWidget {

  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

              Container(

                height: 180,
                width: 180,

                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.green,
                  size: 110,
                ),
              ),

              const SizedBox(height: 50),

              const Text(

                "Verification\nSuccessful!",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              const Text(

                "Your email has been verified successfully.\nYou can now continue using SmileWell.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 70),

              SizedBox(

                width: double.infinity,
                height: 65,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.teal,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),

                  onPressed: () {

                    context.go('/login');

                  },

                  child: const Text(

                    "Continue",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(

                onPressed: () {

                  context.go('/otp');

                },

                child: const Text(

                  "Back",

                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
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