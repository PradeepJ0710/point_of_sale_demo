import '../../../../core/database/database_helper.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import '../../domain/repositories/i_menu_repository.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';
import '../models/menu_model.dart';

class MenuRepositoryImpl implements IMenuRepository {
  final DatabaseHelper databaseHelper;

  MenuRepositoryImpl(this.databaseHelper);

  @override
  Future<List<Menu>> getMenus() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('menu');
    return List.generate(maps.length, (i) => MenuModel.fromMap(maps[i]));
  }

  @override
  Future<List<Category>> getCategories(int menuId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category',
      where: 'menu_id = ?',
      whereArgs: [menuId],
    );
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  @override
  Future<List<Item>> getItems(int categoryId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'item',
      where: 'cat_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => ItemModel.fromMap(maps[i]));
  }
}
