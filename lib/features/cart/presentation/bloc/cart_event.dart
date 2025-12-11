import 'package:equatable/equatable.dart';
import 'package:pos/features/menu/domain/entities/item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddCartItem extends CartEvent {
  final Item item;

  const AddCartItem(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveCartItem extends CartEvent {
  final Item item;

  const RemoveCartItem(this.item);

  @override
  List<Object> get props => [item];
}

class ClearCart extends CartEvent {}
