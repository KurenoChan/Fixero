import '../../../features/CRM/models/reply_model.dart';
import '../../repositories/CRM/reply_repository.dart';

/*
********************************************************************************
OBJECTIVE:
- DAO is a thin wrapper around repository.
- The Controller/Notifier can use DAO instead of directly hitting Firebase.
********************************************************************************
*/

class ReplyDAO {
  final ReplyRepository _repo = ReplyRepository();

  Future<List<ReplyModel>> getAllReplies() async {
    return await _repo.fetchAllReplies();
  }

  Future<ReplyModel?> getReplyById(String replyID) async {
    return await _repo.fetchReplyById(replyID);
  }

  Future<void> addReply(ReplyModel reply) async {
    await _repo.addReply(reply);
  }

  Future<void> updateReply(ReplyModel reply) async {
    await _repo.updateReply(reply.replyID, reply);
  }

  Future<void> deleteReply(String replyID) async {
    await _repo.deleteReply(replyID);
  }
}
