/// Gives the current time, in UTC.
typedef Clock = DateTime Function();

/// The device's clock, in UTC.
DateTime systemClock() => DateTime.now().toUtc();
