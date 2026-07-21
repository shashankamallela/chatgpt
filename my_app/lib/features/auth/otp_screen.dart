import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_service.dart';
import '../../services/auth_storage.dart';

class OtpScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String otp;
  final bool savePassword;

  const OtpScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.otp,
    required this.savePassword,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final String enteredOtp = otpController.text.trim();

    if (enteredOtp.length != 4) {
      showSnackBar('Invalid OTP');
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    final bool verified = ApiService.verifyLocalOtp(
      enteredOtp: enteredOtp,
      expectedOtp: widget.otp,
    );

    if (!verified) {
      setState(() {
        isLoading = false;
      });

      showSnackBar('Invalid OTP');
      return;
    }

    try {
      final Map<String, dynamic> result = await ApiService.signup(
        name: widget.name,
        email: widget.email,
        password: widget.password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await AuthStorage.setCurrentEmail(widget.email);

        if (widget.savePassword) {
          await AuthStorage.saveCredentials(
            email: widget.email,
            password: widget.password,
          );
        }

        if (!mounted) return;

        showSnackBar('Verification success');
        context.go('/login');
        return;
      }

      setState(() {
        isLoading = false;
      });

      showSnackBar(result['message'] ?? 'Signup failed');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              IconButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.pop();
                      },
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "OTP Verification",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Enter OTP sent to ${widget.email}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: otpController,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                  onPressed: isLoading ? null : verifyOtp,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Verify OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
