import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/features/cart/domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartLoaded()) {
    on<AddCartItem>(_onAddItem);
    on<RemoveCartItem>(_onRemoveItem);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItem(AddCartItem event, Emitter<CartState> emit) {
    final currentState = state as CartLoaded;
    final List<CartItem> updatedItems = List.from(currentState.items);

    final existingIndex = updatedItems.indexWhere(
      (i) => i.item.id == event.item.id,
    );

    if (existingIndex >= 0) {
      // Increment Quantity
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Add New Item
      updatedItems.add(CartItem(item: event.item, quantity: 1));
    }

    emit(_calculateState(updatedItems));
  }

  void _onRemoveItem(RemoveCartItem event, Emitter<CartState> emit) {
    final currentState = state as CartLoaded;
    final List<CartItem> updatedItems = List.from(currentState.items);

    final existingIndex = updatedItems.indexWhere(
      (i) => i.item.id == event.item.id,
    );

    if (existingIndex >= 0) {
      final existingItem = updatedItems[existingIndex];
      if (existingItem.quantity > 1) {
        // Decrement Quantity
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity - 1,
        );
      } else {
        // Remove Item
        updatedItems.removeAt(existingIndex);
      }
    }

    emit(_calculateState(updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartLoaded());
  }

  CartLoaded _calculateState(List<CartItem> items) {
    double total = 0.0;
    for (var item in items) {
      total += item.totalPrice;
    }

    return CartLoaded(items: items, total: total);
  }
}
