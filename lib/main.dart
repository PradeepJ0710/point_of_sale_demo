import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/database/database_helper.dart' show DatabaseHelper;
import 'package:pos/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:pos/features/menu/domain/use_cases/get_categories.dart';
import 'package:pos/features/menu/domain/use_cases/get_items.dart';
import 'package:pos/features/menu/domain/use_cases/get_menus.dart';
import 'package:pos/features/home/presentation/pages/home_page.dart';
import 'package:pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:pos/features/orders/data/repositories/order_repository_impl.dart';
import 'package:pos/features/orders/domain/use_cases/get_orders.dart';
import 'package:pos/features/orders/domain/use_cases/place_order.dart';
import 'package:pos/features/orders/presentation/bloc/order_bloc.dart';
import 'package:pos/features/cart/presentation/bloc/cart_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  // VERIFICATION: Run manual tests on app startup
  // Remove this line after verification is complete
  // await verifyDataLayer();

  runApp(const AppProvider(child: PosApp()));
}

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 1. Provide Repositories
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => MenuRepositoryImpl(DatabaseHelper.instance),
        ),
        RepositoryProvider(
          create: (context) => OrderRepositoryImpl(DatabaseHelper.instance),
        ),
      ],
      child: Builder(
        builder: (context) {
          // 2. Provide BLoCs
          // We need to use Builder to access the RepositoryProvider context
          return MultiBlocProvider(
            providers: [
              BlocProvider<MenuBloc>(
                create: (context) => MenuBloc(
                  getMenus: GetMenus(context.read<MenuRepositoryImpl>()),
                  getCategories: GetCategories(
                    context.read<MenuRepositoryImpl>(),
                  ),
                  getItems: GetItems(context.read<MenuRepositoryImpl>()),
                ),
              ),
              BlocProvider<CartBloc>(create: (context) => CartBloc()),
              BlocProvider<OrderBloc>(
                create: (context) => OrderBloc(
                  getOrders: GetOrders(context.read<OrderRepositoryImpl>()),
                  placeOrder: PlaceOrderUseCase(
                    context.read<OrderRepositoryImpl>(),
                  ),
                ),
              ),
            ],
            child: child,
          );
        },
      ),
    );
  }
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIN Point-0f-Sale',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.rubik(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191D17),
          ),
        ),
        textTheme: GoogleFonts.rubikTextTheme(
          const TextTheme(bodyMedium: TextStyle(fontSize: 16.0)),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedLabelStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.rubik(fontSize: 16),
        ),
      ),
      home: const HomePage(),
    );
  }
}
