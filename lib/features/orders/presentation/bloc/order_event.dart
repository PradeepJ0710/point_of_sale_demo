import 'package:equatable/equatable.dart';
import 'package:pos/features/orders/domain/entities/order.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class LoadOrders extends OrderEvent {}

class PlaceOrder extends OrderEvent {
  final Order order;

  const PlaceOrder(this.order);

  @override
  List<Object> get props => [order];
}
