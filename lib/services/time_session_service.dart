import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skify1/reusable_widgets/duration_h_format.dart';

class time_session {
  static void updateTime(Stopwatch time, String session) {
    var currentUser = FirebaseAuth.instance.currentUser;
    Duration elapsed = time.elapsed;
    final now = elapsed;

    DatabaseReference ref = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/time");

    ref.set(printDuration.printDurationH(now));
  }
}
