import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseInit {
  static Future<void> init() async {
    // Load environment variables (ensure .env file exists in assets if using this)
    // For now, we use placeholders as requested.
    
    // TODO: Replace with actual values from .env or config
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://absamxtltbygnadetgex.supabase.co');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    // Auto-sign in removed. Authentication is now handled by AuthBloc.
  }
}
