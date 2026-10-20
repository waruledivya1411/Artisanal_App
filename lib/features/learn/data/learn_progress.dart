import 'package:flutter/foundation.dart';

import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';

class LearnProgress extends ChangeNotifier {
  LearnProgress._();

  static final LearnProgress instance = LearnProgress._();

  final Map<String, int> _completed = {};

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
    notifyListeners();
  }

  void finishTask(String taskId, int partCount) {
    if (completedParts(taskId) >= partCount) return;
    _completed[taskId] = partCount;
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _completed.clear();
    notifyListeners();
  }
}
