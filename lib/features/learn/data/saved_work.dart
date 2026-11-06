import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artisnal_app/features/learn/data/learn_progress.dart';

/// Ready-made bios to copy. Instagram allows 150 characters.
const bioIdeas = <String>[
  'From my loom in Sualkuchi to your wardrobe · Made by hand, one piece at a time · Message me to order',
  'No two pieces are the same · Slow, handwoven cloth from Assam · Message me to order',
  'A weaver, not a factory · Real hands, real thread · Sualkuchi, Assam',
  'Cloth that takes days to weave and years to wear · Handloom from Assam',
  'See the loom, meet the weaver · New pieces and behind the scenes · Order on WhatsApp',
  'I weave what I love, you wear what lasts · Handmade in Assam · Message me to order',
];

/// Ready-made captions to copy.
const captionIdeas = <String>[
  'This one took days on my loom. I counted every motif by hand, thread by thread. Want to see it closer? Message me. #handloom #assam',
  'Look closely at the border. That small pattern is where I spent the most time. This is what handwoven means. #handwoven #weaverslife',
  'Which colour would you wear to your next celebration? Tell me in the comments and I will show you more. #handloom #assam',
  'A gift made by hand says more. Looking for someone special? Message me and I will help you choose. #handmadegifts #assam',
  'When you buy this, you support one weaver and one loom in Assam. Thank you for choosing handmade. #supportartisans #handloom',
  'Morning light, my loom and this cloth. This is how my day begins. What does yours look like? #weaverslife #madeinassam',
];

/// What the artisan wrote while practising, kept on this device so an earned
/// badge can show it again.
class SavedWork extends ChangeNotifier {
  SavedWork._();

  static final SavedWork instance = SavedWork._();

  static const _key = 'saved-work';

  SharedPreferences? _prefs;
  Map<String, String> _values = {};

  String? get name => _values['name'];
  String? get username => _values['username'];
  String? get category => _values['category'];
  String? get bio => _values['bio'];
  String? get caption => _values['caption'];
  String? get aiPrompt => _values['aiPrompt'];

  bool get hasPage => bio != null || name != null || username != null;

  /// Each part of the task saves what it has just had written.
  void savePage({
    String? name,
    String? username,
    String? category,
    String? bio,
  }) {
    _update({
      'name': ?name,
      'username': ?username,
      'category': ?category,
      'bio': ?bio,
    });
  }

  void saveCaption(String text) => _update({'caption': text});

  void saveAiPrompt(String text) => _update({'aiPrompt': text});

  void _update(Map<String, String> values) {
    _values = {..._values, ...values};
    _prefs?.setString(_key, jsonEncode(_values));
    notifyListeners();
  }

  void _restore(SharedPreferences prefs) {
    _prefs = prefs;
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      _values = {
        for (final entry in decoded.entries)
          if (entry.value is String) '${entry.key}': entry.value as String,
      };
    }
  }

  @visibleForTesting
  void reset() {
    _values = {};
    _prefs = null;
    notifyListeners();
  }
}

/// Brings back saved work and earned badges. If storage is unavailable the app
/// still opens, and simply forgets them when it closes.
Future<void> loadSavedData() async {
  try {
    final prefs = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 2),
    );
    SavedWork.instance._restore(prefs);
    LearnProgress.instance.restore(prefs);
  } catch (error) {
    debugPrint('Saved data not available: $error');
  }
}
