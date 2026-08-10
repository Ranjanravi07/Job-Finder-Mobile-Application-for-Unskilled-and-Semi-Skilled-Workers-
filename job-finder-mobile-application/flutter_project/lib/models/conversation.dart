import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String applicationId;
  final String workerId;
  final String employerId;
  final String workerName;
  final String employerName;
  final String jobTitle;
  final String lastMessage;
  final DateTime? lastUpdatedAt;

  const Conversation({
    required this.id,
    required this.applicationId,
    required this.workerId,
    required this.employerId,
    required this.workerName,
    required this.employerName,
    required this.jobTitle,
    required this.lastMessage,
    this.lastUpdatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'workerId': workerId,
      'employerId': employerId,
      'workerName': workerName,
      'employerName': employerName,
      'jobTitle': jobTitle,
      'lastMessage': lastMessage,
      'lastUpdatedAt': lastUpdatedAt != null
          ? Timestamp.fromDate(lastUpdatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return Conversation(
      id: doc.id,
      applicationId: data['applicationId'] as String? ?? '',
      workerId: data['workerId'] as String? ?? '',
      employerId: data['employerId'] as String? ?? '',
      workerName: data['workerName'] as String? ?? 'Worker',
      employerName: data['employerName'] as String? ?? 'Employer',
      jobTitle: data['jobTitle'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime? timestamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return Message(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
