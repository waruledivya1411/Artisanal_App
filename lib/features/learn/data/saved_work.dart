import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artisnal_app/features/learn/data/learn_progress.dart';

/// Ready-made bios to copy. Instagram allows 150 characters.
const bioIdeas = <String>[
  'Handwoven in Sualkuchi, Assam · Sarees and mekhela sador · Order on WhatsApp',
  'Weaving by hand since 2010 · Sualkuchi, Assam · Message me to order',
  'Every piece made by hand on my own loom · Assam · Message me to order',
  'Handloom from Assam, woven by me · New pieces every week · Order on WhatsApp',
];

/// Ready-made captions to copy.
const captionIdeas = <String>[
  'Woven by hand in Sualkuchi, Assam. Every motif takes hours on the loom. Message me to order. #handloom #assam',
  'New on my loom. Soft, handwoven and ready to wear. Message me for the price. #handwoven #assam',
  'Made for your special day. Woven by hand, one thread at a time. Order on WhatsApp. #handloom #sualkuchi',
  'Save this post for your next festival. Handwoven in Assam, made by me. #handloom #madeinassam',
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

  void savePage({
    required String name,
    required String username,
    required String category,
    required String bio,
  }) {
    _update({
      'name': name,
      'username': username,
      'category': category,
      'bio': bio,
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
