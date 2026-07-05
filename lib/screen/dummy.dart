import 'package:flutter/material.dart';

class SinglePostCheckIn extends StatefulWidget {
  final String? scannedCode;

  const SinglePostCheckIn({super.key, this.scannedCode});

  @override
  State<SinglePostCheckIn> createState() => _SinglePostCheckInState();
}

class _SinglePostCheckInState extends State<SinglePostCheckIn> {
  // ─── COLORS ───
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color lightBlueTint = Color(0xFFEEF4FF);
  static const Color bgColor = Color(0xFFF5F7FB);
  static const Color textGrey = Color(0xFF6B7BA4);

  // ─── DEMO DATA ───
  late final String scannedCode;

  final List<_PermitHolder> permitHolders = [
    _PermitHolder(
      sn: 1,
      name: 'Ishwor Raj\nChalise',
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
  ];

  @override
  void initState() {
    super.initState();
    // Use the scanned code passed from QR Scanner, or fallback to demo value
    scannedCode = widget.scannedCode ?? "ONNqEshLD10";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScannedCodeCard(),
                  const SizedBox(height: 12),
                  _buildSummaryCard(),
                  const SizedBox(height: 12),
                  _buildPermitHolderCard(),
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
      color: primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
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
              const SizedBox(width: 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Single Post Check-in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Verify and check-in permit holder',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
          const Icon(
            Icons.qr_code_scanner_rounded,
            color: accentBlue,
            size: 32,
          ),
        ],
      ),
    );
  }

  // ─── SUMMARY CARD ───
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(Icons.person_rounded, 'Male', '1'),
          _buildSummaryItem(Icons.person_rounded, 'Female', '1'),
          _buildSummaryItem(Icons.groups_rounded, 'Other', '1'),
          _buildSummaryItem(Icons.directions_car_rounded, 'Vehicle', '1'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: lightBlueTint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentBlue, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              count,
              style: const TextStyle(
                fontSize: 12,
                color: textGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── PERMIT HOLDER CARD ───
  Widget _buildPermitHolderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permit Holder Details',
            style: TextStyle(
              color: accentBlue,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatChip(Icons.person_rounded, 'Male', '1'),
                const SizedBox(width: 12),
                _buildStatChip(Icons.person_rounded, 'Female', '1'),
                const SizedBox(width: 12),
                _buildStatChip(Icons.groups_rounded, 'Other', '1'),
                const SizedBox(width: 12),
                _buildStatChip(Icons.groups_rounded, 'Nepali', '2'),
                const SizedBox(width: 12),
                _buildStatChip(Icons.person_rounded, 'Saarc', '1'),
                const SizedBox(width: 12),
                _buildStatChip(Icons.person_rounded, 'Foreigner', '1'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DATA TABLE ───
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCE4F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 12,
        headingRowHeight: 42,
        dataRowMinHeight: 50,
        dataRowMaxHeight: 70,
        headingRowColor: WidgetStateProperty.all(lightBlueTint),
        dividerThickness: 1,
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Color(0xFFDCE4F0), width: 1),
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
      ),
    );
  }

  // ─── STAT CHIP ───
  Widget _buildStatChip(IconData icon, String label, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: lightBlueTint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentBlue, size: 18),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              count,
              style: const TextStyle(
                fontSize: 11,
                color: textGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── BOTTOM ACTION BUTTONS ───
  Widget _buildBottomActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checked in successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Check-in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checked out'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Check-out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.logout_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DATA MODEL ───
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

// ─── TABLE HEADER CELL ───
class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }
}

// ─── TABLE DATA CELL ───
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