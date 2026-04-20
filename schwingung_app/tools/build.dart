import 'dart:io';

void main() {
  copyJSFiles();
}

/// copies the custom JS file to the
/// web folder so it can be used in the app
Future<void> copyJSFiles() async {
  Map<String, String> srcDest = {'assets/my_custom.js': 'web/my_custom.js'};

  for (var entry in srcDest.entries) {
    File source = File(entry.key);
    File destination = File(entry.value);

    if (!source.existsSync()) {
      print('ERROR: Source JS not found');
      exit(1);
    }

    destination.createSync(recursive: true);
    destination.writeAsBytesSync(source.readAsBytesSync());
  }

  print('Copied all');
}
