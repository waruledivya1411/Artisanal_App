import 'package:flutter/foundation.dart';

/// Something the artisan weaves and sells.
class ProductOption {
  const ProductOption({required this.name, required this.image});

  final String name;

  /// Photo of the product, from the Kamrup & Nalbari set.
  final String image;
}

const _dir = 'assets/images/lessons/products';

const photographyProducts = <ProductOption>[
  ProductOption(name: 'Saree', image: '$_dir/product_saree.jpg'),
  ProductOption(
    name: 'Mekhala sador',
    image: '$_dir/product_mekhala_sador.jpg',
  ),
  ProductOption(name: 'Stole', image: '$_dir/product_stole.jpg'),
  ProductOption(name: 'Gamusa', image: '$_dir/product_gamusa.jpg'),
  ProductOption(name: 'Shawl', image: '$_dir/product_shawl.jpg'),
  ProductOption(name: 'Jod kappur', image: '$_dir/product_jod_kappur.jpg'),
  ProductOption(name: 'Yardages', image: '$_dir/product_yardages.jpg'),
  ProductOption(
    name: 'Cushion covers',
    image: '$_dir/product_cushion_covers.jpg',
  ),
];

class SelectedProduct extends ChangeNotifier {
  SelectedProduct._();

  static final SelectedProduct instance = SelectedProduct._();

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
