// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package visualization_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';
import 'package:ros2_client/ros2_client.dart' as ros2;

/// `visualization_msgs/msg/ImageMarker`
final class ImageMarker implements RosMessage {
  ImageMarker({
    ros2.Header? header,
    this.ns = '',
    this.id = 0,
    this.type = 0,
    this.action = 0,
    ros2.Point? position,
    this.scale = 0,
    ros2.ColorRGBA? outlineColor,
    this.filled = 0,
    ros2.ColorRGBA? fillColor,
    ros2.RosDuration? lifetime,
    this.points = const [],
    this.outlineColors = const [],
  })  : header = header ?? ros2.Header(),
        position = position ?? ros2.Point(),
        outlineColor = outlineColor ?? ros2.ColorRGBA(),
        fillColor = fillColor ?? ros2.ColorRGBA(),
        lifetime = lifetime ?? ros2.RosDuration();

  factory ImageMarker.fromJson(Map<String, Object?> json) => ImageMarker(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        ns: Field.asString(json['ns']),
        id: Field.asInt(json['id']),
        type: Field.asInt(json['type']),
        action: Field.asInt(json['action']),
        position: Field.asMessage(json['position'], ros2.Point.fromJson),
        scale: Field.asDouble(json['scale']),
        outlineColor:
            Field.asMessage(json['outline_color'], ros2.ColorRGBA.fromJson),
        filled: Field.asInt(json['filled']),
        fillColor: Field.asMessage(json['fill_color'], ros2.ColorRGBA.fromJson),
        lifetime: Field.asMessage(json['lifetime'], ros2.RosDuration.fromJson),
        points: Field.asList<ros2.Point>(json['points'], ros2.Point.fromJson),
        outlineColors: Field.asList<ros2.ColorRGBA>(
            json['outline_colors'], ros2.ColorRGBA.fromJson),
      );

  static const int circle = 0;
  static const int lineStrip = 1;
  static const int lineList = 2;
  static const int polygon = 3;
  static const int pointsConst = 4;
  static const int add = 0;
  static const int remove = 1;

  final ros2.Header header;
  final String ns;
  final int id;
  final int type;
  final int action;
  final ros2.Point position;
  final double scale;
  final ros2.ColorRGBA outlineColor;
  final int filled;
  final ros2.ColorRGBA fillColor;
  final ros2.RosDuration lifetime;
  final List<ros2.Point> points;
  final List<ros2.ColorRGBA> outlineColors;

  @override
  String get rosType => 'visualization_msgs/msg/ImageMarker';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'ns': ns,
        'id': id,
        'type': type,
        'action': action,
        'position': position.toJson(),
        'scale': scale,
        'outline_color': outlineColor.toJson(),
        'filled': filled,
        'fill_color': fillColor.toJson(),
        'lifetime': lifetime.toJson(),
        'points': points.map((ros2.Point e) => e.toJson()).toList(),
        'outline_colors':
            outlineColors.map((ros2.ColorRGBA e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageMarker &&
          other.header == header &&
          other.ns == ns &&
          other.id == id &&
          other.type == type &&
          other.action == action &&
          other.position == position &&
          other.scale == scale &&
          other.outlineColor == outlineColor &&
          other.filled == filled &&
          other.fillColor == fillColor &&
          other.lifetime == lifetime &&
          _listEquals(other.points, points) &&
          _listEquals(other.outlineColors, outlineColors));

  @override
  int get hashCode => Object.hashAll([
        header,
        ns,
        id,
        type,
        action,
        position,
        scale,
        outlineColor,
        filled,
        fillColor,
        lifetime,
        ...points,
        ...outlineColors,
      ]);

  @override
  String toString() => 'ImageMarker(${toJson()})';
}

/// Time/frame info.
/// If header.time is set to 0, the marker will be retransformed into
/// its frame on each timestep. You will receive the pose feedback
/// in the same frame.
/// Otherwise, you might receive feedback in a different frame.
/// For rviz, this will be the current 'fixed frame' set by the user.
///
/// `visualization_msgs/msg/InteractiveMarker`
final class InteractiveMarker implements RosMessage {
  InteractiveMarker({
    ros2.Header? header,
    ros2.Pose? pose,
    this.name = '',
    this.description = '',
    this.scale = 0,
    this.menuEntries = const [],
    this.controls = const [],
  })  : header = header ?? ros2.Header(),
        pose = pose ?? ros2.Pose();

  factory InteractiveMarker.fromJson(Map<String, Object?> json) =>
      InteractiveMarker(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        pose: Field.asMessage(json['pose'], ros2.Pose.fromJson),
        name: Field.asString(json['name']),
        description: Field.asString(json['description']),
        scale: Field.asDouble(json['scale']),
        menuEntries:
            Field.asList<MenuEntry>(json['menu_entries'], MenuEntry.fromJson),
        controls: Field.asList<InteractiveMarkerControl>(
            json['controls'], InteractiveMarkerControl.fromJson),
      );

  final ros2.Header header;
  final ros2.Pose pose;
  final String name;
  final String description;
  final double scale;
  final List<MenuEntry> menuEntries;
  final List<InteractiveMarkerControl> controls;

  @override
  String get rosType => 'visualization_msgs/msg/InteractiveMarker';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'pose': pose.toJson(),
        'name': name,
        'description': description,
        'scale': scale,
        'menu_entries': menuEntries.map((MenuEntry e) => e.toJson()).toList(),
        'controls':
            controls.map((InteractiveMarkerControl e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractiveMarker &&
          other.header == header &&
          other.pose == pose &&
          other.name == name &&
          other.description == description &&
          other.scale == scale &&
          _listEquals(other.menuEntries, menuEntries) &&
          _listEquals(other.controls, controls));

  @override
  int get hashCode => Object.hashAll([
        header,
        pose,
        name,
        description,
        scale,
        ...menuEntries,
        ...controls,
      ]);

  @override
  String toString() => 'InteractiveMarker(${toJson()})';
}

/// Represents a control that is to be displayed together with an interactive marker
///
/// `visualization_msgs/msg/InteractiveMarkerControl`
final class InteractiveMarkerControl implements RosMessage {
  InteractiveMarkerControl({
    this.name = '',
    ros2.Quaternion? orientation,
    this.orientationMode = 0,
    this.interactionMode = 0,
    this.alwaysVisible = false,
    this.markers = const [],
    this.independentMarkerOrientation = false,
    this.description = '',
  }) : orientation = orientation ?? ros2.Quaternion();

  factory InteractiveMarkerControl.fromJson(Map<String, Object?> json) =>
      InteractiveMarkerControl(
        name: Field.asString(json['name']),
        orientation:
            Field.asMessage(json['orientation'], ros2.Quaternion.fromJson),
        orientationMode: Field.asInt(json['orientation_mode']),
        interactionMode: Field.asInt(json['interaction_mode']),
        alwaysVisible: Field.asBool(json['always_visible']),
        markers: Field.asList<Marker>(json['markers'], Marker.fromJson),
        independentMarkerOrientation:
            Field.asBool(json['independent_marker_orientation']),
        description: Field.asString(json['description']),
      );

  static const int inherit = 0;
  static const int fixed = 1;
  static const int viewFacing = 2;
  static const int none = 0;
  static const int menu = 1;
  static const int button = 2;
  static const int moveAxis = 3;
  static const int movePlane = 4;
  static const int rotateAxis = 5;
  static const int moveRotate = 6;
  static const int move3d = 7;
  static const int rotate3d = 8;
  static const int moveRotate3d = 9;

  final String name;
  final ros2.Quaternion orientation;
  final int orientationMode;
  final int interactionMode;
  final bool alwaysVisible;
  final List<Marker> markers;
  final bool independentMarkerOrientation;
  final String description;

  @override
  String get rosType => 'visualization_msgs/msg/InteractiveMarkerControl';

  @override
  Map<String, Object?> toJson() => {
        'name': name,
        'orientation': orientation.toJson(),
        'orientation_mode': orientationMode,
        'interaction_mode': interactionMode,
        'always_visible': alwaysVisible,
        'markers': markers.map((Marker e) => e.toJson()).toList(),
        'independent_marker_orientation': independentMarkerOrientation,
        'description': description,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractiveMarkerControl &&
          other.name == name &&
          other.orientation == orientation &&
          other.orientationMode == orientationMode &&
          other.interactionMode == interactionMode &&
          other.alwaysVisible == alwaysVisible &&
          _listEquals(other.markers, markers) &&
          other.independentMarkerOrientation == independentMarkerOrientation &&
          other.description == description);

  @override
  int get hashCode => Object.hashAll([
        name,
        orientation,
        orientationMode,
        interactionMode,
        alwaysVisible,
        ...markers,
        independentMarkerOrientation,
        description,
      ]);

  @override
  String toString() => 'InteractiveMarkerControl(${toJson()})';
}

/// Time/frame info.
///
/// `visualization_msgs/msg/InteractiveMarkerFeedback`
final class InteractiveMarkerFeedback implements RosMessage {
  InteractiveMarkerFeedback({
    ros2.Header? header,
    this.clientId = '',
    this.markerName = '',
    this.controlName = '',
    this.eventType = 0,
    ros2.Pose? pose,
    this.menuEntryId = 0,
    ros2.Point? mousePoint,
    this.mousePointValid = false,
  })  : header = header ?? ros2.Header(),
        pose = pose ?? ros2.Pose(),
        mousePoint = mousePoint ?? ros2.Point();

  factory InteractiveMarkerFeedback.fromJson(Map<String, Object?> json) =>
      InteractiveMarkerFeedback(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        clientId: Field.asString(json['client_id']),
        markerName: Field.asString(json['marker_name']),
        controlName: Field.asString(json['control_name']),
        eventType: Field.asInt(json['event_type']),
        pose: Field.asMessage(json['pose'], ros2.Pose.fromJson),
        menuEntryId: Field.asInt(json['menu_entry_id']),
        mousePoint: Field.asMessage(json['mouse_point'], ros2.Point.fromJson),
        mousePointValid: Field.asBool(json['mouse_point_valid']),
      );

  static const int keepAlive = 0;
  static const int poseUpdate = 1;
  static const int menuSelect = 2;
  static const int buttonClick = 3;
  static const int mouseDown = 4;
  static const int mouseUp = 5;

  final ros2.Header header;
  final String clientId;
  final String markerName;
  final String controlName;
  final int eventType;
  final ros2.Pose pose;
  final int menuEntryId;
  final ros2.Point mousePoint;
  final bool mousePointValid;

  @override
  String get rosType => 'visualization_msgs/msg/InteractiveMarkerFeedback';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'client_id': clientId,
        'marker_name': markerName,
        'control_name': controlName,
        'event_type': eventType,
        'pose': pose.toJson(),
        'menu_entry_id': menuEntryId,
        'mouse_point': mousePoint.toJson(),
        'mouse_point_valid': mousePointValid,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractiveMarkerFeedback &&
          other.header == header &&
          other.clientId == clientId &&
          other.markerName == markerName &&
          other.controlName == controlName &&
          other.eventType == eventType &&
          other.pose == pose &&
          other.menuEntryId == menuEntryId &&
          other.mousePoint == mousePoint &&
          other.mousePointValid == mousePointValid);

  @override
  int get hashCode => Object.hashAll([
        header,
        clientId,
        markerName,
        controlName,
        eventType,
        pose,
        menuEntryId,
        mousePoint,
        mousePointValid,
      ]);

  @override
  String toString() => 'InteractiveMarkerFeedback(${toJson()})';
}

/// Identifying string. Must be unique in the topic namespace
/// that this server works on.
///
/// `visualization_msgs/msg/InteractiveMarkerInit`
final class InteractiveMarkerInit implements RosMessage {
  const InteractiveMarkerInit({
    this.serverId = '',
    this.seqNum = 0,
    this.markers = const [],
  });

  factory InteractiveMarkerInit.fromJson(Map<String, Object?> json) =>
      InteractiveMarkerInit(
        serverId: Field.asString(json['server_id']),
        seqNum: Field.asInt(json['seq_num']),
        markers: Field.asList<InteractiveMarker>(
            json['markers'], InteractiveMarker.fromJson),
      );

  final String serverId;
  final int seqNum;
  final List<InteractiveMarker> markers;

  @override
  String get rosType => 'visualization_msgs/msg/InteractiveMarkerInit';

  @override
  Map<String, Object?> toJson() => {
        'server_id': serverId,
        'seq_num': seqNum,
        'markers': markers.map((InteractiveMarker e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractiveMarkerInit &&
          other.serverId == serverId &&
          other.seqNum == seqNum &&
          _listEquals(other.markers, markers));

  @override
  int get hashCode => Object.hashAll([
        serverId,
        seqNum,
        ...markers,
      ]);

  @override
  String toString() => 'InteractiveMarkerInit(${toJson()})';
}

/// Time/frame info.
///
/// `visualization_msgs/msg/InteractiveMarkerPose`
final class InteractiveMarkerPose implements RosMessage {
  InteractiveMarkerPose({
    ros2.Header? header,
    ros2.Pose? pose,
    this.name = '',
  })  : header = header ?? ros2.Header(),
        pose = pose ?? ros2.Pose();

  factory InteractiveMarkerPose.fromJson(Map<String, Object?> json) =>
      InteractiveMarkerPose(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        pose: Field.asMessage(json['pose'], ros2.Pose.fromJson),
        name: Field.asString(json['name']),
      );

  final ros2.Header header;
  final ros2.Pose pose;
  final String name;

  @override
  String get rosType => 'visualization_msgs/msg/InteractiveMarkerPose';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'pose': pose.toJson(),
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractiveMarkerPose &&
          other.header == header &&
          other.pose == pose &&
          other.name == name);

  @override
  int get hashCode => Object.hashAll([
        header,
        pose,
        name,
      ]);

  @override
  String toString() => 'InteractiveMarkerPose(${toJson()})';
}

/// Identifying string. Must be unique in the topic namespace
/// that this server works on.
///
/// `visualization_msgs/msg/InteractiveMarkerUpdate`
final class InteractiveMarkerUpdate implements RosMessage {
  const InteractiveMarkerUpdate({
    this.serverId = '',
    this.seqNum = 0,
    this.type = 0,
    this.markers = const [],
    this.poses = const [],
    this.erases = const [],
  });

  factory InteractiveMarkerUpdate.fromJson(Map<String, Object?> json) =>
      InteractiveMarkerUpdate(
        serverId: Field.asString(json['server_id']),
        seqNum: Field.asInt(json['seq_num']),
        type: Field.asInt(json['type']),
        markers: Field.asList<InteractiveMarker>(
            json['markers'], InteractiveMarker.fromJson),
        poses: Field.asList<InteractiveMarkerPose>(
            json['poses'], InteractiveMarkerPose.fromJson),
        erases: Field.asStringList(json['erases']),
      );

  static const int keepAlive = 0;
  static const int update = 1;

  final String serverId;
  final int seqNum;
  final int type;
  final List<InteractiveMarker> markers;
  final List<InteractiveMarkerPose> poses;
  final List<String> erases;

  @override
  String get rosType => 'visualization_msgs/msg/InteractiveMarkerUpdate';

  @override
  Map<String, Object?> toJson() => {
        'server_id': serverId,
        'seq_num': seqNum,
        'type': type,
        'markers': markers.map((InteractiveMarker e) => e.toJson()).toList(),
        'poses': poses.map((InteractiveMarkerPose e) => e.toJson()).toList(),
        'erases': erases,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractiveMarkerUpdate &&
          other.serverId == serverId &&
          other.seqNum == seqNum &&
          other.type == type &&
          _listEquals(other.markers, markers) &&
          _listEquals(other.poses, poses) &&
          _listEquals(other.erases, erases));

  @override
  int get hashCode => Object.hashAll([
        serverId,
        seqNum,
        type,
        ...markers,
        ...poses,
        ...erases,
      ]);

  @override
  String toString() => 'InteractiveMarkerUpdate(${toJson()})';
}

/// See:
/// - http://www.ros.org/wiki/rviz/DisplayTypes/Marker
/// - http://www.ros.org/wiki/rviz/Tutorials/Markers%3A%20Basic%20Shapes
///
/// for more information on using this message with rviz.
///
/// `visualization_msgs/msg/Marker`
final class Marker implements RosMessage {
  Marker({
    ros2.Header? header,
    this.ns = '',
    this.id = 0,
    this.type = 0,
    this.action = 0,
    ros2.Pose? pose,
    ros2.Vector3? scale,
    ros2.ColorRGBA? color,
    ros2.RosDuration? lifetime,
    this.frameLocked = false,
    this.points = const [],
    this.colors = const [],
    this.textureResource = '',
    ros2.CompressedImage? texture,
    this.uvCoordinates = const [],
    this.text = '',
    this.meshResource = '',
    MeshFile? meshFile,
    this.meshUseEmbeddedMaterials = false,
  })  : header = header ?? ros2.Header(),
        pose = pose ?? ros2.Pose(),
        scale = scale ?? ros2.Vector3(),
        color = color ?? ros2.ColorRGBA(),
        lifetime = lifetime ?? ros2.RosDuration(),
        texture = texture ?? ros2.CompressedImage.fromJson(const {}),
        meshFile = meshFile ?? MeshFile();

  factory Marker.fromJson(Map<String, Object?> json) => Marker(
        header: Field.asMessage(json['header'], ros2.Header.fromJson),
        ns: Field.asString(json['ns']),
        id: Field.asInt(json['id']),
        type: Field.asInt(json['type']),
        action: Field.asInt(json['action']),
        pose: Field.asMessage(json['pose'], ros2.Pose.fromJson),
        scale: Field.asMessage(json['scale'], ros2.Vector3.fromJson),
        color: Field.asMessage(json['color'], ros2.ColorRGBA.fromJson),
        lifetime: Field.asMessage(json['lifetime'], ros2.RosDuration.fromJson),
        frameLocked: Field.asBool(json['frame_locked']),
        points: Field.asList<ros2.Point>(json['points'], ros2.Point.fromJson),
        colors: Field.asList<ros2.ColorRGBA>(
            json['colors'], ros2.ColorRGBA.fromJson),
        textureResource: Field.asString(json['texture_resource']),
        texture:
            Field.asMessage(json['texture'], ros2.CompressedImage.fromJson),
        uvCoordinates: Field.asList<UVCoordinate>(
            json['uv_coordinates'], UVCoordinate.fromJson),
        text: Field.asString(json['text']),
        meshResource: Field.asString(json['mesh_resource']),
        meshFile: Field.asMessage(json['mesh_file'], MeshFile.fromJson),
        meshUseEmbeddedMaterials:
            Field.asBool(json['mesh_use_embedded_materials']),
      );

  static const int arrow = 0;
  static const int cube = 1;
  static const int sphere = 2;
  static const int cylinder = 3;
  static const int lineStrip = 4;
  static const int lineList = 5;
  static const int cubeList = 6;
  static const int sphereList = 7;
  static const int pointsConst = 8;
  static const int textViewFacing = 9;
  static const int meshResourceConst = 10;
  static const int triangleList = 11;
  static const int add = 0;
  static const int modify = 0;
  static const int delete = 2;
  static const int deleteall = 3;

  final ros2.Header header;
  final String ns;
  final int id;
  final int type;
  final int action;
  final ros2.Pose pose;
  final ros2.Vector3 scale;
  final ros2.ColorRGBA color;
  final ros2.RosDuration lifetime;
  final bool frameLocked;
  final List<ros2.Point> points;
  final List<ros2.ColorRGBA> colors;
  final String textureResource;
  final ros2.CompressedImage texture;
  final List<UVCoordinate> uvCoordinates;
  final String text;
  final String meshResource;
  final MeshFile meshFile;
  final bool meshUseEmbeddedMaterials;

  @override
  String get rosType => 'visualization_msgs/msg/Marker';

  @override
  Map<String, Object?> toJson() => {
        'header': header.toJson(),
        'ns': ns,
        'id': id,
        'type': type,
        'action': action,
        'pose': pose.toJson(),
        'scale': scale.toJson(),
        'color': color.toJson(),
        'lifetime': lifetime.toJson(),
        'frame_locked': frameLocked,
        'points': points.map((ros2.Point e) => e.toJson()).toList(),
        'colors': colors.map((ros2.ColorRGBA e) => e.toJson()).toList(),
        'texture_resource': textureResource,
        'texture': texture.toJson(),
        'uv_coordinates':
            uvCoordinates.map((UVCoordinate e) => e.toJson()).toList(),
        'text': text,
        'mesh_resource': meshResource,
        'mesh_file': meshFile.toJson(),
        'mesh_use_embedded_materials': meshUseEmbeddedMaterials,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Marker &&
          other.header == header &&
          other.ns == ns &&
          other.id == id &&
          other.type == type &&
          other.action == action &&
          other.pose == pose &&
          other.scale == scale &&
          other.color == color &&
          other.lifetime == lifetime &&
          other.frameLocked == frameLocked &&
          _listEquals(other.points, points) &&
          _listEquals(other.colors, colors) &&
          other.textureResource == textureResource &&
          other.texture == texture &&
          _listEquals(other.uvCoordinates, uvCoordinates) &&
          other.text == text &&
          other.meshResource == meshResource &&
          other.meshFile == meshFile &&
          other.meshUseEmbeddedMaterials == meshUseEmbeddedMaterials);

  @override
  int get hashCode => Object.hashAll([
        header,
        ns,
        id,
        type,
        action,
        pose,
        scale,
        color,
        lifetime,
        frameLocked,
        ...points,
        ...colors,
        textureResource,
        texture,
        ...uvCoordinates,
        text,
        meshResource,
        meshFile,
        meshUseEmbeddedMaterials,
      ]);

  @override
  String toString() => 'Marker(${toJson()})';
}

/// `visualization_msgs/msg/MarkerArray`
final class MarkerArray implements RosMessage {
  const MarkerArray({
    this.markers = const [],
  });

  factory MarkerArray.fromJson(Map<String, Object?> json) => MarkerArray(
        markers: Field.asList<Marker>(json['markers'], Marker.fromJson),
      );

  final List<Marker> markers;

  @override
  String get rosType => 'visualization_msgs/msg/MarkerArray';

  @override
  Map<String, Object?> toJson() => {
        'markers': markers.map((Marker e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarkerArray && _listEquals(other.markers, markers));

  @override
  int get hashCode => Object.hashAll([
        ...markers,
      ]);

  @override
  String toString() => 'MarkerArray(${toJson()})';
}

/// MenuEntry message.
///
/// Each InteractiveMarker message has an array of MenuEntry messages.
/// A collection of MenuEntries together describe a
/// menu/submenu/subsubmenu/etc tree, though they are stored in a flat
/// array.  The tree structure is represented by giving each menu entry
/// an ID number and a "parent_id" field.  Top-level entries are the
/// ones with parent_id = 0.  Menu entries are ordered within their
/// level the same way they are ordered in the containing array.  Parent
/// entries must appear before their children.
///
/// Example:
/// - id = 3
/// parent_id = 0
/// title = "fun"
/// - id = 2
/// parent_id = 0
/// title = "robot"
/// - id = 4
/// parent_id = 2
/// title = "pr2"
/// - id = 5
/// parent_id = 2
/// title = "turtle"
///
/// Gives a menu tree like this:
/// - fun
/// - robot
/// - pr2
/// - turtle
///
/// `visualization_msgs/msg/MenuEntry`
final class MenuEntry implements RosMessage {
  const MenuEntry({
    this.id = 0,
    this.parentId = 0,
    this.title = '',
    this.command = '',
    this.commandType = 0,
  });

  factory MenuEntry.fromJson(Map<String, Object?> json) => MenuEntry(
        id: Field.asInt(json['id']),
        parentId: Field.asInt(json['parent_id']),
        title: Field.asString(json['title']),
        command: Field.asString(json['command']),
        commandType: Field.asInt(json['command_type']),
      );

  static const int feedback = 0;
  static const int rosrun = 1;
  static const int roslaunch = 2;

  final int id;
  final int parentId;
  final String title;
  final String command;
  final int commandType;

  @override
  String get rosType => 'visualization_msgs/msg/MenuEntry';

  @override
  Map<String, Object?> toJson() => {
        'id': id,
        'parent_id': parentId,
        'title': title,
        'command': command,
        'command_type': commandType,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuEntry &&
          other.id == id &&
          other.parentId == parentId &&
          other.title == title &&
          other.command == command &&
          other.commandType == commandType);

  @override
  int get hashCode => Object.hashAll([
        id,
        parentId,
        title,
        command,
        commandType,
      ]);

  @override
  String toString() => 'MenuEntry(${toJson()})';
}

/// Used to send raw mesh files.
///
/// `visualization_msgs/msg/MeshFile`
final class MeshFile implements RosMessage {
  MeshFile({
    this.filename = '',
    Uint8List? data,
  }) : data = data ?? Uint8List(0);

  factory MeshFile.fromJson(Map<String, Object?> json) => MeshFile(
        filename: Field.asString(json['filename']),
        data: Field.asBytes(json['data']),
      );

  final String filename;
  final Uint8List data;

  @override
  String get rosType => 'visualization_msgs/msg/MeshFile';

  @override
  Map<String, Object?> toJson() => {
        'filename': filename,
        'data': Field.encodeBytes(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshFile &&
          other.filename == filename &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        filename,
        ...data,
      ]);

  @override
  String toString() => 'MeshFile(${toJson()})';
}

/// Location of the pixel as a ratio of the width of a 2D texture.
/// Values should be in range: [0.0-1.0].
///
/// `visualization_msgs/msg/UVCoordinate`
final class UVCoordinate implements RosMessage {
  const UVCoordinate({
    this.u = 0,
    this.v = 0,
  });

  factory UVCoordinate.fromJson(Map<String, Object?> json) => UVCoordinate(
        u: Field.asDouble(json['u']),
        v: Field.asDouble(json['v']),
      );

  final double u;
  final double v;

  @override
  String get rosType => 'visualization_msgs/msg/UVCoordinate';

  @override
  Map<String, Object?> toJson() => {
        'u': u,
        'v': v,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UVCoordinate && other.u == u && other.v == v);

  @override
  int get hashCode => Object.hashAll([
        u,
        v,
      ]);

  @override
  String toString() => 'UVCoordinate(${toJson()})';
}

/// `visualization_msgs/msg/GetInteractiveMarkers_Request`
final class GetInteractiveMarkersRequest implements RosMessage {
  const GetInteractiveMarkersRequest();

  factory GetInteractiveMarkersRequest.fromJson(Map<String, Object?> json) =>
      GetInteractiveMarkersRequest();

  @override
  String get rosType => 'visualization_msgs/msg/GetInteractiveMarkers_Request';

  @override
  Map<String, Object?> toJson() => {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GetInteractiveMarkersRequest;

  @override
  int get hashCode => Object.hashAll([]);

  @override
  String toString() => 'GetInteractiveMarkersRequest(${toJson()})';
}

/// Sequence number.
/// Set to the sequence number of the latest update message
/// at the time the server received the request.
/// Clients use this to detect if any updates were missed.
///
/// `visualization_msgs/msg/GetInteractiveMarkers_Response`
final class GetInteractiveMarkersResponse implements RosMessage {
  const GetInteractiveMarkersResponse({
    this.sequenceNumber = 0,
    this.markers = const [],
  });

  factory GetInteractiveMarkersResponse.fromJson(Map<String, Object?> json) =>
      GetInteractiveMarkersResponse(
        sequenceNumber: Field.asInt(json['sequence_number']),
        markers: Field.asList<InteractiveMarker>(
            json['markers'], InteractiveMarker.fromJson),
      );

  final int sequenceNumber;
  final List<InteractiveMarker> markers;

  @override
  String get rosType => 'visualization_msgs/msg/GetInteractiveMarkers_Response';

  @override
  Map<String, Object?> toJson() => {
        'sequence_number': sequenceNumber,
        'markers': markers.map((InteractiveMarker e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GetInteractiveMarkersResponse &&
          other.sequenceNumber == sequenceNumber &&
          _listEquals(other.markers, markers));

  @override
  int get hashCode => Object.hashAll([
        sequenceNumber,
        ...markers,
      ]);

  @override
  String toString() => 'GetInteractiveMarkersResponse(${toJson()})';
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

/// Registers every message in `visualization_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerVisualizationMsgs() {
  MessageRegistry.register(const MessageCodec<ImageMarker>(
    rosType: 'visualization_msgs/msg/ImageMarker',
    fromJson: ImageMarker.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InteractiveMarker>(
    rosType: 'visualization_msgs/msg/InteractiveMarker',
    fromJson: InteractiveMarker.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InteractiveMarkerControl>(
    rosType: 'visualization_msgs/msg/InteractiveMarkerControl',
    fromJson: InteractiveMarkerControl.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InteractiveMarkerFeedback>(
    rosType: 'visualization_msgs/msg/InteractiveMarkerFeedback',
    fromJson: InteractiveMarkerFeedback.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InteractiveMarkerInit>(
    rosType: 'visualization_msgs/msg/InteractiveMarkerInit',
    fromJson: InteractiveMarkerInit.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InteractiveMarkerPose>(
    rosType: 'visualization_msgs/msg/InteractiveMarkerPose',
    fromJson: InteractiveMarkerPose.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<InteractiveMarkerUpdate>(
    rosType: 'visualization_msgs/msg/InteractiveMarkerUpdate',
    fromJson: InteractiveMarkerUpdate.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Marker>(
    rosType: 'visualization_msgs/msg/Marker',
    fromJson: Marker.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MarkerArray>(
    rosType: 'visualization_msgs/msg/MarkerArray',
    fromJson: MarkerArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MenuEntry>(
    rosType: 'visualization_msgs/msg/MenuEntry',
    fromJson: MenuEntry.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MeshFile>(
    rosType: 'visualization_msgs/msg/MeshFile',
    fromJson: MeshFile.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UVCoordinate>(
    rosType: 'visualization_msgs/msg/UVCoordinate',
    fromJson: UVCoordinate.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetInteractiveMarkersRequest>(
    rosType: 'visualization_msgs/msg/GetInteractiveMarkers_Request',
    fromJson: GetInteractiveMarkersRequest.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<GetInteractiveMarkersResponse>(
    rosType: 'visualization_msgs/msg/GetInteractiveMarkers_Response',
    fromJson: GetInteractiveMarkersResponse.fromJson,
    toJson: _toJson,
  ));
  ServiceRegistry.register(const ServiceCodec<GetInteractiveMarkersRequest,
      GetInteractiveMarkersResponse>(
    serviceType: 'visualization_msgs/srv/GetInteractiveMarkers',
    encodeRequest: _toJson,
    decodeResponse: GetInteractiveMarkersResponse.fromJson,
    decodeRequest: GetInteractiveMarkersRequest.fromJson,
    encodeResponse: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
