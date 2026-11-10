/// A part of the day a mood can be recorded for, in the order of the day.
enum Moment {
  morning('morning'),
  noon('noon'),
  afternoon('afternoon'),
  evening('evening'),
  night('night');

  new(this.id);

  /// Stored in the database and synced. NEVER change an existing id.
  final String id;

  /// The moment stored as [id].
  static Moment fromId(String id) => Moment.values.firstWhere(
    (moment) => moment.id == id,
    orElse: () => throw ArgumentError.value(id, 'id', 'Unknown moment'),
  );
}
