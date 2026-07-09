import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

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

    debugPrint('[CheckinService] URL: $uri');
    debugPrint('[CheckinService] Token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');

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

      debugPrint('[CheckinService] Status: ${response.statusCode}');
      debugPrint('[CheckinService] Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (payload == null) {
          return const CheckinFailure('Something went wrong, please try again');
        }

        final permitResponse = PermitCheckinResponse.fromJson(payload);
        debugPrint('[CheckinService] Parsed status: ${permitResponse.status}, visitors: ${permitResponse.visitors.length}');
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
      debugPrint('[CheckinService] Error: $e');
      return const CheckinFailure('Something went wrong, please try again');
    }
  }

  Future<CheckinResult> performCheckInOut({
    required String code,
    required int direction,
    required String remark,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      return const CheckinUnauthorized();
    }

    final baseUrl = AppConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$baseUrl/checkpost/permit/check-in');

    final body = jsonEncode({
      'code': code,
      'direction': direction,
      'remark': remark,
    });

    debugPrint('[CheckinService POST] URL: $uri');
    debugPrint('[CheckinService POST] Body: $body');

    try {
      final response = await _client
          .post(
            uri,
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic>? payload;
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          payload = decoded;
        }
      }

      debugPrint('[CheckinService POST] Status: ${response.statusCode}');
      debugPrint('[CheckinService POST] Body: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message = payload?['message']?.toString() ??
            (direction == 1 ? 'Checked in successfully' : 'Checked out successfully');
        return CheckinSuccess(PermitCheckinResponse(
          status: true,
          message: message,
          visitors: [],
          hasBeenCheckedIn: direction == 1,
        ));
      }

      if (response.statusCode == HttpStatus.unauthorized) {
        return const CheckinUnauthorized();
      }

      return CheckinFailure(
        payload?['message']?.toString() ??
            (direction == 1 ? 'Check-in failed' : 'Check-out failed'),
      );
    } on SocketException {
      return const CheckinNetworkError('Check your internet connection');
    } on TimeoutException {
      return const CheckinNetworkError('Request timed out. Please try again.');
    } on FormatException {
      return const CheckinFailure('Something went wrong, please try again');
    } on http.ClientException {
      return const CheckinNetworkError('Check your internet connection');
    } catch (e) {
      debugPrint('[CheckinService POST] Error: $e');
      return const CheckinFailure('Something went wrong, please try again');
    }
  }
}
