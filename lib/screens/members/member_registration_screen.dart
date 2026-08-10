import 'package:flutter/material.dart';
import '../../services/member_service.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({super.key});

  @override
  State<MemberRegistrationScreen> createState() =>
      _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState
    extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final MemberService memberService = MemberService();

  String? department;
  String? batch;

  final List<String> departments = [
    "CSE",
    "IT",
    "ECE",
    "EE",
    "ME",
    "CE",
    "ChemE",
    "LTE",
    "BMR",
    "M&C",
    "Pharmacy"
  ];

  final List<String> batches = [
    "2023",
    "2024",
    "2025",
    "2026",
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> registerMember() async {
    if (!_formKey.currentState!.validate()) return;

    if (department == null || batch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Department and Batch"),
        ),
      );
      return;
    }

    try {
      await memberService.registerMember(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        department: department!,
        batch: batch!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member Registered Successfully!"),
        ),
      );

      _formKey.currentState!.reset();

      nameController.clear();
      phoneController.clear();
      emailController.clear();

      setState(() {
        department = null;
        batch = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration Failed: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Member"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter full name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter phone number";
                  }

                  if (value.length != 10) {
                    return "Phone number must be 10 digits";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: department,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
                items: departments
                    .map(
                      (dept) => DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    department = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: batch,
                decoration: const InputDecoration(
                  labelText: "Batch",
                  border: OutlineInputBorder(),
                ),
                items: batches
                    .map(
                      (year) => DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    batch = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: registerMember,
                  child: const Text(
                    "Register Member",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}