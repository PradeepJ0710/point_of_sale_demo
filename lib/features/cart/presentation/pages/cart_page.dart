import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import 'package:pos/features/cart/domain/entities/cart_item.dart';
import 'package:pos/features/orders/presentation/bloc/order_bloc.dart';
import 'package:pos/features/orders/presentation/bloc/order_event.dart';
import 'package:pos/features/orders/presentation/bloc/order_state.dart';
import 'package:pos/features/orders/domain/entities/order.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderPlacedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order Placed Successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear cart after successful order
          context.read<CartBloc>().add(ClearCart());
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to place order: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                context.read<CartBloc>().add(ClearCart());
              },
            ),
          ],
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoaded) {
              if (state.items.isEmpty) {
                return Center(
                  child: Text(
                    'Your cart is empty',
                    style: GoogleFonts.rubik(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      separatorBuilder: (c, i) => const Divider(),
                      itemBuilder: (context, index) {
                        final cartItem = state.items[index];
                        return _CartItemTile(cartItem: cartItem);
                      },
                    ),
                  ),
                  _buildSummarySection(context, state),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartLoaded state) {
    // Calculate Tax just for display (12.5% of Total)
    final tax = state.total * 0.125;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Total', state.total, isBold: true),
          const SizedBox(height: 8),
          _buildRow('Includes Tax (12.5%)', tax, isBold: false),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final order = Order(
                  id: 0, // Auto-increment DB
                  orderDate: DateTime.now().toIso8601String(),
                  orderId: 0, // Can be same as ID or UUID
                  orderStatus: 'Pending',
                  totalAmount: state.total,
                  items: state.items
                      .map(
                        (ci) => OrderItem(
                          itemId: ci.item.id,
                          price: ci.item.price,
                          quantity: ci.quantity,
                          total: ci.totalPrice,
                        ),
                      )
                      .toList(),
                );
                context.read<OrderBloc>().add(PlaceOrder(order));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey[800]),
        ),
        Text(
          '£${amount.toStringAsFixed(2)}',
          style: GoogleFonts.rubik(
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const _CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        cartItem.item.name,
        style: GoogleFonts.rubik(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '£${cartItem.item.price.toStringAsFixed(2)} x ${cartItem.quantity}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '£${cartItem.totalPrice.toStringAsFixed(2)}',
            style: GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              context.read<CartBloc>().add(RemoveCartItem(cartItem.item));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              context.read<CartBloc>().add(AddCartItem(cartItem.item));
            },
          ),
        ],
      ),
    );
  }
}
