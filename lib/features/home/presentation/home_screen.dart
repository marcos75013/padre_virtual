import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:padre_virtual/features/home/presentation/pages/conversation_mode_screen.dart';
import 'package:padre_virtual/core/services/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? gender;
  int age = 25;

  final TextEditingController nameController = TextEditingController();

  bool isValid = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    nameController.addListener(_validateForm);
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString("name") ?? "";
      gender = prefs.getString("gender");
      age = prefs.getInt("age") ?? 25;
    });

    _validateForm();
  }

  void _validateForm() {
    setState(() {
      isValid = nameController.text.trim().isNotEmpty && gender != null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C3D),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 30),

                /// AVATAR
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage("assets/images/boucheopen.png"),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "home.title".tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "home.description".tr(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                /// NAME
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "home.name".tr(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "home.name_placeholder".tr(),
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// GENDER
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "home.gender".tr(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    _genderButton("home.man".tr(), Icons.male, "male"),
                    const SizedBox(width: 10),
                    _genderButton("home.woman".tr(), Icons.female, "female"),
                  ],
                ),

                const SizedBox(height: 16),

                /// AGE
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "home.age".tr(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

                Slider(
                  value: age.toDouble(),
                  min: 10,
                  max: 90,
                  divisions: 80,
                  activeColor: Colors.amber,
                  label: "$age",
                  onChanged: (value) {
                    setState(() {
                      age = value.toInt();
                    });
                  },
                ),

                Text(
                  "$age",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 20),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? Colors.amber : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isValid
                        ? () async {

                      final lang = context.locale.languageCode;

                      await UserPreferences.saveUser(
                        name: nameController.text.trim(),
                        gender: gender!,
                        age: age,
                      );

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("onboarding_done", true);

                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConversationModeScreen(
                            language: lang,
                            gender: gender!,
                            age: age,
                            name: nameController.text.trim(),
                          ),
                        ),
                      );
                    }
                        : null,
                    child: Text(
                      "home.start".tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String label, IconData icon, String value) {

    final selected = gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            gender = value;
            _validateForm();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.amber : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.black : Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}