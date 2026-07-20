class PermitCheckinResponse {
  final bool status;
  final String message;
  final Permit? permit;
  final Summary? summary;
  final List<Visitor> visitors;
  final IssuingAuthority? issuingAuthority;
  final String? travelAgency;
  final bool hasBeenCheckedIn;
  final List<dynamic> checkInHistory;

  PermitCheckinResponse({
    required this.status,
    required this.message,
    this.permit,
    this.summary,
    required this.visitors,
    this.issuingAuthority,
    this.travelAgency,
    this.hasBeenCheckedIn = false,
    this.checkInHistory = const [],
  });

  factory PermitCheckinResponse.fromJson(Map<String, dynamic> json) {
    return PermitCheckinResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      permit: json['permit'] != null ? Permit.fromJson(json['permit']) : null,
      summary: json['summary'] != null ? Summary.fromJson(json['summary']) : null,
      visitors: (json['visitors'] as List<dynamic>?)
              ?.map((v) => Visitor.fromJson(v))
              .toList() ??
          [],
      issuingAuthority: json['issuing_authority'] != null
          ? IssuingAuthority.fromJson(json['issuing_authority'])
          : null,
      travelAgency: json['travel_agency']?.toString(),
      hasBeenCheckedIn: json['has_been_checked_in'] ?? false,
      checkInHistory: (json['check_in_history'] as List<dynamic>?) ?? [],
    );
  }
}

class PermitData {
  final Permit? permit;
  final Summary? summary;
  final List<Visitor> visitors;
  final IssuingAuthority? issuingAuthority;

  PermitData({
    this.permit,
    this.summary,
    required this.visitors,
    this.issuingAuthority,
  });

  factory PermitData.fromJson(Map<String, dynamic> json) {
    return PermitData(
      permit: json['permit'] != null ? Permit.fromJson(json['permit']) : null,
      summary: json['summary'] != null ? Summary.fromJson(json['summary']) : null,
      visitors: (json['visitors'] as List<dynamic>?)
              ?.map((v) => Visitor.fromJson(v))
              .toList() ??
          [],
      issuingAuthority: json['issuing_authority'] != null
          ? IssuingAuthority.fromJson(json['issuing_authority'])
          : null,
    );
  }
}

class Permit {
  final int? id;
  final String? code;
  final String? receipt;
  final String? issuedAt;
  final String? paymentMethod;
  final String? fee;
  final int? totalPax;
  final bool? status;

  Permit({
    this.id,
    this.code,
    this.receipt,
    this.issuedAt,
    this.paymentMethod,
    this.fee,
    this.totalPax,
    this.status,
  });

  factory Permit.fromJson(Map<String, dynamic> json) {
    return Permit(
      id: json['id'] as int?,
      code: json['code']?.toString(),
      receipt: json['receipt']?.toString(),
      issuedAt: json['issued_at']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      fee: json['fee']?.toString(),
      totalPax: json['total_pax'] as int?,
      status: json['status'] as bool?,
    );
  }
}

class Summary {
  final int totalMfov;
  final int male;
  final int female;
  final int other;
  final int vehicle;
  final int nepali;
  final int saarc;
  final int foreigner;

  Summary({
    required this.totalMfov,
    required this.male,
    required this.female,
    required this.other,
    required this.vehicle,
    required this.nepali,
    required this.saarc,
    required this.foreigner,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalMfov: json['total_mfov'] ?? 0,
      male: json['male'] ?? 0,
      female: json['female'] ?? 0,
      other: json['other'] ?? 0,
      vehicle: json['vehicle'] ?? 0,
      nepali: json['nepali'] ?? 0,
      saarc: json['saarc'] ?? 0,
      foreigner: json['foreigner'] ?? 0,
    );
  }
}

class Visitor {
  final String? name;
  final String? gender;
  final String? passport;
  final String? country;
  final String? contact;
  final String? ticketType;
  final String? vehicleNo;

  Visitor({
    this.name,
    this.gender,
    this.passport,
    this.country,
    this.contact,
    this.ticketType,
    this.vehicleNo,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      name: json['name']?.toString(),
      gender: json['gender']?.toString(),
      passport: json['passport']?.toString(),
      country: json['country']?.toString(),
      contact: json['contact']?.toString(),
      ticketType: json['ticket_type']?.toString(),
      vehicleNo: json['vehicle_no']?.toString(),
    );
  }

  /// Returns true if this visitor is a vehicle-only record
  /// (name, gender, passport, contact, and country are all null)
  bool get isVehicleOnly =>
      name == null &&
      gender == null &&
      passport == null &&
      contact == null &&
      country == null;
}

class IssuingAuthority {
  final String? code;
  final String? name;
  final String? phone;

  IssuingAuthority({
    this.code,
    this.name,
    this.phone,
  });

  factory IssuingAuthority.fromJson(Map<String, dynamic> json) {
    return IssuingAuthority(
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

/// A single offline-scanned permit queued for sync.
class SyncCheckinItem {
  final String code;
  final DateTime timestamp;
  final int direction;

  SyncCheckinItem({
    required this.code,
    required this.timestamp,
    required this.direction,
  });
}

/// A single permit entry in the offline sync request body.
class SyncCheckinRequest {
  final String code;
  final String loggedAt;
  final int direction;

  SyncCheckinRequest({
    required this.code,
    required this.loggedAt,
    required this.direction,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'logged_at': loggedAt,
        'direction': direction,
      };
}

/// Per-permit result returned by the bulk check-in sync endpoint.
class SyncCheckinResult {
  final String code;
  final bool success;
  final String? message;

  SyncCheckinResult({
    required this.code,
    required this.success,
    this.message,
  });

  factory SyncCheckinResult.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString().toLowerCase() ?? '';
    return SyncCheckinResult(
      code: json['code']?.toString() ?? '',
      success: status == 'success' || status == 'ok',
      message: json['message']?.toString(),
    );
  }
}

/// Parsed bulk check-in sync response.
///
/// The server returns:
/// ```json
/// {
///   "valid": ["CODE1", "CODE2"],
///   "invalid": [{"code": "CODE3", "message": "..."}]
/// }
/// ```
/// Results are matched back to the request by [SyncCheckinResult.code].
class SyncCheckinResponse {
  final List<SyncCheckinResult> results;

  SyncCheckinResponse({required this.results});

  factory SyncCheckinResponse.fromJson(Map<String, dynamic> json) {
    final results = <SyncCheckinResult>[];

    // Parse "valid" — array of strings (codes that succeeded)
    final validRaw = json['valid'];
    if (validRaw is List) {
      for (final item in validRaw) {
        if (item is String && item.isNotEmpty) {
          results.add(SyncCheckinResult(code: item, success: true));
        }
      }
    }

    // Parse "invalid" — array of objects { code, message }
    final invalidRaw = json['invalid'];
    if (invalidRaw is List) {
      for (final item in invalidRaw) {
        if (item is Map<String, dynamic>) {
          results.add(SyncCheckinResult(
            code: item['code']?.toString() ?? '',
            success: false,
            message: item['message']?.toString(),
          ));
        }
      }
    }

    return SyncCheckinResponse(results: results);
  }
}
