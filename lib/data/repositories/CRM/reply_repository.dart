import 'package:firebase_database/firebase_database.dart';
import '../../../features/CRM/models/reply_model.dart';

class ReplyRepository {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("communications/replies");

  Future<List<ReplyModel>> fetchAllReplies() async {
    final snap = await _dbRef.get();
    if (!snap.exists) return [];

    return snap.children.map((child) {
      final id = child.key!;
      final data = Map<String, dynamic>.from(child.value as Map);
      return ReplyModel.fromMap(id, data);
    }).toList();
  }

  Future<ReplyModel?> fetchReplyById(String id) async {
    final snap = await _dbRef.child(id).get();
    if (!snap.exists) return null;

    return ReplyModel.fromMap(
      id,
      Map<String, dynamic>.from(snap.value as Map),
    );
  }

  Future<void> addReply(ReplyModel reply) async {
    await _dbRef.child(reply.replyID).set(reply.toMap());
  }

  Future<void> updateReply(String id, ReplyModel reply) async {
    await _dbRef.child(id).update(reply.toMap());
  }

  Future<void> deleteReply(String id) async {
    await _dbRef.child(id).remove();
  }
}
