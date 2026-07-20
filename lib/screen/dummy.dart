import 'package:flutter/material.dart';
import 'package:dnpwc/services/checkin_service.dart';

class Dummy extends StatefulWidget {
  final String? scannedCode;

  const Dummy({super.key, this.scannedCode});

  @override
  State<Dummy> createState() => _DummyState();
}

class _DummyState extends State<Dummy> {
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color darkBlue = Color(0xFF0A2E5C);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color lightBlueTint = Color(0xFFEEF4FF);
  static const Color bgColor = Color(0xFFF5F7FB);
  static const Color textGrey = Color(0xFF6B7BA4);
  static const Color borderColor = Color(0xFFE1E8F0);

  late final String scannedCode;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasBeenCheckedIn = false;
  String? _errorMessage;
  List<_StatItem> _stats = [];
  List<_PermitHolder> _permitHolders = [];
  List<_VehicleItem> _vehicles = [];

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scannedCode = widget.scannedCode ?? '';
    if (scannedCode.isEmpty) {
      _isLoading = false;
      _errorMessage = 'No scanned code provided';
    } else {
      _fetchPermitDetails();
    }
  }



  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPermitDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = CheckinService();
    final result = await service.fetchPermitDetails(scannedCode);

    if (!mounted) return;

    if (result is CheckinSuccess) {
      final response = result.response;
      debugPrint('[Dummy] API success - status: ${response.status}, permit: ${response.permit?.code}');
      if (!response.status) {
        setState(() {
          _isLoading = false;
          _errorMessage = response.message.isNotEmpty ? response.message : 'Failed to load permit details';
        });
        return;
      }

      final summary = response.summary;

      final List<_StatItem> stats = [];
      _hasBeenCheckedIn = response.hasBeenCheckedIn;

      if (summary != null) {
        if (summary.male >= 1) {
          stats.add(_StatItem(icon: Icons.male_rounded, label: 'Male', count: '${summary.male}'));
        }
        if (summary.female >= 1) {
          stats.add(_StatItem(icon: Icons.female_rounded, label: 'Female', count: '${summary.female}'));
        }
        if (summary.other >= 1) {
          stats.add(_StatItem(icon: Icons.groups_rounded, label: 'Other', count: '${summary.other}'));
        }
        if (summary.vehicle >= 1) {
          stats.add(_StatItem(icon: Icons.directions_car_rounded, label: 'Vehicle', count: '${summary.vehicle}'));
        }
        if (summary.nepali >= 1) {
          stats.add(_StatItem(icon: Icons.flag_rounded, label: 'Nepali', count: '${summary.nepali}'));
        }
        if (summary.saarc >= 1) {
          stats.add(_StatItem(icon: Icons.public_rounded, label: 'Saarc', count: '${summary.saarc}'));
        }
        if (summary.foreigner >= 1) {
          stats.add(_StatItem(icon: Icons.language_rounded, label: 'Foreigner', count: '${summary.foreigner}'));
        }
      }

      final personVisitors = response.visitors.where((v) => !v.isVehicleOnly).toList();
      final vehicleVisitors = response.visitors.where((v) => v.vehicleNo != null).toList();

      final List<_PermitHolder> holders = [];
      for (var i = 0; i < personVisitors.length; i++) {
        final v = personVisitors[i];
        holders.add(_PermitHolder(
          sn: i + 1,
          name: v.name ?? '',
          gender: v.gender ?? '',
          passport: v.passport ?? '',
          country: v.country ?? '',
          contact: v.contact ?? '',
          ticketType: v.ticketType ?? '',
        ));
      }

      final List<_VehicleItem> vehicles = [];
      for (var i = 0; i < vehicleVisitors.length; i++) {
        final v = vehicleVisitors[i];
        vehicles.add(_VehicleItem(
          sn: i + 1,
          vehicleNo: v.vehicleNo ?? '',
          ticketType: v.ticketType ?? '',
        ));
      }

      setState(() {
        _isLoading = false;
        _stats = stats;
        _permitHolders = holders;
        _vehicles = vehicles;
      });
    } else if (result is CheckinUnauthorized) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Session expired. Please log in again.';
      });
    } else if (result is CheckinNotFound) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    } else if (result is CheckinNetworkError) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    } else if (result is CheckinFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  Future<void> _checkInOut({required int direction, required String remark}) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final service = CheckinService();
    final result = await service.performCheckInOut(
      code: scannedCode,
      direction: direction,
      remark: remark,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result is CheckinSuccess) {
      setState(() => _hasBeenCheckedIn = true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.response.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (result is CheckinUnauthorized) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (result is CheckinNetworkError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (result is CheckinFailure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
          if (!_isLoading && _errorMessage == null) _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryBlue, strokeWidth: 3),
          SizedBox(height: 16),
          Text('Loading permit details...', style: TextStyle(color: textGrey, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final bool isAuthError = _errorMessage?.toLowerCase().contains('session') ??
        _errorMessage?.toLowerCase().contains('login') ?? false;
    final bool isNetworkError = _errorMessage?.toLowerCase().contains('internet') ??
        _errorMessage?.toLowerCase().contains('connection') ?? false;
    final bool isNotFound = _errorMessage?.toLowerCase().contains('not found') ??
        _errorMessage?.toLowerCase().contains('invalid') ?? false;

    IconData errorIcon;
    Color errorColor;
    String title;
    String hint;

    if (isAuthError) {
      errorIcon = Icons.login_rounded;
      errorColor = const Color(0xFFE67E22);
      title = 'Session Expired';
      hint = 'Please log in again to continue.';
    } else if (isNetworkError) {
      errorIcon = Icons.wifi_off_rounded;
      errorColor = const Color(0xFFE67E22);
      title = 'Connection Issue';
      hint = 'Please check your internet connection and try again.';
    } else if (isNotFound) {
      errorIcon = Icons.search_off_rounded;
      errorColor = const Color(0xFFE67E22);
      title = 'Not Found';
      hint = 'The permit code could not be found. Please verify and try again.';
    } else {
      errorIcon = Icons.error_outline_rounded;
      errorColor = const Color(0xFFC62828);
      title = 'Oops!';
      hint = 'Something went wrong. Please try again.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── Animated error icon with glow ───
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: errorColor.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(errorIcon, color: errorColor, size: 42),
            ),
            const SizedBox(height: 24),
            // ─── Title ───
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            // ─── Error message ───
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Text(
                _errorMessage ?? hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // ─── Retry button ───
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _fetchPermitDetails,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: primaryBlue.withValues(alpha: 0.3),
                ),
              ),
            ),
            // Secondary hint shown only when we have a specific server message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScannedCodeCard(),
          const SizedBox(height: 12),
          _buildStatsGrid(),
          const SizedBox(height: 12),
          _buildPermitHolderCard(),
          if (_vehicles.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildVehicleCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkBlue, primaryBlue])),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mark Check-in', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                    SizedBox(height: 2),
                    Text('Verify and check-in permit holder', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannedCodeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scanned Code', style: TextStyle(color: accentBlue, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                const SizedBox(height: 4),
                Text(scannedCode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.5)),
              ],
            ),
          ),
          Container(width: 44, height: 44, decoration: BoxDecoration(color: lightBlueTint, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.qr_code_scanner_rounded, color: accentBlue, size: 24)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: accentBlue, size: 20),
              const SizedBox(width: 8),
              const Text('Summary', style: TextStyle(color: accentBlue, fontSize: 15, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: lightBlueTint, borderRadius: BorderRadius.circular(20)),
                child: Text('${_stats.length} categor${_stats.length == 1 ? 'y' : 'ies'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentBlue)),
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.0),
            itemBuilder: (context, index) => _buildStatGridItem(_stats[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGridItem(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor, width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 32, height: 32, decoration: const BoxDecoration(color: lightBlueTint, shape: BoxShape.circle), child: Icon(stat.icon, color: accentBlue, size: 17)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
              children: [
                Text(stat.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black87), overflow: TextOverflow.ellipsis),
                Text(stat.count, style: const TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermitHolderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: accentBlue, size: 20),
              const SizedBox(width: 8),
              const Text('Permit Holder Details', style: TextStyle(color: accentBlue, fontSize: 15, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: lightBlueTint, borderRadius: BorderRadius.circular(20)),
                child: Text('${_permitHolders.length} holder${_permitHolders.length != 1 ? 's' : ''}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Scrollbar(
                controller: _horizontalScrollController, thumbVisibility: true, thickness: 6, radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _horizontalScrollController, scrollDirection: Axis.horizontal, physics: const AlwaysScrollableScrollPhysics(),
                  child: _buildPermitHolderTable(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermitHolderTable() {
    return DataTable(
      columnSpacing: 22, horizontalMargin: 14, headingRowHeight: 44, dataRowMinHeight: 52, dataRowMaxHeight: 52,
      headingRowColor: WidgetStateProperty.all(lightBlueTint), dividerThickness: 1,
      border: TableBorder.symmetric(inside: const BorderSide(color: borderColor, width: 1)),
      columns: const [
        DataColumn(label: _TableHeader('S.N')),
        DataColumn(label: _TableHeader('Name')),
        DataColumn(label: _TableHeader('Gender')),
        DataColumn(label: _TableHeader('Passport No')),
        DataColumn(label: _TableHeader('Country')),
        DataColumn(label: _TableHeader('Contact No')),
        DataColumn(label: _TableHeader('Ticket Type')),
      ],
      rows: _permitHolders.map((holder) {
        return DataRow(cells: [
          DataCell(_TableCell(holder.sn.toString())),
          DataCell(_TableCell(holder.name)),
          DataCell(_TableCell(holder.gender)),
          DataCell(_TableCell(holder.passport)),
          DataCell(_TableCell(holder.country)),
          DataCell(_TableCell(holder.contact)),
          DataCell(_TableCell(holder.ticketType)),
        ]);
      }).toList(),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car_rounded, color: accentBlue, size: 20),
              const SizedBox(width: 8),
              const Text('Vehicle Details', style: TextStyle(color: accentBlue, fontSize: 15, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: lightBlueTint, borderRadius: BorderRadius.circular(20)),
                child: Text('${_vehicles.length} vehicle${_vehicles.length != 1 ? 's' : ''}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(borderRadius: BorderRadius.circular(10), child: _buildVehicleTable()),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTable() {
    return DataTable(
      columnSpacing: 22, horizontalMargin: 14, headingRowHeight: 44, dataRowMinHeight: 52, dataRowMaxHeight: 52,
      headingRowColor: WidgetStateProperty.all(lightBlueTint), dividerThickness: 1,
      border: TableBorder.symmetric(inside: const BorderSide(color: borderColor, width: 1)),
      columns: const [
        DataColumn(label: _TableHeader('S.N')),
        DataColumn(label: _TableHeader('Vehicle No')),
        DataColumn(label: _TableHeader('Ticket Type')),
      ],
      rows: _vehicles.map((vehicle) {
        return DataRow(cells: [
          DataCell(_TableCell(vehicle.sn.toString())),
          DataCell(_TableCell(vehicle.vehicleNo)),
          DataCell(_TableCell(vehicle.ticketType)),
        ]);
      }).toList(),
    );
  }

  Widget _buildBottomActions() {
    final bool canCheckIn = !_isSubmitting && !_hasBeenCheckedIn;
    final bool canCheckOut = !_isSubmitting && _hasBeenCheckedIn;

    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3))]),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: canCheckIn
                      ? () => _checkInOut(direction: 1, remark: 'Checked in')
                      : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    _isSubmitting ? 'Processing...' : 'Check-in',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasBeenCheckedIn ? Colors.grey : primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: canCheckOut
                      ? () => _checkInOut(direction: 0, remark: 'Checked out')
                      : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.logout_rounded, size: 20),
                  label: Text(
                    _isSubmitting ? 'Processing...' : 'Check-out',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: darkBlue.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String count;
  _StatItem({required this.icon, required this.label, required this.count});
}

class _PermitHolder {
  final int sn;
  final String name;
  final String gender;
  final String passport;
  final String country;
  final String contact;
  final String ticketType;
  _PermitHolder({required this.sn, required this.name, required this.gender, required this.passport, required this.country, required this.contact, required this.ticketType});
}

class _VehicleItem {
  final int sn;
  final String vehicleNo;
  final String ticketType;
  _VehicleItem({required this.sn, required this.vehicleNo, required this.ticketType});
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF1A2547), letterSpacing: 0.2));
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87));
  }
}
