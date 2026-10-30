import 'package:flutter/foundation.dart';

/// The yarn each product is woven in. It picks the product's example photos;
/// there is no choice to make, so the artisan is never asked.
const _materialByProduct = <String, String>{
  'Saree': 'Cotton',
  'Mekhala sador': 'Mulberry',
  'Gamusa': 'Cotton',
  'Stole': 'Eri',
  'Shawl': 'Eri',
  'Cushion covers': 'Mulberry',
  'Jod kappur': 'Cotton',
  'Yardages': 'Cotton',
};

/// The yarn [product] is woven in.
String materialFor(String? product) => _materialByProduct[product] ?? 'Cotton';

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
