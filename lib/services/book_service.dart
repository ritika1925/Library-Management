import 'package:supabase_flutter/supabase_flutter.dart';

class BookService {
  final SupabaseClient client = Supabase.instance.client;

  // Get all books
  Future<List<Map<String, dynamic>>> getBooks() async {
    final response = await client
        .from('books')
        .select()
        .order('book_id');

    return List<Map<String, dynamic>>.from(response);
  }

  // Add a new book
  Future<void> addBook({
    required String title,
    required String author,
    required String category,
    required int numberOfCopies,
    required String available,
  }) async {
    await client.from('books').insert({
      'title': title,
      'author': author,
      'category': category,
      'No._of_copies': numberOfCopies,
      'available': available,
    });
  }

  // Update an existing book
  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String category,
    required int numberOfCopies,
    required String available,
  }) async {
    await client
        .from('books')
        .update({
          'title': title,
          'author': author,
          'category': category,
          'No._of_copies': numberOfCopies,
          'available': available,
        })
        .eq('book_id', bookId);
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    await client
        .from('books')
        .delete()
        .eq('book_id', bookId);
  }
}