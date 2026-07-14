import 'package:flutter/material.dart';

void showContactAdminDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  color: Color(0xFF0D47A1),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'For any assistance, please contact the admin office.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.business, size: 18, color: Color(0xFF0D47A1)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'DNPWC Admin Office',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('बबरमहल, काठमाडौँ', style: TextStyle(fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('+977-01-4220912', style: TextStyle(fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('info@dnpwc.gov.np', style: TextStyle(fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}