import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dnpwc/config/app_config.dart';
import 'package:http/http.dart'
    as http;
import 'package:shared_preferences/shared_preferences.dart';

sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess
    extends
        LoginResult {
  const LoginSuccess(
    this.accessToken,
  );

  final String
  accessToken;
}

class LoginInvalidCredentials
    extends
        LoginResult {
  const LoginInvalidCredentials(
    this.message,
  );

  final String
  message;
}

class LoginNetworkError
    extends
        LoginResult {
  const LoginNetworkError(
    this.message,
  );

  final String
  message;
}

class LoginFailure
    extends
        LoginResult {
  const LoginFailure(
    this.message,
  );

  final String
  message;
}

sealed class LogoutResult {
  const LogoutResult();
}

class LogoutSuccess
    extends
        LogoutResult {
  const LogoutSuccess();
}

class LogoutNetworkError
    extends
        LogoutResult {
  const LogoutNetworkError(
    this.message,
  );

  final String
  message;
}

class LogoutFailure
    extends
        LogoutResult {
  const LogoutFailure(
    this.message,
  );

  final String
  message;
}

class AuthService {
  AuthService({
    http.Client?
    client,
  }) : _client =
           client ??
           http.Client();

  static const String
  accessTokenKey =
      'access_token';
  static const String
  isLoggedInKey =
      'is_logged_in';

  final http.Client
  _client;

  Future<
    LoginResult
  >
  login(
    String
    email,
    String
    password,
  ) async {
    final baseUrl = AppConfig.baseUrl.replaceAll(
      RegExp(
        r'/$',
      ),
      '',
    );
    final uri = Uri.parse(
      '$baseUrl/login',
    );

    try {
      final response = await _client
          .post(
            uri,
            headers:
                const <
                  String,
                  String
                >{
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
            body: jsonEncode(
              <
                String,
                String
              >{
                'email': email,
                'password': password,
              },
            ),
          )
          .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      final payload = _decodeJsonObject(
        response.body,
      );

      final message = _readMessage(
        payload,
        response.body,
      );

      if (response.statusCode >=
              200 &&
          response.statusCode <
              300) {
        final token = _readToken(
          payload,
        );
        if (token ==
                null ||
            token.isEmpty) {
          return const LoginFailure(
            'Something went wrong, please try again',
          );
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          accessTokenKey,
          token,
        );
        await prefs.setBool(
          isLoggedInKey,
          true,
        );

        return LoginSuccess(
          token,
        );
      }

      if (response.statusCode ==
          HttpStatus.unauthorized) {
        return LoginInvalidCredentials(
          message ??
              'Email or password do not matched!',
        );
      }

      return LoginFailure(
        message ??
            'Something went wrong, please try again',
      );
    } on SocketException {
      return const LoginNetworkError(
        'Check your internet connection',
      );
    } on TimeoutException {
      return const LoginNetworkError(
        'Check your internet connection',
      );
    } on FormatException {
      return const LoginFailure(
        'Something went wrong, please try again',
      );
    } on http.ClientException {
      return const LoginNetworkError(
        'Check your internet connection',
      );
    } on TypeError {
      return const LoginFailure(
        'Something went wrong, please try again',
      );
    } catch (
      _
    ) {
      return const LoginFailure(
        'Something went wrong, please try again',
      );
    }
  }

  Map<
    String,
    dynamic
  >?
  _decodeJsonObject(
    String
    body,
  ) {
    if (body.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(
      body,
    );
    if (decoded
        is Map<
          String,
          dynamic
        >) {
      return decoded;
    }

    return null;
  }

  String?
  _readMessage(
    Map<
      String,
      dynamic
    >?
    payload,
    String
    rawBody,
  ) {
    final message =
        payload?['message'];
    if (message
            is String &&
        message.trim().isNotEmpty) {
      return message.trim();
    }

    // Never expose raw response body to the user – return null so
    // the caller falls back to its own default message.
    return null;
  }

  String?
  _readToken(
    Map<
      String,
      dynamic
    >?
    payload,
  ) {
    final directToken =
        payload?['access_token'];
    if (directToken
            is String &&
        directToken.isNotEmpty) {
      return directToken;
    }

    final nestedToken =
        payload?['token'];
    if (nestedToken
            is String &&
        nestedToken.isNotEmpty) {
      return nestedToken;
    }

    final data =
        payload?['data'];
    if (data
        is Map<
          String,
          dynamic
        >) {
      final dataAccessToken = data['access_token'];
      if (dataAccessToken
              is String &&
          dataAccessToken.isNotEmpty) {
        return dataAccessToken;
      }

      final dataToken = data['token'];
      if (dataToken
              is String &&
          dataToken.isNotEmpty) {
        return dataToken;
      }
    }

    return null;
  }

  Future<
    LogoutResult
  >
  logout({
    required bool
    fromAllDevices,
  }) async {
    final baseUrl = AppConfig.baseUrl.replaceAll(
      RegExp(
        r'/$',
      ),
      '',
    );
    final endpoint =
        fromAllDevices
        ? 'logout-all'
        : 'logout';
    final uri = Uri.parse(
      '$baseUrl/$endpoint',
    );

    try {
      final token = await getToken();

      final response = await _client
          .post(
            uri,
            headers: <
              String,
              String
            >{
              'Accept': 'application/json',
              if (token !=
                  null)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      final payload = _decodeJsonObject(
        response.body,
      );

      final message = _readMessage(
        payload,
        response.body,
      );

      if (response.statusCode >=
              200 &&
          response.statusCode <
              300) {
        return const LogoutSuccess();
      }

      return LogoutFailure(
        message ??
            'Something went wrong, please try again',
      );
    } on SocketException {
      return const LogoutNetworkError(
        'Check your internet connection',
      );
    } on TimeoutException {
      return const LogoutNetworkError(
        'Check your internet connection',
      );
    } on FormatException {
      return const LogoutFailure(
        'Something went wrong, please try again',
      );
    } on http.ClientException {
      return const LogoutNetworkError(
        'Check your internet connection',
      );
    } on TypeError {
      return const LogoutFailure(
        'Something went wrong, please try again',
      );
    } catch (
      _
    ) {
      return const LogoutFailure(
        'Something went wrong, please try again',
      );
    }
  }

  Future<
    void
  >
  clearSession() async {
    final prefs =
        await SharedPreferences.getInstance();
    await prefs.remove(
      accessTokenKey,
    );
    await prefs.setBool(
      isLoggedInKey,
      false,
    );
  }

  static Future<
    String?
  >
  getToken() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getString(
      accessTokenKey,
    );
  }

  static Future<
    bool
  >
  isLoggedIn() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getBool(
          isLoggedInKey,
        ) ??
        false;
  }
}