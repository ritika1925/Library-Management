import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../members/members_screen.dart';
import '../books/books_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {"title": "Members", "icon": Icons.people},
      {"title": "Books", "icon": Icons.menu_book},
      {"title": "Issue Book", "icon": Icons.library_add},
      {"title": "Return Book", "icon": Icons.assignment_return},
      {"title": "Reports", "icon": Icons.bar_chart},
    ];
      

    return Scaffold(
      appBar: AppBar(
        title: const Text("Baithak Library"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
  switch (action["title"]) {
    case "Members":
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MembersScreen(),
        ),
      );
      break;

    case "Books":
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const BooksScreen(),
    ),
  );
  break;

    case "Issue Book":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Issue Book module coming soon"),
        ),
      );
      break;

    case "Return Book":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Return Book module coming soon"),
        ),
      );
      break;

    case "Reports":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reports module coming soon"),
        ),
      );
      break;
  }
},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action["icon"] as IconData,
                      size: 50,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      action["title"] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}