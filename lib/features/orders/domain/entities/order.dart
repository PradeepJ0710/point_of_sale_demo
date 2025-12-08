import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final String orderDate;
  // In a real app, this might be a list of custom objects,
  // but strictly following the user's "single data table" description:
  // "ID, Order Date, Order ID, Item ID, Price, Qty, Order Status, Total"
  // Since "Order" represents a single Header + List of Items, we model it as an aggregate root.

  final int orderId; // Distinct from primary key ID if needed, or same.
  final String orderStatus;
  final double totalAmount;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderDate,
    required this.orderId,
    required this.orderStatus,
    required this.totalAmount,
    required this.items,
  });

  @override
  List<Object?> get props => [
    id,
    orderDate,
    orderId,
    orderStatus,
    totalAmount,
    items,
  ];
}

class OrderItem extends Equatable {
  final int itemId;
  final double price;
  final int quantity;
  final double total;

  const OrderItem({
    required this.itemId,
    required this.price,
    required this.quantity,
    required this.total,
  });

  @override
  List<Object?> get props => [itemId, price, quantity, total];
}
