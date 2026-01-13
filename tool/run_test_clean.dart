import 'dart:io';

void main(List<String> args) async {
  // Run flutter test with the provided arguments
  // Use --no-color to avoid ANSI codes locally if needed, but Process.run usually handles it.
  final command = Platform.isWindows ? 'flutter.bat' : 'flutter';
  final result = await Process.run(command, ['test', '--no-color', ...args], runInShell: true);
  
  print('--- STDOUT ---');
  print(result.stdout);
  
  if (result.stderr.toString().isNotEmpty) {
    print('--- STDERR ---');
    print(result.stderr);
  }
  
  exit(result.exitCode);
}
