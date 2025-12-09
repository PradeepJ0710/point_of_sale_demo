import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.menuId,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int,
      name: map['name'] as String,
      menuId: map['menu_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'menu_id': menuId};
  }
}
