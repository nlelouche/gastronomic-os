import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/core/error/exception_handler.dart';
import 'package:gastronomic_os/core/error/error_reporter.dart';
import 'package:gastronomic_os/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:gastronomic_os/features/inventory/data/models/inventory_model.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';

class InventoryRepositoryImpl implements IInventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(Failure?, List<InventoryItem>?)> getInventory() async {
    try {
      final remoteInventory = await remoteDataSource.getInventory();
      return (null, remoteInventory);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('getInventory'),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, InventoryItem?)> addItem(InventoryItem item) async {
    try {
      final model = InventoryModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        expirationDate: item.expirationDate,
        category: item.category,
        metadata: item.metadata,
      );
      final result = await remoteDataSource.addItem(model);
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('addItem', extra: {
          'itemName': item.name,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, void)> deleteItem(String id) async {
    try {
      await remoteDataSource.deleteItem(id);
      return (null, null);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('deleteItem', extra: {
          'itemId': id,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, InventoryItem?)> updateItem(InventoryItem item) async {
    try {
      final model = InventoryModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        expirationDate: item.expirationDate,
        category: item.category,
        metadata: item.metadata,
      );
      final result = await remoteDataSource.updateItem(model);
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('updateItem', extra: {
          'itemId': item.id,
          'itemName': item.name,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }
}
