import 'package:flutter/foundation.dart';

/// One way of showing a piece to the camera.
///
/// [key] is the file stem shared by every material's photo of that display,
/// so the example shown on the card follows the material the artisan chose.
class DisplayOption {
  const DisplayOption({required this.name, required this.key});

  final String name;
  final String key;

  /// Example photo for this display.
  ///
  /// The default set is shot on a sari, so a product with its own photos is
  /// looked up first - otherwise a gamusa would be illustrated by a sari.
  String imageFor(String material, {String? product}) {
    const dir = 'assets/images/lessons/displays';
    final m = material.toLowerCase();
    if (_usesOwnPhoto(product, material)) {
      final slug = product!.toLowerCase().replaceAll(' ', '_');
      return '$dir/${slug}_${m}_$key.jpg';
    }
    return '$dir/${m}_$key.jpg';
  }

  /// Mekhala sador has its own Cotton, Mulberry, Eri, and Muga shots.
  bool _usesOwnPhoto(String? product, String material) {
    if (product != null && productsWithOwnPhotos.contains(product)) {
      return true;
    }
    return product == 'Mekhala sador' &&
        (material == 'Cotton' ||
            material == 'Mulberry' ||
            material == 'Eri' ||
            material == 'Muga');
  }
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
const _sofaSeated = DisplayOption(
  name: 'Sofa-Seated',
  key: 'sofa_seated_display',
);
const _flatLay = DisplayOption(
  name: 'Flat-Lay',
  key: 'flat_lay_display',
);

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

/// Products that have their own example photos for every display they offer.
/// Everything else falls back to the sari set.
const productsWithOwnPhotos = {
  'Gamusa',
  'Shawl',
  'Stole',
  'Cushion covers',
  'Jod kappur',
  'Yardages',
};

/// A jod kappur is shown folded or hanging. There is no full-display shot.
const _jodDisplays = <DisplayOption>[_folded, _hanging];

/// A cushion cover is shown on a sofa or laid flat.
const _cushionDisplays = <DisplayOption>[_sofaSeated, _flatLay];

/// Yardage is shown hanging or as a close-up of the weave.
const _yardageDisplays = <DisplayOption>[_hanging, _closeUp];

List<DisplayOption> displaysFor(String? product) {
  if (_drapedProducts.contains(product)) return everyDisplay;
  if (product == 'Jod kappur') return _jodDisplays;
  if (product == 'Cushion covers') return _cushionDisplays;
  if (product == 'Yardages') return _yardageDisplays;
  return basicDisplays;
}

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
