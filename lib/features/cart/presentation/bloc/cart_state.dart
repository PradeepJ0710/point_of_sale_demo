import 'package:equatable/equatable.dart';
import 'package:pos/features/cart/domain/entities/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;

  const CartLoaded({this.items = const [], this.total = 0.0});

  CartLoaded copyWith({List<CartItem>? items, double? total}) {
    return CartLoaded(items: items ?? this.items, total: total ?? this.total);
  }

  @override
  List<Object> get props => [items, total];
}
