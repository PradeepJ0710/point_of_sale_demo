import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final int menuId;

  const Category({required this.id, required this.name, required this.menuId});

  @override
  List<Object?> get props => [id, name, menuId];
}
