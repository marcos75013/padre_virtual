abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSuccess extends ChatState {

  final String answer;

  ChatSuccess(this.answer);
}

class ChatError extends ChatState {}