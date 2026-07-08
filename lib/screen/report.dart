import 'dart:io';

import 'package:dnpwc/screen/pdf_viewer.dart';
import 'package:dnpwc/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // ─── THEME COLORS ───
  static const Color primaryBlue = Color(0xFF0A2E5C);
  static const Color lightBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);

  // ─── STATE ───
  int _selectedTab = 0; // 0 = Check In, 1 = Check Out
  DateTime _selectedDate = DateTime.now();
  bool _isGenerating = false;

  final ReportService _reportService = ReportService();
  int? _cachedOrgId;

  // ─── PICK DATE ───
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: primaryBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: accentBlue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // ─── GENERATE REPORT ───
  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      // 1. Resolve organization ID (from cache or fetch from profile)
      int orgId;
      if (_cachedOrgId != null) {
        orgId = _cachedOrgId!;
      } else {
        final orgResult = await _reportService.fetchOrganizationId();
        if (!mounted) return;
        if (orgResult is OrgIdFailure) {
          _showError(orgResult.message);
          return;
        }
        orgId = (orgResult as OrgIdSuccess).organizationId;
        _cachedOrgId = orgId;
      }

      // 2. Build request parameters
      //    Check In (_selectedTab == 0) → direction = 1
      //    Check Out (_selectedTab == 1) → direction = 0
      final direction = _selectedTab == 0 ? 1 : 0;
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // 3. Download the PDF
      final downloadResult = await _reportService.downloadReportPdf(
        organizationId: orgId,
        direction: direction,
        date: dateStr,
      );

      if (!mounted) return;

      if (downloadResult is ReportDownloadFailure) {
        _showError(downloadResult.message);
        return;
      }

      // 4. Save PDF to a temp file
      final pdfBytes = (downloadResult as ReportDownloadSuccess).pdfBytes;
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'report_${_selectedTab == 0 ? "checkin" : "checkout"}_$dateStr.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      if (!mounted) return;

      // 5. Show snackbar confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: accentBlue,
          content: Text(
            "${_selectedTab == 0 ? 'Check-In' : 'Check-Out'} report generated for "
            "${DateFormat('MMM dd, yyyy').format(_selectedDate)}",
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // 6. Navigate to PDF viewer
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            filePath: file.path,
            title:
                "${_selectedTab == 0 ? 'Check-In' : 'Check-Out'} Report",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  /// Shows a floating error snackbar. The `finally` block in
  /// [_generateReport] resets the generating state.
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFC62828),
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 18),
                  _buildSectionLabel(
                    icon: Icons.filter_list_rounded,
                    label: "Report Type",
                  ),
                  const SizedBox(height: 10),
                  _buildTabSelector(),
                  const SizedBox(height: 22),
                  _buildSectionLabel(
                    icon: Icons.event_rounded,
                    label: "Select Date",
                  ),
                  const SizedBox(height: 10),
                  _buildDatePickerCard(),
                  const SizedBox(height: 22),
                  _buildSectionLabel(
                    icon: Icons.summarize_rounded,
                    label: "Summary",
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryCard(),
                  const SizedBox(height: 28),
                  _buildGenerateButton(),
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
                onTap: () => Navigator.pop(context),
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
                      "Report",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Generate check-in & check-out reports",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.assessment_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── INFO BANNER ───
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB3CEF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.06),
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
              color: accentBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentBlue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.info_outline_rounded,
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
                  "Generate Detailed Reports",
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Select report type and date to generate",
                  style: TextStyle(
                    color: Color(0xFF6B7BA4),
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

  // ─── SECTION LABEL ───
  Widget _buildSectionLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryBlue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ─── TAB SELECTOR (Check In / Check Out) ───
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              index: 0,
              label: "Check In",
              icon: Icons.login_rounded,
              gradient: const [lightBlue, primaryBlue],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabItem(
              index: 1,
              label: "Check Out",
              icon: Icons.logout_rounded,
              gradient: const [Color(0xFFEF5350), Color(0xFFC62828)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
    required List<Color> gradient,
  }) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 52,
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.last.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF6B7BA4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B7BA4),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DATE PICKER CARD ───
  Widget _buildDatePickerCard() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM').format(_selectedDate).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Date",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7BA4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: primaryBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SUMMARY CARD ───
  Widget _buildSummaryCard() {
    final bool isCheckIn = _selectedTab == 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.description_rounded,
                  label: "Type",
                  value: isCheckIn ? "Check In" : "Check Out",
                  color: isCheckIn ? accentBlue : const Color(0xFFC62828),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE8EEF5),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.today_rounded,
                  label: "Date",
                  value: DateFormat('MMM dd, yyyy').format(_selectedDate),
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDDE3F0)),
            ),
            child: Row(
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: isCheckIn ? accentBlue : const Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Report will include all ${isCheckIn ? 'check-in' : 'check-out'} "
                    "records for the selected date",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7BA4),
                      height: 1.4,
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

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9AAAC8),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  // ─── GENERATE REPORT BUTTON ───
  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightBlue, primaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isGenerating ? null : _generateReport,
          child: Center(
            child: _isGenerating
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Generating...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Generate Report",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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