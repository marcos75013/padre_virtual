import 'dart:convert';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// 🔥 IMPORTS
import '../../../../common/widgets/app_drawer.dart';
import '../../../../common/widgets/custom_app_bar.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  late AnimationController micPulseController;
  late Animation<double> micPulseAnimation;

  final List<String> priestFrames = [
    "assets/images/boucheferme.png",
    "assets/images/boucheopen.png",
    "assets/images/bouchebienouverte.png",
    "assets/images/boucheopen.png",
  ];

  late String userName;
  late int userAge;
  late String userGender;

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();

    selectedLang = widget.language;
    userName = widget.name;
    userAge = widget.age;
    userGender = widget.gender;

    initSpeech();

    micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    micPulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: micPulseController, curve: Curves.easeInOut),
    );

    /// 🔥 TTS EVENTS
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

  /// 🔥 INIT MICRO
  Future<void> initSpeech() async {
    speechReady = await speech.initialize(
      onStatus: (status) {
        if (status == "done") unlockAndListen();
      },
      onError: (_) => unlockAndListen(),
    );

    if (speechReady) startListening();
  }

  void unlockAndListen() {
    Future.delayed(const Duration(milliseconds: 800), () {
      canListen = true;
      startListening();
    });
  }

  /// 🔥 API CALL (FIX IMPORTANT)
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
          "gender": userGender,
          "age": userAge,
          "name": userName,
        }),
      );

      if (res.statusCode != 200) throw Exception();

      final data = jsonDecode(res.body);
      final answer = data["answer"] ?? "Erreur";

      await tts.setLanguage(selectedLang);
      await tts.speak(answer);

    } catch (_) {
      await tts.speak("Une erreur est survenue");
      unlockAndListen();
    }

    isProcessing = false;
  }

  /// 🔥 LISTEN
  Future<void> startListening() async {
    if (!speechReady || !canListen) return;
    if (isSpeaking || isProcessing) return;
    if (speech.isListening) return;

    canListen = false;
    setState(() => listening = true);

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

  /// 🔥 STOP
  Future<void> stopListening() async {
    if (!speech.isListening) return;

    await speech.stop();

    setState(() => listening = false);

    micPulseController.stop();
    micPulseController.reset();
  }

  /// 🔥 BOUCHE
  void startMouthAnimation() {
    mouthTimer = Timer.periodic(
      const Duration(milliseconds: 180),
          (_) => setState(() {
        frame = (frame + 1) % priestFrames.length;
      }),
    );
  }

  void stopMouthAnimation() {
    mouthTimer?.cancel();
    setState(() => frame = 0);
  }

  /// 🔥 RACCROCHER
  Future<void> hangUp() async {
    await speech.stop();
    await tts.stop();
    stopMouthAnimation();
    micPulseController.stop();

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0B1C3D),

      appBar: CustomAppBar(
        title: "voice.title".tr(),
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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// 🔥 PRÊTRE ANIMÉ
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

            /// 🔥 MICRO
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

            /// 🔥 RACCROCHER
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