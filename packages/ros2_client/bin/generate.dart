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

  /// Fully qualified type names actually emitted, and those referenced.
  final allTypes = <String>{};
  final emitted = <String, Set<String>>{};

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
    for (final file in _interfaceFiles(dir, 'msg', '.msg')) {
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

    final services = <ServiceDef>[];
    for (final file in _interfaceFiles(dir, 'srv', '.srv')) {
      final name = file.uri.pathSegments.last.replaceAll('.srv', '');
      try {
        services.add(InterfaceParser.parseService(
          file.readAsStringSync(),
          package: package,
          name: name,
        ));
      } on InterfaceParseException catch (e) {
        stderr.writeln('!  $e');
        totalFailures++;
      }
    }

    final actions = <ActionDef>[];
    for (final file in _interfaceFiles(dir, 'action', '.action')) {
      final name = file.uri.pathSegments.last.replaceAll('.action', '');
      try {
        actions.add(InterfaceParser.parseAction(
          file.readAsStringSync(),
          package: package,
          name: name,
        ));
      } on InterfaceParseException catch (e) {
        stderr.writeln('!  $e');
        totalFailures++;
      }
    }

    if (messages.isEmpty && services.isEmpty && actions.isEmpty) {
      stderr.writeln('!  $package: no .msg, .srv or .action files under '
          '${dir.path}');
      continue;
    }

    final writer = LibraryWriter(
      package: package,
      messages: messages,
      services: services,
      actions: actions,
    );
    final target = File('$outDir/$package.dart')
      ..writeAsStringSync(writer.write());
    totalMessages += messages.length;
    generated.add(package);

    for (final message in messages) {
      allTypes.add('$package/${message.name}');
    }
    for (final service in services) {
      allTypes.add('$package/${service.request.name}');
      allTypes.add('$package/${service.response.name}');
    }
    for (final action in actions) {
      allTypes.add('$package/${action.goal.name}');
      allTypes.add('$package/${action.result.name}');
      allTypes.add('$package/${action.feedback.name}');
    }
    emitted[package] = writer.referencedTypes;

    final summary = [
      '${messages.length} messages',
      if (services.isNotEmpty) '${services.length} services',
      if (actions.isNotEmpty) '${actions.length} actions',
    ].join(', ');

    final deps = writer.referencedPackages.where((d) => !done.contains(d));
    if (deps.isNotEmpty) {
      stdout.writeln('   ${target.path}  ($summary)'
          '  -> pulling in ${deps.join(', ')}');
      queue.addAll(deps);
    } else {
      stdout.writeln('   ${target.path}  ($summary)');
    }
  }

  generated.sort();
  _writeBarrel(output, generated);

  // A field can reference a type that has no .msg file -- ROS also allows
  // .idl definitions, which this generator does not read. Without this check
  // generation "succeeds" and the output simply fails to compile.
  final missing = <String>{};
  for (final entry in emitted.entries) {
    for (final type in entry.value) {
      if (!allTypes.contains(type)) missing.add('${entry.key}: $type');
    }
  }
  if (missing.isNotEmpty) {
    stderr.writeln('\n!  Referenced types with no .msg definition '
        '(likely .idl-only, which is not supported):');
    for (final item in missing) {
      stderr.writeln('!    $item');
    }
    stderr.writeln('!  The generated code will not compile until these are '
        'removed or provided.');
    totalFailures++;
  }

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
  // Imports, but deliberately no re-exports. ROS packages legitimately reuse
  // type names -- geometry_msgs/Pose and turtlesim/Pose, std_msgs/Bool and
  // example_interfaces/Bool -- and a barrel cannot export both. Import the
  // specific library you need, with a prefix when two collide:
  //
  //   import 'msgs/geometry_msgs.dart';
  //   import 'msgs/turtlesim.dart' as turtlesim;
  for (final package in packages) {
    buffer.writeln("import '$package.dart';");
  }
  buffer
    ..writeln()
    ..writeln('/// Registers every generated message, service and action.')
    ..writeln('///')
    ..writeln(
        '/// Call once at startup, before the first subscribe, advertise,')
    ..writeln('/// service call or action goal. This barrel intentionally does')
    ..writeln('/// not re-export the types: import the individual libraries')
    ..writeln('/// listed below, since ROS packages reuse type names.')
    ..writeln('///');
  for (final package in packages) {
    buffer.writeln("/// * `$package.dart`");
  }
  buffer.writeln('void registerGeneratedMessages() {');
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

/// Interface files of one kind inside a package share directory, sorted so
/// generation is deterministic.
List<File> _interfaceFiles(Directory pkg, String subdir, String extension) {
  final dir = Directory('${pkg.path}/$subdir');
  if (!dir.existsSync()) return const [];
  return dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(extension))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
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
