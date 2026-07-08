import 'package:flutter/material.dart';

class Dummy extends StatefulWidget {
  final String? scannedCode;

  const Dummy({super.key, this.scannedCode});

  @override
  State<Dummy> createState() => _DummyState();
}

class _DummyState extends State<Dummy> {
  // ─── COLORS ───
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color darkBlue = Color(0xFF0A2E5C);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color lightBlueTint = Color(0xFFEEF4FF);
  static const Color bgColor = Color(0xFFF5F7FB);
  static const Color textGrey = Color(0xFF6B7BA4);
  static const Color borderColor = Color(0xFFE1E8F0);

  late final String scannedCode;

  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  final List<_PermitHolder> permitHolders = [
    _PermitHolder(
      sn: 1,
      name: 'Ishwor Raj Chalise',
      gender: 'Male',
      passport: '121212',
      country: 'Nepal',
      contact: '9856038358',
      ticketType: 'Entry Permit',
    ),
    _PermitHolder(
      sn: 2,
      name: 'Sita Sharma',
      gender: 'Female',
      passport: 'AB34567',
      country: 'Nepal',
      contact: '9841234567',
      ticketType: 'Entry Permit',
    ),
    _PermitHolder(
      sn: 3,
      name: 'Gita Thapa',
      gender: 'Female',
      passport: 'CD78901',
      country: 'Nepal',
      contact: '9801234567',
      ticketType: 'Entry Permit',
    ),
    _PermitHolder(
      sn: 4,
      name: 'Ram Bahadur',
      gender: 'Male',
      passport: 'EF45678',
      country: 'Nepal',
      contact: '9812345678',
      ticketType: 'Entry Permit',
    ),
    _PermitHolder(
      sn: 5,
      name: 'Hari Krishna',
      gender: 'Male',
      passport: 'GH11223',
      country: 'India',
      contact: '9823456789',
      ticketType: 'Entry Permit',
    ),
  ];

  final List<_StatItem> stats = [
    _StatItem(icon: Icons.male_rounded, label: 'Male', count: '1'),
    _StatItem(icon: Icons.female_rounded, label: 'Female', count: '1'),
    _StatItem(icon: Icons.groups_rounded, label: 'Other', count: '1'),
    _StatItem(icon: Icons.directions_car_rounded, label: 'Vehicle', count: '1'),
    _StatItem(icon: Icons.flag_rounded, label: 'Nepali', count: '1'),
    _StatItem(icon: Icons.public_rounded, label: 'Saarc', count: '1'),
    _StatItem(icon: Icons.language_rounded, label: 'Foreigner', count: '1'),
  ];

  @override
  void initState() {
    super.initState();
    scannedCode = widget.scannedCode ?? "ONNqEshLD10";
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScannedCodeCard(),
                  const SizedBox(height: 12),
                  _buildStatsGrid(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildPermitHolderCard(),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
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
          colors: [darkBlue, primaryBlue],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── BACK BUTTON (circular styled) ───
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
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
                      'Mark Check-in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Verify and check-in permit holder',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scanned Code',
                  style: TextStyle(
                    color: accentBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scannedCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightBlueTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: accentBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATS GRID (WITH ICON + TIGHT SPACING) ───
  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── SUMMARY TITLE ROW WITH ICON ───
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: accentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Summary',
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              // ─── Total count badge  ───
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: lightBlueTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '7 categories',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentBlue,
                  ),
                ),
              ),
            ],
          ),
          //const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemBuilder: (context, index) {
              return _buildStatGridItem(stats[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatGridItem(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: lightBlueTint,
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: accentBlue, size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stat.count,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PERMIT HOLDER CARD ───
  Widget _buildPermitHolderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_alt_rounded,
                color: accentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Permit Holder Details',
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: lightBlueTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${permitHolders.length} holder${permitHolders.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ─── SCROLLABLE TABLE with VISIBLE SIDE SCROLLBAR ───
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(8),
                      notificationPredicate: (notif) => notif.depth == 1,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _buildTable(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DATA TABLE ───
  Widget _buildTable() {
    return DataTable(
      columnSpacing: 22,
      horizontalMargin: 14,
      headingRowHeight: 44,
      dataRowMinHeight: 52,
      dataRowMaxHeight: 52,
      headingRowColor: WidgetStateProperty.all(lightBlueTint),
      dividerThickness: 1,
      border: TableBorder.symmetric(
        inside: const BorderSide(color: borderColor, width: 1),
      ),
      columns: const [
        DataColumn(label: _TableHeader('S.N')),
        DataColumn(label: _TableHeader('Name')),
        DataColumn(label: _TableHeader('Gender')),
        DataColumn(label: _TableHeader('Passport No')),
        DataColumn(label: _TableHeader('Country')),
        DataColumn(label: _TableHeader('Contact No')),
        DataColumn(label: _TableHeader('Ticket Type')),
      ],
      rows: permitHolders.map((holder) {
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

  // ─── BOTTOM ACTION BUTTONS ───
  Widget _buildBottomActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checked in successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'Check-in',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checked out'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Check-out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── REUSABLE CARD DECORATION ───
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: darkBlue.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

// ─── MODELS ───
class _StatItem {
  final IconData icon;
  final String label;
  final String count;

  _StatItem({
    required this.icon,
    required this.label,
    required this.count,
  });
}

class _PermitHolder {
  final int sn;
  final String name;
  final String gender;
  final String passport;
  final String country;
  final String contact;
  final String ticketType;

  _PermitHolder({
    required this.sn,
    required this.name,
    required this.gender,
    required this.passport,
    required this.country,
    required this.contact,
    required this.ticketType,
  });
}

// ─── TABLE CELLS ───
class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A2547),
        letterSpacing: 0.2,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }
}