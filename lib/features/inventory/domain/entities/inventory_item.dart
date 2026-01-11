import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime? expirationDate;
  final String? category;
  final Map<String, dynamic> metadata;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expirationDate,
    this.category,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, name, quantity, unit, expirationDate, category, metadata];
}
