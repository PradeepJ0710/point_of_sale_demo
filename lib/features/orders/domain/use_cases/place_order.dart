import 'package:equatable/equatable.dart';
import 'package:pos/core/use_cases/use_case.dart';
import 'package:pos/features/orders/domain/repositories/i_order_repository.dart';
import 'package:pos/features/orders/domain/entities/order.dart';
import 'package:pos/features/orders/domain/entities/payment.dart';

class PlaceOrderUseCase implements UseCase<int, PlaceOrderParams> {
  final IOrderRepository repository;

  PlaceOrderUseCase(this.repository);

  @override
  Future<int> call(PlaceOrderParams params) async {
    return await repository.createOrder(params.order, payment: params.payment);
  }
}

class PlaceOrderParams extends Equatable {
  final Order order;
  final Payment? payment;

  const PlaceOrderParams({required this.order, this.payment});

  @override
  List<Object?> get props => [order, payment];
}
