import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [

              Image.asset(
                "assets/images/Baithak_logo.jpeg",
                width: 280,
              ),

              const SizedBox(height: 25),

              Text(
  "Baithak Library",
  style: GoogleFonts.playfairDisplay(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: AppTheme.text,
  ),
),

              const SizedBox(height: 10),

              const Text(
  "Read • Reflect • Grow",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
    letterSpacing: 0.8,
  ),
),
              const SizedBox(height: 12),

              const Text(
                "Welcome back, Library Volunteer.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                width: 420,
                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: Icon(Icons.visibility_off_outlined),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {},

                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "MITMAAI LeadHer Initiative",
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}