enum MoodScore {
  rough(1),
  low(2),
  okay(3),
  good(4),
  great(5);

  new(this.value);

  final int value;

  static MoodScore fromValue(int value) {
    return MoodScore.values.firstWhere(
      (mood) => mood.value == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'A mood must be between 1 and 5',
      ),
    );
  }
}
