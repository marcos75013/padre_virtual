import 'package:flutter/material.dart';
import 'package:padre_virtual/features/home/presentation/pages/conversation_mode_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? gender;
  String? language;
  int age = 25;

  final Map<String, String> languageFlags = {
    "Français": "🇫🇷",
    "English": "🇬🇧",
    "Português": "🇧🇷",
    "Español": "🇪🇸",
  };

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
                    backgroundImage: AssetImage("assets/boucheopen.png"),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Prêtre Virtuel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Je suis un prêtre virtuel, je suis là pour vous écouter et vous aider.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                /// SEXE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Votre sexe",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    _genderButton("Homme", Icons.male),
                    const SizedBox(width: 10),
                    _genderButton("Femme", Icons.female),
                  ],
                ),

                const SizedBox(height: 16),

                /// AGE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Votre âge",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                Slider(
                  value: age.toDouble(),
                  min: 10,
                  max: 90,
                  divisions: 80,
                  activeColor: Colors.amber,
                  label: "$age ans",
                  onChanged: (value) {
                    setState(() {
                      age = value.toInt();
                    });
                  },
                ),

                Text(
                  "$age ans",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 16),

                /// LANGUE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Langue de conversation",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF0B1C3D),
                  value: language,
                  decoration: InputDecoration(
                    hintText: "Sélectionnez une langue",
                    hintStyle: const TextStyle(color: Colors.amber),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: languageFlags.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Text(entry.value, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Text(entry.key, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      language = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                /// BOUTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: gender != null && language != null
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConversationModeScreen(
                            language: language!,
                            gender: gender!,
                            age: age,
                          ),
                        ),
                      );
                    }
                        : null,
                    child: const Text(
                      "Démarrer un échange avec le prêtre",
                      style: TextStyle(
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

  Widget _genderButton(String label, IconData icon) {

    final selected = gender == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            gender = label;
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