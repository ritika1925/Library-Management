class Member {
  final String memberId;
  final String name;
  final String phone;
  final String department;
  final String year;
  final DateTime joinedOn;
  final bool isActive;

  Member({
    required this.memberId,
    required this.name,
    required this.phone,
    required this.department,
    required this.year,
    required this.joinedOn,
    this.isActive = true,
  });
}