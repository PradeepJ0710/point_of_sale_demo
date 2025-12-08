import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int id;
  final String paymentDate;
  final int orderId;
  final double amountDue;
  final double tips;
  final double discount;
  final double totalPaid; // This should match Order Total roughly
  final String paymentType; // 'Card' or 'Cash'
  final String paymentStatus;

  const Payment({
    required this.id,
    required this.paymentDate,
    required this.orderId,
    required this.amountDue,
    this.tips = 0.0,
    this.discount = 0.0,
    required this.totalPaid,
    required this.paymentType,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [
    id,
    paymentDate,
    orderId,
    amountDue,
    tips,
    discount,
    totalPaid,
    paymentType,
    paymentStatus,
  ];
}
