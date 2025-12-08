import '../../../../core/use_cases/use_case.dart';
import '../entities/menu.dart';
import '../repositories/i_menu_repository.dart';

class GetMenus implements UseCase<List<Menu>, NoParams> {
  final IMenuRepository repository;

  GetMenus(this.repository);

  @override
  Future<List<Menu>> call(NoParams params) async {
    return await repository.getMenus();
  }
}
