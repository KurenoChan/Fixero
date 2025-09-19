import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/service_job.dart';

class ServiceHistoryController extends ChangeNotifier {
  ServiceHistoryController(this.plateNo);
  final String plateNo;

  final List<ServiceJob> _all = [];
  StreamSubscription<DatabaseEvent>? _sub;

  /// Newest → oldest
  List<ServiceJob> get allSorted {
    final l = [..._all];
    l.sort((a, b) => b.sortStamp.compareTo(a.sortStamp));
    return l;
  }

  List<ServiceJob> get recent3 => allSorted.take(3).toList();

  Future<void> listen() async {
    await _sub?.cancel();

    // Read /jobservices/jobs and filter by plateNo
    final ref = FirebaseDatabase.instance.ref('jobservices/jobs');
    _sub = ref.onValue.listen((event) {
      final next = <ServiceJob>[];
      for (final c in event.snapshot.children) {
        // Build from snapshot so the node key is available as a fallback ID.
        final job = ServiceJob.fromSnapshot(c);
        if (job.plateNo.trim().toLowerCase() == plateNo.trim().toLowerCase()) {
          next.add(job);
        }
      }
      _all
        ..clear()
        ..addAll(next);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
