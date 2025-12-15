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
import 'package:pos/features/orders/domain/entities/payment.dart';

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
    final totalAmount = state.total;
    final tax = totalAmount * 0.125;

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
          _buildRow('Total', totalAmount, isBold: true),
          const SizedBox(height: 8),
          _buildRow('Includes Tax (12.5%)', tax, isBold: false),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleCheckout(context, state, 'Card'),
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Card', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCashDialog(context, state),
                    icon: const Icon(Icons.money),
                    label: const Text('Cash', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCashDialog(BuildContext context, CartLoaded state) {
    final tenderedController = TextEditingController();
    double change = 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Cash Payment',
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: £${state.total.toStringAsFixed(2)}',
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: GoogleFonts.rubik(fontSize: 16),
                    controller: tenderedController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount Tendered',
                      labelStyle: GoogleFonts.rubik(
                        fontWeight: FontWeight.w200,
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(),
                      prefixText: '£',
                      prefixStyle: GoogleFonts.rubik(fontSize: 16),
                    ),
                    onChanged: (val) {
                      final tendered = double.tryParse(val) ?? 0.0;
                      setState(() {
                        change = tendered - state.total;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (tenderedController.text.isNotEmpty)
                    if (change >= 0)
                      Text(
                        'Change: £${change.toStringAsFixed(2)}',
                        style: GoogleFonts.rubik(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      )
                    else
                      Text(
                        'Insufficient Amount',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                  if (tenderedController.text.isEmpty)
                    Text(
                      'Please enter an amount',
                      style: GoogleFonts.rubik(
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.rubik(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: tenderedController.text.isNotEmpty && change >= 0
                      ? () {
                          Navigator.pop(context);
                          _handleCheckout(
                            context,
                            state,
                            'Cash',
                            tendered: double.tryParse(tenderedController.text),
                          );
                        }
                      : null,
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.rubik(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleCheckout(
    BuildContext context,
    CartLoaded state,
    String paymentType, {
    double? tendered,
  }) {
    final now = DateTime.now();
    final totalPaid = tendered ?? state.total;

    // Create Payment Object
    // Note: ID will be ignored/auto-generated by DB
    // OrderID will be linked in Bloc
    final payment = Payment(
      id: 0,
      paymentDate: now.toIso8601String(),
      orderId: 0, // Placeholder
      amountDue: state.total,
      tips: 0.0,
      discount: 0.0,
      totalPaid: totalPaid,
      paymentType: paymentType,
      paymentStatus: 'Pending',
    );

    final order = Order(
      id: 0,
      orderDate: now.toIso8601String(),
      orderId: 0,
      orderStatus: 'Pending', // Will be updated to Completed by payment process
      totalAmount: state.total,
      paymentType: paymentType,
      items: state.items
          .map(
            (ci) => OrderItem(
              itemId: ci.item.id,
              itemName: ci.item.name,
              price: ci.item.price,
              quantity: ci.quantity,
              total: ci.totalPrice,
            ),
          )
          .toList(),
    );

    context.read<OrderBloc>().add(PlaceOrder(order, payment: payment));
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
        style: GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        '£${cartItem.item.price.toStringAsFixed(2)} x ${cartItem.quantity}',
        style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w400),
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
      contentPadding: EdgeInsets.zero,
    );
  }
}
