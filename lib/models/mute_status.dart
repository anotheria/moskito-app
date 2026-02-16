class MuteStatus {
  final int remainingMutingTime;
  final bool muted;
  final String remainingMutingTimeAsString;

  MuteStatus({
    required this.remainingMutingTime,
    required this.muted,
    required this.remainingMutingTimeAsString,
  });

  factory MuteStatus.fromJson(Map<String, dynamic> json) {
    return MuteStatus(
      remainingMutingTime: json['remainingMutingTime'] as int,
      muted: json['muted'] as bool,
      remainingMutingTimeAsString: json['remainingMutingTimeAsString'] as String,
    );
  }
}
