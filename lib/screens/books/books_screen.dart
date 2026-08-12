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
  List<Map<String, dynamic>> filteredBooks = [];

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
        filteredBooks = data;
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

  // Search books
  void searchBooks(String query) {
    final searchQuery = query.trim().toLowerCase();

    setState(() {
      if (searchQuery.isEmpty) {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) {
          final bookId =
              book['book_id']?.toString().toLowerCase() ?? '';

          final title =
              book['title']?.toString().toLowerCase() ?? '';

          final author =
              book['author']?.toString().toLowerCase() ?? '';

          final category =
              book['category']?.toString().toLowerCase() ?? '';

          return bookId.contains(searchQuery) ||
              title.contains(searchQuery) ||
              author.contains(searchQuery) ||
              category.contains(searchQuery);
        }).toList();
      }
    });
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
                    onChanged: searchBooks,
                    decoration: InputDecoration(
                      hintText:
                          "Search by Book Name, ID, Author or Category",
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
                  : filteredBooks.isEmpty
                      ? const Center(
                          child: Text(
                            "No books found.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];

                            return Card(
                              margin:
                                  const EdgeInsets.only(bottom: 12),

                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.primary,
                                  child: Icon(
                                    Icons.menu_book,
                                    color: Colors.white,
                                  ),
                                ),

                                title: Text(
                                  book['book_id']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Text(
                                  book['title']?.toString() ?? '',
                                ),

                                trailing: Text(
                                  book['available']
                                          ?.toString() ??
                                      '',
                                  style: TextStyle(
                                    color: book['available']
                                                ?.toString() ==
                                            'Yes'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookDetailsScreen(
                                        book: book,
                                      ),
                                    ),
                                  );

                                  // Refresh after returning
                                  loadBooks();
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