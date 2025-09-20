class ReplyModel {
  final String replyID;
  final String feedbackID;
  String date;
  String from;
  String replyEmail;
  String message;

  ReplyModel({
    required this.replyID,
    required this.feedbackID,
    required this.date,
    required this.from,
    required this.replyEmail,
    required this.message,
  });

  factory ReplyModel.fromMap(String id, Map<String, dynamic> data) {
    return ReplyModel(
      replyID: id,
      feedbackID: data['feedbackID'] ?? '',
      date: data['date'] ?? '',
      from: data['from'] ?? '',
      replyEmail: data['replyEmail'] ?? '',
      message: data['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "feedbackID": feedbackID,
      "date": date,
      "from": from,
      "replyEmail": replyEmail,
      "message": message,
    };
  }
}
