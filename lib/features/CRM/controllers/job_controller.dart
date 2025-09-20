// controllers/job_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/job_model.dart';

class JobController extends ValueNotifier<int> {
  static final JobController _instance = JobController._internal();
  factory JobController() => _instance;

  JobController._internal() : super(0) {
    _init();
  }

  final dbRef = FirebaseDatabase.instance.ref("jobservices/jobs");
  final Map<String, Job> _byId = {};
  StreamSubscription? _subAdded, _subChanged, _subRemoved;

  List<Job> get allJobs => _byId.values.toList();

  Future<void> _init() async {
    final snap = await dbRef.get();
    if (snap.exists) {
      for (final child in snap.children) {
        final id = child.key!;
        final data = Map<String, dynamic>.from(child.value as Map);
        _byId[id] = Job.fromMap(id, data);
      }
    }
    _notify();

    _subAdded = dbRef.onChildAdded.listen((event) {
      final id = event.snapshot.key!;
      if (_byId.containsKey(id)) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byId[id] = Job.fromMap(id, data);
      _notify();
    });

    _subChanged = dbRef.onChildChanged.listen((event) {
      final id = event.snapshot.key!;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byId[id] = Job.fromMap(id, data);
      _notify();
    });

    _subRemoved = dbRef.onChildRemoved.listen((event) {
      _byId.remove(event.snapshot.key);
      _notify();
    });
  }

  void _notify() => value = _byId.length;

  Job? getById(String id) => _byId[id];

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }
}
