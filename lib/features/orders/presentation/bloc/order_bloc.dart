import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/use_cases/use_case.dart';
import 'package:pos/features/orders/domain/use_cases/get_orders.dart';
import 'package:pos/features/orders/domain/use_cases/place_order.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrders getOrders;
  final PlaceOrderUseCase placeOrder;

  OrderBloc({required this.getOrders, required this.placeOrder})
    : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<PlaceOrder>(_onPlaceOrder);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await getOrders(NoParams());
      // Sort by date descending (newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await placeOrder(PlaceOrderParams(order: event.order));
      // Refresh list
      final orders = await getOrders(NoParams());
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      // Emit Success first to trigger listeners
      emit(OrderPlacedSuccess());
      // Then emit the updated list
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
