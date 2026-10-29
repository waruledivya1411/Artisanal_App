import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A yarn the artisan weaves with.
///
/// [image] is the photo shown on the picker card. The files live in the
/// photography lesson folder, which `pubspec.yaml` already bundles, so adding
/// a real photo under that name is all it takes to replace the drawn
/// [swatch] fallback.
class MaterialOption {
  const MaterialOption({
    required this.name,
    required this.image,
    required this.swatch,
  });

  final String name;
  final String image;
  final Color swatch;
}

const photographyMaterials = <MaterialOption>[
  MaterialOption(
    name: 'Cotton',
    image: 'assets/images/lessons/photography/material_cotton.jpg',
    swatch: Color(0xFFE6DFD0),
  ),
  MaterialOption(
    name: 'Mulberry',
    image: 'assets/images/lessons/photography/material_mulberry.jpg',
    swatch: Color(0xFFF0E9DC),
  ),
  MaterialOption(
    name: 'Tussar',
    image: 'assets/images/lessons/photography/material_tussar.jpg',
    swatch: Color(0xFFC9A063),
  ),
  MaterialOption(
    name: 'Muga',
    image: 'assets/images/lessons/photography/material_muga.jpg',
    swatch: Color(0xFFBE8A32),
  ),
  MaterialOption(
    name: 'Eri',
    image: 'assets/images/lessons/photography/material_eri.jpg',
    swatch: Color(0xFFDED2BE),
  ),
];

/// Yarns each product is actually woven in. Anything not listed here is
/// offered in every material.
const _materialsByProduct = <String, Set<String>>{
  'Saree': {'Cotton'},
  'Mekhala sador': {'Mulberry'},
  'Gamusa': {'Cotton', 'Mulberry', 'Tussar'},
  'Stole': {'Cotton', 'Eri'},
  'Shawl': {'Cotton', 'Eri'},
  'Cushion covers': {'Cotton', 'Mulberry', 'Tussar', 'Muga', 'Eri'},
  'Jod kappur': {'Cotton'},
  'Yardages': {'Cotton'},
};

/// Materials to offer for [product], in the usual order.
List<MaterialOption> materialsFor(String? product) {
  final allowed = _materialsByProduct[product];
  if (allowed == null) return photographyMaterials;
  return photographyMaterials.where((m) => allowed.contains(m.name)).toList();
}

class SelectedMaterial extends ChangeNotifier {
  SelectedMaterial._();

  static final SelectedMaterial instance = SelectedMaterial._();

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
