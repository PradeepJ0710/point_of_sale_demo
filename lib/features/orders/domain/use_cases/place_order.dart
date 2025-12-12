import 'package:equatable/equatable.dart';
import 'package:pos/core/use_cases/use_case.dart';
import 'package:pos/features/orders/domain/repositories/i_order_repository.dart';
import 'package:pos/features/orders/domain/entities/order.dart';

class PlaceOrderUseCase implements UseCase<void, PlaceOrderParams> {
  final IOrderRepository repository;

  PlaceOrderUseCase(this.repository);

  @override
  Future<void> call(PlaceOrderParams params) async {
    await repository.createOrder(params.order);
  }
}

class PlaceOrderParams extends Equatable {
  final Order order;

  const PlaceOrderParams({required this.order});

  @override
  List<Object> get props => [order];
}
