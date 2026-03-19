import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../voice/presentation/pages/voice_screen.dart';

class ConversationModeScreen extends StatelessWidget {
  final String language;
  final String gender;
  final int age;
  final String name;

  const ConversationModeScreen({
    super.key,
    required this.language,
    required this.gender,
    required this.age,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C3D),

      appBar: AppBar(
        title: Text("mode.title".tr())
        ,
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
                title: "mode.text".tr()
                ,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      language: language,
                      gender: gender,
                      age: age,
                      name: name,
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
                title: "mode.voice".tr()
                ,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoiceScreen(
                      language: language,
                      gender: gender,
                      age: age,
                      name: name,
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