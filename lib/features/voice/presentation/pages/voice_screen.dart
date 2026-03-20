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

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {

  final FlutterTts tts = FlutterTts();
  late stt.SpeechToText speech;

  bool listening = false;
  bool isSpeaking = false;
  bool isProcessing = false;
  bool speechReady = false;
  bool canListen = true;

  late String selectedLang;

  int frame = 0;
  Timer? mouthTimer;

  /// 🔥 HALO MICRO
  late AnimationController micPulseController;
  late Animation<double> micPulseAnimation;

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

    initSpeech();

    /// 🔥 HALO INIT
    micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    micPulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: micPulseController, curve: Curves.easeInOut),
    );

    tts.setStartHandler(() {
      isSpeaking = true;
      stopListening();
      startMouthAnimation();
    });

    tts.setCompletionHandler(() {
      isSpeaking = false;
      stopMouthAnimation();
      unlockAndListen();
    });
  }

  @override
  void dispose() {
    mouthTimer?.cancel();
    micPulseController.dispose();
    speech.stop();
    tts.stop();
    super.dispose();
  }

  /// INIT MICRO
  Future<void> initSpeech() async {
    speechReady = await speech.initialize(
      onStatus: (status) {
        if (status == "done") {
          unlockAndListen();
        }
      },
      onError: (error) {
        unlockAndListen();
      },
    );

    if (speechReady) {
      startListening();
    }
  }

  void unlockAndListen() {
    Future.delayed(const Duration(milliseconds: 800), () {
      canListen = true;
      startListening();
    });
  }

  /// 📞 RACCROCHER
  Future<void> hangUp() async {
    await speech.stop();
    await tts.stop();
    stopMouthAnimation();
    micPulseController.stop();

    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.transparent, // 🔥 IMPORTANT
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A4A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// ✨ ICON
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TEXT (sans highlight)
                  Text(
                    "voice.hangup_title".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "voice.hangup_subtitle".tr(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
  }

  String _mapLanguage(String lang) {
    return lang; // 🔥 CLEAN
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
    setState(() => frame = 0);
  }

  /// API
  Future<void> askPriest(String text) async {
    if (isProcessing) return;

    isProcessing = true;

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
          "name": widget.name,
        }),
      );

      final data = jsonDecode(res.body);

      if (data["answer"] == null) {
        await tts.speak("Erreur.");
        unlockAndListen();
        return;
      }

      await tts.setLanguage(selectedLang);
      await tts.speak(data["answer"]);

    } catch (_) {}

    isProcessing = false;
  }

  /// START LISTENING
  Future<void> startListening() async {

    if (!speechReady || !canListen) return;
    if (isSpeaking || isProcessing) return;
    if (speech.isListening) return;

    canListen = false;

    setState(() => listening = true);

    /// 🔥 START HALO
    micPulseController.repeat(reverse: true);

    speech.listen(
      localeId: selectedLang,
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.finalResult) {
          final text = result.recognizedWords;

          stopListening();

          if (text.trim().isNotEmpty) {
            askPriest(text);
          } else {
            unlockAndListen();
          }
        }
      },
    );
  }

  /// STOP LISTENING
  Future<void> stopListening() async {
    if (!speech.isListening) return;

    await speech.stop();

    setState(() => listening = false);

    /// 🔥 STOP HALO
    micPulseController.stop();
    micPulseController.reset();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C3D),

      appBar: AppBar(
        title: Text("voice.title".tr()),
        backgroundColor: Colors.amber,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// PRÊTRE
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
                Image.asset(priestFrames[frame], height: 300),
              ],
            ),

            const SizedBox(height: 40),

            Text(
              isSpeaking
                  ? "voice.speaking".tr()
                  : listening
                  ? "voice.listening".tr()
                  : "voice.processing".tr(),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 40),

            /// 🎤 MICRO + HALO
            AnimatedBuilder(
              animation: micPulseAnimation,
              builder: (_, __) {

                return Stack(
                  alignment: Alignment.center,
                  children: [

                    if (listening)
                      Transform.scale(
                        scale: micPulseAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber.withOpacity(0.2),
                          ),
                        ),
                      ),

                    GestureDetector(
                      onTap: () {
                        listening ? stopListening() : startListening();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: listening
                              ? Colors.amber
                              : Colors.deepPurple,
                        ),
                        child: Icon(
                          listening ? Icons.mic : Icons.mic_none,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            /// 📞 RACCROCHER
            GestureDetector(
              onTap: hangUp,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: const Icon(
                  Icons.call_end,
                  size: 30,
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