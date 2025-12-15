import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderDate,
    required super.orderId,
    required super.orderStatus,
    required super.totalAmount,
    required super.paymentType,
    required super.items,
  });

  // Note: Since 'Order' is a composite object (Headers + Items),
  // fromMap here effectively constructs the 'Header' part mostly,
  // but we need the items list passed in separately or handled via a join query in Repo.
  // For simplicity, we'll assume the Repository assembles the Model.

  static OrderModel fromRow(
    Map<String, dynamic> headerRow,
    List<OrderItem> items,
  ) {
    return OrderModel(
      id: headerRow['id'] as int,
      orderDate: headerRow['order_date'] as String,
      orderId: headerRow['id'] as int, // Using ID as OrderID
      orderStatus: headerRow['order_status'] as String,
      // CONVERSION: Pence -> Pounds
      totalAmount: (headerRow['total_amount'] as int) / 100.0,
      paymentType: headerRow['payment_type'] as String,
      items: items,
    );
  }

  Map<String, dynamic> toHeaderMap() {
    return {
      'order_date': orderDate,
      'order_status': orderStatus,
      // CONVERSION: Pounds -> Pence
      'total_amount': (totalAmount * 100).round(),
      'payment_type': paymentType,
    };
  }
}
