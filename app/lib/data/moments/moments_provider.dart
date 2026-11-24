import 'package:lumaely_core/lumaely_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'moments_provider.g.dart';

/// The moments the person uses, in the order of the day.
// TODO(issue-144): get user-set setting. For now, all are chosen.
@riverpod
List<Moment> moments(Ref ref) => Moment.values;
