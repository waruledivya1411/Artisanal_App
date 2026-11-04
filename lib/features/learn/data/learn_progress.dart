import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';

class LearnProgress extends ChangeNotifier {
  LearnProgress._();

  static final LearnProgress instance = LearnProgress._();

  static const _key = 'learn-progress';

  final Map<String, int> _completed = {};
  SharedPreferences? _prefs;

  /// Brings back finished parts, and keeps later ones on this device.
  void restore(SharedPreferences prefs) {
    _prefs = prefs;
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      for (final entry in decoded.entries) {
        if (entry.value is int) _completed['${entry.key}'] = entry.value as int;
      }
      notifyListeners();
    }
  }

  void _changed() {
    _prefs?.setString(_key, jsonEncode(_completed));
    notifyListeners();
  }

  int completedParts(String taskId) => _completed[taskId] ?? 0;

  bool isLearnTaskComplete(String taskId) {
    final need = LearnTaskChain.partCounts[taskId] ?? 0;
    return completedParts(taskId) >= need;
  }

  int get completedLearnTasks {
    var done = 0;
    for (final id in LearnTaskChain.taskOrder) {
      final need = LearnTaskChain.partCounts[id] ?? 0;
      if (completedParts(id) >= need) done++;
    }
    return done;
  }

  double get learnTasksProgress =>
      completedLearnTasks / LearnTaskChain.totalTasks;

  void completePart(String taskId, int index) {
    if (index != completedParts(taskId)) return;
    _completed[taskId] = index + 1;
    _changed();
  }

  void finishTask(String taskId, int partCount) {
    if (completedParts(taskId) >= partCount) return;
    _completed[taskId] = partCount;
    _changed();
  }

  @visibleForTesting
  void reset() {
    _completed.clear();
    _prefs = null;
    notifyListeners();
  }
}
