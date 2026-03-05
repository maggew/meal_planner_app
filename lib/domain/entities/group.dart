import 'package:meal_planner/domain/entities/group_settings.dart';

class Group {
  final String name;
  final String id;
  final String imageUrl;
  final GroupSettings settings;

  Group({
    required this.name,
    required this.id,
    required this.imageUrl,
    GroupSettings? settings,
  }) : settings = settings ?? GroupSettings.defaultSettings;

  Group copyWith({
    String? name,
    String? id,
    String? imageUrl,
    GroupSettings? settings,
  }) {
    return Group(
      name: name ?? this.name,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'Group(name: $name, id: $id, imageUrl: $imageUrl, settings: $settings)';
  }
}
