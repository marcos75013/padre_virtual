import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';

class ChatCubit extends Cubit<List<Map<String, String>>> {

  final ChatRepository repository;

  ChatCubit(this.repository) : super([]);

  Future sendMessage(String text, String lang) async {

    final messages = List<Map<String, String>>.from(state);

    messages.add({
      "role": "user",
      "content": text
    });

    emit(List.from(messages));

    final answer = await repository.askPriest(messages, lang);

    messages.add({
      "role": "assistant",
      "content": answer
    });

    emit(List.from(messages));
  }
}