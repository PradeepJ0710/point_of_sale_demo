import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../../domain/entities/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Load orders when page opens
    context.read<OrderBloc>().add(LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Orders')),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderError) {
            return const Center(child: Text('Something went wrong'));
          } else if (state is OrderLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Text(
                  'No order found',
                  style: GoogleFonts.rubik(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return ListView.separated(
              itemCount: state.orders.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _OrderTile(order: order);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(order.orderDate);
    } catch (e) {
      parsedDate = DateTime.now(); // Fallback
    }

    return ExpansionTile(
      title: Text(
        'Order #${order.id}',
        style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateFormatter.format(parsedDate)),
          Text(
            '£${order.totalAmount.toStringAsFixed(2)} - ${order.orderStatus}',
            style: GoogleFonts.rubik(
              color: order.orderStatus == 'Completed'
                  ? Colors.green
                  : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      children: order.items.map((item) {
        return ListTile(
          dense: true,
          title: Text('Item #${item.itemId}'),
          trailing: Text('£${item.total.toStringAsFixed(2)}'),
          leading: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }
}
