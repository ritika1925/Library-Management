import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/issue_book_service.dart';

class IssueBookScreen extends StatefulWidget {
  const IssueBookScreen({super.key});

  @override
  State<IssueBookScreen> createState() => _IssueBookScreenState();
}

class _IssueBookScreenState extends State<IssueBookScreen> {
  final IssueBookService _issueBookService = IssueBookService();

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _books = [];

  String? _selectedMemberId;
  String? _selectedBookId;

  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  bool _loading = true;
  bool _issuing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ------------------------------------------------------------
  // LOAD MEMBERS AND BOOKS
  // ------------------------------------------------------------

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _issueBookService.getMembers(),
        _issueBookService.getBooks(),
      ]);

      if (!mounted) return;

      setState(() {
        _members = List<Map<String, dynamic>>.from(results[0]);
        _books = List<Map<String, dynamic>>.from(results[1]);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load data: $e"),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // DATE FORMAT
  // ------------------------------------------------------------

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ------------------------------------------------------------
  // PICK ISSUE DATE
  // ------------------------------------------------------------

  Future<void> _selectIssueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _issueDate = pickedDate;

      // Keep due date after issue date.
      if (!_dueDate.isAfter(_issueDate)) {
        _dueDate = _issueDate.add(const Duration(days: 30));
      }
    });
  }

  // ------------------------------------------------------------
  // PICK DUE DATE
  // ------------------------------------------------------------

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate.isAfter(_issueDate)
          ? _dueDate
          : _issueDate.add(const Duration(days: 30)),
      firstDate: _issueDate.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _dueDate = pickedDate;
    });
  }

  // ------------------------------------------------------------
  // ISSUE BOOK
  // ------------------------------------------------------------
Future<void> _issueBook() async {
  if (_selectedMemberId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a member"),
      ),
    );
    return;
  }

  if (_selectedBookId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a book"),
      ),
    );
    return;
  }

    setState(() {
      _issuing = true;
    });

    try {
      print("========== ISSUE BOOK DEBUG ==========");
      print("Selected Member ID: $_selectedMemberId");
      print("Selected Book ID: $_selectedBookId");
      print("======================================");
      await _issueBookService.issueBook(
        memberId: _selectedMemberId!,
        bookId: _selectedBookId!,
        issueDate: _issueDate,
        dueDate: _dueDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Book issued successfully"),
        ),
      );

      // Go back to dashboard.
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to issue book: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _issuing = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Issue Book"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),

                child: Container(
                  width: 650,
                  padding: const EdgeInsets.all(30),

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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // ------------------------------------------------
                      // HEADER
                      // ------------------------------------------------

                      const Text(
                        "Issue a Book",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Select a member and a book to issue.",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ------------------------------------------------
                      // MEMBER DROPDOWN
                      // ------------------------------------------------

                      DropdownButtonFormField<String>(
                        value: _selectedMemberId,

                        isExpanded: true,

                        decoration: InputDecoration(
                          labelText: "Member",
                          prefixIcon: const Icon(
                            Icons.person_outline,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        items: _members.map((member) {
                          final memberId =
                              member['id'].toString();

                          final memberCode =
                              member['member_code']?.toString() ?? '';

                          final fullName =
                              member['full_name']?.toString() ?? '';

                          return DropdownMenuItem<String>(
                            value: memberId,

                            child: Text(
                              '$memberCode - $fullName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            _selectedMemberId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // BOOK DROPDOWN
                      // ------------------------------------------------

                      DropdownButtonFormField<String>(
                        value: _selectedBookId,

                        isExpanded: true,

                        decoration: InputDecoration(
                          labelText: "Book",
                          prefixIcon: const Icon(
                            Icons.menu_book,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        items: _books
                            .where((book) {
                              final availableCopies =
                                  (book['available_copies'] ?? 0)
                                      as int;

                              return availableCopies > 0;
                            })
                            .map((book) {
                          final bookId =
                              book['id'].toString();

                          final displayBookId =
                              book['book_id']?.toString() ?? '';

                          final title =
                              book['title']?.toString() ?? '';

                          final availableCopies =
                              (book['available_copies'] ?? 0)
                                  as int;

                          return DropdownMenuItem<String>(
                            value: bookId,

                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '$displayBookId - $title',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Text(
                                  '$availableCopies available',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            _selectedBookId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 30),

                      // ------------------------------------------------
                      // ISSUE DATE
                      // ------------------------------------------------

                      InkWell(
                        onTap: _selectIssueDate,

                        borderRadius:
                            BorderRadius.circular(10),

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppTheme.primary,
                              ),

                              const SizedBox(width: 16),

                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Issue Date",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    _formatDate(_issueDate),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ------------------------------------------------
                      // DUE DATE
                      // ------------------------------------------------

                      InkWell(
                        onTap: _selectDueDate,

                        borderRadius:
                            BorderRadius.circular(10),

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_available_outlined,
                                color: AppTheme.primary,
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    const Text(
                                      "Due Date",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      _formatDate(_dueDate),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              TextButton(
                                onPressed:
                                    _selectDueDate,
                                child:
                                    const Text("Change"),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ------------------------------------------------
                      // ISSUE BUTTON
                      // ------------------------------------------------

                      SizedBox(
                        height: 55,

                        child: ElevatedButton(
                          onPressed:
                              _issuing ? null : _issueBook,

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.primary,
                            foregroundColor:
                                Colors.white,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),

                          child: _issuing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,

                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Issue Book",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
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