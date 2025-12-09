import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.paymentDate,
    required super.orderId,
    required super.amountDue,
    required super.tips,
    required super.discount,
    required super.totalPaid,
    required super.paymentType,
    required super.paymentStatus,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int,
      paymentDate: map['payment_date'] as String,
      orderId: map['order_id'] as int,
      // CONVERSION: Pence -> Pounds
      amountDue: (map['amount_due'] as int) / 100.0,
      tips: (map['tips'] as int) / 100.0,
      discount: (map['discount'] as int) / 100.0,
      totalPaid: (map['total_paid'] as int) / 100.0,
      paymentType: map['payment_type'] as String,
      paymentStatus: map['payment_status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // id is auto-incremented, so we don't include it for creation unless needed
      // but for updates we might. For now, matching standard pattern.
      if (id != 0) 'id': id,
      'payment_date': paymentDate,
      'order_id': orderId,
      // CONVERSION: Pounds -> Pence
      'amount_due': (amountDue * 100).round(),
      'tips': (tips * 100).round(),
      'discount': (discount * 100).round(),
      'total_paid': (totalPaid * 100).round(),
      'payment_type': paymentType,
      'payment_status': paymentStatus,
    };
  }
}
