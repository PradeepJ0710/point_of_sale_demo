import '../../domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.menuId,
    required super.price,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int,
      name: map['name'] as String,
      categoryId: map['cat_id'] as int,
      menuId: map['menu_id'] as int,
      // CONVERSION: Database (Pence/Integer) -> Domain (Pounds/Double)
      price: (map['price'] as int) / 100.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cat_id': categoryId,
      'menu_id': menuId,
      // CONVERSION: Domain (Pounds/Double) -> Database (Pence/Integer)
      'price': (price * 100).round(),
    };
  }
}
