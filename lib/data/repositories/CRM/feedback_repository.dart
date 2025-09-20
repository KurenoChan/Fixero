import 'package:firebase_database/firebase_database.dart';
import '../../../features/CRM/models/feedback_model.dart';

class FeedbackRepository {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("communications/feedbacks");

  Future<List<FeedbackModel>> fetchAllFeedback() async {
    final snap = await _dbRef.get();
    if (!snap.exists) return [];

    return snap.children.map((child) {
      final id = child.key!;
      final data = Map<String, dynamic>.from(child.value as Map);
      return FeedbackModel.fromMap(id, data);
    }).toList();
  }

  Future<FeedbackModel?> fetchFeedbackById(String id) async {
    final snap = await _dbRef.child(id).get();
    if (!snap.exists) return null;

    return FeedbackModel.fromMap(
      id,
      Map<String, dynamic>.from(snap.value as Map),
    );
  }

  Future<void> addFeedback(FeedbackModel feedback) async {
    await _dbRef.child(feedback.feedbackID).set(feedback.toMap());
  }


  Future<void> updateFeedback(String id, FeedbackModel feedback) async {
    await _dbRef.child(id).update(feedback.toMap());
  }

  Future<void> deleteFeedback(String id) async {
    await _dbRef.child(id).remove();
  }
}
