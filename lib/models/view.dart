import 'component.dart';

class MoSKitoView {
  final String name;
  final String color;
  final List<MoSKitoComponent> components;

  MoSKitoView({required this.name, required this.color, required this.components});

  factory MoSKitoView.fromJson(Map<String, dynamic> json) {
    return MoSKitoView (
      name: json['name'] as String,
      color: json['viewColor'] as String,
      components: (json['components'] as List<dynamic>)
          .map((componentJson) => MoSKitoComponent.fromJson(componentJson))
          .toList(),
    );
  }
}