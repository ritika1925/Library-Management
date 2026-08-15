import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/member_service.dart';

class MemberDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> member;

  const MemberDetailsScreen({
    super.key,
    required this.member,
  });

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  final MemberService _memberService = MemberService();

  bool _editing = false;
  bool _saving = false;

  List<Map<String, dynamic>> _borrowingHistory = [];
  bool _loadingHistory = true;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  late TextEditingController _batchController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.member['full_name']?.toString() ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.member['phone']?.toString() ?? '',
    );

    _emailController = TextEditingController(
      text: widget.member['email']?.toString() ?? '',
    );

    _departmentController = TextEditingController(
      text: widget.member['department']?.toString() ?? '',
    );

    _batchController = TextEditingController(
      text: widget.member['batch']?.toString() ?? '',
    );

    _loadBorrowingHistory();
  }

  // ============================================================
  // LOAD BORROWING HISTORY
  // ============================================================

  Future<void> _loadBorrowingHistory() async {
    try {
      final memberId = widget.member['id']?.toString();

      if (memberId == null || memberId.isEmpty) {
        if (mounted) {
          setState(() {
            _loadingHistory = false;
          });
        }
        return;
      }

      final history =
          await _memberService.getBorrowingHistory(memberId);

      if (!mounted) return;

      setState(() {
        _borrowingHistory = history;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingHistory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load borrowing history: $e",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _batchController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE MEMBER
  // ============================================================

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty"),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _memberService.updateMember(
        memberCode: widget.member['member_code'].toString(),
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        department: _departmentController.text.trim(),
        batch: _batchController.text.trim(),
      );

      // Update local member data.
      widget.member['full_name'] =
          _nameController.text.trim();

      widget.member['phone'] =
          _phoneController.text.trim();

      widget.member['email'] =
          _emailController.text.trim();

      widget.member['department'] =
          _departmentController.text.trim();

      widget.member['batch'] =
          _batchController.text.trim();

      if (!mounted) return;

      setState(() {
        _editing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member updated successfully"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update member: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget infoRow(
    String label,
    String value,
  ) {
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

  // ============================================================
  // EDIT FIELD
  // ============================================================

  Widget editField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final dateString = value.toString();

    if (dateString.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(dateString);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  // ============================================================
  // BORROWING HISTORY SECTION
  // ============================================================

  Widget borrowingHistorySection() {
    if (_loadingHistory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_borrowingHistory.isEmpty) {
      return Container(
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
      );
    }

    return Column(
      children: _borrowingHistory.map((issue) {
        // ------------------------------------------------------
        // BOOK DATA
        // ------------------------------------------------------

        final bookData = issue['books'];

        String bookTitle = 'Unknown Book';
        String bookId = '';

        if (bookData is Map) {
          bookTitle =
              bookData['title']?.toString() ??
              'Unknown Book';

          bookId =
              bookData['book_id']?.toString() ??
              '';
        }

        // ------------------------------------------------------
        // ISSUE DATA
        // ------------------------------------------------------

        final status =
            issue['status']?.toString() ?? 'Unknown';

        final issueDate =
            _formatDate(issue['issue_date']);

        final dueDate =
            _formatDate(issue['due_date']);

        final returnDate =
            _formatDate(issue['return_date']);

        final isIssued =
            status.toLowerCase() == 'issued';

        // ------------------------------------------------------
        // STATUS COLOR
        // ------------------------------------------------------

        final statusColor = isIssued
            ? Colors.orange.shade700
            : Colors.green.shade700;

        // ------------------------------------------------------
        // CARD
        // ------------------------------------------------------

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // BOOK TITLE + STATUS
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primary,
                    child: Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        if (bookId.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            bookId,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(height: 1),

              const SizedBox(height: 12),

              // DATES
              Row(
                children: [
                  Expanded(
                    child: _historyDate(
                      Icons.calendar_today,
                      "Issued",
                      issueDate,
                    ),
                  ),

                  Expanded(
                    child: _historyDate(
                      Icons.event_available,
                      "Due",
                      dueDate,
                    ),
                  ),
                ],
              ),

              // RETURN DATE
              if (returnDate.isNotEmpty) ...[
                const SizedBox(height: 10),

                _historyDate(
                  Icons.assignment_return,
                  "Returned",
                  returnDate,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // HISTORY DATE
  // ============================================================

  Widget _historyDate(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primary,
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value.isEmpty
                  ? "—"
                  : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Details"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,

        actions: [
          if (!_editing)
            IconButton(
              tooltip: "Edit Member",
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _editing = true;
                });
              },
            ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Container(
            width: 600,
            padding: const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset:
                      const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ==================================================
                // MEMBER HEADER
                // ==================================================

                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          AppTheme.primary,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            member['full_name']
                                    ?.toString() ??
                                '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            member['member_code']
                                    ?.toString() ??
                                '',
                            style:
                                const TextStyle(
                              color:
                                  Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 35),

                // ==================================================
                // MEMBER DETAILS
                // ==================================================

                if (_editing) ...[
                  editField(
                    "Name",
                    _nameController,
                  ),

                  editField(
                    "Phone",
                    _phoneController,
                  ),

                  editField(
                    "Department",
                    _departmentController,
                  ),

                  editField(
                    "Batch",
                    _batchController,
                  ),

                  editField(
                    "Email",
                    _emailController,
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () {
                                setState(() {
                                  _editing =
                                      false;
                                });
                              },
                        child:
                            const Text("Cancel"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: _saving
                            ? null
                            : _saveChanges,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Save"),
                      ),
                    ],
                  ),
                ] else ...[
                  infoRow(
                    "Phone",
                    member['phone']
                            ?.toString() ??
                        '',
                  ),

                  infoRow(
                    "Department",
                    member['department']
                            ?.toString() ??
                        '',
                  ),

                  infoRow(
                    "Batch",
                    member['batch']
                            ?.toString() ??
                        '',
                  ),

                  infoRow(
                    "Email",
                    member['email']
                            ?.toString() ??
                        '',
                  ),

                  infoRow(
                    "Status",
                    member['status']
                            ?.toString() ??
                        '',
                  ),
                ],

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 15),

                // ==================================================
                // BORROWING HISTORY
                // ==================================================

                const Text(
                  "Borrowing History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                borrowingHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}