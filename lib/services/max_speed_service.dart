import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class max_speed {
  static Future<double?> checkMaxSpeed(
      double? speed, bool state, String session) async {
    var currentUser = FirebaseAuth.instance.currentUser;

    DatabaseReference ref = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/max_speed");

    DatabaseEvent event = await ref.once();

    if (event.snapshot.value == null) {
      ref.set(speed);
      return speed;
    } else {
      if (state) {
        String maxSpeedString = event.snapshot.value.toString();
        double maxSpeed = double.parse(maxSpeedString);
        if (maxSpeed < speed!) {
          ref.set(speed);
        }
        return maxSpeed;
      } else {
        String maxSpeedString = event.snapshot.value.toString();
        double maxSpeed = double.parse(maxSpeedString);
        return maxSpeed;
      }
    }
  }
}
