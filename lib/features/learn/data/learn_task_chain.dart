import 'package:artisnal_app/features/learn/data/learn_tasks.dart';

/// Order of the five Learn home tasks and titles for "Next task" buttons.
class LearnTaskChain {
  LearnTaskChain._();

  static const createPostTaskId = 'create_post';

  static const _order = <String>[
    photographyTaskId,
    setUpPageTaskId,
    createPostTaskId,
    postingPlanTaskId,
    readNumbersTaskId,
  ];

  static const _titles = <String, String>{
    photographyTaskId: 'Photography',
    setUpPageTaskId: 'Set up your page',
    createPostTaskId: 'Create a post',
    postingPlanTaskId: 'Posting plan',
    readNumbersTaskId: 'Read the numbers',
  };

  static String titleFor(String taskId) => _titles[taskId] ?? taskId;

  /// Next learn-home task title, or null if [taskId] is the last task.
  static String? nextTaskTitle(String taskId) {
    final next = nextTaskId(taskId);
    return next == null ? null : titleFor(next);
  }

  /// Next task id in the Learn home sequence, or null if [taskId] is last.
  static String? nextTaskId(String taskId) {
    final index = _order.indexOf(taskId);
    if (index < 0 || index >= _order.length - 1) return null;
    return _order[index + 1];
  }
}
