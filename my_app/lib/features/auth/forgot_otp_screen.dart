import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_service.dart';

class ForgotOtpScreen extends StatefulWidget {
  const ForgotOtpScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  @override
  State<ForgotOtpScreen> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpScreen> {
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

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    final bool verified = ApiService.verifyLocalOtp(
      enteredOtp: enteredOtp,
      expectedOtp: widget.otp,
    );

    setState(() {
      isLoading = false;
    });

    if (!verified) {
      showSnackBar('Invalid OTP');
      return;
    }

    showSnackBar('Verification success');
    context.go('/new-password', extra: widget.email);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: isLoading
              ? null
              : () {
                  context.go('/forgot');
                },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 20),
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 60,
                  color: Colors.cyan,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Verify\nOTP",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Enter the 4-digit OTP sent to ${widget.email}.",
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                  height: 1.6,
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
                  prefixIcon: const Icon(Icons.password_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: isLoading ? null : verifyOtp,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
