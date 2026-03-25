import 'dart:convert';
import 'package:http/http.dart' as http;
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
  State<ConversationModeScreen> createState() =>
      _ConversationModeScreenState();
}

class _ConversationModeScreenState extends State<ConversationModeScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

      appBar: CustomAppBar(
        title: "mode.title".tr(),
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),

      drawer: AppDrawer(
        currentLanguage: selectedLang,
        name: userName,
        age: userAge,
        gender: userGender,
        onLanguageChanged: (lang) {
          setState(() => selectedLang = lang);
        },
        onUserChanged: (name, age, gender) {
          setState(() {
            userName = name;
            userAge = age;
            userGender = gender;
          });
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            Text(
              "conversation.hello".tr(args: [userName]),
              style: const TextStyle(color: Colors.white, fontSize: 26),
            ),

            const SizedBox(height: 8),

            Text(
              "conversation.subtitle".tr(),
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            _featureCard(
              icon: Icons.chat,
              title: "conversation.chat_title".tr(),
              subtitle: "conversation.chat_subtitle".tr(),
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

            const SizedBox(height: 16),

            _featureCard(
              icon: Icons.mic,
              title: "conversation.voice_title".tr(),
              subtitle: "conversation.voice_subtitle".tr(),
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

            const SizedBox(height: 16),

            _featureCard(
              icon: Icons.self_improvement,
              title: "conversation.prayer_title".tr(),
              subtitle: "conversation.prayer_subtitle".tr(),
              onTap: _showMoodBottomSheet,
            ),

            const SizedBox(height: 16),

            _featureCard(
              icon: Icons.menu_book,
              title: "conversation.verse_title".tr(),
              subtitle: "conversation.verse_subtitle".tr(),
              onTap: _getVerse,
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white)),
                Text(subtitle, style: const TextStyle(color: Colors.white54)),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 🔥 MOOD
  void _showMoodBottomSheet() {
    final moods = [
      {"key": "sad", "label": "😢 ${"conversation.moods.sad".tr()}"},
      {"key": "angry", "label": "😡 ${"conversation.moods.angry".tr()}"},
      {"key": "anxious", "label": "😨 ${"conversation.moods.anxious".tr()}"},
      {"key": "happy", "label": "😊 ${"conversation.moods.happy".tr()}"},
      {"key": "grateful", "label": "🙏 ${"conversation.moods.grateful".tr()}"},
      {"key": "lost", "label": "😔 ${"conversation.moods.lost".tr()}"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1C2A4A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Text(
                  "🙏 ${"conversation.prayer_title".tr()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: moods.map((mood) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _askPrayer(mood["key"]!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mood["label"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _askPrayer(String mood) async {
    final res = await http.post(
      Uri.parse("http://192.168.1.36:3000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "type": "prayer",
        "mood": mood,
        "lang": selectedLang,
        "name": userName,
        "age": userAge,
        "gender": userGender,
        "messages": []
      }),
    );

    final data = jsonDecode(res.body);

    await Future.delayed(const Duration(milliseconds: 500)); // 🔥 ICI

    _showDialog(data["answer"]);
  }

  Future<void> _getVerse() async {
    final res = await http.post(
      Uri.parse("http://192.168.1.36:3000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "type": "verse",
        "lang": selectedLang,
        "name": userName,
        "age": userAge,
        "gender": userGender,
        "messages": []
      }),
    );

    final data = jsonDecode(res.body);

    await Future.delayed(const Duration(milliseconds: 500)); // 🔥 ICI

    _showDialog(data["answer"]);
  }

  void _showDialog(String text) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dialog",
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, // 🔥 LIMIT HEIGHT
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2A4A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [

                const Text("🙏", style: TextStyle(fontSize: 28)),

                const SizedBox(height: 15),

                /// 🔥 SCROLLABLE TEXT
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // 🔥 PLUS PETIT
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}