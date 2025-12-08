import '../../../../core/use_cases/use_case.dart';
import '../entities/order.dart';
import '../repositories/i_order_repository.dart';

class GetOrders implements UseCase<List<Order>, NoParams> {
  final IOrderRepository repository;

  GetOrders(this.repository);

  @override
  Future<List<Order>> call(NoParams params) async {
    return await repository.getOrders();
  }
}
