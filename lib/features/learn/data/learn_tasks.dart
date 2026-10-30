import 'package:flutter/material.dart';

import 'package:artisnal_app/features/learn/screens/check_part_screen.dart';
import 'package:artisnal_app/features/learn/screens/display_picker_screen.dart';
import 'package:artisnal_app/features/learn/screens/find_numbers_screen.dart';
import 'package:artisnal_app/features/learn/screens/learn_part_screen.dart';
import 'package:artisnal_app/features/learn/data/materials.dart';
import 'package:artisnal_app/features/learn/data/products.dart';
import 'package:artisnal_app/features/learn/screens/numbers_mean_screen.dart';
import 'package:artisnal_app/features/learn/screens/product_picker_screen.dart';
import 'package:artisnal_app/features/learn/screens/task_parts_screen.dart';
import 'package:artisnal_app/features/learn/screens/professional_part_screen.dart';
import 'package:artisnal_app/features/learn/screens/setup_try_it_flow_screen.dart';

/// Shared by every route of the photography setup, so finishing the last
/// step can pop back past all of them in one go.
const photographySetupRoute = 'photography-setup';

const photographyTaskId = 'photography';
const setUpPageTaskId = 'set_up_page';
const postingPlanTaskId = 'posting_plan';
const readNumbersTaskId = 'read_numbers';

ProductPickerScreen photographyEntry(String locale) {
  return ProductPickerScreen(
    locale: locale,
    taskLabel: 'TASK 1 OF 5',
    onPicked: (_) {
      // Each product is woven in one yarn, so there is nothing to ask: its
      // material is set and the shoot goes straight to the displays.
      SelectedMaterial.instance.select(
        materialFor(SelectedProduct.instance.name),
      );
      return photographyDisplayPicker(locale);
    },
  );
}

DisplayPickerScreen photographyDisplayPicker(String locale) {
  return DisplayPickerScreen(
    locale: locale,
    taskLabel: 'TASK 1 OF 5',
    product: SelectedProduct.instance.name,
    material: SelectedMaterial.instance.name,
  );
}

TaskPartsScreen photographyTask(String locale) {
  return TaskPartsScreen(
    locale: locale,
    taskId: photographyTaskId,
    taskLabel: 'TASK 1 OF 5',
    title: 'Photography',
    parts: [
      TaskPart(
        '1',
        'Hold steady',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'PART 1 · HOLD STEADY',
          title: 'Hold with two hands',
          image: 'assets/images/lessons/photography/hold_steady_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'PART 1 · HOLD STEADY',
            wrong: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_shaky.jpg',
              label: 'Shaky',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_steady.jpg',
              label: 'Steady',
            ),
            rightReason: 'Sharp photos sell better',
            wrongReason: 'Shaky photos look blurry',
          ),
        ),
      ),
      TaskPart(
        '2',
        'Plain sheet',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'PART 2 · PLAIN SHEET',
          title: 'Put a plain sheet behind',
          image: 'assets/images/lessons/photography/plain_sheet_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'PART 2 · PLAIN SHEET',
            wrong: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_messy.jpg',
              label: 'Messy',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_steady.jpg',
              label: 'Plain',
            ),
            rightReason: 'The cloth stands out',
            wrongReason: 'A messy background hides the cloth',
          ),
        ),
      ),
      TaskPart(
        '3',
        'Window light',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'PART 3 · WINDOW LIGHT',
          title: 'Stand near a window',
          image: 'assets/images/lessons/photography/window_light_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'PART 3 · WINDOW LIGHT',
            wrong: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_dark.jpg',
              label: 'Dark corner',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_window.jpg',
              label: 'Near window',
            ),
            rightReason: 'True colours by the window',
            wrongReason: 'A dark corner makes colours dull',
          ),
        ),
      ),
      TaskPart(
        '4',
        'Straight angle',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'PART 4 · STRAIGHT ANGLE',
          title: 'Hold the phone straight',
          image: 'assets/images/lessons/photography/straight_angle_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'PART 4 · STRAIGHT ANGLE',
            wrong: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_tilted.jpg',
              label: 'Tilted',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/photography/fabric_straight.jpg',
              label: 'Straight',
            ),
            rightReason: 'Shows the full cloth',
            wrongReason: 'A tilted photo cuts off the cloth',
          ),
        ),
      ),
    ],
  );
}

TaskPartsScreen setUpPageTask(String locale) {
  return TaskPartsScreen(
    locale: locale,
    taskId: setUpPageTaskId,
    taskLabel: 'TASK 2 OF 5',
    title: 'Set up your page',
    showChevron: true,
    parts: [
      TaskPart(
        '1',
        'Good name',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'TASK 2 · PART 1 · GOOD NAME',
          title: 'Short name with your craft',
          image: 'assets/images/lessons/set_up_page/good_name_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'TASK 2 · PART 1 · GOOD NAME',
            wrong: const CheckOption(
              text: '@divya_w_\n1987_xyz',
              label: 'Long',
            ),
            right: const CheckOption(text: '@divya\n.weaves', label: 'Short'),
            rightReason: 'Easy to say and find',
            wrongReason: 'Long names are hard to remember',
          ),
        ),
      ),
      TaskPart(
        '2',
        'Clear photo',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'TASK 2 · PART 2 · CLEAR PHOTO',
          title: 'Use your face or your loom',
          image: 'assets/images/lessons/set_up_page/clear_photo_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'TASK 2 · PART 2 · CLEAR PHOTO',
            wrong: const CheckOption(
              image: 'assets/images/lessons/set_up_page/profile_blurry.jpg',
              caption: 'divya.weaves',
              label: 'Blurry',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/set_up_page/profile_clear.jpg',
              caption: 'divya.weaves',
              label: 'Clear',
            ),
            rightReason: 'Buyers trust a clear face',
            wrongReason: 'A blurry photo hides who you are',
          ),
        ),
      ),
      TaskPart(
        '3',
        'Professional',
        open: (_) => ProfessionalPartScreen(locale: locale),
      ),
      TaskPart(
        '4',
        'Try it',
        showOnList: false,
        open: (_) => SetupTryItFlowScreen(locale: locale),
      ),
    ],
  );
}

TaskPartsScreen postingPlanTask(String locale) {
  return TaskPartsScreen(
    locale: locale,
    taskId: postingPlanTaskId,
    taskLabel: 'TASK 4 OF 5',
    title: 'Posting plan',
    showChevron: true,
    parts: [
      TaskPart(
        '1',
        'Post often',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'TASK 4 · PART 1 · POST OFTEN',
          title: 'Post 3 times a week',
          image: 'assets/images/lessons/posting_plan/post_often_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'TASK 4 · PART 1 · POST OFTEN',
            wrong: const CheckOption(
              image: 'assets/images/lessons/posting_plan/calendar_rarely.jpg',
              caption: '1 a month',
              roundImage: false,
              label: 'Rarely',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/posting_plan/calendar_often.jpg',
              caption: '3 a week',
              roundImage: false,
              label: 'Often',
            ),
            rightReason: 'People remember you',
            wrongReason: 'People forget pages that post rarely',
          ),
        ),
      ),
      TaskPart(
        '2',
        'Good time',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'TASK 4 · PART 2 · GOOD TIME',
          title: 'Post in the evening',
          image: 'assets/images/lessons/posting_plan/good_time_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'TASK 4 · PART 2 · GOOD TIME',
            wrong: const CheckOption(
              label: '2 am',
              tile: CheckTile(
                icon: Icons.bedtime_outlined,
                title: '2 am',
                subtitle: 'All asleep',
                background: Color(0xFF16231F),
                iconColor: Color(0xFFC9D2CF),
                titleColor: Colors.white,
                subtitleColor: Color(0xFFAAB5B2),
              ),
            ),
            right: const CheckOption(
              label: '7 pm',
              tile: CheckTile(
                icon: Icons.wb_twilight_rounded,
                title: '7 pm',
                subtitle: 'Buyers online',
                background: Color(0xFFFBF1E3),
                iconColor: Color(0xFFB07A1F),
                titleColor: Color(0xFF152322),
                subtitleColor: Color(0xFF4F5F5D),
              ),
            ),
            rightReason: 'More people see it',
            wrongReason: 'At 2 am most people are asleep',
          ),
        ),
      ),
      TaskPart(
        '3',
        'Mix posts',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'TASK 4 · PART 3 · MIX POSTS',
          title: 'Cloth, work, then price',
          image: 'assets/images/lessons/posting_plan/mix_posts_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'TASK 4 · PART 3 · MIX POSTS',
            wrong: const CheckOption(
              image: 'assets/images/lessons/posting_plan/posts_same.jpg',
              contain: true,
              label: 'Same photo',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/posting_plan/posts_mixed.jpg',
              contain: true,
              label: 'Mixed',
            ),
            rightReason: 'Every post shows something new',
            wrongReason: 'The same photo again gets boring',
          ),
        ),
      ),
    ],
  );
}

TaskPartsScreen readNumbersTask(String locale) {
  return TaskPartsScreen(
    locale: locale,
    taskId: readNumbersTaskId,
    taskLabel: 'TASK 5 OF 5',
    title: 'Read the numbers',
    showChevron: true,
    parts: [
      TaskPart(
        '1',
        'Saves matter',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'TASK 5 · PART 1 · SAVES MATTER',
          title: 'Saves mean buyers',
          image: 'assets/images/lessons/read_numbers/saves_matter_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'TASK 5 · PART 1 · SAVES MATTER',
            wrong: const CheckOption(
              image: 'assets/images/lessons/read_numbers/post_only_likes.jpg',
              stats: [
                CheckStat(Icons.favorite_border_rounded, '120 likes'),
                CheckStat(Icons.bookmark_border_rounded, '0 saves'),
              ],
              label: 'Only likes',
            ),
            right: const CheckOption(
              image: 'assets/images/lessons/read_numbers/post_many_saves.jpg',
              stats: [
                CheckStat(Icons.favorite_border_rounded, '60 likes'),
                CheckStat(Icons.bookmark_border_rounded, '18 saves'),
              ],
              label: 'Many saves',
            ),
            rightReason: 'Saves show they want to buy',
            wrongReason: 'Likes alone do not bring buyers',
          ),
        ),
      ),
      TaskPart(
        '2',
        'Reply fast',
        open: (_) => LearnPartScreen(
          locale: locale,
          partLabel: 'TASK 5 · PART 2 · REPLY FAST',
          title: 'Reply the same day',
          image: 'assets/images/lessons/read_numbers/reply_fast_art.jpg',
          nextBuilder: (_) => CheckPartScreen(
            locale: locale,
            partLabel: 'TASK 5 · PART 2 · REPLY FAST',
            wrong: const CheckOption(
              chat: CheckChat(
                image:
                    'assets/images/lessons/read_numbers/reply_cloth_post.jpg',
                question: 'Price please?',
                time: 'After 3 days',
                reply: '₹4,500',
              ),
              label: 'Late',
            ),
            right: const CheckOption(
              chat: CheckChat(
                image:
                    'assets/images/lessons/read_numbers/reply_cloth_post.jpg',
                question: 'Price please?',
                time: 'In 1 hour',
                reply: '₹4,500',
              ),
              label: 'Fast',
            ),
            rightReason: 'Fast replies make sales',
            wrongReason: 'Buyers leave when you reply late',
          ),
        ),
      ),
      TaskPart(
        '3',
        'What they mean',
        open: (_) => NumbersMeanScreen(
          locale: locale,
          nextBuilder: (_) => FindNumbersScreen(
            locale: locale,
            taskId: readNumbersTaskId,
            partCount: 3,
          ),
        ),
      ),
    ],
  );
}
