import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/features/inventory/data/models/inventory_model.dart';
import 'package:gastronomic_os/core/error/failures.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryModel>> getInventory();
  Future<InventoryModel> addItem(InventoryModel item);
  Future<void> deleteItem(String id);
  Future<InventoryModel> updateItem(InventoryModel item);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  InventoryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<InventoryModel> addItem(InventoryModel item) async {
    try {
      final itemMap = item.toJson();
      itemMap.remove('id'); 
      final userId = supabaseClient.auth.currentUser?.id;
      itemMap['user_id'] = userId;
      
      final response = await supabaseClient
          .from('inventory_items')
          .insert(itemMap)
          .select()
          .single();
      return InventoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<List<InventoryModel>> getInventory() async {
    try {
      final response = await supabaseClient.from('inventory_items').select();
      return (response as List).map((e) => InventoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await supabaseClient.from('inventory_items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<InventoryModel> updateItem(InventoryModel item) async {
    try {
      final response = await supabaseClient
          .from('inventory_items')
          .update(item.toJson())
          .eq('id', item.id)
          .select()
          .single();
      return InventoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }
}
