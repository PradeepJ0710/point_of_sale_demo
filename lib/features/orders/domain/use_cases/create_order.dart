import 'package:equatable/equatable.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/order.dart';
import '../repositories/i_order_repository.dart';

class CreateOrder implements UseCase<int, CreateOrderParams> {
  final IOrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<int> call(CreateOrderParams params) async {
    return await repository.createOrder(params.order);
  }
}

class CreateOrderParams extends Equatable {
  final Order order;

  const CreateOrderParams({required this.order});

  @override
  List<Object> get props => [order];
}
