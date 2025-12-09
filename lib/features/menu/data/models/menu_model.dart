import '../../domain/entities/menu.dart';

class MenuModel extends Menu {
  const MenuModel({required super.id, required super.name});

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(id: map['id'] as int, name: map['name'] as String);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
