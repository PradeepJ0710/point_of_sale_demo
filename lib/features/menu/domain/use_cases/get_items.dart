import 'package:equatable/equatable.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/item.dart';
import '../repositories/i_menu_repository.dart';

class GetItems implements UseCase<List<Item>, GetItemsParams> {
  final IMenuRepository repository;

  GetItems(this.repository);

  @override
  Future<List<Item>> call(GetItemsParams params) async {
    return await repository.getItems(params.categoryId);
  }
}

class GetItemsParams extends Equatable {
  final int categoryId;

  const GetItemsParams({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}
