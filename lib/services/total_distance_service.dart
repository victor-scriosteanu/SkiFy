import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// ignore: camel_case_types
class total_distance {
  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static Future<double?> checkDistance(
      double? long, double? lat, bool state, String session) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    // ignore: unused_local_variable
    var currentDistance = 0.0;

    DatabaseReference refDistance = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/distance");

    DatabaseEvent eventDistance = await refDistance.once();

    DatabaseReference refLastLong = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/lastLong");

    DatabaseEvent eventLastLong = await refLastLong.once();

    DatabaseReference refLastLat = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/lastLat");

    DatabaseEvent eventLastLat = await refLastLat.once();

    DatabaseReference refTime = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/time");

    DatabaseEvent eventTime = await refTime.once();

    if (eventLastLong.snapshot.value == null ||
        eventLastLat.snapshot.value == null) {
      refLastLong.set(long);
      refLastLat.set(lat);
      return currentDistance;
    } else {
      String lastLongString = eventLastLong.snapshot.value.toString();
      double lastLong = double.parse(lastLongString);
      String lastLatString = eventLastLat.snapshot.value.toString();
      double lastLat = double.parse(lastLatString);
      currentDistance = calculateDistance(lastLat, lastLong, lat, long);

      refLastLong.set(long);
      refLastLat.set(lat);

      if (eventDistance.snapshot.value == null) {
        refDistance.set(currentDistance);
        return currentDistance;
      } else {
        String distanceString = eventDistance.snapshot.value.toString();
        double distance = double.parse(distanceString);
        if (state) {
          distance = distance + currentDistance;
          refDistance.set(distance);
          if (eventTime.snapshot.value.toString() == "00:00:00" ||
              eventTime.snapshot.value.toString() == "00:00:01") {
            refDistance.set(0.0);
          }
        }
        if (eventTime.snapshot.value.toString() == "00:00:00" ||
            eventTime.snapshot.value.toString() == "00:00:01") {
          return 0.0;
        } else {
          return distance;
        }
      }
    }
  }
}
