import 'dart:io';
import 'package:path/path.dart' as p;

///
/// Parses the Font assets found within assets/fonts/ and generates the [fonts] section of 
/// the pubspec.yaml, outputs this to bin/pubspec-fonts-stub.yaml. Additionally generates a list
/// family names of the parsed font files and outputs this to bin/family-names.txt
///

void main() async {
  print('Running Load Fonts Script...');
  final cwd = Directory.current.path;
  final binDirPath = Directory(p.join(cwd, 'bin')).path;
  final pubspecStubFile = File(p.join(binDirPath, 'pubspec-fonts-stub.yaml'));
  final fontsDir = Directory(p.join(cwd, 'assets', 'fonts'));
  final List<String> familyNames = [];

  print("Parsing font files from ${p.relative(fontsDir.path)}");

  await pubspecStubFile.create();
  final outputStream = pubspecStubFile.openWrite(mode: FileMode.write);
  outputStream.write("fonts:\n");

  await for (var entity in fontsDir.list(recursive: false)) {
    if (entity is Directory) {
      final familyName =
          p.basenameWithoutExtension(entity.path).replaceAll('_', ' ');
      outputStream.write("  - family: $familyName\n    fonts:\n");
      familyNames.add("\"$familyName\",");

      await for (var inner in entity.list(recursive: false)) {
        if (inner is File && p.basename(inner.path) != "OFL.txt") {
          outputStream.write(
              "    - asset: assets/fonts/$familyName/${p.basename(inner.path)}\n");
        }
      }
    }
  }

  await outputStream.close();

  print('Finished writing ${p.basename(pubspecStubFile.path)}');
  final familyNamesFile = File(p.join(binDirPath, 'family-names.txt'));
  await familyNamesFile.create();

  familyNames.sort();

  print('Writing family names to ${p.relative(familyNamesFile.path)}');
  await familyNamesFile.writeAsString(familyNames.join("\n"));

  print('Script Finished');
}
