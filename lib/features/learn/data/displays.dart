import 'package:flutter/foundation.dart';

/// One way of showing a piece to the camera.
///
/// [key] is the file stem shared by every material's photo of that display,
/// so the example shown on the card follows the material the artisan chose.
class DisplayOption {
  const DisplayOption({required this.name, required this.key});

  final String name;
  final String key;

  String imageFor(String material) =>
      'assets/images/lessons/displays/${material.toLowerCase()}_$key.jpg';
}

const _fullDisplay = DisplayOption(name: 'Full display', key: 'full_display');
const _closeUp = DisplayOption(
  name: 'Close-up texture',
  key: 'close-up_texture',
);
const _draped = DisplayOption(name: 'Draped', key: 'draped_look');
const _border = DisplayOption(
  name: 'Embroidery and border',
  key: 'embroidery_and_border',
);
const _folded = DisplayOption(name: 'Folded', key: 'folded_stack');
const _hanging = DisplayOption(name: 'Hanging', key: 'hanging_display');

/// A draped garment can be shown every way.
const everyDisplay = <DisplayOption>[
  _fullDisplay,
  _closeUp,
  _draped,
  _border,
  _folded,
  _hanging,
];

/// Everything else is shown flat or folded.
const basicDisplays = <DisplayOption>[_fullDisplay, _folded];

const _drapedProducts = {'Saree', 'Mekhala sador'};

List<DisplayOption> displaysFor(String? product) =>
    _drapedProducts.contains(product) ? everyDisplay : basicDisplays;

class SelectedDisplay extends ChangeNotifier {
  SelectedDisplay._();

  static final SelectedDisplay instance = SelectedDisplay._();

  String? _name;

  String? get name => _name;

  void select(String name) {
    if (name == _name) return;
    _name = name;
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _name = null;
    notifyListeners();
  }
}
