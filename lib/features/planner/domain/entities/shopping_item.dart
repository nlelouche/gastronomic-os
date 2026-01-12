import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final String name;
  final double quantity;
  final String unit;
  final bool isVariant; // e.g., "Tofu" instead of "Egg"
  final String originalInput; // For debug

  const ShoppingItem({
    required this.name,
    this.quantity = 1.0,
    this.unit = '',
    this.isVariant = false,
    required this.originalInput,
  });

  ShoppingItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    bool? isVariant,
  }) {
    return ShoppingItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isVariant: isVariant ?? this.isVariant,
      originalInput: originalInput,
    );
  }

  @override
  List<Object?> get props => [name, quantity, unit, isVariant];
}
