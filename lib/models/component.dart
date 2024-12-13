class MoSKitoComponent {
  final String name;
  final String color;

  MoSKitoComponent({required this.name, required this.color});

  factory MoSKitoComponent.fromJson(Map<String, dynamic> json) {
    return MoSKitoComponent(
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }
}