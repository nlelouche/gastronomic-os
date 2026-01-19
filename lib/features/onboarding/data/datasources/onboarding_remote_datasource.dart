import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/core/error/failures.dart';


abstract class OnboardingRemoteDataSource {
  Future<void> updateProfileConfig(Map<String, dynamic> config);
  Future<Map<String, dynamic>?> getProfileConfig();
  Future<void> resetProfileConfig();
  Future<void> setPrimaryCook(String memberId);
  Future<List<Map<String, dynamic>>> getFamilyMembersFromTable();
  Future<void> syncFamilyMembers(List<Map<String, dynamic>> membersData);
  Future<void> updateFamilyMember(Map<String, dynamic> data);
  Future<String> uploadAvatar(List<int> fileBytes, String fileExtension);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final SupabaseClient supabaseClient;

  OnboardingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> updateProfileConfig(Map<String, dynamic> config) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('Datasource operation failed');

      await supabaseClient
          .from('profiles')
          .update({'family_config': config})
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<Map<String, dynamic>?> getProfileConfig() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await supabaseClient
          .from('profiles')
          .select('family_config')
          .eq('id', user.id)
          .single();
      
      return response['family_config'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> resetProfileConfig() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('Datasource operation failed');

      await supabaseClient
          .from('profiles')
          .update({'family_config': {'onboarding_completed': false, 'members': []}})
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<void> setPrimaryCook(String memberId) async {
    try {
      await supabaseClient.rpc('set_primary_cook', params: {'target_member_id': memberId});
    } catch (e) {
      throw Exception('Datasource operation failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFamilyMembersFromTable() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('family_members')
          .select()
          .eq('user_id', user.id);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> syncFamilyMembers(List<Map<String, dynamic>> membersData) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('Datasource operation failed');

      // 1. Enrich data with user_id
      final enrichedData = membersData.map((m) => {
        ...m,
        'user_id': user.id,
      }).toList();

      // 2. Upsert Members
      await supabaseClient
          .from('family_members')
          .upsert(enrichedData); // Use enriched data

      // 3. Delete removed members
      // Get IDs from incoming list
      final incomingIds = membersData.map((m) => m['id']).toList();
      
      // Delete any family member for this user that is NOT in the incoming list
      await supabaseClient
          .from('family_members')
          .delete()
          .eq('user_id', user.id)
          .not('id', 'in', incomingIds);

    } catch (e) {
      throw Exception('Datasource operation failed: $e');
    }
  }

  @override
  Future<void> updateFamilyMember(Map<String, dynamic> data) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('Datasource operation failed');

      // Enrich with user_id
      final enrichedData = {
        ...data,
        'user_id': user.id,
      };

      await supabaseClient
          .from('family_members')
          .upsert(enrichedData);
    } catch (e) {
      throw Exception('Datasource operation failed: $e');
    }
  }

  @override
  Future<String> uploadAvatar(List<int> fileBytes, String fileExtension) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      final path = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      await supabaseClient.storage.from('avatars').uploadBinary(
        path,
        fileBytes as dynamic, 
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      final publicUrl = supabaseClient.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Avatar upload failed: $e');
    }
  }
}
