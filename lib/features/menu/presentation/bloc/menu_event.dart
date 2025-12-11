import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class LoadMenus extends MenuEvent {}

class SelectMenu extends MenuEvent {
  final int menuId;

  const SelectMenu(this.menuId);

  @override
  List<Object> get props => [menuId];
}
