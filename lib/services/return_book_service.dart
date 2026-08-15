import 'package:supabase_flutter/supabase_flutter.dart';

class ReturnBookService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> returnBook({
    required String issueId,
  }) async {
    await _supabase.rpc(
      'return_book',
      params: {
        'p_issue_id': issueId,
      },
    );
  }
}