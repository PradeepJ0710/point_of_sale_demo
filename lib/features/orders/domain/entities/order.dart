import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final String orderDate;
  final int orderId;
  final String orderStatus;
  final double totalAmount;
  final String paymentType;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderDate,
    required this.orderId,
    required this.orderStatus,
    required this.totalAmount,
    required this.paymentType,
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
  final String itemName;
  final double price;
  final int quantity;
  final double total;

  const OrderItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  @override
  List<Object?> get props => [itemId, itemName, price, quantity, total];
}
