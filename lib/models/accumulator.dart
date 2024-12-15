class MoSKitoAccumulator {
  final String name;

  MoSKitoAccumulator({required this.name});

  factory MoSKitoAccumulator.fromJson(String json) {
    return MoSKitoAccumulator(name: json);
  }
}