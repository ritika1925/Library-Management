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
}