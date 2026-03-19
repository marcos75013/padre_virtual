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
  bool isSpeaking = false;

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
      isSpeaking = true;
      startMouthAnimation();
    });

    /// quand il finit
    tts.setCompletionHandler(() {
      isSpeaking = false;
      stopMouthAnimation();
      startListening();
    });
  }

  @override
  void dispose() {
    mouthTimer?.cancel();
    speech.stop();
    tts.stop();
    super.dispose();
  }

  /// 📞 Raccrocher
  Future<void> hangUp() async {

    await speech.stop();
    await tts.stop();

    stopMouthAnimation();

    if (!mounted) return;

    setState(() {
      listening = false;
      isSpeaking = false;
    });

    /// 🔔 POPUP
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.call_end, color: Colors.red, size: 50),
            SizedBox(height: 20),
            Text(
              "Appel terminé",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );

    /// ⏱️ ferme popup + écran après 1.5s
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // ferme popup
        Navigator.pop(context); // quitte écran
      }
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
    mouthTimer?.cancel();

    mouthTimer = Timer.periodic(
      const Duration(milliseconds: 180),
          (_) {
        if (!mounted) return;
        setState(() {
          frame = (frame + 1) % priestFrames.length;
        });
      },
    );
  }

  void stopMouthAnimation() {
    mouthTimer?.cancel();

    if (!mounted) return;

    setState(() {
      frame = 0;
    });
  }

  Future<void> askPriest(String text) async {

    try {

      final res = await http.post(
        Uri.parse("http://192.168.1.36:3000/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "messages": [
            {"role": "user", "content": text}
          ],
          "lang": selectedLang,
          "gender": widget.gender,
          "age": widget.age,
          "name": widget.name, // 🔥 AJOUT IMPORTANT
        }),
      );

      final data = jsonDecode(res.body);

      await tts.setLanguage(selectedLang);
      await tts.setSpeechRate(0.45);

      await tts.speak(data["answer"]);

    } catch (e) {
      debugPrint("❌ ERREUR API: $e");
    }
  }

  Future<void> startListening() async {

    bool available = await speech.initialize();

    if (!available) return;

    if (!mounted) return;

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

  Future<void> stopListening() async {

    await speech.stop();

    if (!mounted) return;

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
          children: [

            /// HALO + PRÊTRE
            Stack(
              alignment: Alignment.center,
              children: [

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
              ),
            ),

            const SizedBox(height: 40),

            /// 🎤 + 📞
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

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
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: listening
                          ? Colors.red
                          : Colors.deepPurple,
                    ),
                    child: const Icon(
                      Icons.mic,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 40),

                /// 📞 RACCROCHER
                GestureDetector(
                  onTap: hangUp,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}