import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  final String language;
  final String gender;
  final int age;

  const ChatScreen({
    super.key,
    required this.language,
    required this.gender,
    required this.age,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 🔥 NEW

  late stt.SpeechToText speech;

  bool isListening = false;
  bool isTyping = false;

  List<Map<String, String>> messages = [];

  late String selectedLang;

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();
    selectedLang = _mapLanguage(widget.language);
  }

  String _mapLanguage(String lang) {
    switch (lang) {
      case "Français":
        return "fr";
      case "English":
        return "en";
      case "Português":
        return "pt";
      case "Español":
        return "es";
      default:
        return "fr";
    }
  }

  /// 🔥 SCROLL AUTO
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future askPriest() async {

    if (controller.text.isEmpty) return;

    final userMessage = controller.text;

    setState(() {
      messages.add({
        "role": "user",
        "content": userMessage
      });
      isTyping = true;
    });

    controller.clear();

    _scrollToBottom(); // 🔥 après message user

    final res = await http.post(
      Uri.parse("http://192.168.1.36:3000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "messages": messages,
        "lang": selectedLang,
        "gender": widget.gender, // 🔥 NEW
        "age": widget.age,       // 🔥 NEW
      }),
    );

    final data = jsonDecode(res.body);

    setState(() {
      isTyping = false;

      messages.add({
        "role": "assistant",
        "content": data["answer"]
      });
    });

    _scrollToBottom(); // 🔥 après réponse
  }

  Future<void> startListening() async {

    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      isListening = true;
    });

    speech.listen(
      localeId: selectedLang,
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        if (result.finalResult) {
          controller.text = result.recognizedWords;
          stopListening();
        }
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
    setState(() {
      isListening = false;
    });
  }

  Widget buildMessage(Map<String, String> message) {

    bool isUser = message["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.deepPurple
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message["content"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TypingDots(),
            SizedBox(width: 10),
            Text(
              "Le prêtre écrit...",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    /// 🔥 scroll automatique après render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C3D),

      appBar: AppBar(
        title: const Text("Conversation texte"),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 10),

            /// HALO + IMAGE
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
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
                  "assets/boucheopen.png",
                  height: 180,
                ),
              ],
            ),

            const Divider(color: Colors.white30),

            /// CHAT
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {

                  if (index < messages.length) {
                    return buildMessage(messages[index]);
                  } else {
                    return buildTypingIndicator();
                  }

                },
              ),
            ),

            /// INPUT
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Pose ta question...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// MICRO
                    GestureDetector(
                      onTap: () {
                        if (isListening) {
                          stopListening();
                        } else {
                          startListening();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListening ? Colors.red : Colors.deepPurple,
                        ),
                        child: const Icon(Icons.mic, color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// SEND
                    GestureDetector(
                      onTap: askPriest,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.deepPurple,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔥 ANIMATION DES 3 POINTS
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget dot(double delay) {
    return FadeTransition(
      opacity: Tween(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.4),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: CircleAvatar(
          radius: 3,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        dot(0.0),
        dot(0.2),
        dot(0.4),
      ],
    );
  }
}