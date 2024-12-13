class ComponentInfo {
  final Map<String, dynamic> data;

  ComponentInfo({required this.data});

  factory ComponentInfo.fromJson(Map<String, dynamic> json) {
    return ComponentInfo(data: json['results'] as Map<String, dynamic>);
  }
}