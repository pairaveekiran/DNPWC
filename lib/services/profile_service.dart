import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dnpwc/config/app_config.dart';
import 'package:dnpwc/models/user_profile.dart';
import 'package:http/http.dart'
    as http;
import 'package:shared_preferences/shared_preferences.dart';

sealed class ProfileResult {
  const ProfileResult();
}

class ProfileSuccess
    extends
        ProfileResult {
  const ProfileSuccess(
    this.userProfile,
  );

  final UserProfile
  userProfile;
}

class ProfileUnauthorized
    extends
        ProfileResult {
  const ProfileUnauthorized();
}

class ProfileNetworkError
    extends
        ProfileResult {
  const ProfileNetworkError(
    this.message,
  );

  final String
  message;
}

class ProfileFailure
    extends
        ProfileResult {
  const ProfileFailure(
    this.message,
  );

  final String
  message;
}

class ProfileService {
  ProfileService({
    http.Client?
    client,
  }) : _client =
           client ??
           http.Client();

  final http.Client
  _client;

  Future<
    ProfileResult
  >
  getProfile() async {
    final prefs =
        await SharedPreferences.getInstance();
    final token = prefs.getString(
      'access_token',
    );

    if (token ==
            null ||
        token.isEmpty) {
      return const ProfileUnauthorized();
    }

    final baseUrl = AppConfig.baseUrl.replaceAll(
      RegExp(
        r'/$',
      ),
      '',
    );
    final uri = Uri.parse(
      '$baseUrl/profile',
    );

    try {
      final response = await _client
          .get(
            uri,
            headers:
                <
                  String,
                  String
                >{
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
          )
          .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      Map<
        String,
        dynamic
      >?
      payload;
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(
          response.body,
        );
        if (decoded
            is Map<
              String,
              dynamic
            >) {
          payload = decoded;
        }
      }

      if (response.statusCode >=
              200 &&
          response.statusCode <
              300) {
        if (payload ==
            null) {
          return const ProfileFailure(
            'Something went wrong, please try again',
          );
        }

        final status = payload['status'];
        if (status
                is bool &&
            !status) {
          return const ProfileFailure(
            'Something went wrong, please try again',
          );
        }

        final userProfile = UserProfile.fromJson(
          payload,
        );
        return ProfileSuccess(
          userProfile,
        );
      }

      if (response.statusCode ==
          HttpStatus.unauthorized) {
        return const ProfileUnauthorized();
      }

      return const ProfileFailure(
        'Something went wrong, please try again',
      );
    } on SocketException {
      return const ProfileNetworkError(
        'Check your internet connection',
      );
    } on TimeoutException {
      return const ProfileNetworkError(
        'Check your internet connection',
      );
    } on FormatException {
      return const ProfileFailure(
        'Something went wrong, please try again',
      );
    } on http.ClientException {
      return const ProfileNetworkError(
        'Check your internet connection',
      );
    } catch (
      _
    ) {
      return const ProfileFailure(
        'Something went wrong, please try again',
      );
    }
  }
}
