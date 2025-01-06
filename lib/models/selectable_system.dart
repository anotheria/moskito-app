class SelectableSystem{
  String name;
  String url;

  SelectableSystem({required this.name, required this.url});

  @override
  String toString() {
    return 'SelectableSystem{name: $name, url: $url}';
  }

  factory SelectableSystem.fromJson(Map<String, dynamic> json) {
    return SelectableSystem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
  };

}