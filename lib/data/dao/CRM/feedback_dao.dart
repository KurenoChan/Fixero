import '../../../features/CRM/models/feedback_model.dart';
import '../../repositories/CRM/feedback_repository.dart';

/*
********************************************************************************
OBJECTIVE:
- DAO is a thin wrapper around repository.
- The Controller/Notifier can use DAO instead of directly hitting Firebase.
********************************************************************************
*/

class FeedbackDAO {
  final FeedbackRepository _repo = FeedbackRepository();

  Future<List<FeedbackModel>> getAllFeedback() async {
    return await _repo.fetchAllFeedback();
  }

  Future<FeedbackModel?> getFeedbackById(String feedbackID) async {
    return await _repo.fetchFeedbackById(feedbackID);
  }

  Future<void> addFeedback(FeedbackModel feedback) async {
    await _repo.addFeedback(feedback);
  }

  Future<void> updateFeedback(FeedbackModel feedback) async {
    await _repo.updateFeedback(feedback.feedbackID, feedback);
  }

  Future<void> deleteFeedback(String feedbackID) async {
    await _repo.deleteFeedback(feedbackID);
  }
}
