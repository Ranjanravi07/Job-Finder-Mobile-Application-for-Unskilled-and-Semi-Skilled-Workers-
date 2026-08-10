import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation.dart';
import '../models/job_application.dart';
import '../models/employer_profile.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a conversation when an application is accepted.
  /// The document ID is deterministic based on the application ID to prevent duplicates.
  Future<void> createConversation(
      JobApplication app, EmployerProfile employer) async {
    final String conversationId = 'chat_${app.id}';

    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);

    // Use set with merge: true to avoid overwriting an existing conversation
    await conversationRef.set({
      'applicationId': app.id,
      'workerId': app.workerId,
      'employerId': employer.id,
      'workerName': app.workerName,
      'employerName': employer.name,
      'jobTitle':
          'Job ID: ${app.jobId}', // Since jobTitle isn't in JobApplication directly, we put ID or it can be fetched
      'lastMessage': 'Application Accepted! Start chatting.',
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add an initial system message
    await conversationRef.collection('messages').add({
      'senderId': 'system',
      'text':
          'Employer ${employer.name} has accepted the application. You can now chat directly!',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get conversations for a specific user (Worker or Employer)
  Stream<List<Conversation>> getConversationsForUser(
      String userId, String role) {
    String queryField = role == 'worker' ? 'workerId' : 'employerId';

    return _firestore
        .collection('conversations')
        .where(queryField, isEqualTo: userId)
        .orderBy('lastUpdatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .toList());
  }

  /// Get messages for a specific conversation
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  /// Send a new message
  Future<void> sendMessage(
      String conversationId, String senderId, String text) async {
    if (text.trim().isEmpty) return;

    final batch = _firestore.batch();

    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    final messageRef = conversationRef.collection('messages').doc();

    batch.set(messageRef, {
      'senderId': senderId,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(conversationRef, {
      'lastMessage': text.trim(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
