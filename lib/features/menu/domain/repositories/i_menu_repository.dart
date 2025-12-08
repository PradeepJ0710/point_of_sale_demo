import '../entities/menu.dart';
import '../entities/category.dart';
import '../entities/item.dart';

abstract class IMenuRepository {
  /// Fetches all available menus (e.g., Food, Drinks).
  Future<List<Menu>> getMenus();

  /// Fetches all categories for a specific menu.
  Future<List<Category>> getCategories(int menuId);

  /// Fetches all items for a specific category.
  Future<List<Item>> getItems(int categoryId);
}
