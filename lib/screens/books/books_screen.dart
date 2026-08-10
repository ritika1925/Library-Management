import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/book_service.dart';
import 'add_book_screen.dart';
import 'book_details_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final BookService _bookService = BookService();

  List<Map<String, dynamic>> books = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      final data = await _bookService.getBooks();

      if (!mounted) return;

      setState(() {
        books = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load books: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Search + Add Book
            Row(
              children: [

                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by Book Name or Book ID",
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
                        builder: (_) => const AddBookScreen(),
                      ),
                    );

                    loadBooks();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Book"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : books.isEmpty
                      ? const Center(
                          child: Text(
                            "No books added yet.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),

                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.primary,
                                  child: Icon(
                                    Icons.menu_book,
                                    color: Colors.white,
                                  ),
                                ),

                                title: Text(
                                  book['book_id'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Text(
                                  book['title'] ?? '',
                                ),

                                trailing: Text(
                                  book['available'] ?? '',
                                  style: TextStyle(
                                    color: book['available'] == 'Yes'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BookDetailsScreen(
        book: book,
      ),
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