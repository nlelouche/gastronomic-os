import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inventory_model.g.dart';

@JsonSerializable()
class InventoryModel extends InventoryItem {


  const InventoryModel({
    required String id,
    required String name,
    required double quantity,
    required String unit,
    @JsonKey(name: 'expiration_date') DateTime? expirationDate,
    String? category,
    @JsonKey(name: 'meta') Map<String, dynamic> metadata = const {},
  }) : super(
          id: id,
          name: name,
          quantity: quantity,
          unit: unit,
          expirationDate: expirationDate,
          category: category,
          metadata: metadata,
        );

  factory InventoryModel.fromJson(Map<String, dynamic> json) => _$InventoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryModelToJson(this);
}
