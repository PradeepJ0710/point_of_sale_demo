import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/domain/entities/payment.dart';

/// Runs manual verification tests on the actual Android SQLite database.
Future<void> verifyDataLayer() async {
  debugPrint('--- STARTING DATA LAYER VERIFICATION ---');

  final dbHelper = DatabaseHelper.instance;
  final menuRepo = MenuRepositoryImpl(dbHelper);
  final orderRepo = OrderRepositoryImpl(dbHelper);

  try {
    // -------------------------------------------------------------------------
    // TEST 1: Menu Repository
    // -------------------------------------------------------------------------
    debugPrint('TEST 1: Menu Repository (Seeding Check)');
    final menus = await menuRepo.getMenus();
    _expect(menus.length, 2, 'Menu Count');

    final foodCategories = await menuRepo.getCategories(1);
    _expect(foodCategories.length >= 2, true, 'Food Categories Count');

    final starterItems = await menuRepo.getItems(1);
    _expect(starterItems.isNotEmpty, true, 'Starter Items Count');
    _expect(
      starterItems[0].price,
      1.50,
      'Item1 Price Conversion (150 -> 1.50)',
    );

    debugPrint('✅ Test 1 Passed');

    // -------------------------------------------------------------------------
    // TEST 2: Order Repository (Create & Fetch)
    // -------------------------------------------------------------------------
    debugPrint('TEST 2: Order Repository (Create & Fetch)');
    final newOrder = Order(
      id: 0,
      orderDate: DateTime.now().toIso8601String(),
      orderId: 0,
      orderStatus: 'Pending',
      totalAmount: 5.50,
      paymentType: 'Card',
      items: const [
        OrderItem(
          itemId: 101,
          itemName: 'Test Item 1',
          price: 10.0,
          quantity: 2,
          total: 20.0,
        ),
        OrderItem(
          itemId: 102,
          itemName: 'Test Item 2',
          price: 5.0,
          quantity: 1,
          total: 5.0,
        ),
      ],
    );

    final createdId = await orderRepo.createOrder(newOrder);
    debugPrint('Created Order ID: $createdId');

    final orders = await orderRepo.getOrders();
    final savedOrder = orders.firstWhere((o) => o.id == createdId);

    _expect(savedOrder.totalAmount, 5.50, 'Order Total');
    _expect(savedOrder.items.length, 2, 'Order Items Count');

    debugPrint('✅ Test 2 Passed');

    // -------------------------------------------------------------------------
    // TEST 3: Payment Process & Status Update
    // -------------------------------------------------------------------------
    debugPrint('TEST 3: Payment Process');

    // A. Create Order
    final orderForPayment = Order(
      id: 0,
      orderDate: DateTime.now().toIso8601String(),
      orderId: 0,
      orderStatus: 'Pending',
      totalAmount: 10.00,
      paymentType: 'Cash',
      items: const [],
    );
    final paymentOrderId = await orderRepo.createOrder(orderForPayment);
    debugPrint('Created Order for Payment, ID: $paymentOrderId');

    // B. Process Payment
    final payment = Payment(
      id: 0,
      paymentDate: DateTime.now().toIso8601String(),
      orderId: paymentOrderId,
      amountDue: 10.00,
      tips: 1.00,
      discount: 0.0,
      totalPaid: 11.00,
      paymentType: 'Card',
      paymentStatus: 'Success',
    );

    final paymentId = await orderRepo.processPayment(payment);
    debugPrint('Processed Payment, ID: $paymentId');

    // C. Verify Order Status Updated
    final updatedOrders = await orderRepo.getOrders();
    final updatedOrder = updatedOrders.firstWhere(
      (o) => o.id == paymentOrderId,
    );
    _expect(updatedOrder.orderStatus, 'Completed', 'Order Status Update');

    // D. Verify Payment Entry exists in DB
    final db = await dbHelper.database;
    final paymentRows = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    _expect(paymentRows.length, 1, 'Payment Row Exists');

    final savedPaymentRow = paymentRows.first;
    _expect(
      (savedPaymentRow['amount_due'] as int),
      1000,
      'Payment Amount Due (Cents)',
    );
    _expect((savedPaymentRow['tips'] as int), 100, 'Payment Tips (Cents)');
    _expect(savedPaymentRow['payment_status'], 'Success', 'Payment Status');

    debugPrint('✅ Test 3 Passed');

    debugPrint('--- ALL TESTS PASSED ---');
  } catch (e, s) {
    debugPrint('❌ TEST FAILED: $e');
    debugPrint(s.toString());
  }
}

void _expect(dynamic actual, dynamic expected, String label) {
  if (actual != expected) {
    throw Exception('$label Failed: Expected $expected but got $actual');
  }
  debugPrint('   OK: $label');
}
