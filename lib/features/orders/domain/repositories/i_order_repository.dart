import '../../domain/entities/order.dart';
import '../../domain/entities/payment.dart';

abstract class IOrderRepository {
  Future<int> createOrder(Order order, {Payment? payment});
  Future<List<Order>> getOrders();
  Future<int> processPayment(Payment payment);
}
