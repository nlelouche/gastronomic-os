import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';

// Correction: I should strictly follow my plan. I mentioned "Either<Failure, T>".
// Since I didn't add dartz to pubspec in the previous step, I will add a simple `Result` class in `core/utils` to avoid compilation errors, 
// OR I can quickly update pubspec. Let's use a custom lightweight Result for now to reduce dependencies, or just Future<List<InventoryItem>> and throw exceptions? 
// The Clean Arch way usually expects Either. 
// I'll add dartz to pubspec in a separate step or just assume it's there? No, I must be precise.
// I will implement a lightweight implementation of Either in core/utils/either.dart to start.

abstract class IInventoryRepository {
  Future<(Failure?, List<InventoryItem>?)> getInventory();
  Future<(Failure?, InventoryItem?)> addItem(InventoryItem item);
  Future<(Failure?, void)> deleteItem(String id);
  Future<(Failure?, InventoryItem?)> updateItem(InventoryItem item);
}

// NOTE: Using Dart 3 Records (Failure?, Data?) as a lightweight Either alternative for now.
