class Message {
  final String content;
  final bool isUser;

  Message({required this.content, required this.isUser});

  factory Message.user(String content) =>
      Message(content: content, isUser: true);
  factory Message.ai(String content) =>
      Message(content: content, isUser: false);
}
