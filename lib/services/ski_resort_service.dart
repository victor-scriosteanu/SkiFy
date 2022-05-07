import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ski_resort {
  static void updateSkiResort(String skiResort, String session) {
    var currentUser = FirebaseAuth.instance.currentUser;

    DatabaseReference ref = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/ski_resort");
    ref.set(skiResort);
  }
}
