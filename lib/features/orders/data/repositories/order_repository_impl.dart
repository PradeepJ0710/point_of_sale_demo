import '../../../../core/database/database_helper.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final DatabaseHelper databaseHelper;

  OrderRepositoryImpl(this.databaseHelper);

  @override
  Future<int> createOrder(Order order) async {
    final db = await databaseHelper.database;
    return await db.transaction((txn) async {
      // 1. Insert Header
      // We need to cast Order to OrderModel or use manual map here since we designed toHeaderMap in OrderModel
      // Ideally, the UseCase passes an Entity, so we map it here:
      final headerMap = {
        'order_date': order.orderDate,
        'order_status': order.orderStatus,
        'total_amount': (order.totalAmount * 100).round(),
      };

      final orderId = await txn.insert('order_headers', headerMap);

      // 2. Insert Items
      for (final item in order.items) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'item_id': item.itemId,
          'price': (item.price * 100).round(),
          'qty': item.quantity,
          'total': (item.total * 100).round(),
        });
      }

      return orderId;
    });
  }

  @override
  Future<List<Order>> getOrders() async {
    final db = await databaseHelper.database;

    // Fetch Headers
    final List<Map<String, dynamic>> headerMaps = await db.query(
      'order_headers',
      orderBy: 'order_date DESC',
    );

    List<Order> orders = [];

    for (final header in headerMaps) {
      final orderId = header['id'] as int;

      // Fetch Items for this Order
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items = itemMaps.map((map) {
        return OrderItem(
          itemId: map['item_id'] as int,
          price: (map['price'] as int) / 100.0,
          quantity: map['qty'] as int,
          total: (map['total'] as int) / 100.0,
        );
      }).toList();

      orders.add(OrderModel.fromRow(header, items));
    }

    return orders;
  }

  @override
  Future<int> processPayment(Payment payment) async {
    final db = await databaseHelper.database;

    // We can cast entity to model if we want to use toMap,
    // or just construct the map manually here to be safe and explicit.
    final paymentMap = {
      'payment_date': payment.paymentDate,
      'order_id': payment.orderId,
      'amount_due': (payment.amountDue * 100).round(),
      'tips': (payment.tips * 100).round(),
      'discount': (payment.discount * 100).round(),
      'total_paid': (payment.totalPaid * 100).round(),
      'payment_type': payment.paymentType,
      'payment_status': payment.paymentStatus,
    };

    return await db.transaction((txn) async {
      final paymentId = await txn.insert('payments', paymentMap);

      // Update Order Status to 'Completed' (or similar)
      await txn.update(
        'order_headers',
        {'order_status': 'Completed'},
        where: 'id = ?',
        whereArgs: [payment.orderId],
      );

      return paymentId;
    });
  }
}
