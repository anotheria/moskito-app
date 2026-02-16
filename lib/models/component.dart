class MoSKitoComponent {
  final String name;
  final String color;
  final bool maintenanceMode;

  MoSKitoComponent({required this.name, required this.color, required this.maintenanceMode});

  factory MoSKitoComponent.fromJson(Map<String, dynamic> json) {
    return MoSKitoComponent(
      name: json['name'] as String,
      color: json['color'] as String,
      maintenanceMode: json['maintenanceMode'] as bool,
    );
  }
}