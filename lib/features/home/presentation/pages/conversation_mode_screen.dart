import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/app_drawer.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../voice/presentation/pages/voice_screen.dart';


class ConversationModeScreen extends StatefulWidget {
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
  State<ConversationModeScreen> createState() => _ConversationModeScreenState();
}

class _ConversationModeScreenState extends State<ConversationModeScreen> {

  /// 🔥 SCAFFOLD KEY
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 🔥 STATE LOCAL
  late String selectedLang;
  late String userName;
  late int userAge;
  late String userGender;

  @override
  void initState() {
    super.initState();

    selectedLang = widget.language;
    userName = widget.name;
    userAge = widget.age;
    userGender = widget.gender;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0B1C3D),

      /// 🔥 APPBAR
      appBar: CustomAppBar(
        title: "mode.title".tr(),
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),

      /// 🔥 DRAWER
      drawer: AppDrawer(
        currentLanguage: selectedLang,
        name: userName,
        age: userAge,
        gender: userGender,

        onLanguageChanged: (lang) {
          setState(() {
            selectedLang = lang;
          });
        },

        onUserChanged: (name, age, gender) {
          setState(() {
            userName = name;
            userAge = age;
            userGender = gender;
          });
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 40),

            /// 🔥 TEXTE
            _modeCard(
              icon: Icons.chat,
              title: "mode.text".tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      language: selectedLang,
                      gender: userGender,
                      age: userAge,
                      name: userName,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// 🔥 VOIX
            _modeCard(
              icon: Icons.mic,
              title: "mode.voice".tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoiceScreen(
                      language: selectedLang,
                      gender: userGender,
                      age: userAge,
                      name: userName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 CARD UI
  Widget _modeCard({
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