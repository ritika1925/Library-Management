import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/member_service.dart';
import 'member_registration_screen.dart';
import 'member_details_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final MemberService _memberService = MemberService();

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> filteredMembers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      final data = await _memberService.getMembers();

      if (!mounted) return;

      setState(() {
        members = data;
        filteredMembers = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load members: $e"),
        ),
      );
    }
  }

  // Search members
  void searchMembers(String query) {
    final searchQuery = query.trim().toLowerCase();

    setState(() {
      if (searchQuery.isEmpty) {
        filteredMembers = members;
      } else {
        filteredMembers = members.where((member) {
          final memberCode =
              member['member_code']?.toString().toLowerCase() ?? '';

          final name =
              member['full_name']?.toString().toLowerCase() ?? '';

          final email =
              member['email']?.toString().toLowerCase() ?? '';

          final phone =
              member['phone']?.toString().toLowerCase() ?? '';

          final department =
              member['department']?.toString().toLowerCase() ?? '';

          final batch =
              member['batch']?.toString().toLowerCase() ?? '';

          return memberCode.contains(searchQuery) ||
              name.contains(searchQuery) ||
              email.contains(searchQuery) ||
              phone.contains(searchQuery) ||
              department.contains(searchQuery) ||
              batch.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // Search + Register
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: searchMembers,
                    decoration: InputDecoration(
                      hintText:
                          "Search by Name, Member ID, Email, Phone, Department or Batch",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MemberRegistrationScreen(),
                      ),
                    );

                    loadMembers();
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("Register"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredMembers.isEmpty
                      ? const Center(
                          child: Text(
                            "No members found.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];

                            return Card(
                              margin:
                                  const EdgeInsets.only(bottom: 12),

                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: AppTheme.primary,
                                ),

                                title: Text(
                                  member['member_code']
                                          ?.toString() ??
                                      '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Text(
                                  member['full_name']
                                          ?.toString() ??
                                      '',
                                ),

                                trailing: const Icon(
                                  Icons.chevron_right,
                                ),

                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MemberDetailsScreen(
                                        member: member,
                                      ),
                                    ),
                                  );

                                  // Refresh after returning
                                  loadMembers();
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}