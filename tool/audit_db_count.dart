import 'package:supabase/supabase.dart';

Future<void> main() async {
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('Authenticating anonymously...');
  await supabase.auth.signInAnonymously();

  print('1. Counting Total Recipes...');
  final countResponse = await supabase.from('recipes').select('id, title').count();
  final count = countResponse.count;
  print('Total Recipes: $count');
  
  print('\n2. Checking Titles (Sample first 5 & last 5)...');
  final list = await supabase.from('recipes').select('title').limit(150); // Get all to scan locally
  final titles = (list as List).map((e) => e['title'].toString()).toList();
  
  final gosNew = titles.where((t) => t.contains('[GOS-')).length;
  final legacy = titles.length - gosNew;
  
  print(' - New Format [GOS-XX]: $gosNew');
  print(' - Legacy Format:       $legacy');

  print('\n3. Inspecting GOS-100 Tags...');
  final gos100 = await supabase.from('recipes').select().ilike('title', '%[GOS-100]%').maybeSingle();
  
  if (gos100 != null) {
    print('Title: ${gos100['title']}');
    print('Tags (Raw): ${gos100['tags']}');
    print('Description Length: ${(gos100['description'] as String).length}');
  } else {
    print('GOS-100 NOT FOUND!');
  }
}
