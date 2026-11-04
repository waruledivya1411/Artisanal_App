import 'package:artisnal_app/features/learn/data/learn_tasks.dart';

/// Order of the Learn home tasks and titles for "Next task" buttons.
class LearnTaskChain {
  LearnTaskChain._();

  static const createPostTaskId = 'create_post';

  static const taskOrder = <String>[
    photographyTaskId,
    setUpPageTaskId,
    createPostTaskId,
    postingPlanTaskId,
    readNumbersTaskId,
    aiPhotosTaskId,
  ];

  static const _order = taskOrder;

  /// Parts required to count a Learn home task as fully done (badge / last step).
  static const partCounts = <String, int>{
    photographyTaskId: 6,
    setUpPageTaskId: 4,
    createPostTaskId: 3,
    postingPlanTaskId: 3,
    readNumbersTaskId: 3,
    aiPhotosTaskId: 1,
  };

  static int get totalTasks => taskOrder.length;

  static const _titles = <String, String>{
    photographyTaskId: 'Photography',
    setUpPageTaskId: 'Set up your page',
    createPostTaskId: 'Create a post',
    postingPlanTaskId: 'Posting plan',
    readNumbersTaskId: 'Read the numbers',
    aiPhotosTaskId: 'AI photos',
  };

  static String titleFor(String taskId) => _titles[taskId] ?? taskId;

  static const _badgeLines = <String, String>{
    photographyTaskId: 'Sharp photos sell better',
    setUpPageTaskId:
        'You practiced your name, bio, category, and pro page on Instagram.',
    createPostTaskId: 'You practiced Post, Story, and Reel on Instagram.',
    postingPlanTaskId: 'People remember you',
    readNumbersTaskId: 'You can read views, likes, saves and messages.',
    aiPhotosTaskId: 'You can use AI and keep your product the same.',
  };

  /// The line under a badge.
  static String badgeLineFor(String taskId) => _badgeLines[taskId] ?? 'Done';

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
