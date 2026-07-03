import 'package:flutter/material.dart';

/// Custom Bottom Navigation Bar with a centered floating QR scanner button.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onScanPressed;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      // Reduced padding to prevent overflow
      padding: EdgeInsets.zero,
      height: 65, // Fixed height that fits both icon + label
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // ─── LEFT ITEM: NOTIFICATION ───
          _buildNavItem(
            icon: Icons.notifications_none,
            label: 'Notification',
            index: 0,
          ),

          // Empty space in the middle for the floating QR button
          const SizedBox(width: 60),

          // ─── RIGHT ITEM: CHECK-IN ───
          _buildNavItem(
            icon: Icons.cloud_off_outlined,
            label: 'Check-in',
            index: 1,
          ),
        ],
      ),
    );
  }

  /// Builds a single tappable navigation item with icon + label.
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? const Color(0xFF0D47A1) : Colors.black87;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          // Use min so column takes only needed space (no overflow)
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Floating Action Button for the QR Scanner.
/// Sits in the notch of the bottom navigation bar.
class ScanFab extends StatelessWidget {
  final VoidCallback onPressed;

  const ScanFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer border ring for a professional look
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF0D47A1),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Color(0xFF0D47A1),
          size: 30,
        ),
      ),
    );
  }
}