// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Regenerate with:
//   dart run ros2_client:generate --package std_msgs

import 'dart:typed_data';

import 'package:ros2_client/codegen_support.dart';

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Byte`
final class Byte implements RosMessage {
  const Byte({
    this.data = 0,
  });

  factory Byte.fromJson(Map<String, Object?> json) => Byte(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/Byte';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Byte && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'Byte(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/ByteMultiArray`
final class ByteMultiArray implements RosMessage {
  ByteMultiArray({
    MultiArrayLayout? layout,
    Uint8List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Uint8List(0);

  factory ByteMultiArray.fromJson(Map<String, Object?> json) => ByteMultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asBytes(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Uint8List data;

  @override
  String get rosType => 'std_msgs/msg/ByteMultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeBytes(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ByteMultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'ByteMultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Char`
final class Char implements RosMessage {
  const Char({
    this.data = 0,
  });

  factory Char.fromJson(Map<String, Object?> json) => Char(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/Char';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Char && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'Char(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Float32`
final class Float32 implements RosMessage {
  const Float32({
    this.data = 0,
  });

  factory Float32.fromJson(Map<String, Object?> json) => Float32(
        data: Field.asDouble(json['data']),
      );

  final double data;

  @override
  String get rosType => 'std_msgs/msg/Float32';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Float32 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'Float32(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Float32MultiArray`
final class Float32MultiArray implements RosMessage {
  Float32MultiArray({
    MultiArrayLayout? layout,
    Float32List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Float32List(0);

  factory Float32MultiArray.fromJson(Map<String, Object?> json) =>
      Float32MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asFloat32List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Float32List data;

  @override
  String get rosType => 'std_msgs/msg/Float32MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Float32MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'Float32MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Float64MultiArray`
final class Float64MultiArray implements RosMessage {
  Float64MultiArray({
    MultiArrayLayout? layout,
    Float64List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Float64List(0);

  factory Float64MultiArray.fromJson(Map<String, Object?> json) =>
      Float64MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asFloat64List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Float64List data;

  @override
  String get rosType => 'std_msgs/msg/Float64MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Float64MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'Float64MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Int16`
final class Int16 implements RosMessage {
  const Int16({
    this.data = 0,
  });

  factory Int16.fromJson(Map<String, Object?> json) => Int16(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/Int16';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Int16 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'Int16(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Int16MultiArray`
final class Int16MultiArray implements RosMessage {
  Int16MultiArray({
    MultiArrayLayout? layout,
    Int16List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Int16List(0);

  factory Int16MultiArray.fromJson(Map<String, Object?> json) =>
      Int16MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asInt16List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Int16List data;

  @override
  String get rosType => 'std_msgs/msg/Int16MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Int16MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'Int16MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Int32MultiArray`
final class Int32MultiArray implements RosMessage {
  Int32MultiArray({
    MultiArrayLayout? layout,
    Int32List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Int32List(0);

  factory Int32MultiArray.fromJson(Map<String, Object?> json) =>
      Int32MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asInt32List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Int32List data;

  @override
  String get rosType => 'std_msgs/msg/Int32MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Int32MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'Int32MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Int64`
final class Int64 implements RosMessage {
  const Int64({
    this.data = 0,
  });

  factory Int64.fromJson(Map<String, Object?> json) => Int64(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/Int64';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Int64 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'Int64(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Int64MultiArray`
final class Int64MultiArray implements RosMessage {
  Int64MultiArray({
    MultiArrayLayout? layout,
    Int64List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Int64List(0);

  factory Int64MultiArray.fromJson(Map<String, Object?> json) =>
      Int64MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asInt64List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Int64List data;

  @override
  String get rosType => 'std_msgs/msg/Int64MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Int64MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'Int64MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Int8`
final class Int8 implements RosMessage {
  const Int8({
    this.data = 0,
  });

  factory Int8.fromJson(Map<String, Object?> json) => Int8(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/Int8';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Int8 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'Int8(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/Int8MultiArray`
final class Int8MultiArray implements RosMessage {
  Int8MultiArray({
    MultiArrayLayout? layout,
    Int8List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Int8List(0);

  factory Int8MultiArray.fromJson(Map<String, Object?> json) => Int8MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asInt8List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Int8List data;

  @override
  String get rosType => 'std_msgs/msg/Int8MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Int8MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'Int8MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/MultiArrayDimension`
final class MultiArrayDimension implements RosMessage {
  const MultiArrayDimension({
    this.label = '',
    this.size = 0,
    this.stride = 0,
  });

  factory MultiArrayDimension.fromJson(Map<String, Object?> json) =>
      MultiArrayDimension(
        label: Field.asString(json['label']),
        size: Field.asInt(json['size']),
        stride: Field.asInt(json['stride']),
      );

  /// label of given dimension
  final String label;

  /// size of given dimension (in type units)
  final int size;

  /// stride of given dimension
  final int stride;

  @override
  String get rosType => 'std_msgs/msg/MultiArrayDimension';

  @override
  Map<String, Object?> toJson() => {
        'label': label,
        'size': size,
        'stride': stride,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiArrayDimension &&
          other.label == label &&
          other.size == size &&
          other.stride == stride);

  @override
  int get hashCode => Object.hashAll([
        label,
        size,
        stride,
      ]);

  @override
  String toString() => 'MultiArrayDimension(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/MultiArrayLayout`
final class MultiArrayLayout implements RosMessage {
  const MultiArrayLayout({
    this.dim = const [],
    this.dataOffset = 0,
  });

  factory MultiArrayLayout.fromJson(Map<String, Object?> json) =>
      MultiArrayLayout(
        dim: Field.asList<MultiArrayDimension>(
            json['dim'], MultiArrayDimension.fromJson),
        dataOffset: Field.asInt(json['data_offset']),
      );

  /// Array of dimension properties
  final List<MultiArrayDimension> dim;

  /// padding bytes at front of data
  final int dataOffset;

  @override
  String get rosType => 'std_msgs/msg/MultiArrayLayout';

  @override
  Map<String, Object?> toJson() => {
        'dim': dim.map((MultiArrayDimension e) => e.toJson()).toList(),
        'data_offset': dataOffset,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiArrayLayout &&
          _listEquals(other.dim, dim) &&
          other.dataOffset == dataOffset);

  @override
  int get hashCode => Object.hashAll([
        ...dim,
        dataOffset,
      ]);

  @override
  String toString() => 'MultiArrayLayout(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt16`
final class UInt16 implements RosMessage {
  const UInt16({
    this.data = 0,
  });

  factory UInt16.fromJson(Map<String, Object?> json) => UInt16(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/UInt16';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UInt16 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'UInt16(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt16MultiArray`
final class UInt16MultiArray implements RosMessage {
  UInt16MultiArray({
    MultiArrayLayout? layout,
    Uint16List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Uint16List(0);

  factory UInt16MultiArray.fromJson(Map<String, Object?> json) =>
      UInt16MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asUint16List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Uint16List data;

  @override
  String get rosType => 'std_msgs/msg/UInt16MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UInt16MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'UInt16MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt32`
final class UInt32 implements RosMessage {
  const UInt32({
    this.data = 0,
  });

  factory UInt32.fromJson(Map<String, Object?> json) => UInt32(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/UInt32';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UInt32 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'UInt32(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt32MultiArray`
final class UInt32MultiArray implements RosMessage {
  UInt32MultiArray({
    MultiArrayLayout? layout,
    Uint32List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Uint32List(0);

  factory UInt32MultiArray.fromJson(Map<String, Object?> json) =>
      UInt32MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asUint32List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Uint32List data;

  @override
  String get rosType => 'std_msgs/msg/UInt32MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UInt32MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'UInt32MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt64`
final class UInt64 implements RosMessage {
  const UInt64({
    this.data = 0,
  });

  factory UInt64.fromJson(Map<String, Object?> json) => UInt64(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/UInt64';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UInt64 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'UInt64(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt64MultiArray`
final class UInt64MultiArray implements RosMessage {
  UInt64MultiArray({
    MultiArrayLayout? layout,
    Uint64List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Uint64List(0);

  factory UInt64MultiArray.fromJson(Map<String, Object?> json) =>
      UInt64MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asUint64List(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Uint64List data;

  @override
  String get rosType => 'std_msgs/msg/UInt64MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeNumbers(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UInt64MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'UInt64MultiArray(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt8`
final class UInt8 implements RosMessage {
  const UInt8({
    this.data = 0,
  });

  factory UInt8.fromJson(Map<String, Object?> json) => UInt8(
        data: Field.asInt(json['data']),
      );

  final int data;

  @override
  String get rosType => 'std_msgs/msg/UInt8';

  @override
  Map<String, Object?> toJson() => {
        'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UInt8 && other.data == data);

  @override
  int get hashCode => Object.hashAll([
        data,
      ]);

  @override
  String toString() => 'UInt8(${toJson()})';
}

/// This was originally provided as an example message.
/// It is deprecated as of Foxy
/// It is recommended to create your own semantically meaningful message.
/// However if you would like to continue using this please use the equivalent in example_msgs.
///
/// `std_msgs/msg/UInt8MultiArray`
final class UInt8MultiArray implements RosMessage {
  UInt8MultiArray({
    MultiArrayLayout? layout,
    Uint8List? data,
  })  : layout = layout ?? MultiArrayLayout(),
        data = data ?? Uint8List(0);

  factory UInt8MultiArray.fromJson(Map<String, Object?> json) =>
      UInt8MultiArray(
        layout: Field.asMessage(json['layout'], MultiArrayLayout.fromJson),
        data: Field.asBytes(json['data']),
      );

  /// specification of data layout
  final MultiArrayLayout layout;

  /// array of data
  final Uint8List data;

  @override
  String get rosType => 'std_msgs/msg/UInt8MultiArray';

  @override
  Map<String, Object?> toJson() => {
        'layout': layout.toJson(),
        'data': Field.encodeBytes(data),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UInt8MultiArray &&
          other.layout == layout &&
          _listEquals(other.data, data));

  @override
  int get hashCode => Object.hashAll([
        layout,
        ...data,
      ]);

  @override
  String toString() => 'UInt8MultiArray(${toJson()})';
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

/// Registers every message in `std_msgs`.
///
/// Call once at startup, before the first subscribe or advertise.
void registerStdMsgs() {
  MessageRegistry.register(const MessageCodec<Byte>(
    rosType: 'std_msgs/msg/Byte',
    fromJson: Byte.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<ByteMultiArray>(
    rosType: 'std_msgs/msg/ByteMultiArray',
    fromJson: ByteMultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Char>(
    rosType: 'std_msgs/msg/Char',
    fromJson: Char.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Float32>(
    rosType: 'std_msgs/msg/Float32',
    fromJson: Float32.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Float32MultiArray>(
    rosType: 'std_msgs/msg/Float32MultiArray',
    fromJson: Float32MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Float64MultiArray>(
    rosType: 'std_msgs/msg/Float64MultiArray',
    fromJson: Float64MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Int16>(
    rosType: 'std_msgs/msg/Int16',
    fromJson: Int16.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Int16MultiArray>(
    rosType: 'std_msgs/msg/Int16MultiArray',
    fromJson: Int16MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Int32MultiArray>(
    rosType: 'std_msgs/msg/Int32MultiArray',
    fromJson: Int32MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Int64>(
    rosType: 'std_msgs/msg/Int64',
    fromJson: Int64.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Int64MultiArray>(
    rosType: 'std_msgs/msg/Int64MultiArray',
    fromJson: Int64MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Int8>(
    rosType: 'std_msgs/msg/Int8',
    fromJson: Int8.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<Int8MultiArray>(
    rosType: 'std_msgs/msg/Int8MultiArray',
    fromJson: Int8MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MultiArrayDimension>(
    rosType: 'std_msgs/msg/MultiArrayDimension',
    fromJson: MultiArrayDimension.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<MultiArrayLayout>(
    rosType: 'std_msgs/msg/MultiArrayLayout',
    fromJson: MultiArrayLayout.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt16>(
    rosType: 'std_msgs/msg/UInt16',
    fromJson: UInt16.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt16MultiArray>(
    rosType: 'std_msgs/msg/UInt16MultiArray',
    fromJson: UInt16MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt32>(
    rosType: 'std_msgs/msg/UInt32',
    fromJson: UInt32.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt32MultiArray>(
    rosType: 'std_msgs/msg/UInt32MultiArray',
    fromJson: UInt32MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt64>(
    rosType: 'std_msgs/msg/UInt64',
    fromJson: UInt64.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt64MultiArray>(
    rosType: 'std_msgs/msg/UInt64MultiArray',
    fromJson: UInt64MultiArray.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt8>(
    rosType: 'std_msgs/msg/UInt8',
    fromJson: UInt8.fromJson,
    toJson: _toJson,
  ));
  MessageRegistry.register(const MessageCodec<UInt8MultiArray>(
    rosType: 'std_msgs/msg/UInt8MultiArray',
    fromJson: UInt8MultiArray.fromJson,
    toJson: _toJson,
  ));
}

Map<String, Object?> _toJson(RosMessage m) => m.toJson();
