import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/book_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _copiesController = TextEditingController();

  final BookService _bookService = BookService();

  bool _loading = false;

  // Book categories
  String? _selectedCategory;

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

  Future<void> _addBook() async {
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _copiesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    final numberOfCopies = int.tryParse(
      _copiesController.text.trim(),
    );

    if (numberOfCopies == null || numberOfCopies <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid number of copies"),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _bookService.addBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _selectedCategory!,
        numberOfCopies: numberOfCopies,
        available: numberOfCopies > 0 ? "Yes" : "No",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Book added successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add book: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Book"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),

          child: Container(
            width: 500,
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
                const Text(
                  "Add New Book",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Enter the details of the book below.",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                // Book Title
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Book Title",
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                ),

                const SizedBox(height: 20),

                // Author
                TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: "Author",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 20),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    prefixIcon: Icon(Icons.category_outlined),
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

                // Number of Copies
                TextField(
                  controller: _copiesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Number of Copies",
                    prefixIcon: Icon(Icons.library_books_outlined),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 55,

                  child: ElevatedButton(
                    onPressed: _loading ? null : _addBook,

                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Add Book",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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