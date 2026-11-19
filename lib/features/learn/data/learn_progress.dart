import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';

class LearnProgress extends ChangeNotifier {
  LearnProgress._();

  static final LearnProgress instance = LearnProgress._();

  static const _key = 'learn-progress';
  static const _anyOrderKey = 'learn-parts-done';

  final Map<String, int> _completed = {};

  /// Parts finished out of order, in tasks whose parts can be done in any
  /// order. [_completed] still counts the parts done from the start.
  final Map<String, Set<int>> _doneOutOfOrder = {};
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
    }
    final rawParts = prefs.getString(_anyOrderKey);
    final parts = rawParts == null ? null : jsonDecode(rawParts);
    if (parts is Map) {
      for (final entry in parts.entries) {
        if (entry.value is List) {
          _doneOutOfOrder['${entry.key}'] = {
            for (final index in entry.value as List)
              if (index is int) index,
          };
        }
      }
    }
    notifyListeners();
  }

  void _changed() {
    _prefs?.setString(_key, jsonEncode(_completed));
    _prefs?.setString(
      _anyOrderKey,
      jsonEncode({
        for (final entry in _doneOutOfOrder.entries)
          entry.key: entry.value.toList()..sort(),
      }),
    );
    notifyListeners();
  }

  bool isPartDone(String taskId, int index) =>
      index < completedParts(taskId) ||
      (_doneOutOfOrder[taskId]?.contains(index) ?? false);

  /// For tasks whose parts can be done in any order: marks one part, and
  /// counts the task done once every part is.
  void markPartDone(String taskId, int index) {
    if (isPartDone(taskId, index)) return;
    final done = _doneOutOfOrder.putIfAbsent(taskId, () => {})..add(index);
    var count = completedParts(taskId);
    while (done.remove(count)) {
      count++;
    }
    _completed[taskId] = count;
    if (done.isEmpty) _doneOutOfOrder.remove(taskId);
    _changed();
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
    _doneOutOfOrder.clear();
    _prefs = null;
    notifyListeners();
  }
}
