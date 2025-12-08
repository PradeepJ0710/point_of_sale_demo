import 'package:equatable/equatable.dart';

class Menu extends Equatable {
  final int id;
  final String name;

  const Menu({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
