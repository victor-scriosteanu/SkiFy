import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class runs_service {
  static Future<int?> checkRuns(
      double? altitude, bool state, String session) async {
    var currentUser = FirebaseAuth.instance.currentUser;

    DatabaseReference ref = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/runs");

    DatabaseEvent event = await ref.once();

    DatabaseReference refRunOrLift = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/runOrLift");

    DatabaseEvent eventRunOrLift = await refRunOrLift.once();

    DatabaseReference refLastVertical = FirebaseDatabase.instance.ref(
        "/users/${currentUser?.uid}/sessions/$session/verticalLastVerticalRuns");

    DatabaseEvent eventLastVertical = await refLastVertical.once();

    if (event.snapshot.value == null) {
      ref.set(0);
      return 0;
    } else {
      if (eventLastVertical.snapshot.value == null) {
        refLastVertical.set(altitude);
        return 0;
      } else {
        String runsString = event.snapshot.value.toString();
        int runs = int.parse(runsString);
        String lastVerticalString = eventLastVertical.snapshot.value.toString();
        double lastVertical = double.parse(lastVerticalString);
        if (state) {
          if (eventRunOrLift.snapshot.value == null) {
            return 0;
          } else {
            String runOrLiftString = eventRunOrLift.snapshot.value.toString();
            if (runOrLiftString != "Going Down") {
              if (altitude! < lastVertical - 20) {
                runs++;
                ref.set(runs);
                refLastVertical.set(altitude);
                refRunOrLift.set("Going Down");
                return runs;
              } else if (altitude > lastVertical + 20) {
                refLastVertical.set(altitude);
                refRunOrLift.set("Going Up");
                return runs;
              } else {
                return runs;
              }
            } else {
              if (altitude! < lastVertical - 20) {
                refLastVertical.set(altitude);
                refRunOrLift.set("Going Down");
                return runs;
              } else if (altitude > lastVertical + 20) {
                refLastVertical.set(altitude);
                refRunOrLift.set("Going Up");
                return runs;
              } else {
                return runs;
              }
            }
          }
        } else {
          refLastVertical.set(altitude);
          return runs;
        }
      }
    }
  }
}
