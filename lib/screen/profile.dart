import 'package:dnpwc/models/user_profile.dart';
import 'package:dnpwc/screen/login.dart';
import 'package:dnpwc/services/auth_service.dart';
import 'package:dnpwc/services/profile_service.dart';
import 'package:flutter/material.dart';

class ProfilePage
    extends
        StatefulWidget {
  const ProfilePage({
    super.key,
    this.userProfile,
  });

  final UserProfile?
  userProfile;

  @override
  State<
    ProfilePage
  >
  createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends
        State<
          ProfilePage
        > {
  static const Color
  primaryBlue = Color(
    0xFF0D47A1,
  );
  static const Color
  darkBlue = Color(
    0xFF0A2E5C,
  );
  static const Color
  mediumBlue = Color(
    0xFF1E5AA8,
  );
  static const Color
  accentBlue = Color(
    0xFF1976D2,
  );
  static const Color
  lightBlueTint = Color(
    0xFFEEF4FF,
  );
  static const Color
  backgroundColor = Color(
    0xFFF4F7FC,
  );
  static const Color
  signOutRed = Color(
    0xFFEF4444,
  );
  static const Color
  textPrimary = Color(
    0xFF1A2547,
  );
  static const Color
  textSecondary = Color(
    0xFF6B7BA4,
  );

  final ProfileService
  _profileService =
      ProfileService();

  UserProfile?
  _profile;
  bool
  _isLoading =
      false;
  String?
  _errorMessage;

  @override
  void
  initState() {
    super.initState();
    if (widget.userProfile !=
        null) {
      _profile = widget.userProfile;
    } else {
      _fetchProfile();
    }
  }

  Future<
    void
  >
  _fetchProfile() async {
    if (mounted) {
      setState(
        () {
          _isLoading = true;
          _errorMessage = null;
        },
      );
    }

    final result =
        await _profileService.getProfile();

    if (!mounted) {
      return;
    }

    if (result
        is ProfileSuccess) {
      setState(
        () {
          _profile = result.userProfile;
          _isLoading = false;
          _errorMessage = null;
        },
      );
      return;
    }

    if (result
        is ProfileUnauthorized) {
      await AuthService().clearSession();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (
                _,
              ) => const LoginPage(),
        ),
        (
          route,
        ) => false,
      );
      return;
    }

    final message =
        result
            is ProfileNetworkError
        ? result.message
        : result
              is ProfileFailure
        ? result.message
        : 'Something went wrong, please try again';

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<
    void
  >
  _signOut() async {
    await AuthService().clearSession();
    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (
              _,
            ) => const LoginPage(),
      ),
      (
        route,
      ) => false,
    );
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    if (_profile ==
        null) {
      if (_isLoading) {
        return _buildLoadingState();
      }
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(
                  context,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(
                          _profile!,
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        _buildSectionTitle(
                          'General Information',
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        _buildInfoCard(
                          icon: Icons.badge_outlined,
                          label: 'Role',
                          value: _profile!.roleName,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildInfoCard(
                          icon: Icons.person_outline_rounded,
                          label: 'Gender',
                          value: _profile!.gender,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildInfoCard(
                          icon: Icons.fingerprint_rounded,
                          label: 'Employee ID',
                          value: _profile!.employeeId,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildInfoCard(
                          icon: Icons.apartment_rounded,
                          label: 'Organization',
                          value: _profile!.organizationDescription,
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        _buildSignOutButton(
                          context,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildLoadingState() {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 12,
            ),
            Text(
              'Loading profile...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildErrorState() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 44,
                color: Colors.redAccent,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                _errorMessage ??
                    'Something went wrong, please try again',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: _fetchProfile,
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildHeaderBackground() {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            darkBlue,
            mediumBlue,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            32,
          ),
          bottomRight: Radius.circular(
            32,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(
              0x33000000,
            ),
            blurRadius: 14,
            offset: Offset(
              0,
              4,
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildTopBar(
    BuildContext
    context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(
              context,
            ),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.18,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.4,
                  ),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(
            width: 42,
          ),
        ],
      ),
    );
  }

  Widget
  _buildProfileCard(
    UserProfile
    profile,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          22,
        ),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(
              alpha: 0.12,
            ),
            blurRadius: 20,
            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      lightBlueTint,
                      Color(
                        0xFFDDE7F5,
                      ),
                    ],
                  ),
                  border: Border.all(
                    color: primaryBlue,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 16,
                      offset: const Offset(
                        0,
                        6,
                      ),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: primaryBlue,
                  size: 55,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 14,
                color: textSecondary,
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                profile.email,
                style: const TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  lightBlueTint,
                  Color(
                    0xFFDDE7F5,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(
                30,
              ),
              border: Border.all(
                color: primaryBlue.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: primaryBlue,
                  size: 15,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  profile.roleName,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildSectionTitle(
    String
    title,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryBlue,
                accentBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(
              2,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget
  _buildInfoCard({
    required IconData
    icon,
    required String
    label,
    required String
    value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          14,
        ),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(
              alpha: 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightBlueTint,
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color: primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: lightBlueTint,
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: primaryBlue,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildSignOutButton(
    BuildContext
    context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _showSignOutDialog(
          context,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: signOutRed,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: signOutRed.withValues(
            alpha: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 22,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void
  _showSignOutDialog(
    BuildContext
    context,
  ) {
    showDialog(
      context: context,
      builder:
          (
            dialogContext,
          ) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                22,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                26,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(
                      18,
                    ),
                    decoration: BoxDecoration(
                      color: signOutRed.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: signOutRed,
                      size: 36,
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Are you sure you want to sign out from your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(
                            dialogContext,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await AuthService().clearSession();
                            if (!mounted) {
                              return;
                            }

                            Navigator.of(
                              dialogContext,
                              rootNavigator: true,
                            ).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder:
                                    (
                                      _,
                                    ) => const LoginPage(),
                              ),
                              (
                                route,
                              ) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            backgroundColor: signOutRed,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
