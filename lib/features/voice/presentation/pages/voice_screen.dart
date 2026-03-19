import 'dart:convert';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceScreen extends StatefulWidget {
  final String language;
  final String gender;
  final int age;
  final String name;

  const VoiceScreen({
    super.key,
    required this.language,
    required this.gender,
    required this.age,
    required this.name,
  });

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {

  final FlutterTts tts = FlutterTts();
  late stt.SpeechToText speech;

  bool listening = false;

  late String selectedLang;

  /// animation bouche
  int frame = 0;
  Timer? mouthTimer;

  final List<String> priestFrames = [
    "assets/images/boucheferme.png",
    "assets/images/boucheopen.png",
    "assets/images/bouchebienouverte.png",
    "assets/images/boucheopen.png",
  ];

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();

    selectedLang = _mapLanguage(widget.language);

    /// quand le prêtre parle
    tts.setStartHandler(() {
      startMouthAnimation();
    });

    /// quand il finit
    tts.setCompletionHandler(() {

      stopMouthAnimation();

      startListening();
    });
  }

  String _mapLanguage(String lang) {

    switch (lang) {

      case "Français":
        return "fr-FR";

      case "English":
        return "en-US";

      case "Português":
        return "pt-PT";

      case "Español":
        return "es-ES";

      default:
        return "fr-FR";
    }
  }

  void startMouthAnimation() {

    mouthTimer = Timer.periodic(
      const Duration(milliseconds: 180),
          (_) {

        setState(() {
          frame = (frame + 1) % priestFrames.length;
        });

      },
    );
  }

  void stopMouthAnimation() {

    mouthTimer?.cancel();

    setState(() {
      frame = 0;
    });
  }

  Future askPriest(String text) async {

    final res = await http.post(
      Uri.parse("http://192.168.1.36:3000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": text}
        ],
        "lang": selectedLang,
        "gender": widget.gender, // 🔥 NEW
        "age": widget.age,       // 🔥 NEW
      }),
    );

    final data = jsonDecode(res.body);

    await tts.setLanguage(selectedLang);
    await tts.setSpeechRate(0.45);

    await tts.speak(data["answer"]);
  }

  startListening() async {

    bool available = await speech.initialize();

    if (!available) return;

    setState(() {
      listening = true;
    });

    speech.listen(
      localeId: selectedLang,
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {

        if (result.finalResult) {

          final text = result.recognizedWords;

          stopListening();

          askPriest(text);

        }

      },
    );
  }

  stopListening() async {

    await speech.stop();

    setState(() {
      listening = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF0B1C3D),

      appBar: AppBar(
        title: Text("voice.title".tr()),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            /// HALO + PRÊTRE

            Stack(
              alignment: Alignment.center,
              children: [

                /// HALO LUMINEUX

                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                /// PRÊTRE ANIMÉ

                Image.asset(
                  priestFrames[frame],
                  height: 300,
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// TEXTE

            Text(
              listening
                  ? "voice.listening".tr()
                  : "voice.tap".tr(),

              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            /// MICRO

            GestureDetector(

              onTap: () {

                if (listening) {
                  stopListening();
                } else {
                  startListening();
                }

              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(35),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: listening
                      ? Colors.red
                      : Colors.deepPurple,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.6),
                      blurRadius: listening ? 40 : 20,
                      spreadRadius: listening ? 10 : 3,
                    )
                  ],
                ),

                child: const Icon(
                  Icons.mic,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}