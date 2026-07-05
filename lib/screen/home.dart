import 'package:dnpwc/models/user_profile.dart';
import 'package:dnpwc/screen/login.dart';
import 'package:dnpwc/screen/off_checkin.dart';
import 'package:dnpwc/screen/qr_scanner.dart';
import 'package:dnpwc/services/auth_service.dart';
import 'package:dnpwc/services/profile_service.dart';
import 'package:flutter/material.dart';
import '../widget/bottom_nav.dart';
import '../widget/app_drawer.dart';
import 'notices.dart';

class HomePage
    extends
        StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<
    HomePage
  >
  createState() =>
      _HomePageState();
}

class _HomePageState
    extends
        State<
          HomePage
        > {
  int
  _currentIndex =
      -1;
  final ProfileService
  _profileService =
      ProfileService();

  UserProfile?
  _userProfile;
  bool
  _isLoadingProfile =
      true;
  String?
  _profileError;

  // ─── COLORS ───
  static const Color
  primaryBlue = Color(
    0xFF0A2E5C,
  );
  static const Color
  lightBlue = Color(
    0xFF0D47A1,
  );
  static const Color
  bgColor = Color(
    0xFFF5F7FB,
  );

  @override
  void
  initState() {
    super.initState();
    _loadProfile();
  }

  Future<
    void
  >
  _loadProfile() async {
    if (mounted) {
      setState(
        () {
          _isLoadingProfile = true;
          _profileError = null;
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
          _userProfile = result.userProfile;
          _isLoadingProfile = false;
          _profileError = null;
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

    final String
    errorMessage;
    if (result
        is ProfileNetworkError) {
      errorMessage = result.message;
    } else if (result
        is ProfileFailure) {
      errorMessage = result.message;
    } else {
      errorMessage = 'Something went wrong, please try again';
    }

    setState(() {
      _profileError = errorMessage;
      _isLoadingProfile = false;
    });
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: AppDrawer(
        userProfile: _userProfile,
      ),
      extendBody: true,
      body: _buildBody(
        context,
      ),

      // ─── QR FAB ───
      floatingActionButton: ScanFab(
        onPressed: _openQrScanner,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ─── BOTTOM NAV ───
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTabSelected:
            (
              index,
            ) {
              setState(
                () => _currentIndex = index,
              );
              if (index ==
                  0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          _,
                        ) => const NoticesPage(),
                  ),
                );
              } else if (index ==
                  1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          _,
                        ) => const OfflineScanScreen(),
                  ),
                );
              }
            },
        onScanPressed: _openQrScanner,
      ),
    );
  }

  Widget
  _buildBody(
    BuildContext
    context,
  ) {
    if (_isLoadingProfile &&
        _userProfile ==
            null) {
      return const Center(
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
      );
    }

    if (_profileError !=
            null &&
        _userProfile ==
            null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                _profileError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            context,
          ),

          // ─── WELCOME ───
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              12,
            ),
            child: Row(
              children: [
                Text(
                  'Welcome, ${_userProfile?.name ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                const Text(
                  '👋',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),

          _buildNoticeCard(),

          // ─── QUICK ACCESS ───
          const Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              12,
            ),
            child: Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          _buildQuickAccessGrid(),

          // ─── EXPLORE ───
          const Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              12,
            ),
            child: Text(
              'Explore',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          _buildExploreCard(),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  void
  _openQrScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (
              _,
            ) => const QRScannerScreen(),
      ),
    );
  }

  // ─── HEADER ───
  Widget
  _buildHeader(
    BuildContext
    context,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top:
            MediaQuery.of(
              context,
            ).padding.top +
            10,
        bottom: 20,
        left: 12,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryBlue,
            lightBlue,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            24,
          ),
          bottomRight: Radius.circular(
            24,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(
            builder:
                (
                  context,
                ) => IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () => Scaffold.of(
                    context,
                  ).openDrawer(),
                  padding: EdgeInsets.zero,
                ),
          ),
          const SizedBox(
            width: 4,
          ),
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(
              'assets/images/dnpwc.png',
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'राष्ट्रिय निकुञ्ज तथा वन्यजन्तु संरक्षण\nविभाग',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'बबरमहल, काठमाडौँ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── NOTICE CARD ───
  Widget
  _buildNoticeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (
                    _,
                  ) => const NoticesPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(
          14,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            14,
          ),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(
              14,
            ),
            boxShadow: [
              BoxShadow(
                color: lightBlue.withValues(
                  alpha: 0.2,
                ),
                blurRadius: 10,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: lightBlue,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'सूचना',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      'यहाँ तपाईंका महत्वपूर्ण सूचना तथा अपडेटहरू\nदेखिनेछन्।',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── QUICK ACCESS GRID ───
  Widget
  _buildQuickAccessGrid() {
    final items = [
      {
        'onTap': _openQrScanner,
      },
      {
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (
                    _,
                  ) => const OfflineScanScreen(),
            ),
          );
        },
      },
      {
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (
                    _,
                  ) => const NoticesPage(),
            ),
          );
        },
      },
      {
        'onTap': () {},
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemBuilder:
            (
              context,
              index,
            ) {
              return _buildEmptyQuickAccessCard(
                onTap:
                    items[index]['onTap']
                        as VoidCallback,
              );
            },
      ),
    );
  }

  // ─── EMPTY WHITE CARD ───
  Widget
  _buildEmptyQuickAccessCard({
    required VoidCallback
    onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        14,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            14,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.05,
              ),
              blurRadius: 8,
              offset: const Offset(
                0,
                3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── EXPLORE CARD ───
  Widget
  _buildExploreCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: AspectRatio(
          aspectRatio:
              16 /
              8,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/img2.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(
                      alpha: 0.75,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(
                16,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'हाम्रो वन्यजन्तु',
                    style: TextStyle(
                      color: lightBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'हाम्रो सम्पदा, हाम्रो जिम्मेवारी',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
