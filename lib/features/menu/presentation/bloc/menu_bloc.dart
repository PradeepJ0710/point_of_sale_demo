import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/use_cases/use_case.dart';
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
      // Automatically select the first menu (e.g. Food)
      add(SelectMenu(menus.first.id));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onSelectMenu(SelectMenu event, Emitter<MenuState> emit) async {
    // We need to keep the list of menus if we are already in Loaded state,
    // or fetch them if we came from somewhere else (though usually LoadMenus handles that).
    // For simplicity, we'll re-fetch everything or assume we have the list if we check state.
    // However, to be robust, let's just re-fetch the Menus list from the repository
    // OR ideally we persist the 'menus' list in the event or state.
    // A cleaner way relies on the previous state.

    List<Menu> menus = [];
    if (state is MenuLoaded) {
      menus = (state as MenuLoaded).menus;
    } else {
      // Logic gap: If we call SelectMenu directly without LoadMenus, we might miss the menus list.
      // But typically LoadMenus calls this.
      // Let's safe-guard:
      final menusResult = await getMenus(NoParams());
      menus = menusResult;
    }

    // emit(MenuLoading());

    try {
      final categories = await getCategories(
        GetCategoriesParams(menuId: event.menuId),
      );

      final Map<int, List<Item>> itemsMap = {};

      // Parallel fetch items for all categories
      // Or sequential. Sequential is safer for SQLite usually, though sqflite handles concurrency relatively well.
      for (final category in categories) {
        final items = await getItems(GetItemsParams(categoryId: category.id));
        itemsMap[category.id] = items;
      }

      emit(
        MenuLoaded(
          menus: menus,
          selectedMenuId: event.menuId,
          categories: categories,
          itemsByCategory: itemsMap,
        ),
      );
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
