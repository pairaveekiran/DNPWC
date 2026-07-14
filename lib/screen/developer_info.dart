import 'package:flutter/material.dart';

class DeveloperInfo extends StatefulWidget {
  const DeveloperInfo({super.key});

  @override
  State<DeveloperInfo> createState() => _DeveloperInfoState();
}

class _DeveloperInfoState extends State<DeveloperInfo> {
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color darkBlue = Color(0xFF0A2E5C);
  static const Color mediumBlue = Color(0xFF1E5AA8);
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color lightBlue = Color(0xFFE3ECF9);

  final List<Map<String, String>> developers = const [
    {
      'name': 'Bikash Karki',
      'position': 'Senior Flutter Developer',
    },
    {
      'name': 'Aayush Sharma',
      'position': 'Backend Developer',
    },
    {
      'name': 'Srijan Gurung',
      'position': 'UI/UX Designer',
    },
    {
      'name': 'Pratik Adhikari',
      'position': 'Project Manager',
    },
    {
      'name': 'Nisha Thapa',
      'position': 'QA Engineer',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompanyCard(),
                    const SizedBox(height: 22),
                    _buildTeamHeader(),
                    const SizedBox(height: 4),
                    _buildDeveloperGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 18,
        right: 18,
        bottom: 26,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkBlue, mediumBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.45),
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
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developer Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'About company and development team',
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
    );
  }

  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Websoft Nepal",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            text: "Srijana Chowk, Pokhara-8",
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            text: "061 588358",
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.language_rounded,
            text: "https://www.websoftnepal.com.np",
            isLink: true,
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black12),
          const SizedBox(height: 10),
          const Text(
            "Websoft Technology Nepal is a privately owned software company in Pokhara. We deliver various IT services including, IT outsourcing, hosting and cloud services, custom software application development, social media development and application development for local and international clients.",
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.black87,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "The company's clients include some of the most prestigious banks, media companies, government agencies, and small to mid-size companies representing a wide range of industries.",
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.black87,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    bool isLink = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.black54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: isLink ? const Color(0xFF1976D2) : Colors.black54,
              fontWeight: FontWeight.w500,
              decoration:
                  isLink ? TextDecoration.underline : TextDecoration.none,
              decorationColor: isLink ? const Color(0xFF1976D2) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamHeader() {
    return Row(
      children: [
        _buildSectionTitle(
          icon: Icons.groups_rounded,
          title: 'Developer Team',
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromRGBO(13, 71, 161, 0.15),
            ),
          ),
          child: Text(
            '${developers.length} Members',
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryBlue,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 520;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: developers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isWide ? 0.9 : 0.82,
          ),
          itemBuilder: (context, index) {
            final developer = developers[index];
            return _buildDeveloperCard(
              name: developer['name']!,
              position: developer['position']!,
              index: index,
            );
          },
        );
      },
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String position,
    required int index,
  }) {
    final List<Color> avatarColors = [
      const Color(0xFF0D47A1),
      const Color(0xFF1565C0),
      const Color(0xFF1E88E5),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
    ];

    final Color avatarColor = avatarColors[index % avatarColors.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.045),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(
                avatarColor.r.toInt(),
                avatarColor.g.toInt(),
                avatarColor.b.toInt(),
                0.12,
              ),
              border: Border.all(
                color: Color.fromRGBO(
                  avatarColor.r.toInt(),
                  avatarColor.g.toInt(),
                  avatarColor.b.toInt(),
                  0.25,
                ),
                width: 1.4,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(name),
                style: TextStyle(
                  color: avatarColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              position,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}