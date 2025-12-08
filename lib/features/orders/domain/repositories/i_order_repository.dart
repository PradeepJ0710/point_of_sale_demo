import '../entities/order.dart';
import '../entities/payment.dart';

abstract class IOrderRepository {
  /// Creates a new order and returns the Order ID.
  Future<int> createOrder(Order order);

  /// Fetches the list of all past orders.
  Future<List<Order>> getOrders();

  /// Records a payment for an order and updates the order status.
  Future<int> processPayment(Payment payment);
}
