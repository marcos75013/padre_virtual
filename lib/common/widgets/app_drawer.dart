import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final String currentLanguage;
  final String name;
  final int age;
  final String gender;
  final Function(String lang) onLanguageChanged;
  final Function(String name, int age, String gender) onUserChanged;

  const AppDrawer({
    super.key,
    required this.currentLanguage,
    required this.name,
    required this.age,
    required this.gender,
    required this.onLanguageChanged,
    required this.onUserChanged,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late TextEditingController nameController;
  late TextEditingController ageController;

  String selectedGender = "male";

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    ageController = TextEditingController(text: widget.age.toString());

    selectedGender = ["male", "female"].contains(widget.gender)
        ? widget.gender
        : "male";
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B1C3D),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// 🔥 TITLE
            const Text(
              "⚙️ Paramètres",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 🌍 LANGUE
            const Text(
              "Langue",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A4A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: widget.currentLanguage,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF1C2A4A),

                /// 🔥 STYLE TEXTE SELECTION
                style: const TextStyle(color: Colors.amber),

                items: const [
                  DropdownMenuItem(
                    value: "fr",
                    child: Text("🇫🇷 Français"),
                  ),
                  DropdownMenuItem(
                    value: "en",
                    child: Text("🇬🇧 English"),
                  ),
                  DropdownMenuItem(
                    value: "pt",
                    child: Text("🇧🇷 Português"),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    widget.onLanguageChanged(value);
                    context.setLocale(Locale(value));
                  }
                },
              ),
            ),

            const Divider(color: Colors.white30),

            /// 👤 NOM
            const Text("Nom", style: TextStyle(color: Colors.white70)),

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 10),

            /// 🎂 AGE
            const Text("Âge", style: TextStyle(color: Colors.white70)),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 10),

            /// 🚻 GENRE
            const Text("Genre", style: TextStyle(color: Colors.white70)),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A4A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedGender,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF1C2A4A),
                style: const TextStyle(color: Colors.white),

                items: const [
                  DropdownMenuItem(
                    value: "male",
                    child: Text("👨 Homme"),
                  ),
                  DropdownMenuItem(
                    value: "female",
                    child: Text("👩 Femme"),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedGender = value);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            /// 💾 SAVE
            ElevatedButton(
              onPressed: () {
                widget.onUserChanged(
                  nameController.text,
                  int.tryParse(ageController.text) ?? 30,
                  selectedGender,
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text("Sauvegarder"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}