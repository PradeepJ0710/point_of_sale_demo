import 'package:equatable/equatable.dart';
import 'package:pos/features/menu/domain/entities/item.dart';

class CartItem extends Equatable {
  final Item item;
  final int quantity;

  const CartItem({required this.item, required this.quantity});

  double get totalPrice => item.price * quantity;

  CartItem copyWith({Item? item, int? quantity}) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [item, quantity];
}
