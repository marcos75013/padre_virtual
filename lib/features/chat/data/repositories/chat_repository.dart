import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatRepository {

  Future<String> askPriest(
      List<Map<String, String>> messages,
      String lang,
      ) async {

    final res = await http.post(
      Uri.parse("http://172.20.10.8:3000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "messages": messages,
        "lang": lang
      }),
    );

    final data = jsonDecode(res.body);

    return data["answer"];
  }
}