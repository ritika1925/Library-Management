import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MemberDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> member;

  const MemberDetailsScreen({
    super.key,
    required this.member,
  });

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "Not provided" : value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Details"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Container(
            width: 600,
            padding: const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primary,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member['full_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            member['member_code'] ?? '',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 35),

                infoRow(
                  "Phone",
                  member['phone']?.toString() ?? '',
                ),

                infoRow(
                  "Department",
                  member['department']?.toString() ?? '',
                ),

                infoRow(
                  "Batch",
                  member['batch']?.toString() ?? '',
                ),

                infoRow(
                  "Email",
                  member['email']?.toString() ?? '',
                ),

                infoRow(
                  "Status",
                  member['status']?.toString() ?? '',
                ),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 15),

                const Text(
                  "Borrowing History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "No borrowing history yet.",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
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