import 'package:equatable/equatable.dart';
import 'package:pos/features/orders/domain/entities/order.dart';
import 'package:pos/features/orders/domain/entities/payment.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {}

class PlaceOrder extends OrderEvent {
  final Order order;
  final Payment? payment;

  const PlaceOrder(this.order, {this.payment});

  @override
  List<Object?> get props => [order, payment];
}
