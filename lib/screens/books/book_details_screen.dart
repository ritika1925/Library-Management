import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/book_service.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final BookService _bookService = BookService();

  bool _editing = false;
  bool _saving = false;

  late TextEditingController _titleController;
late TextEditingController _authorController;
late TextEditingController _copiesController;

final List<String> _categories = [
  'Fiction',
  'Classics',
  'Fantasy and Sci-Fi',
  'Romance and Y/A',
  'Mystery and Thriller',
  'Self Growth',
  'Indian Heritage',
  'Manga and Comics',
];

String? _selectedCategory;

String _available = 'Yes';

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.book['title']?.toString() ?? '',
    );

    _authorController = TextEditingController(
      text: widget.book['author']?.toString() ?? '',
    );

   final existingCategory = widget.book['category']?.toString();

if (_categories.contains(existingCategory)) {
  _selectedCategory = existingCategory;
} else {
  _selectedCategory = null;
}

    _copiesController = TextEditingController(
      text: widget.book['No._of_copies']?.toString() ?? '1',
    );

    _available =
        widget.book['available']?.toString() ?? 'Yes';
  }

 @override
void dispose() {
  _titleController.dispose();
  _authorController.dispose();
  _copiesController.dispose();
  super.dispose();
}

  Future<void> _saveChanges() async {
  if (_titleController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Book title cannot be empty"),
      ),
    );
    return;
  }

  if (_selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a category"),
      ),
    );
    return;
  }

  final copies =
      int.tryParse(_copiesController.text.trim());

  if (copies == null || copies < 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Enter a valid number of copies"),
      ),
    );
    return;
  }

  setState(() {
    _saving = true;
  });

  try {
    await _bookService.updateBook(
      bookId: widget.book['book_id'].toString(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      category: _selectedCategory!,
      numberOfCopies: copies,
      available: _available,
    );

    // Update local data
    widget.book['title'] =
        _titleController.text.trim();

    widget.book['author'] =
        _authorController.text.trim();

    widget.book['category'] =
        _selectedCategory!;

    widget.book['No._of_copies'] = copies;

    widget.book['available'] = _available;

    if (!mounted) return;

    setState(() {
      _editing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Book updated successfully"),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to update book: $e"),
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

  @override
Widget build(BuildContext context) {
  final book = widget.book;

  return Scaffold(
    appBar: AppBar(
      title: const Text("Book Details"),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      actions: [
        if (!_editing)
          IconButton(
            tooltip: "Edit Book",
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

              // BOOK HEADER
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primary,
                    child: Icon(
                      Icons.menu_book,
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
                          book['title']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          book['book_id']?.toString() ?? '',
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

              // =========================
              // EDIT MODE
              // =========================
              if (_editing) ...[
                editField(
                  "Title",
                  _titleController,
                ),

                editField(
                  "Author",
                  _authorController,
                ),

                const SizedBox(height: 8),

                // CATEGORY DROPDOWN
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  hint: const Text(
                    "Select a category",
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                editField(
                  "No. of Copies",
                  _copiesController,
                ),

                const SizedBox(height: 8),

                // AVAILABLE DROPDOWN
                DropdownButtonFormField<String>(
                  value: _available,
                  decoration: InputDecoration(
                    labelText: "Available",
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Yes',
                      child: Text("Yes"),
                    ),
                    DropdownMenuItem(
                      value: 'No',
                      child: Text("No"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _available = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                // SAVE / CANCEL
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              setState(() {
                                _editing = false;
                              });
                            },
                      child: const Text("Cancel"),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      onPressed:
                          _saving ? null : _saveChanges,
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
              ]

              // =========================
              // VIEW MODE
              // =========================
              else ...[
                infoRow(
                  "Author",
                  book['author']?.toString() ?? '',
                ),

                infoRow(
                  "Category",
                  book['category']?.toString() ?? '',
                ),

                infoRow(
                  "No. of Copies",
                  book['No._of_copies']
                          ?.toString() ??
                      '',
                ),

                infoRow(
                  "Available",
                  book['available']?.toString() ?? '',
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
