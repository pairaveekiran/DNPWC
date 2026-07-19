import 'package:dnpwc/screen/notices.dart';
import 'package:dnpwc/widget/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'qr_scanner.dart';
import 'home.dart';

class OfflineScanScreen extends StatefulWidget {
  const OfflineScanScreen({super.key});

  @override
  State<OfflineScanScreen> createState() => _OfflineScanScreenState();
}

class ScannedPermitRecord {
  final String code;
  final int direction;
  final DateTime timestamp;
  String syncStatus;
  String? errorMessage;

  ScannedPermitRecord({
    required this.code,
    required this.direction,
    required this.timestamp,
    this.syncStatus = "pending",
    this.errorMessage,
  });

  // ─── CONVERT TO JSON ───
  Map<String, dynamic> toJson() => {
        'code': code,
        'direction': direction,
        'timestamp': timestamp.toIso8601String(),
        'syncStatus': syncStatus,
        'errorMessage': errorMessage,
      };

  // ─── CREATE FROM JSON ───
  factory ScannedPermitRecord.fromJson(Map<String, dynamic> json) {
    return ScannedPermitRecord(
      code: json['code'] as String,
      direction: json['direction'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class _OfflineScanScreenState extends State<OfflineScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Color primaryBlue = Color(0xFF0A2E5C);
  static const Color lightBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);

  // ─── SHARED PREFERENCES KEY ───
  static const String _storageKey = 'offline_scanned_permits';

  String? scannedCode;
  String? selectedAction;
  DateTime? _scannedAt;
  bool _isSyncing = false;
  bool _isSelectionMode = false;
  bool _isLoading = true;
  final Set<int> _selectedIndexes = {};
  final List<ScannedPermitRecord> _scannedPermits = [];

  late AnimationController _syncIconController;

  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    // ─── REGISTER OBSERVER TO DETECT APP LIFECYCLE ───
    WidgetsBinding.instance.addObserver(this);

    _syncIconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // ─── LOAD SAVED PERMITS ON STARTUP ───
    _loadPermits();
  }

  @override
  void dispose() {
    // ─── SAVE BEFORE DISPOSING ───
    _savePermits();
    WidgetsBinding.instance.removeObserver(this);
    _syncIconController.dispose();
    super.dispose();
  }

  // ─── LIFECYCLE OBSERVER: SAVE WHEN APP GOES TO BACKGROUND/PAUSED ───
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Save data on these states to ensure persistence even when
    // app is removed from recents (killed by system)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _savePermits();
    }
  }

  // ─── LOAD PERMITS FROM SHARED PREFERENCES ───
  Future<void> _loadPermits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList =
            json.decode(jsonString) as List<dynamic>;

        final List<ScannedPermitRecord> loaded = jsonList
            .map(
              (e) =>
                  ScannedPermitRecord.fromJson(e as Map<String, dynamic>),
            )
            .toList();

        if (mounted) {
          setState(() {
            _scannedPermits.addAll(loaded);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // If parsing fails, clear corrupted data and start fresh
      await _clearCorruptedData();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── SAVE PERMITS TO SHARED PREFERENCES ───
  Future<void> _savePermits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          _scannedPermits.map((r) => r.toJson()).toList();
      final String jsonString = json.encode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving permits: $e');
    }
  }

  // ─── CLEAR CORRUPTED DATA ───
  Future<void> _clearCorruptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  // ─── HANDLE BOTTOM NAV TAP ───
  void _onTabSelected(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const NoticesPage(),
          ),
          (route) => false,
        );
        break;
      case 1:
        break;
    }
  }

  // ─── OPEN QR SCANNER ───
  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onScanned: (code) {
            if (mounted) {
              setState(() {
                scannedCode = code;
                _scannedAt = DateTime.now();
                selectedAction = null;
              });
            }
          },
        ),
      ),
    );
  }

  // ─── HANDLE CHECK IN / OUT ───
  void _handleAction(int direction) {
    if (scannedCode == null) return;
    final timestamp = _scannedAt ?? DateTime.now();

    setState(() {
      _scannedPermits.insert(
        0,
        ScannedPermitRecord(
          code: scannedCode!,
          direction: direction,
          timestamp: timestamp,
        ),
      );
      scannedCode = null;
      _scannedAt = null;
      selectedAction = null;
    });

    // ─── SAVE IMMEDIATELY AFTER ADDING RECORD ───
    _savePermits();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            direction == 1 ? accentBlue : const Color(0xFFC62828),
        content: Text(
          direction == 1
              ? "Checked In successfully"
              : "Checked Out successfully",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIndexes.clear();
    });
  }

  void _deleteSelectedRecords() {
    if (_selectedIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFE67E22),
          content: Text("Select at least one record to delete"),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFC62828),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Remove Selected",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you sure you want to remove "
                "${_selectedIndexes.length} record(s)?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7BA4),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Color(0xFF6B7BA4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final toRemove = _selectedIndexes.toList()
                          ..sort((a, b) => b.compareTo(a));
                        for (final i in toRemove) {
                          _scannedPermits.removeAt(i);
                        }
                        setState(() {
                          _isSelectionMode = false;
                          _selectedIndexes.clear();
                        });

                        // ─── SAVE IMMEDIATELY AFTER DELETING ───
                        _savePermits();

                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Remove",
                        style: TextStyle(
                          color: Colors.white,
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

  // ─── SYNC (UI only) ───
  Future<void> _syncRecords() async {
    final pending =
        _scannedPermits.where((r) => r.syncStatus == "pending").toList();
    if (pending.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFE67E22),
          content: Text("No pending records to sync"),
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);
    _syncIconController.repeat();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSyncing = false;
      for (final r in pending) {
        r.syncStatus = "success";
      }
      _scannedPermits.removeWhere((r) => r.syncStatus == "success");
    });

    _syncIconController.stop();
    _syncIconController.reset();

    // ─── SAVE IMMEDIATELY AFTER SYNCING ───
    await _savePermits();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: accentBlue,
        content: Text("${pending.length} records synced successfully!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      extendBody: true,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTabSelected: _onTabSelected,
        onScanPressed: _openScanner,
      ),
      floatingActionButton: ScanFab(
        onPressed: _openScanner,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryBlue,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOfflineBanner(),
                        const SizedBox(height: 14),
                        _buildScanCard(),
                        const SizedBox(height: 12),
                        _buildScannedCodeCard(),
                        if (scannedCode != null) ...[
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
                        const SizedBox(height: 22),
                        _buildRecordsHeader(),
                        const SizedBox(height: 8),
                        if (_isSelectionMode) _buildSelectionBar(),
                        const SizedBox(height: 8),
                        _scannedPermits.isEmpty
                            ? _buildEmptyState()
                            : _buildPermitTable(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───
  Widget _buildHeader() {
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
          child: Row(
            children: [
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
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Check In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Scan permits and manage check-ins",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isSyncing ? null : _syncRecords,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _isSyncing
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: _isSyncing
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.sync_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── OFFLINE BANNER ───
  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE67E22).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE67E22).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You are currently offline",
                  style: TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Permits will be synced when you're back online",
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SCAN QR CARD ───
  Widget _buildScanCard() {
    return _buildCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _openScanner,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [lightBlue, primaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scan QR Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Tap to open camera and scan permit",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7BA4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SCANNED CODE CARD ───
  Widget _buildScannedCodeCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  scannedCode != null
                      ? Icons.check_circle_rounded
                      : Icons.qr_code_rounded,
                  size: 18,
                  color: scannedCode != null
                      ? accentBlue
                      : const Color(0xFF9AAAC8),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Scanned Code",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7BA4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_scannedAt != null && scannedCode != null)
                  Text(
                    DateFormat('HH:mm:ss').format(_scannedAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9AAAC8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: scannedCode != null
                    ? const Color(0xFFEEF4FF)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scannedCode != null
                      ? const Color(0xFFB3CEF5)
                      : const Color(0xFFDDE3F0),
                  width: 1,
                ),
              ),
              child: Text(
                scannedCode ?? "No code scanned yet",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: scannedCode == null
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: scannedCode == null
                      ? const Color(0xFF9AAAC8)
                      : primaryBlue,
                  fontWeight: scannedCode == null
                      ? FontWeight.normal
                      : FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTION BUTTONS ───
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: "Check In",
            icon: Icons.login_rounded,
            gradient: const [lightBlue, primaryBlue],
            isSelected: selectedAction == "checkin",
            selectedBorderColor: const Color(0xFF90CAF9),
            onTap: () => _handleAction(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: "Check Out",
            icon: Icons.logout_rounded,
            gradient: const [
              Color(0xFFEF5350),
              Color(0xFFC62828),
            ],
            isSelected: selectedAction == "checkout",
            selectedBorderColor: const Color(0xFFEF9A9A),
            onTap: () => _handleAction(0),
          ),
        ),
      ],
    );
  }

  // ─── RECORDS HEADER ───
  Widget _buildRecordsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              "Scanned Permits",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: primaryBlue,
              ),
            ),
            if (_scannedPermits.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_scannedPermits.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        GestureDetector(
          onTap: _scannedPermits.isEmpty
              ? null
              : (_isSelectionMode
                  ? _deleteSelectedRecords
                  : _toggleSelectionMode),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _scannedPermits.isEmpty
                  ? Colors.grey.shade100
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isSelectionMode
                  ? Icons.delete_sweep_rounded
                  : Icons.delete_outline_rounded,
              color: _scannedPermits.isEmpty
                  ? const Color(0xFFCDD8EC)
                  : const Color(0xFFC62828),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // ─── SELECTION BAR ───
  Widget _buildSelectionBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDD8EC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${_selectedIndexes.length} selected",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryBlue,
            ),
          ),
          GestureDetector(
            onTap: _toggleSelectionMode,
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF6B7BA4),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ───
  Widget _buildEmptyState() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                color: Color(0xFF9AAAC8),
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "No scanned permits yet",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Scan a QR code to get started",
              style: TextStyle(
                color: Color(0xFF9AAAC8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PERMIT TABLE ───
  Widget _buildPermitTable() {
    return _buildCard(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2F8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: const IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        "PERMIT ID",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B7BA4),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.white,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Text(
                        "ACTION",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B7BA4),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EEF5)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _scannedPermits.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF0F4FA),
            ),
            itemBuilder: (context, index) {
              final record = _scannedPermits[index];
              final isCheckIn = record.direction == 1;
              final isFailed = record.syncStatus == "failed";
              final isSelected = _selectedIndexes.contains(index);

              return GestureDetector(
                onTap: () {
                  if (_isSelectionMode) {
                    setState(() {
                      if (_selectedIndexes.contains(index)) {
                        _selectedIndexes.remove(index);
                      } else {
                        _selectedIndexes.add(index);
                      }
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEEF2F8)
                        : Colors.transparent,
                    border: isSelected
                        ? const Border(
                            left: BorderSide(
                              color: primaryBlue,
                              width: 3,
                            ),
                          )
                        : null,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        if (_isSelectionMode)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? primaryBlue
                                  : const Color(0xFFCDD8EC),
                              size: 20,
                            ),
                          ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.code,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isFailed &&
                                    record.errorMessage != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    record.errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFC62828),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: Color(0xFF9AAAC8),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm')
                                          .format(record.timestamp),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9AAAC8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xFFF0F4FA),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCheckIn
                                          ? const Color(0xFFE3F2FD)
                                          : const Color(0xFFFFEBEE),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isCheckIn
                                            ? const Color(0xFF90CAF9)
                                            : const Color(0xFFEF9A9A),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCheckIn
                                              ? Icons.login_rounded
                                              : Icons.logout_rounded,
                                          size: 12,
                                          color: isCheckIn
                                              ? accentBlue
                                              : const Color(0xFFC62828),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isCheckIn ? "In" : "Out",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isCheckIn
                                                ? accentBlue
                                                : const Color(0xFFC62828),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isFailed) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFEF9A9A),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 11,
                                            color: Color(0xFFC62828),
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            "Failed",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFC62828),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── ACTION BUTTON WIDGET ───
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final bool isSelected;
  final Color selectedBorderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.isSelected,
    required this.selectedBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: isSelected
            ? Border.all(color: selectedBorderColor, width: 2.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}