import 'package:pos/core/use_cases/use_case.dart';
import 'package:pos/features/orders/domain/repositories/i_order_repository.dart';
import 'package:pos/features/orders/domain/entities/order.dart';

class GetOrders implements UseCase<List<Order>, NoParams> {
  final IOrderRepository repository;

  GetOrders(this.repository);

  @override
  Future<List<Order>> call(NoParams params) async {
    // Repository implementation currently returns List<Order> directly (not Either)
    // We should probably wrap it, but for now matching existing repo style
    try {
      final orders = await repository.getOrders();
      return orders;
    } catch (e) {
      // If repo doesn't handle errors, we might need to change this.
      // Checking repo signature next.
      throw e;
    }
  }
}
