/// A single chat message. Mirrors the React chat message objects.
class ChatMessage {
  final String sender; // 'user' | 'other'
  final String text;
  final String time;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
        'sender': sender,
        'text': text,
        'time': time,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        sender: map['sender'] as String? ?? 'other',
        text: map['text'] as String? ?? '',
        time: map['time'] as String? ?? '',
      );
}
