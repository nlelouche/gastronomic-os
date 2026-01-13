import 'package:supabase/supabase.dart';

Future<void> main() async {
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('Authenticating anonymously...');
  try {
     await supabase.auth.signInAnonymously();
  } catch(e) {
     print('Auth failed: $e');
     return;
  }

  print('Fetching all recipes...');
  final response = await supabase.from('recipes').select('id, title');
  
  int deleted = 0;
  for (final r in response) {
    final title = r['title'].toString();
    if (!title.contains('[GOS-')) {
       print('Deleting Legacy: $title (${r['id']})');
       await supabase.from('recipe_snapshots').delete().eq('recipe_id', r['id']);
       await supabase.from('commits').delete().eq('recipe_id', r['id']);
       await supabase.from('recipes').delete().eq('id', r['id']);
       deleted++;
    }
  }
  
  print('Deleted $deleted legacy recipes.');
}
