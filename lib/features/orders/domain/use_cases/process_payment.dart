import 'package:equatable/equatable.dart';
import 'package:pos/core/use_cases/use_case.dart';
import 'package:pos/features/orders/domain/repositories/i_order_repository.dart';
import 'package:pos/features/orders/domain/entities/payment.dart';

class ProcessPayment implements UseCase<int, ProcessPaymentParams> {
  final IOrderRepository repository;

  ProcessPayment(this.repository);

  @override
  Future<int> call(ProcessPaymentParams params) async {
    return await repository.processPayment(params.payment);
  }
}

class ProcessPaymentParams extends Equatable {
  final Payment payment;

  const ProcessPaymentParams(this.payment);

  @override
  List<Object> get props => [payment];
}
