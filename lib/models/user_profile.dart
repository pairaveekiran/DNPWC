class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.roleName,
    required this.employeeId,
    required this.organizationDescription,
  });

  final int
  id;
  final String
  name;
  final String
  email;
  final String
  gender;
  final String
  roleName;
  final String
  employeeId;
  final String
  organizationDescription;

  factory UserProfile.fromJson(
    Map<
      String,
      dynamic
    >
    json,
  ) {
    final user =
        json['user']
            as Map<
              String,
              dynamic
            >? ??
        const <
          String,
          dynamic
        >{};
    final activeRole =
        json['active_role']
            as Map<
              String,
              dynamic
            >? ??
        const <
          String,
          dynamic
        >{};
    final projects =
        json['projects'];

    final int
    id =
        _readInt(
          user['id'],
        ) ??
        0;
    final String
    name =
        _readString(
          user['name'],
        ) ??
        'Not specified';
    final String
    email =
        _readString(
          user['email'],
        ) ??
        'Not specified';
    final String
    gender = _formatGender(
      _readString(
        user['gender'],
      ),
    );
    final String
    roleName =
        _readString(
          activeRole['name'],
        ) ??
        'Not specified';
    final String
    employeeId =
        id ==
            0
        ? 'Not specified'
        : id.toString();
    final String
    organizationDescription = _readOrganizationDescription(
      projects,
    );

    return UserProfile(
      id: id,
      name: name,
      email: email,
      gender: gender,
      roleName: roleName,
      employeeId: employeeId,
      organizationDescription: organizationDescription,
    );
  }

  static String?
  _readString(
    Object?
    value,
  ) {
    if (value ==
        null) {
      return null;
    }

    final text =
        value.toString().trim();
    return text.isEmpty
        ? null
        : text;
  }

  static int?
  _readInt(
    Object?
    value,
  ) {
    if (value
        is int) {
      return value;
    }

    if (value
        is String) {
      return int.tryParse(
        value,
      );
    }

    return null;
  }

  static String
  _formatGender(
    String?
    gender,
  ) {
    if (gender ==
            null ||
        gender.isEmpty) {
      return 'Not specified';
    }

    final normalized =
        gender.toUpperCase();
    if (normalized ==
        'M') {
      return 'Male';
    }

    if (normalized ==
        'F') {
      return 'Female';
    }

    return gender;
  }

  static String
  _readOrganizationDescription(
    Object?
    projects,
  ) {
    if (projects
            is! List ||
        projects.isEmpty) {
      return 'Not assigned';
    }

    final firstProject =
        projects.first;
    if (firstProject
        is! Map<
          String,
          dynamic
        >) {
      return 'Not assigned';
    }

    final description = _readString(
      firstProject['description'],
    );
    return description ??
        'Not assigned';
  }
}
