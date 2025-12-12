import '../../domain/entities/order.dart';
import '../../domain/entities/payment.dart';

abstract class IOrderRepository {
  Future<int> createOrder(Order order);
  Future<List<Order>> getOrders();
  Future<int> processPayment(Payment payment);
}
