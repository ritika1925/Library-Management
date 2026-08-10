import 'package:supabase_flutter/supabase_flutter.dart';

class BookService {
  final SupabaseClient client = Supabase.instance.client;

  Future<void> addBook({
    required String title,
    required String author,
    required String category,
    required int numberOfCopies,
  }) async {
    await client.from('books').insert({
      'title': title,
      'author': author,
      'category': category,
      'No._of_copies': numberOfCopies,
      'available': 'Yes',
    });
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    final response = await client
        .from('books')
        .select()
        .order('book_id');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getBookById(String bookId) async {
    return await client
        .from('books')
        .select()
        .eq('book_id', bookId)
        .maybeSingle();
  }
}