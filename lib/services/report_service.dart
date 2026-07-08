import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dnpwc/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Result of fetching the organization ID from the profile endpoint.
sealed class OrgIdResult {
  const OrgIdResult();
}

class OrgIdSuccess extends OrgIdResult {
  const OrgIdSuccess(this.organizationId);
  final int organizationId;
}

class OrgIdFailure extends OrgIdResult {
  const OrgIdFailure(this.message);
  final String message;
}

/// Result of downloading a report PDF.
sealed class ReportDownloadResult {
  const ReportDownloadResult();
}

class ReportDownloadSuccess extends ReportDownloadResult {
  const ReportDownloadSuccess(this.pdfBytes);
  final List<int> pdfBytes;
}

class ReportDownloadFailure extends ReportDownloadResult {
  const ReportDownloadFailure(this.message);
  final String message;
}

/// Service for generating daily check-in/check-out reports.
///
/// Fetches the user's organization ID from the profile endpoint,
/// then downloads the PDF report from the report endpoint.
class ReportService {
  ReportService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  int? _cachedOrgId;

  /// Reads the Bearer token from SharedPreferences.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Fetches the organization ID from the profile endpoint.
  ///
  /// Parses `projects[0].organizations[0].id` from the response.
  /// Returns [OrgIdSuccess] on success, [OrgIdFailure] on any error.
  Future<OrgIdResult> fetchOrganizationId() async {
    if (_cachedOrgId != null) {
      return OrgIdSuccess(_cachedOrgId!);
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const OrgIdFailure('Session expired. Please log in again.');
    }

    final baseUrl = AppConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$baseUrl/profile');

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

      if (response.statusCode == HttpStatus.unauthorized) {
        return const OrgIdFailure('Session expired. Please log in again.');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const OrgIdFailure(
          'Couldn\'t load profile. Please try again.',
        );
      }

      final Map<String, dynamic>? payload;
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        payload = decoded is Map<String, dynamic> ? decoded : null;
      } else {
        payload = null;
      }

      if (payload == null) {
        return const OrgIdFailure(
          'Couldn\'t load profile. Please try again.',
        );
      }

      final status = payload['status'];
      if (status is bool && !status) {
        return const OrgIdFailure(
          'Couldn\'t load profile. Please try again.',
        );
      }

      final projects = payload['projects'];
      if (projects is! List || projects.isEmpty) {
        return const OrgIdFailure(
          'No project assigned to your account.',
        );
      }

      final firstProject = projects[0];
      if (firstProject is! Map<String, dynamic>) {
        return const OrgIdFailure(
          'Couldn\'t determine your organization.',
        );
      }

      final organizations = firstProject['organizations'];
      if (organizations is! List || organizations.isEmpty) {
        return const OrgIdFailure(
          'No organization assigned to your project.',
        );
      }

      final firstOrg = organizations[0];
      if (firstOrg is! Map<String, dynamic>) {
        return const OrgIdFailure(
          'Couldn\'t determine your organization.',
        );
      }

      final orgId = firstOrg['id'];
      if (orgId is! int) {
        return const OrgIdFailure(
          'Couldn\'t determine your organization.',
        );
      }

      _cachedOrgId = orgId;
      return OrgIdSuccess(orgId);
    } on SocketException {
      return const OrgIdFailure('Check your internet connection.');
    } on TimeoutException {
      return const OrgIdFailure('Request timed out. Please try again.');
    } on FormatException {
      return const OrgIdFailure('Something went wrong. Please try again.');
    } on http.ClientException {
      return const OrgIdFailure('Check your internet connection.');
    } catch (_) {
      return const OrgIdFailure('Something went wrong. Please try again.');
    }
  }

  /// Downloads the daily check-in/check-out report PDF.
  ///
  /// [organizationId] - the org ID path segment.
  /// [direction] - 1 for check-in, 0 for check-out.
  /// [date] - the date string in `yyyy-MM-dd` format.
  ///
  /// Returns [ReportDownloadSuccess] with raw PDF bytes on success,
  /// or [ReportDownloadFailure] on any error.
  Future<ReportDownloadResult> downloadReportPdf({
    required int organizationId,
    required int direction,
    required String date,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const ReportDownloadFailure(
        'Session expired. Please log in again.',
      );
    }

    final baseUrl = AppConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse(
      '$baseUrl/checkpost/$organizationId/daily-checkin-report/pdf',
    ).replace(queryParameters: {
      'direction': direction.toString(),
      'date': date,
    });

    try {
      final response = await _client
          .get(
            uri,
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'Accept': 'application/pdf',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == HttpStatus.unauthorized) {
        return const ReportDownloadFailure(
          'Session expired. Please log in again.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const ReportDownloadFailure(
          'Couldn\'t generate report. Please try again.',
        );
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        return const ReportDownloadFailure(
          'Received an empty report. Please try again.',
        );
      }

      return ReportDownloadSuccess(bytes);
    } on SocketException {
      return const ReportDownloadFailure('Check your internet connection.');
    } on TimeoutException {
      return const ReportDownloadFailure(
        'Request timed out. Please try again.',
      );
    } on FormatException {
      return const ReportDownloadFailure(
        'Something went wrong. Please try again.',
      );
    } on http.ClientException {
      return const ReportDownloadFailure('Check your internet connection.');
    } catch (_) {
      return const ReportDownloadFailure(
        'Something went wrong. Please try again.',
      );
    }
  }
}
