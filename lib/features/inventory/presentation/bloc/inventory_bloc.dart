import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';

// Events
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddInventoryItem extends InventoryEvent {
  final InventoryItem item;
  const AddInventoryItem(this.item);
  @override
  List<Object> get props => [item];
}

class UpdateInventoryItem extends InventoryEvent {
  final InventoryItem item;
  const UpdateInventoryItem(this.item);
  @override
  List<Object> get props => [item]; // item.id must be valid
}

class DeleteInventoryItem extends InventoryEvent {
  final String id;
  const DeleteInventoryItem(this.id);
  @override
  List<Object> get props => [id];
}

// States
abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;
  const InventoryLoaded(this.items);
  @override
  List<Object> get props => [items];
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final IInventoryRepository repository;

  InventoryBloc({required this.repository}) : super(InventoryInitial()) {
    on<LoadInventory>((event, emit) async {
      emit(InventoryLoading());
      final result = await repository.getInventory();
      final failure = result.$1;
      final inventory = result.$2;

      if (failure != null) {
        emit(InventoryError(failure.message));
      } else if (inventory != null) {
        emit(InventoryLoaded(inventory));
      }
    });

    on<AddInventoryItem>((event, emit) async {
      emit(InventoryLoading());
      final result = await repository.addItem(event.item);
      final failure = result.$1;
      
      if (failure != null) {
        emit(InventoryError(failure.message));
      } else {
        // Reload inventory to reflect changes
        add(LoadInventory());
      }
    });

    on<UpdateInventoryItem>((event, emit) async {
      emit(InventoryLoading());
      final result = await repository.updateItem(event.item);
      final failure = result.$1;
      
      if (failure != null) {
        emit(InventoryError(failure.message));
      } else {
        add(LoadInventory());
      }
    });

    on<DeleteInventoryItem>((event, emit) async {
      emit(InventoryLoading());
      final result = await repository.deleteItem(event.id);
      final failure = result.$1;
      
      if (failure != null) {
        emit(InventoryError(failure.message));
      } else {
        add(LoadInventory());
      }
    });
  }
}
