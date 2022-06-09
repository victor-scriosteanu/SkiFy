import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class vertical_service {
  static Future<double?> checkVertical(
      double? altitude, bool state, String session) async {
    var currentUser = FirebaseAuth.instance.currentUser;

    DatabaseReference ref = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/vertical");

    DatabaseEvent event = await ref.once();

    DatabaseReference refLastVertical = FirebaseDatabase.instance.ref(
        "/users/${currentUser?.uid}/sessions/$session/verticalLastVertical");

    DatabaseEvent eventLastVertical = await refLastVertical.once();

    if (event.snapshot.value == null) {
      ref.set(0);
      return 0;
    } else {
      if (eventLastVertical.snapshot.value == null) {
        refLastVertical.set(altitude);
        return 0;
      } else {
        String verticalString = event.snapshot.value.toString();
        double vertical = double.parse(verticalString);
        String lastVerticalString = eventLastVertical.snapshot.value.toString();
        double lastVertical = double.parse(lastVerticalString);
        if (state) {
          if (altitude! < lastVertical - 10) {
            vertical = vertical + (lastVertical - altitude);
            ref.set(vertical);
            refLastVertical.set(altitude);
            return vertical;
          } else {
            return vertical;
          }
        } else {
          refLastVertical.set(altitude);
          return vertical;
        }
      }
    }
  }
}
