// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package shape_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;
import 'geometry_msgs.dart';

/// Definition of a mesh.
///
/// `shape_msgs/msg/Mesh`
final class Mesh implements RosMessage {
  const Mesh({
    this.triangles = const [],
    this.vertices = const [],
  });

  factory Mesh.fromJson(Map<String, Object?> json) => Mesh(
        triangles: Field.asList<MeshTriangle>(
            json['triangles'], MeshTriangle.fromJson),
        vertices:
            Field.asList<ros2.Point>(json['vertices'], ros2.Point.fromJson),
      );

  final List<MeshTriangle> triangles;
  final List<ros2.Point> vertices;

  @override
  String get rosType => 'shape_msgs/msg/Mesh';

  @override
  Map<String, Object?> toJson() => {
        'triangles': triangles.map((MeshTriangle e) => e.toJson()).toList(),
        'vertices': vertices.map((ros2.Point e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mesh &&
          _listEquals(other.triangles, triangles) &&
          _listEquals(other.vertices, vertices));

  @override
  int get hashCode => Object.hashAll([
        ...triangles,
        ...vertices,
      ]);

  @override
  String toString() => 'Mesh(${toJson()})';
}

/// Definition of a triangle's vertices.
///
/// `shape_msgs/msg/MeshTriangle`
final class MeshTriangle implements RosMessage {
  MeshTriangle({
    Uint32List? vertexIndices,
  }) : vertexIndices = vertexIndices ?? Uint32List(3);

  factory MeshTriangle.fromJson(Map<String, Object?> json) => MeshTriangle(
        vertexIndices: Field.asUint32List(json['vertex_indices']),
      );

  /// Fixed length: 3.
  final Uint32List vertexIndices;

  @override
  String get rosType => 'shape_msgs/msg/MeshTriangle';

  @override
  Map<String, Object?> toJson() => {
        'vertex_indices': Field.encodeNumbers(vertexIndices),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshTriangle &&
          _listEquals(other.vertexIndices, vertexIndices));

  @override
  int get hashCode => Object.hashAll([
        ...vertexIndices,
      ]);

  @override
  String toString() => 'MeshTriangle(${toJson()})';
}

/// Representation of a plane, using the plane equation ax + by + cz + d = 0.
///
/// a := coef[0]
/// b := coef[1]
/// c := coef[2]
/// d := coef[3]
///
/// `shape_msgs/msg/Plane`
final class Plane implements RosMessage {
  Plane({
    Float64List? coef,
  }) : coef = coef ?? Float64List(4);

  factory Plane.fromJson(Map<String, Object?> json) => Plane(
        coef: Field.asFloat64List(json['coef']),
      );

  /// Fixed length: 4.
  final Float64List coef;

  @override
  String get rosType => 'shape_msgs/msg/Plane';

  @override
  Map<String, Object?> toJson() => {
        'coef': Field.encodeNumbers(coef),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plane && _listEquals(other.coef, coef));

  @override
  int get hashCode => Object.hashAll([
        ...coef,
      ]);

  @override
  String toString() => 'Plane(${toJson()})';
}

/// Defines box, sphere, cylinder, cone and prism.
/// All shapes are defined to have their bounding boxes centered around 0,0,0.
///
/// `shape_msgs/msg/SolidPrimitive`
final class SolidPrimitive implements RosMessage {
  SolidPrimitive({
    this.type = 0,
    Float64List? dimensions,
    Polygon? polygon,
  })  : dimensions = dimensions ?? Float64List(0),
        polygon = polygon ?? Polygon();

  factory SolidPrimitive.fromJson(Map<String, Object?> json) => SolidPrimitive(
        type: Field.asInt(json['type']),
        dimensions: Field.asFloat64List(json['dimensions']),
        polygon: Field.asMessage(json['polygon'], Polygon.fromJson),
      );

  static const int box = 1;
  static const int sphere = 2;
  static const int cylinder = 3;
  static const int cone = 4;
  static const int prism = 5;
  static const int boxX = 0;
  static const int boxY = 1;
  static const int boxZ = 2;
  static const int sphereRadius = 0;
  static const int cylinderHeight = 0;
  static const int cylinderRadius = 1;
  static const int coneHeight = 0;
  static const int coneRadius = 1;
  static const int prismHeight = 0;

  final int type;

  /// At no point will dimensions have a length &gt; 3.
  /// At most 3 elements.
  final Float64List dimensions;
  final Polygon polygon;

  @override
  String get rosType => 'shape_msgs/msg/SolidPrimitive';

  @override
  Map<String, Object?> toJson() => {
        'type': type,
        'dimensions': Field.encodeNumbers(dimensions),
        'polygon': polygon.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolidPrimitive &&
          other.type == type &&
          _listEquals(other.dimensions, dimensions) &&
          other.polygon == polygon);

  @override
  int get hashCode => Object.hashAll([
        type,
        ...dimensions,
        polygon,
      ]);

  @override
  String toString() => 'SolidPrimitive(${toJson()})';
}

/// Element-wise list comparison used by generated `==`.
bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Registers every message in `shape_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerShapeMsgs() {
  MessageRegistry.register(const MessageCodec<Mesh>(
    rosType: 'shape_msgs/msg/Mesh',
    fromJson: Mesh.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MeshTriangle>(
    rosType: 'shape_msgs/msg/MeshTriangle',
    fromJson: MeshTriangle.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Plane>(
    rosType: 'shape_msgs/msg/Plane',
    fromJson: Plane.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<SolidPrimitive>(
    rosType: 'shape_msgs/msg/SolidPrimitive',
    fromJson: SolidPrimitive.fromJson,
    toJson: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
