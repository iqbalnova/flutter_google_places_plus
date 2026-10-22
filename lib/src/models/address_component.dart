import 'package:flutter/foundation.dart';

/// Structured component of a place's address.
@immutable
class AddressComponent {
  const AddressComponent({
    required this.name,
    this.shortName,
    required this.types,
  });

  /// Full text name of the address component (e.g. 'California').
  final String name;

  /// Abbreviated name if available (e.g. 'CA').
  final String? shortName;

  /// Types categorization for this component (e.g. ['administrative_area_level_1', 'political']).
  final List<String> types;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressComponent &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          shortName == other.shortName &&
          listEquals(types, other.types);

  @override
  int get hashCode => Object.hash(name, shortName, Object.hashAll(types));

  @override
  String toString() =>
      'AddressComponent(name: $name, shortName: $shortName, types: $types)';
}
