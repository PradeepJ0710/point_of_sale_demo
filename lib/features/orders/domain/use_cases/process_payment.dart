import 'package:equatable/equatable.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/payment.dart';
import '../repositories/i_order_repository.dart';

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

  const ProcessPaymentParams({required this.payment});

  @override
  List<Object> get props => [payment];
}
