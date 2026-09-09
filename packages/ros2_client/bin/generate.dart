// Generates Dart message classes from ROS 2 interface definitions.
//
//   dart run ros2_client:generate --out lib/msgs sensor_msgs geometry_msgs
//   dart run ros2_client:generate --out lib/msgs --search ~/ws/src my_msgs
//
// Packages are located in --search roots, or in the sourced ROS installation
// via AMENT_PREFIX_PATH / ROS_DISTRO.
import 'dart:io';

import 'package:ros2_client/src/codegen/interface_def.dart';
import 'package:ros2_client/src/codegen/interface_parser.dart';
import 'package:ros2_client/src/codegen/library_writer.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _usage();
    exit(args.isEmpty ? 64 : 0);
  }

  var outDir = 'lib/generated';
  final searchRoots = <String>[];
  final packages = <String>[];

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--out' || '-o':
        outDir = args[++i];
      case '--search' || '-s':
        searchRoots.add(args[++i]);
      default:
        if (args[i].startsWith('-')) {
          stderr.writeln('Unknown option: ${args[i]}');
          exit(64);
        }
        packages.add(args[i]);
    }
  }

  searchRoots.addAll(_rosSearchRoots());
  if (searchRoots.isEmpty) {
    stderr
        .writeln('No search roots. Source your ROS install, or pass --search.');
    exit(69);
  }

  final output = Directory(outDir)..createSync(recursive: true);
  var totalMessages = 0;
  var totalFailures = 0;

  // A message may reference a type from a package the user did not ask for
  // (action_msgs needs unique_identifier_msgs/UUID, for example). Generating
  // only the requested packages produces code that does not compile, so the
  // queue grows as dependencies are discovered.
  final queue = <String>[...packages];
  final done = <String>{};
  final generated = <String>[];

  while (queue.isNotEmpty) {
    final package = queue.removeAt(0);
    if (!done.add(package)) continue;
    final dir = _findPackage(package, searchRoots);
    if (dir == null) {
      stderr.writeln('!  $package: not found in ${searchRoots.join(', ')}');
      totalFailures++;
      continue;
    }

    final messages = <MessageDef>[];
    final msgDir = Directory('${dir.path}/msg');
    if (msgDir.existsSync()) {
      final files = msgDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.msg'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final name = file.uri.pathSegments.last.replaceAll('.msg', '');
        try {
          messages.add(InterfaceParser.parseMessage(
            file.readAsStringSync(),
            package: package,
            name: name,
          ));
        } on InterfaceParseException catch (e) {
          stderr.writeln('!  $e');
          totalFailures++;
        }
      }
    }

    if (messages.isEmpty) {
      stderr.writeln('!  $package: no .msg files under ${dir.path}');
      continue;
    }

    final writer = LibraryWriter(package: package, messages: messages);
    final target = File('$outDir/$package.dart')
      ..writeAsStringSync(writer.write());
    totalMessages += messages.length;
    generated.add(package);

    final deps = writer.referencedPackages.where((d) => !done.contains(d));
    if (deps.isNotEmpty) {
      stdout.writeln('   ${target.path}  (${messages.length} messages)'
          '  -> pulling in ${deps.join(', ')}');
      queue.addAll(deps);
    } else {
      stdout.writeln('   ${target.path}  (${messages.length} messages)');
    }
  }

  generated.sort();
  _writeBarrel(output, generated);

  stdout.writeln('\nGenerated $totalMessages messages into $outDir'
      '${totalFailures > 0 ? '  ($totalFailures problems)' : ''}');
  stdout.writeln('Run `dart format $outDir` to tidy the output.');
  if (totalFailures > 0) exit(70);
}

/// Emits a barrel that exports every generated library and registers them all.
void _writeBarrel(Directory output, List<String> packages) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT EDIT BY HAND.')
    ..writeln();
  // Imported as well as exported: the registration function below calls into
  // each library, which an export alone does not bring into scope.
  for (final package in packages) {
    buffer.writeln("import '$package.dart';");
  }
  buffer.writeln();
  for (final package in packages) {
    buffer.writeln("export '$package.dart';");
  }
  buffer
    ..writeln()
    ..writeln('/// Registers every generated message package.')
    ..writeln('void registerGeneratedMessages() {');
  for (final package in packages) {
    final pascal = package
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join();
    buffer.writeln('  register$pascal();');
  }
  buffer.writeln('}');
  File('${output.path}/generated.dart').writeAsStringSync(buffer.toString());
}

/// Search roots derived from a sourced ROS environment.
List<String> _rosSearchRoots() {
  final roots = <String>[];
  final ament = Platform.environment['AMENT_PREFIX_PATH'];
  if (ament != null) {
    for (final prefix in ament.split(':')) {
      if (prefix.isNotEmpty) roots.add('$prefix/share');
    }
  }
  final distro = Platform.environment['ROS_DISTRO'];
  if (distro != null) roots.add('/opt/ros/$distro/share');
  return roots;
}

Directory? _findPackage(String package, List<String> roots) {
  for (final root in roots) {
    final candidate = Directory('$root/$package');
    if (candidate.existsSync()) return candidate;
  }
  return null;
}

void _usage() {
  stdout.writeln('''
Generate Dart classes from ROS 2 interface definitions.

Usage:
  dart run ros2_client:generate [options] <package>...

Options:
  -o, --out <dir>      Output directory (default: lib/generated)
  -s, --search <dir>   Extra directory to search for packages; repeatable.
                       Your sourced ROS install is searched automatically.
  -h, --help           Show this help.

Examples:
  dart run ros2_client:generate -o lib/msgs sensor_msgs nav_msgs
  dart run ros2_client:generate -s ~/ws/install my_robot_msgs
''');
}
