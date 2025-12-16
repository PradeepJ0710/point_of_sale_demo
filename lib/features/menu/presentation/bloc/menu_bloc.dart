import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/use_cases/use_case.dart';
import 'package:pos/features/menu/domain/entities/category.dart';
import 'package:pos/features/menu/domain/entities/item.dart';
import 'package:pos/features/menu/domain/entities/menu.dart';
import 'package:pos/features/menu/domain/use_cases/get_categories.dart';
import 'package:pos/features/menu/domain/use_cases/get_items.dart';
import 'package:pos/features/menu/domain/use_cases/get_menus.dart';

import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenus getMenus;
  final GetCategories getCategories;
  final GetItems getItems;

  MenuBloc({
    required this.getMenus,
    required this.getCategories,
    required this.getItems,
  }) : super(MenuInitial()) {
    on<LoadMenus>(_onLoadMenus);
    on<SelectMenu>(_onSelectMenu);
  }

  Future<void> _onLoadMenus(LoadMenus event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final menus = await getMenus(NoParams());
      if (menus.isEmpty) {
        emit(const MenuError("No menus found."));
        return;
      }

      final firstMenuId = menus.first.id;
      final content = await _fetchMenuContent(firstMenuId);

      emit(
        MenuLoaded(
          menus: menus,
          selectedMenuId: firstMenuId,
          categories: content.categories,
          itemsByCategory: content.itemsMap,
        ),
      );
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onSelectMenu(SelectMenu event, Emitter<MenuState> emit) async {
    // Avoid reload if already selected (Optimization)
    if (state is MenuLoaded &&
        (state as MenuLoaded).selectedMenuId == event.menuId) {
      return;
    }

    try {
      List<Menu> menus = [];
      if (state is MenuLoaded) {
        menus = (state as MenuLoaded).menus;
      } else {
        menus = await getMenus(NoParams());
      }

      final content = await _fetchMenuContent(event.menuId);

      emit(
        MenuLoaded(
          menus: menus,
          selectedMenuId: event.menuId,
          categories: content.categories,
          itemsByCategory: content.itemsMap,
        ),
      );
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<({List<Category> categories, Map<int, List<Item>> itemsMap})>
  _fetchMenuContent(int menuId) async {
    final categories = await getCategories(GetCategoriesParams(menuId: menuId));

    final Map<int, List<Item>> itemsMap = {};

    for (final category in categories) {
      final items = await getItems(GetItemsParams(categoryId: category.id));
      itemsMap[category.id] = items;
    }

    return (categories: categories, itemsMap: itemsMap);
  }
}
