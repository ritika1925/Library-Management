import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/issue_book_service.dart';

class ReturnBookScreen extends StatefulWidget {
  const ReturnBookScreen({super.key});

  @override
  State<ReturnBookScreen> createState() => _ReturnBookScreenState();
}

class _ReturnBookScreenState extends State<ReturnBookScreen> {
  final IssueBookService _issueBookService = IssueBookService();

  List<Map<String, dynamic>> _issues = [];

  bool _loading = true;
  String? _returningIssueId;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  // ------------------------------------------------------------
  // LOAD ACTIVE ISSUES
  // ------------------------------------------------------------

  Future<void> _loadIssues() async {
    try {
      final data = await _issueBookService.getActiveIssues();

      if (!mounted) return;

      setState(() {
        _issues = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load issued books: $e"),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // FORMAT DATE
  // ------------------------------------------------------------

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '-';
    }

    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) {
      return date;
    }

    final day = parsedDate.day.toString().padLeft(2, '0');
    final month = parsedDate.month.toString().padLeft(2, '0');
    final year = parsedDate.year.toString();

    return '$day/$month/$year';
  }

  // ------------------------------------------------------------
  // RETURN BOOK
  // ------------------------------------------------------------

  Future<void> _returnBook(Map<String, dynamic> issue) async {
    final issueId = issue['id']?.toString();

    if (issueId == null || issueId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid issue record"),
        ),
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final member = issue['members'];
        final book = issue['books'];

        final memberName =
            member is Map
                ? member['full_name']?.toString() ?? ''
                : '';

        final bookTitle =
            book is Map
                ? book['title']?.toString() ?? ''
                : '';

        return AlertDialog(
          title: const Text("Return Book"),
          content: Text(
            'Are you sure you want to mark "$bookTitle" '
            'as returned by $memberName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Return"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _returningIssueId = issueId;
    });

    try {
      await _issueBookService.returnBook(
        issueId: issueId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Book returned successfully"),
        ),
      );

      // Reload active issues.
      await _loadIssues();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to return book: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _returningIssueId = null;
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
        title: const Text("Return Book"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _issues.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 60,
                          color: Colors.black38,
                        ),

                        SizedBox(height: 16),

                        Text(
                          "No books are currently issued.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadIssues,

                    child: ListView.builder(
                      itemCount: _issues.length,

                      itemBuilder: (context, index) {
                        final issue = _issues[index];

                        final member = issue['members'];
                        final book = issue['books'];

                        final memberCode =
                            member is Map
                                ? member['member_code']
                                        ?.toString() ??
                                    ''
                                : '';

                        final memberName =
                            member is Map
                                ? member['full_name']
                                        ?.toString() ??
                                    ''
                                : '';

                        final bookId =
                            book is Map
                                ? book['book_id']
                                        ?.toString() ??
                                    ''
                                : '';

                        final title =
                            book is Map
                                ? book['title']
                                        ?.toString() ??
                                    ''
                                : '';

                        final author =
                            book is Map
                                ? book['author']
                                        ?.toString() ??
                                    ''
                                : '';

                        final issueDate =
                            issue['issue_date']?.toString();

                        final dueDate =
                            issue['due_date']?.toString();

                        final issueId =
                            issue['id']?.toString();

                        final isReturning =
                            issueId != null &&
                            issueId == _returningIssueId;

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 15,
                          ),

                          elevation: 2,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),

                          child: Padding(
                            padding:
                                const EdgeInsets.all(18),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                // ------------------------------
                                // BOOK INFORMATION
                                // ------------------------------

                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    const CircleAvatar(
                                      radius: 26,
                                      backgroundColor:
                                          AppTheme.primary,
                                      child: Icon(
                                        Icons.menu_book,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [
                                          Text(
                                            title,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,

                                            style:
                                                const TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 4,
                                          ),

                                          Text(
                                            bookId,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.black54,
                                              fontSize: 13,
                                            ),
                                          ),

                                          if (author
                                              .isNotEmpty) ...[
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "by $author",
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(
                                  height: 30,
                                ),

                                // ------------------------------
                                // MEMBER
                                // ------------------------------

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 20,
                                      color:
                                          AppTheme.primary,
                                    ),

                                    const SizedBox(
                                      width: 10,
                                    ),

                                    Expanded(
                                      child: Text(
                                        "$memberCode - $memberName",
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // ------------------------------
                                // DATES
                                // ------------------------------

                                Row(
                                  children: [
                                    Expanded(
                                      child: _dateInfo(
                                        "Issued",
                                        _formatDate(
                                          issueDate,
                                        ),
                                        Icons
                                            .calendar_today_outlined,
                                      ),
                                    ),

                                    Expanded(
                                      child: _dateInfo(
                                        "Due",
                                        _formatDate(
                                          dueDate,
                                        ),
                                        Icons
                                            .event_available_outlined,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // ------------------------------
                                // RETURN BUTTON
                                // ------------------------------

                                SizedBox(
                                  width: double.infinity,
                                  height: 48,

                                  child: ElevatedButton.icon(
                                    onPressed: isReturning
                                        ? null
                                        : () {
                                            _returnBook(
                                              issue,
                                            );
                                          },

                                    icon: isReturning
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color:
                                                  Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons
                                                .assignment_return,
                                          ),

                                    label: Text(
                                      isReturning
                                          ? "Returning..."
                                          : "Return Book",
                                    ),

                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppTheme.primary,
                                      foregroundColor:
                                          Colors.white,

                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DATE INFO WIDGET
  // ------------------------------------------------------------

  Widget _dateInfo(
    String label,
    String value,
    IconData icon,
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
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}