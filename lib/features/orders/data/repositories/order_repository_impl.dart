import '../../../../core/database/database_helper.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final DatabaseHelper databaseHelper;

  OrderRepositoryImpl(this.databaseHelper);

  @override
  Future<int> createOrder(Order order, {Payment? payment}) async {
    final db = await databaseHelper.database;

    return await db.transaction((txn) async {
      // 1. Insert Header
      final headerMap = {
        'order_date': order.orderDate,
        'order_status': payment != null ? 'Completed' : order.orderStatus,
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

      // 3. Insert Payment if provided
      if (payment != null) {
        final paymentMap = {
          'payment_date': payment.paymentDate,
          'order_id': orderId, // Link to the new order
          'amount_due': (payment.amountDue * 100).round(),
          'tips': (payment.tips * 100).round(),
          'discount': (payment.discount * 100).round(),
          'total_paid': (payment.totalPaid * 100).round(),
          'payment_type': payment.paymentType,
          'payment_status': 'Completed',
        };
        await txn.insert('payments', paymentMap);
      }

      return orderId;
    });
  }

  @override
  Future<List<Order>> getOrders() async {
    final db = await databaseHelper.database;

    // Use COALESCE to ensure non-null payment_type for OrderModel safety
    final List<Map<String, dynamic>> headerMaps = await db.rawQuery('''
      SELECT h.*, COALESCE(p.payment_type, 'Unpaid') as payment_type 
      FROM order_headers h
      LEFT JOIN payments p ON h.id = p.order_id
      ORDER BY h.order_date DESC
    ''');

    List<Order> orders = [];

    for (final header in headerMaps) {
      final orderId = header['id'] as int;

      // Fetch Items for this Order with Name
      final List<Map<String, dynamic>> itemMaps = await db.rawQuery(
        '''
        SELECT oi.*, i.name as item_name 
        FROM order_items oi 
        LEFT JOIN item i ON oi.item_id = i.id 
        WHERE oi.order_id = ?
      ''',
        [orderId],
      );

      final items = itemMaps.map((map) {
        return OrderItem(
          itemId: map['item_id'] as int,
          itemName: map['item_name'] as String? ?? 'Unknown Item',
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
