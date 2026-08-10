import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BookDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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
    final available = book['available']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Details"),
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

                // Book heading
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                  book['No._of_copies']?.toString() ?? '',
                ),

                infoRow(
                  "Available",
                  available,
                ),

                const SizedBox(height: 15),

                // Availability indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: available == "Yes"
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        available == "Yes"
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: available == "Yes"
                            ? Colors.green
                            : Colors.red,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        available == "Yes"
                            ? "Book is available"
                            : "Book is currently unavailable",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: available == "Yes"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
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