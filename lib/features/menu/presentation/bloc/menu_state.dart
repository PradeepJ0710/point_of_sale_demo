import 'package:equatable/equatable.dart';
import 'package:pos/features/menu/domain/entities/category.dart';
import 'package:pos/features/menu/domain/entities/item.dart';
import 'package:pos/features/menu/domain/entities/menu.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Menu> menus;
  final int selectedMenuId;
  final List<Category> categories;
  // Map of CategoryId -> List<Item>
  final Map<int, List<Item>> itemsByCategory;

  const MenuLoaded({required this.menus, required this.selectedMenuId, required this.categories, required this.itemsByCategory});

  @override
  List<Object> get props => [menus, selectedMenuId, categories, itemsByCategory];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object> get props => [message];
}
