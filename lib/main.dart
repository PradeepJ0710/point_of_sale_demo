import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/database/database_helper.dart' show DatabaseHelper;
import 'package:pos/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:pos/features/menu/domain/use_cases/get_categories.dart';
import 'package:pos/features/menu/domain/use_cases/get_items.dart';
import 'package:pos/features/menu/domain/use_cases/get_menus.dart';
import 'package:pos/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:pos/features/cart/presentation/bloc/cart_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';

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
    return RepositoryProvider(
      create: (context) => MenuRepositoryImpl(DatabaseHelper.instance),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.rubikTextTheme(
          const TextTheme(bodyMedium: TextStyle(fontSize: 16.0)),
        ),
      ),
      home: const HomePage(),
    );
  }
}
