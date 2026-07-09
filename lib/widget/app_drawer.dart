import 'package:dnpwc/models/user_profile.dart';
import 'package:dnpwc/screen/notices.dart';
import 'package:dnpwc/screen/report.dart';
import 'package:dnpwc/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../screen/login.dart';
import '../screen/profile.dart';

import '../screen/qr_scanner.dart';

class AppDrawer
    extends
        StatefulWidget {
  const AppDrawer({
    super.key,
    this.userProfile,
  });

  final UserProfile?
  userProfile;

  @override
  State<
    AppDrawer
  >
  createState() =>
      _AppDrawerState();
}

class _AppDrawerState
    extends
        State<
          AppDrawer
        > {
  // Local state for the checkbox (StatelessWidget, so it's held here
  // and mutated via StatefulBuilder's setState in _buildLogoutButton)
  bool
  _logoutFromAllDevices =
      false;

  // ─── COLORS ───
  static const Color
  _primaryBlue = Color(
    0xFF0A2E5C,
  );
  static const Color
  _lightBlue = Color(
    0xFF0D47A1,
  );

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              children: [
                // ─── MAIN NAVIGATION ───
                _buildMenuItem(
                  context: context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  isSelected: true,
                  onTap: () => Navigator.pop(
                    context,
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () => _navigateTo(
                    context,
                    ProfilePage(
                      userProfile: widget.userProfile,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  badge: '3',
                  onTap: () => _navigateTo(
                    context,
                    const NoticesPage(),
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.qr_code_scanner_outlined,
                  title: 'QR Scanner',
                  onTap: () => _navigateTo(
                    context,
                    const QRScannerScreen(),
                  ),
                ),

                _buildDivider(),

                // ─── SERVICES ───
                _buildSectionTitle(
                  'Services',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.pets_outlined,
                  title: 'Wildlife',
                  onTap: () => Navigator.pop(
                    context,
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.forest_outlined,
                  title: 'National Parks',
                  onTap: () => Navigator.pop(
                    context,
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.article_outlined,
                  title: 'Reports',
                  onTap: () => _navigateTo(
                    context,
                    ReportPage(), ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.history_outlined,
                  title: 'History',
                  onTap: () => Navigator.pop(
                    context,
                  ),
                ),

                _buildDivider(),

                // ─── INFO ───
                _buildSectionTitle(
                  'Info',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => Navigator.pop(
                    context,
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () => Navigator.pop(
                    context,
                  ),
                ),
              ],
            ),
          ),
          _buildLogoutButton(
            context,
          ),
        ],
      ),
    );
  }

  // ─── NAVIGATE TO A SCREEN ───
  void
  _navigateTo(
    BuildContext
    context,
    Widget
    screen,
  ) {
    Navigator.pop(
      context,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (
              _,
            ) => screen,
      ),
    );
  }

  // ─── HEADER ───
  Widget
  _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        50,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryBlue,
            _lightBlue,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + Department name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  3,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    'assets/images/dnpwc.webp',
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'राष्ट्रिय निकुञ्ज तथा वन्यजन्तु\nसंरक्षण विभाग',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'बबरमहल, काठमाडौं',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.85,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          // User info
          Text(
            widget.userProfile?.name ??
                'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            widget.userProfile?.email ??
                '',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.85,
              ),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MENU ITEM ───
  Widget
  _buildMenuItem({
    required BuildContext
    context,
    required IconData
    icon,
    required String
    title,
    required VoidCallback
    onTap,
    String?
    badge,
    bool
        isSelected =
        false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? _lightBlue.withValues(
                alpha: 0.08,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        dense: true,
        leading: Icon(
          icon,
          color: isSelected
              ? _lightBlue
              : Colors.grey.shade700,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? _lightBlue
                : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        trailing:
            badge !=
                null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // ─── SECTION TITLE ───
  Widget
  _buildSectionTitle(
    String
    title,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        6,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ─── DIVIDER ───
  Widget
  _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: Divider(
        color: Colors.grey.shade300,
        thickness: 1,
        height: 1,
      ),
    );
  }

  // ─── LOGOUT BUTTON ───
  Widget
  _buildLogoutButton(
    BuildContext
    context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: StatefulBuilder(
        builder:
            (
              context,
              setState,
            ) {
              return Column(
                children: [
                  // ─── LOG OUT FROM ALL DEVICES ───
                  Row(
                    children: [
                      Checkbox(
                        value: _logoutFromAllDevices,
                        activeColor: Colors.red.shade700,
                        onChanged:
                            (
                              value,
                            ) {
                              setState(
                                () {
                                  _logoutFromAllDevices =
                                      value ??
                                      false;
                                },
                              );
                            },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                _logoutFromAllDevices = !_logoutFromAllDevices;
                              },
                            );
                          },
                          child: Text(
                            'Log out from all devices',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                      _showLogoutDialog(
                        context,
                        _logoutFromAllDevices,
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }

  // ─── LOGOUT DIALOG ───
  void
  _showLogoutDialog(
    BuildContext
    context,
    bool
    logoutFromAllDevices,
  ) {
    bool
    isLoggingOut =
        false;
    String?
    errorText;

    showDialog(
      context: context,
      builder:
          (
            dialogContext,
          ) => StatefulBuilder(
            builder:
                (
                  context,
                  setDialogState,
                ) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(
                            16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.red.shade700,
                            size: 36,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),

                        // Title
                        const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),

                        // Message
                        Text(
                          logoutFromAllDevices
                              ? 'Are you sure you want to logout from all devices?'
                              : 'Are you sure you want to logout from your account?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                        if (errorText !=
                            null) ...[
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            errorText!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],

                        const SizedBox(
                          height: 20,
                        ),

                        // Buttons
                        Row(
                          children: [
                            // Cancel
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoggingOut
                                    ? null
                                    : () => Navigator.pop(
                                        dialogContext,
                                      ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),

                            // Confirm Logout → call API, then clear session & navigate
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoggingOut
                                    ? null
                                    : () async {
                                        setDialogState(
                                          () {
                                            isLoggingOut = true;
                                            errorText = null;
                                          },
                                        );

                                        final result = await AuthService().logout(
                                          fromAllDevices: logoutFromAllDevices,
                                        );

                                        if (result
                                            is! LogoutSuccess) {
                                          setDialogState(
                                            () {
                                              isLoggingOut = false;
                                              errorText =
                                                  result
                                                      is LogoutNetworkError
                                                  ? result.message
                                                  : result
                                                        is LogoutFailure
                                                  ? result.message
                                                  : 'Something went wrong, please try again';
                                            },
                                          );
                                          return;
                                        }

                                        await AuthService().clearSession();
                                        if (!context.mounted) {
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
                                    vertical: 12,
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                child: isLoggingOut
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
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
          ),
    );
  }
}
