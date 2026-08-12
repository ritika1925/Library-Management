import 'package:supabase_flutter/supabase_flutter.dart';

class IssueBookService {
  final SupabaseClient client = Supabase.instance.client;

  // Get all members
  Future<List<Map<String, dynamic>>> getMembers() async {
    final response = await client
        .from('members')
        .select()
        .order('member_code');

    return List<Map<String, dynamic>>.from(response);
  }

  // Get all books
  Future<List<Map<String, dynamic>>> getBooks() async {
    final response = await client
        .from('books')
        .select()
        .order('book_id');

    return List<Map<String, dynamic>>.from(response);
  }

  // Get active issues
  Future<List<Map<String, dynamic>>> getActiveIssues() async {
    final response = await client
        .from('book_issues')
        .select('''
          id,
          member_id,
          book_id,
          issue_date,
          due_date,
          return_date,
          status,
          members (
            member_code,
            full_name
          ),
          books (
            book_id,
            title,
            author
          )
        ''')
        .eq('status', 'Issued')
        .order('issue_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Issue a book
  Future<void> issueBook({
  required String memberId,
  required String bookId,
  required DateTime issueDate,
  required DateTime dueDate,
}) async {
  await client.rpc(
    'issue_book',
    params: {
      'p_member_id': memberId,
      'p_book_id': bookId,
      'p_issue_date':
          issueDate.toIso8601String().split('T')[0],
      'p_due_date':
          dueDate.toIso8601String().split('T')[0],
    },
  );
}
  // Return a book
Future<void> returnBook({
  required String issueId,
}) async {
  await client.rpc(
    'return_book',
    params: {
      'p_issue_id': issueId,
    },
  );
}
}