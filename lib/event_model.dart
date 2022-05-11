import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class Event {
  Event({required this.name, required this.fullDay, required this.startTime, required this.endTime, required this.comment});

  @HiveField(0)
  String name;

  @HiveField(1)
  bool fullDay;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime endTime;

  @HiveField(4)
  String comment;
}
