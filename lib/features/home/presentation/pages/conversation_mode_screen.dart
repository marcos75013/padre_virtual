import 'package:flutter/material.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../voice/presentation/pages/voice_screen.dart';

class ConversationModeScreen extends StatelessWidget {
  final String language;
  final String gender;
  final int age;

  const ConversationModeScreen({
    super.key,
    required this.language,
    required this.gender,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C3D),

      appBar: AppBar(
        title: const Text("Choisir un mode"),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 40),

            /// TEXTE
            _modeCard(
              context,
              icon: Icons.chat,
              title: "Conversation texte",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      language: language,
                      gender: gender,
                      age: age,
                    )
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// VOIX
            _modeCard(
              context,
              icon: Icons.mic,
              title: "Conversation vocale",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoiceScreen(
                      language: language,
                      gender: gender,
                      age: age,
                    )
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          children: [

            Icon(icon, color: Colors.amber, size: 30),

            const SizedBox(width: 20),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}