import 'package:flutter/foundation.dart';

class LearnProgress extends ChangeNotifier {
  LearnProgress._();

  static final LearnProgress instance = LearnProgress._();

  final Map<String, int> _completed = {};

  int completedParts(String taskId) => _completed[taskId] ?? 0;

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
