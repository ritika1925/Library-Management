import 'package:supabase_flutter/supabase_flutter.dart';

class MemberService {
  final SupabaseClient client = Supabase.instance.client;

  Future<void> registerMember({
    required String fullName,
    required String phone,
    required String email,
    required String department,
    required String batch,
  })
   async {
    await client.from('members').insert({
  'full_name': fullName,
  'phone': phone,
  'email': email,
  'department': department,
  'batch': batch,
  'status': 'Active',
});
  }
  Future<List<Map<String, dynamic>>> getMembers() async {
  final response = await client
      .from('members')
      .select()
      .order('member_code');

  return List<Map<String, dynamic>>.from(response);
}
 Future<void> updateMember({
  required String memberCode,
  required String fullName,
  required String phone,
  required String email,
  required String department,
  required String batch,
}) async {
  await client
      .from('members')
      .update({
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'department': department,
        'batch': batch,
      })
      .eq('member_code', memberCode);
}
// Get borrowing history for a member
Future<List<Map<String, dynamic>>> getBorrowingHistory(
  String memberId,
) async {
  final response = await client
      .from('book_issues')
      .select('''
        id,
        status,
        book_id,
        books (
          title
        )
      ''')
      .eq('member_id', memberId)
      .order('issue_date', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}
}