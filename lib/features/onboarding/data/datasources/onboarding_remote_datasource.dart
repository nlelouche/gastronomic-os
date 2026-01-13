import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/core/error/failures.dart';


abstract class OnboardingRemoteDataSource {
  Future<void> updateProfileConfig(Map<String, dynamic> config);
  Future<Map<String, dynamic>?> getProfileConfig();
  Future<void> resetProfileConfig();
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
}
