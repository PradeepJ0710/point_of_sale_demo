import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import 'package:pos/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:pos/features/cart/presentation/bloc/cart_event.dart';
import '../widgets/item_tile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    // Trigger initial load
    context.read<MenuBloc>().add(LoadMenus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MenuError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is MenuLoaded) {
            return _buildMenuContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, MenuLoaded state) {
    // If no categories, show message
    if (state.categories.isEmpty) {
      return Column(
        children: [
          _buildMenuSelector(context, state),
          const Expanded(child: Center(child: Text("No categories found."))),
        ],
      );
    }

    return DefaultTabController(
      length: state.categories.length,
      child: Column(
        children: [
          // Top Bar to switch between Menus (Food, Drinks)
          _buildMenuSelector(context, state),

          // Tab Bar for Categories
          TabBar(
            tabAlignment: TabAlignment.fill,
            isScrollable: false,
            labelStyle: GoogleFonts.rubik(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.rubik(),
            tabs: state.categories.map((c) => Tab(text: c.name)).toList(),
          ),

          // Tab Views (Grids of Items)
          Expanded(
            child: TabBarView(
              children: state.categories.map((category) {
                final items = state.itemsByCategory[category.id] ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Text("No items in this category."),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns for Tablet/Large Phone
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ItemTile(
                      item: item,
                      onTap: () {
                        context.read<CartBloc>().add(AddCartItem(item));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${item.name} to Cart'),
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSelector(BuildContext context, MenuLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: state.menus.map((menu) {
            final isSelected = menu.id == state.selectedMenuId;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                label: Text(menu.name, style: const TextStyle(fontSize: 16)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<MenuBloc>().add(SelectMenu(menu.id));
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
