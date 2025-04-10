class PlayerEntity {
  final String playerId;
  final String playerName;
  final bool isGhost;
  final String input;
  final DateTime? startTime;
  final DateTime? endTime;

  PlayerEntity({
    required this.playerId,
    required this.playerName,
    this.isGhost = false,
    required this.input,
    this.startTime,
    this.endTime,
  });

  Duration get elapsedTime {
    if (startTime == null) return Duration.zero;
    return (endTime ?? DateTime.now()).difference(startTime!);
  }

  bool isComplete(String targetText) =>
      input.trimRight().length >= targetText.trimRight().length;

  int correctChars(String targetText) {
    int correct = 0;
    for (int i = 0; i < input.length && i < targetText.length; i++) {
      if (input[i] == targetText[i]) correct++;
    }
    return correct;
  }

  double accuracy(String targetText) {
    if (input.isEmpty) return 0;
    return (correctChars(targetText) / input.length) * 100;
  }

  double wpm(String targetText) {
    if (startTime == null || input.isEmpty) return 0;
    final minutes = elapsedTime.inMilliseconds / 60000;
    if (minutes == 0) return 0;
    return (correctChars(targetText) / 5) / minutes;
  }

  PlayerEntity copyWith({
    String? playerId,
    String? playerName,
    bool? isGhost,
    String? input,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return PlayerEntity(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isGhost: isGhost ?? this.isGhost,
      input: input ?? this.input,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'PlayerEntity(playerId: $playerId, input: $input, startTime: $startTime, endTime: $endTime)';
  }
}
