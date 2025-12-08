import 'package:equatable/equatable.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/category.dart';
import '../repositories/i_menu_repository.dart';

class GetCategories implements UseCase<List<Category>, GetCategoriesParams> {
  final IMenuRepository repository;

  GetCategories(this.repository);

  @override
  Future<List<Category>> call(GetCategoriesParams params) async {
    return await repository.getCategories(params.menuId);
  }
}

class GetCategoriesParams extends Equatable {
  final int menuId;

  const GetCategoriesParams({required this.menuId});

  @override
  List<Object> get props => [menuId];
}
