import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/feedback_model.dart';

class FeedbackController extends ValueNotifier<int> {
  // value (int) used for unseen count (so old usages like ValueListenableBuilder<int> still work)
  static final FeedbackController _instance = FeedbackController._internal();
  factory FeedbackController() => _instance;

  FeedbackController._internal() : super(0) {
    _init();
  }

  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("communications/feedbacks");

  final Map<String, FeedbackModel> _byId = {};
  final ValueNotifier<bool> ready = ValueNotifier<bool>(false);

  StreamSubscription<DatabaseEvent>? _subAdded;
  StreamSubscription<DatabaseEvent>? _subChanged;
  StreamSubscription<DatabaseEvent>? _subRemoved;

  List<FeedbackModel> get allFeedbacks =>
      _byId.values.toList(growable: false);

  bool get isInitialized => ready.value;

  Future<void> _init() async {
    try {
      // 1) initial snapshot
      final snap = await _dbRef.get();
      if (snap.exists) {
        for (final child in snap.children) {
          final id = child.key;
          if (id == null) continue;
          final data = Map<String, dynamic>.from(child.value as Map);
          final fb = FeedbackModel.fromMap(id, data);
          _byId[id] = fb;
        }
      }

      // 2) enrich all (job/vehicle/customer info) concurrently
      await Future.wait(_byId.values.map((fb) => _enrichFeedback(fb)));

      // 3) set initial unseen count & mark ready
      value = _unseenCount();
      ready.value = true;
      notifyListeners();

      // 4) attach realtime listeners (after initial GET to avoid duplicates/racing)
      _subAdded = _dbRef.onChildAdded.listen(_onChildAdded);
      _subChanged = _dbRef.onChildChanged.listen(_onChildChanged);
      _subRemoved = _dbRef.onChildRemoved.listen(_onChildRemoved);
    } catch (e, st) {
      debugPrint("FeedbackController._init error: $e\n$st");
      // still mark ready so UI won't hang
      ready.value = true;
      notifyListeners();
    }
  }

  Future<void> _onChildAdded(DatabaseEvent event) async {
    final id = event.snapshot.key;
    if (id == null) return;
    // avoid duplicate (initial GET already populated)
    if (_byId.containsKey(id)) return;
    if (event.snapshot.value == null) return;

    final data = Map<String, dynamic>.from(event.snapshot.value as Map);
    final fb = FeedbackModel.fromMap(id, data);
    await _enrichFeedback(fb);
    _byId[id] = fb;

    value = _unseenCount();
    // force rebuild for list/details
    notifyListeners();
  }

  Future<void> _onChildChanged(DatabaseEvent event) async {
    final id = event.snapshot.key;
    if (id == null) return;
    if (event.snapshot.value == null) return;

    final data = Map<String, dynamic>.from(event.snapshot.value as Map);
    final fb = FeedbackModel.fromMap(id, data);
    await _enrichFeedback(fb);
    _byId[id] = fb;

    value = _unseenCount();
    notifyListeners();
  }

  void _onChildRemoved(DatabaseEvent event) {
    final id = event.snapshot.key;
    if (id == null) return;
    _byId.remove(id);
    value = _unseenCount();
    notifyListeners();
  }

  Future<void> _enrichFeedback(FeedbackModel fb) async {
    if (fb.jobID.isEmpty) return;

    try {
      final jobSnap = await FirebaseDatabase.instance
          .ref("jobservices/jobs/${fb.jobID}")
          .get();
      if (!jobSnap.exists) return;

      final jobData = Map<String, dynamic>.from(jobSnap.value as Map);
      fb.serviceType = jobData["jobServiceType"] ?? "-";

      final plateNo = (jobData["plateNo"] ?? "").toString();
      if (plateNo.isNotEmpty) {
        final vehicleSnap =
        await FirebaseDatabase.instance.ref("vehicles/$plateNo").get();
        if (vehicleSnap.exists) {
          final vehicleData = Map<String, dynamic>.from(vehicleSnap.value as Map);
          fb.carModel = vehicleData["model"] ?? "-";

          final ownerId = vehicleData["ownerID"]?.toString();
          if (ownerId != null && ownerId.isNotEmpty) {
            fb.customerId = ownerId;  // ✅ save customerId in model

            final custSnap = await FirebaseDatabase.instance
                .ref("users/customers/$ownerId")
                .get();
            if (custSnap.exists) {
              final custData = Map<String, dynamic>.from(custSnap.value as Map);
              fb.customerName = custData["custName"] ?? "Unknown";
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to enrich feedback ${fb.feedbackID}: $e");
    }
  }


  int _unseenCount() {
    return _byId.values.where((f) {
      final status = f.status.toLowerCase();
      final seen = f.seenStatus.toLowerCase();
      return status == 'open' && seen == 'unseen';
    }).length;
  }

  // ---------- helpers that mutate both local model and Firebase ----------
  Future<void> markSeen(String feedbackID) async {
    final fb = _byId[feedbackID];
    if (fb == null) return;
    if (fb.seenStatus.toLowerCase() == 'unseen') {
      fb.seenStatus = 'Seen';
      value = _unseenCount();
      notifyListeners(); // immediate UI update
      try {
        await _dbRef.child(feedbackID).update({'seenStatus': 'Seen'});
      } catch (e) {
        debugPrint('markSeen DB update failed: $e');
        // optionally re-sync from server later
      }
    }
  }

  Future<void> closeFeedback(String feedbackID) async {
    final fb = _byId[feedbackID];
    if (fb == null) return;
    fb.status = "Closed";
    value = _unseenCount();
    notifyListeners();
    try {
      await _dbRef.child(feedbackID).update({'status': 'Closed'});
    } catch (e) {
      debugPrint('closeFeedback DB update failed: $e');
    }
  }

  Future<void> reopenFeedback(String feedbackID) async {
    final fb = _byId[feedbackID];
    if (fb == null) return;
    fb.status = "Open";
    value = _unseenCount();
    notifyListeners();
    try {
      await _dbRef.child(feedbackID).update({'status': 'Open'});
    } catch (e) {
      debugPrint('reopenFeedback DB update failed: $e');
    }
  }

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    ready.dispose();
    super.dispose();
  }
}
