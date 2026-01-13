import 'package:supabase/supabase.dart';

Future<void> main() async {
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  // simulate valid user
  // We can't easily "force" a new session without persistence reset, 
  // but dart script default is memory storage, so strict new session.
  
  print('1. Signing in Anonymously...');
  final authRes = await supabase.auth.signInAnonymously();
  print('   User ID: ${authRes.user?.id}');

  print('\n2. Searching for recipe with citations...');
  final data = await supabase
      .from('recipes')
      .select('title, description')
      .ilike('description', '%[cite:%')
      .limit(1)
      .maybeSingle();

  if (data != null) {
      print('   SUCCESS! Found recipe with citation.');
      print('   Title: ${data['title']}');
      print('   Snippet: ${data['description'].toString().substring(0, 100)}...');
  } else {
      print('   No recipe with [cite:] found in description. Checking steps (not implemented in script yet).');
  }

  print('\n3. Fetching First 5 Recipes (Any)...');
  final list = await supabase.from('recipes').select('title, author_id').limit(5);
  for(var r in list) {
      print('   - ${r['title']} (Auth: ${r['author_id']})');
  }
}
