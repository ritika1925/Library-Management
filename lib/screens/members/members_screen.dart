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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

 Future<void> loadMembers() async {
  final data = await _memberService.getMembers();

  print("Members from Supabase: $data");

  setState(() {
      members = data;
      loading = false;
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
            /// Search + Register
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by Name or Member ID",
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
                  : members.isEmpty
                      ? const Center(
                          child: Text(
                            "No members registered yet.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),

                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: AppTheme.primary,
                                ),

                                title: Text(
                                  member['member_code'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Text(
                                  member['full_name'] ?? '',
                                ),

                                trailing:
                                    const Icon(Icons.chevron_right),

                                onTap: () {
                                  // Member Details screen comes next
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MemberDetailsScreen(member: member),
                                    ),
                                  );
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