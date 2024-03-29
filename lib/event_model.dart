import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class Event extends HiveObject {
  Event({
    required this.name,
    required this.fullDay,
    required this.startTime,
    required this.endTime,
    required this.comment,
    required this.eventKey,
  });

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

  @HiveField(5)
  String eventKey;

  @override
  String toString() {
    return eventKey;
  }

  @override
  bool operator ==(Object other) {
    return (other is Event) && (eventKey == other.eventKey);
  }

  @override
  int get hashCode => eventKey.hashCode;
}
