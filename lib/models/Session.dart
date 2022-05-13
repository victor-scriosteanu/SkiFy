import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  Timestamp? now;
  String? distance;
  String? energy;
  String? location;
  String? maxSpeed;
  String? runs;
  String? time;
  String? vertical;

  Session();

  Map<String, dynamic> toJson() => {
        'date & time': now,
        'distance': distance,
        'energy': energy,
        'location': location,
        'max speed': maxSpeed,
        'runs': runs,
        'time on slopes': time,
        'vertical': vertical,
      };
  Session.fromSnapshot(snapshot)
      : now = snapshot.data()['date & time'],
        distance = snapshot.data()['distance'],
        energy = snapshot.data()['energy'],
        location = snapshot.data()['location'],
        maxSpeed = snapshot.data()['max speed'],
        runs = snapshot.data()['runs'],
        time = snapshot.data()['time on slopes'],
        vertical = snapshot.data()['vertical'];
}
