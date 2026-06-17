import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _emailJsEndpoint =
      'https://api.emailjs.com/api/v1.0/email/send';
  static const String _emailJsServiceId = 'service_5ly2pcv';
  static const String _emailJsTemplateId = 'template_nz8k21r';
  static const String _emailJsPublicKey = 'AT5-rswxoddiDuccI';
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:5000';
  static const String _localBaseUrl = 'http://127.0.0.1:5000';
  static const String _lanBaseUrl = 'http://10.233.160.158:5000';

  static final Random _random = Random.secure();

  static String get baseUrl {
    return _baseUrlCandidates.first;
  }

  static List<String> get _baseUrlCandidates {
    if (_configuredBaseUrl.isNotEmpty) {
      return [_configuredBaseUrl];
    }

    if (kIsWeb) {
      return ['https://chatgpt-owkm.onrender.com'];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return [_androidEmulatorBaseUrl, _lanBaseUrl];
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return [_localBaseUrl, _lanBaseUrl];
    }

    return [_localBaseUrl];
  }

  static String get _connectionErrorMessage {
    return 'Cannot connect to server. Make sure the backend is running on ${_baseUrlCandidates.join(' or ')}.';
  }

  static Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      throw Exception('Server returned an empty response');
    }

    final decodedBody = jsonDecode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('Server returned an invalid response');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decodedBody['message'] ?? 'Request failed');
    }

    return decodedBody;
  }

  static Future<Map<String, dynamic>> _getJson(String path) async {
    Object? lastConnectionError;

    for (final candidateBaseUrl in _baseUrlCandidates) {
      try {
        final response = await http.get(
          Uri.parse('$candidateBaseUrl$path'),
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(
          const Duration(seconds: 6),
        );

        return _decodeJsonResponse(response);
      } on TimeoutException catch (error) {
        lastConnectionError = error;
      } on http.ClientException catch (error) {
        lastConnectionError = error;
      } on FormatException {
        throw Exception('Server returned an invalid response');
      } on Exception catch (error) {
        throw Exception(error.toString().replaceFirst('Exception: ', ''));
      }
    }

    throw Exception(
      lastConnectionError is http.ClientException &&
              lastConnectionError.message.isNotEmpty
          ? lastConnectionError.message
          : _connectionErrorMessage,
    );
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    Object? lastConnectionError;

    for (final candidateBaseUrl in _baseUrlCandidates) {
      try {
        final response = await http
            .post(
              Uri.parse('$candidateBaseUrl$path'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(
              const Duration(seconds: 6),
            );

        return _decodeJsonResponse(response);
      } on TimeoutException catch (error) {
        lastConnectionError = error;
      } on http.ClientException catch (error) {
        lastConnectionError = error;
      } on FormatException {
        throw Exception('Server returned an invalid response');
      } on Exception catch (error) {
        throw Exception(error.toString().replaceFirst('Exception: ', ''));
      }
    }

    throw Exception(
      lastConnectionError is http.ClientException &&
              lastConnectionError.message.isNotEmpty
          ? lastConnectionError.message
          : _connectionErrorMessage,
    );
  }

  static Future<http.Response> _sendMultipartWithFallback(
    Uint8List bytes,
    String filename,
  ) async {
    Object? lastConnectionError;

    for (final candidateBaseUrl in _baseUrlCandidates) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$candidateBaseUrl/predict'),
        );

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: filename,
          ),
        );

        final streamedResponse = await request.send().timeout(
              const Duration(seconds: 20),
            );

        return http.Response.fromStream(streamedResponse);
      } on TimeoutException catch (error) {
        lastConnectionError = error;
      } on http.ClientException catch (error) {
        lastConnectionError = error;
      }
    }

    throw Exception(
      lastConnectionError is http.ClientException &&
              lastConnectionError.message.isNotEmpty
          ? lastConnectionError.message
          : _connectionErrorMessage,
    );
  }

  /// GENERATE 4-DIGIT OTP
  static String generateOtp() {
    return (1000 + _random.nextInt(9000)).toString();
  }

  static String otpExpiryTime() {
    final DateTime expiry = DateTime.now().add(
      const Duration(minutes: 15),
    );
    final String hour = expiry.hour.toString().padLeft(2, '0');
    final String minute = expiry.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  /// SEND OTP EMAIL USING EMAILJS
  static Future<void> sendOtpEmail({
    required String email,
    required String otp,
  }) async {
    final String trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw Exception('Please enter your email');
    }

    try {
      final response = await http
          .post(
            Uri.parse(_emailJsEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'origin': 'http://localhost',
            },
            body: jsonEncode({
              'service_id': _emailJsServiceId,
              'template_id': _emailJsTemplateId,
              'user_id': _emailJsPublicKey,
              'template_params': {
                'otp': otp,
                'to_email': trimmedEmail,
                'time': otpExpiryTime(),
              }
            }),
          )
          .timeout(
            const Duration(seconds: 45),
          );

      if (response.statusCode != 200) {
        final String errorMessage = response.body.trim().isEmpty
            ? 'EmailJS returned ${response.statusCode}'
            : response.body.trim();

        throw Exception('Failed to send OTP: $errorMessage');
      }
    } on TimeoutException {
      throw Exception(
        'OTP request timed out. Check emulator internet connection and try again.',
      );
    } on Exception catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// VERIFY OTP LOCALLY
  static bool verifyLocalOtp({
    required String enteredOtp,
    required String expectedOtp,
  }) {
    return enteredOtp.trim() == expectedOtp.trim();
  }

  /// SIGNUP API
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    return _postJson(
      '/signup',
      {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );
  }

  /// RESET PASSWORD API
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
  }) async {
    return _postJson(
      '/reset-password',
      {
        'email': email.trim(),
        'password': password,
      },
    );
  }

  /// LOGIN API
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return _postJson(
      '/login',
      {
        'email': email.trim(),
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> fetchProfile(String email) async {
    return _getJson(
      '/profile?email=${Uri.encodeQueryComponent(email.trim())}',
    );
  }

  static Future<Map<String, dynamic>> saveProfile({
    required String email,
    required String name,
    required String age,
    required String gender,
    required String height,
    required String weight,
    required String foodPreference,
    required String dentalIssues,
    required String waterGoal,
  }) async {
    return _postJson(
      '/profile',
      {
        'email': email.trim(),
        'name': name.trim(),
        'age': age.trim(),
        'gender': gender.trim(),
        'height': height.trim(),
        'weight': weight.trim(),
        'food_preference': foodPreference.trim(),
        'dental_issues': dentalIssues.trim(),
        'water_goal': waterGoal.trim(),
      },
    );
  }

  /// FOOD PREDICTION API
  static Future<Map<String, dynamic>> predictFood(
    String food,
  ) async {
    return _postJson(
      '/predict',
      {
        'food': food,
      },
    );
  }

  static Future<Map<String, dynamic>> predictFoodImage(
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final response = await _sendMultipartWithFallback(bytes, filename);
      return _decodeJsonResponse(response);
    } on FormatException {
      throw Exception('Server returned an invalid response');
    } on Exception catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// VIDEOS API
  static Future<List<Map<String, dynamic>>> fetchVideos() async {
    final result = await _getJson('/videos');
    final videos = result['videos'];

    if (videos is! List) {
      throw Exception('Server returned an invalid video list');
    }

    return videos
        .whereType<Map>()
        .map((video) => Map<String, dynamic>.from(video))
        .toList();
  }
}
