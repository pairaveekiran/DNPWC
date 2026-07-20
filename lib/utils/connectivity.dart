import 'dart:io';

import 'package:dnpwc/config/app_config.dart';

/// Utility for checking internet / server connectivity.
///
/// Uses [InternetAddress.lookup] on the API hostname so the check
/// is relevant to the server the app actually talks to.
class ConnectivityUtil {
  ConnectivityUtil._();

  /// Returns `true` if the API server's hostname can be resolved,
  /// meaning the device has internet access to our backend.
  static Future<bool> isInternetAvailable() async {
    try {
      final uri = Uri.parse(AppConfig.baseUrl);
      final result = await InternetAddress.lookup(uri.host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
