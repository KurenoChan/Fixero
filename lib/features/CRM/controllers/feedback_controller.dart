// ../controllers/feedback_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/feedback.dart';

class FeedbackController extends ValueNotifier<int> {
  static final FeedbackController _instance = FeedbackController._internal();
  factory FeedbackController() => _instance;

  FeedbackController._internal() : super(0) {
    _init();
  }

  final DatabaseReference dbRef =
  FirebaseDatabase.instance.ref("communications/feedbacks");

  final Map<String, FeedbackModel> _byId = {};
  StreamSubscription<DatabaseEvent>? _subAdded;
  StreamSubscription<DatabaseEvent>? _subChanged;
  StreamSubscription<DatabaseEvent>? _subRemoved;

  List<FeedbackModel> get allFeedbacks =>
      _byId.values.toList(growable: false);

  // -------------------- init --------------------
  Future<void> _init() async {
    // initial snapshot (populate map)
    try {
      final snap = await dbRef.get();
      if (snap.exists) {
        for (final child in snap.children) {
          final id = child.key;
          if (id == null) continue;
          final data = Map<String, dynamic>.from(child.value as Map);
          _byId[id] = FeedbackModel.fromMap(id, data);
        }
      }
    } catch (e) {
      debugPrint("FeedbackController: initial GET failed: $e");
    }

    _updateUnseen();

    // attach listeners — event handlers will dedupe by key
    _subAdded = dbRef.onChildAdded.listen((event) {
      final id = event.snapshot.key;
      if (id == null) return;
      if (_byId.containsKey(id)) return; // IMPORTANT: avoid duplicate
      if (event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byId[id] = FeedbackModel.fromMap(id, data);
      _updateUnseen();
    });

    _subChanged = dbRef.onChildChanged.listen((event) {
      final id = event.snapshot.key;
      if (id == null) return;
      if (event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byId[id] = FeedbackModel.fromMap(id, data);
      _updateUnseen();
    });

    _subRemoved = dbRef.onChildRemoved.listen((event) {
      final id = event.snapshot.key;
      if (id == null) return;
      _byId.remove(id);
      _updateUnseen();
    });
  }

  // -------------------- unseen count logic --------------------
  void _updateUnseen() {
    value = unseenCount();
  }

  int unseenCount() {
    return _byId.values.where((f) {
      final status = (f.status ?? '').toString().toLowerCase();
      final seen = (f.seenStatus ?? '').toString().toLowerCase();
      return status == 'open' && seen == 'unseen';
    }).length;
  }

  // -------------------- helpers to mutate --------------------
  /// Mark locally and update Firebase. Keeps UI snappy.
  Future<void> markSeen(String feedbackID) async {
    final model = _byId[feedbackID];
    if (model == null) return;
    model.seenStatus = "Seen";
    // optimistic update locally
    _updateUnseen();
    try {
      await dbRef.child(feedbackID).update({"seenStatus": "Seen"});
    } catch (e) {
      debugPrint("Failed to update seenStatus in DB: $e");
      // optionally: revert local change or re-sync from server
    }
  }

  Future<void> reopenFeedback(String feedbackID) async {
    final model = _byId[feedbackID];
    if (model == null) return;
    model.status = "Open";
    _updateUnseen();
    try {
      await dbRef.child(feedbackID).update({"status": "Open"});
    } catch (e) {
      debugPrint("Failed to reopen feedback in DB: $e");
    }
  }

  // -------------------- cleanup --------------------
  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }
}
