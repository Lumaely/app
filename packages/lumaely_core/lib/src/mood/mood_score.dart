enum MoodScore
{

  rough(1),
  low(2),
  okay(3),
  good(4),
  great(5);

  final int value;

  const MoodScore(this.value);

  static MoodScore fromValue(int value)
  {
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