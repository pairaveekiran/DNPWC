import 'package:dnpwc/screen/off_checkin.dart';
import 'package:dnpwc/screen/qr_scanner.dart';
import 'package:flutter/material.dart';
import '../widget/bottom_nav.dart';
import 'home.dart';            // For back navigation


class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage>
    with SingleTickerProviderStateMixin {
  // ─── BLUE THEME COLORS ───
  static const Color primaryBlue = Color(0xFF0A2E5C);
  static const Color lightBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);

  // UI State
  bool _isLoading = false;
  String? _errorMessage;
  String selectedFilter = "All";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> filters = const ["All", "Unread", "Important"];

  // ─── Set to true to show demo data, false for empty state ───
  final bool demoWithData = false;

  late final List<_NoticeUi> allNotices = demoWithData
      ? [
          _NoticeUi(
            title: "Official Notice",
            description: "New official updates are available for all users.",
            time: "Just now",
            icon: Icons.campaign_rounded,
            iconColor: const Color(0xFFE67E22),
            iconBg: const Color(0xFFFFF3E0),
            isUnread: true,
            isImportant: true,
          ),
          _NoticeUi(
            title: "Wildlife Update",
            description:
                "Reminder: Please verify your records before submission.",
            time: "10 mins ago",
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFF1E88E5),
            iconBg: const Color(0xFFE3F2FD),
            isUnread: true,
            isImportant: true,
          ),
          _NoticeUi(
            title: "System Maintenance",
            description:
                "Scheduled maintenance on Sunday 12:00 AM - 4:00 AM.",
            time: "2 hours ago",
            icon: Icons.build_circle_rounded,
            iconColor: const Color(0xFF7B1FA2),
            iconBg: const Color(0xFFF3E5F5),
            isUnread: false,
            isImportant: false,
          ),
          _NoticeUi(
            title: "New Feature Released",
            description:
                "QR code scanning is now available for faster check-ins.",
            time: "Yesterday",
            icon: Icons.new_releases_rounded,
            iconColor: const Color(0xFF2E7D32),
            iconBg: const Color(0xFFE8F5E9),
            isUnread: false,
            isImportant: true,
          ),
        ]
      : [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ─── NAVIGATION HANDLERS ───
  void _navigateToCheckIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OfflineScanScreen(),
      ),
    );
  }

  void _navigateToQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_NoticeUi> visibleNotices = _filterNotices();
    final int unreadCount =
        allNotices.where((e) => e.isUnread).toList().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      extendBody: true,
      
      // ─── FLOATING QR SCANNER BUTTON ───
      floatingActionButton: ScanFab(
        onPressed: _navigateToQRScanner,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // ─── BOTTOM NAVIGATION BAR ───
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTabSelected: (index) {
          if (index == 1) {
            _navigateToCheckIn(); // 👈 Navigate to Check-in screen
          }
        },
        onScanPressed: _navigateToQRScanner, // 👈 Navigate to QR scanner
      ),
      
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(unreadCount),
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : visibleNotices.isEmpty
                          ? _buildEmptyState()
                          : _buildNoticesList(visibleNotices),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FILTER LOGIC ───
  List<_NoticeUi> _filterNotices() {
    if (selectedFilter == "All") return allNotices;
    if (selectedFilter == "Unread") {
      return allNotices.where((e) => e.isUnread).toList();
    }
    return allNotices.where((e) => e.isImportant).toList();
  }

  // ─── HEADER ───
  Widget _buildHeader(int unreadCount) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, lightBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 28),
          child: Column(
            children: [
              Row(
                children: [
                  // ─── BACK BUTTON ───
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
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
                  const SizedBox(width: 12),

                  // ─── Title + Subtitle ───
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notices",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          unreadCount > 0
                              ? "$unreadCount unread notification${unreadCount > 1 ? 's' : ''}"
                              : "Stay updated with announcements",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
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

  // ─── FILTER CHIPS ───
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = filter == selectedFilter;

            int count = 0;
            if (filter == "All") {
              count = allNotices.length;
            } else if (filter == "Unread") {
              count = allNotices.where((e) => e.isUnread).length;
            } else {
              count = allNotices.where((e) => e.isImportant).length;
            }

            return GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        isSelected ? primaryBlue : const Color(0xFFCDD8EC),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF3A4A6B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.25)
                              : const Color(0xFFE8EEF8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5A6A8A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── LOADING STATE ───
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Loading notices...",
            style: TextStyle(
              color: Color(0xFF6B7BA4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── NOTICES LIST ───
  Widget _buildNoticesList(List<_NoticeUi> notices) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
      itemCount: notices.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildNoticeCard(notices[index]),
        );
      },
    );
  }

  // ─── EMPTY STATE ───
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 110),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E4FF).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 148,
                  width: 148,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E4FF).withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 104,
                  width: 104,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accentBlue, primaryBlue],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                Positioned(
                  top: 36,
                  right: 36,
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE67E22).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              "No Notices Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You're all caught up! New announcements\nand important updates will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              width: 160,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  // Simulate refresh
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) setState(() => _isLoading = false);
                  });
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
                label: const Text(
                  "Refresh",
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryBlue, width: 1.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ERROR STATE ───
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 110),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Color(0xFFC62828),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Failed to Load Notices",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? "Something went wrong. Please try again.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7BA4),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              width: 160,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) setState(() => _isLoading = false);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 6,
                  shadowColor: primaryBlue.withOpacity(0.4),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  "Retry",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── NOTICE CARD ───
  Widget _buildNoticeCard(_NoticeUi notice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notice.isUnread
              ? const Color(0xFFB3CEF5)
              : const Color(0xFFE8EEF5),
          width: notice.isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(notice.isUnread ? 0.08 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Opened: ${notice.title}"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: notice.iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    notice.icon,
                    color: notice.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: notice.isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                          if (notice.isUnread)
                            Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: accentBlue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentBlue.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notice.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Colors.grey.shade400,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notice.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (notice.isImportant) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFCC80),
                                  width: 0.8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: Color(0xFFE67E22),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "Important",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE67E22),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── UI MODEL (NO BACKEND) ───
class _NoticeUi {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isUnread;
  final bool isImportant;

  _NoticeUi({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isUnread = false,
    this.isImportant = false,
  });
}