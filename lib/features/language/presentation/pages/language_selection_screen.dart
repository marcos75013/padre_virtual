import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/presentation/home_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {

  Locale selectedLocale = const Locale('fr');

  final List<Map<String, dynamic>> languages = [
    {"name": "Français", "locale": const Locale('fr'), "flag": "🇫🇷"},
    {"name": "English", "locale": const Locale('en'), "flag": "🇬🇧"},
    {"name": "Português (Brasil)", "locale": const Locale('pt'), "flag": "🇧🇷"},
  ];

  Future<void> _saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("lang", locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('choose_language'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            DropdownButton<Locale>(
              value: selectedLocale,
              isExpanded: true,
              items: languages.map((lang) {
                return DropdownMenuItem<Locale>(
                  value: lang["locale"],
                  child: Row(
                    children: [
                      Text(lang["flag"]),
                      const SizedBox(width: 10),
                      Text(lang["name"]),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (locale) {
                setState(() {
                  selectedLocale = locale!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                await _saveLanguage(selectedLocale);

                context.setLocale(selectedLocale);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: Text('continue'.tr()),
            )
          ],
        ),
      ),
    );
  }
}