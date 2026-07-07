import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dnpwc/config/app_config.dart';
import 'package:dnpwc/models/permit_checkin.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

sealed class CheckinResult {
  const CheckinResult();
}

class CheckinSuccess extends CheckinResult {
  const CheckinSuccess(this.response);
  final PermitCheckinResponse response;
}

class CheckinUnauthorized extends CheckinResult {
  const CheckinUnauthorized();
}

class CheckinNotFound extends CheckinResult {
  const CheckinNotFound(this.message);
  final String message;
}

class CheckinNetworkError extends CheckinResult {
  const CheckinNetworkError(this.message);
  final String message;
}

class CheckinFailure extends CheckinResult {
  const CheckinFailure(this.message);
  final String message;
}

class CheckinService {
  CheckinService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<CheckinResult> fetchPermitDetails(String scannedCode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      return const CheckinUnauthorized();
    }

    final baseUrl = AppConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
    final encodedCode = Uri.encodeComponent(scannedCode);
    final uri = Uri.parse('$baseUrl/checkpost/permit/check-in/$encodedCode');

    print('[CheckinService] URL: $uri');
    print('[CheckinService] Token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');

    try {
      final response = await _client
          .get(
            uri,
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic>? payload;
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          payload = decoded;
        }
      }

      print('[CheckinService] Status: ${response.statusCode}');
      print('[CheckinService] Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (payload == null) {
          return const CheckinFailure('Something went wrong, please try again');
        }

        final permitResponse = PermitCheckinResponse.fromJson(payload);
        print('[CheckinService] Parsed status: ${permitResponse.status}, visitors: ${permitResponse.visitors.length}');
        return CheckinSuccess(permitResponse);
      }

      if (response.statusCode == HttpStatus.unauthorized) {
        return const CheckinUnauthorized();
      }

      if (response.statusCode == HttpStatus.notFound) {
        return CheckinNotFound(
          payload?['message']?.toString() ?? 'Permit not found',
        );
      }

      return CheckinFailure(
        payload?['message']?.toString() ?? 'Something went wrong, please try again',
      );
    } on SocketException {
      return const CheckinNetworkError('Check your internet connection');
    } on TimeoutException {
      return const CheckinNetworkError('Check your internet connection');
    } on FormatException {
      return const CheckinFailure('Something went wrong, please try again');
    } on http.ClientException {
      return const CheckinNetworkError('Check your internet connection');
    } catch (e) {
      print('[CheckinService] Error: $e');
      return const CheckinFailure('Something went wrong, please try again');
    }
  }
}
