import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: camel_case_types
class save_service {
  static Future<void> save(String session) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    String location = "";
    String distance = "";
    String maxSpeed = "";
    String vertical = "";
    String time = "";
    String runs = "";
    String energy = "";
    String firebase_data = "";

    DatabaseReference ref = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session");

    DatabaseReference refLocation = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/ski_resort");
    DatabaseEvent eventLocation = await refLocation.once();
    if (eventLocation.snapshot.value != null) {
      location = eventLocation.snapshot.value.toString();
      print(location);
    }

    DatabaseReference refDistance = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/distance");
    DatabaseEvent eventDistance = await refDistance.once();
    if (eventDistance.snapshot.value != null) {
      distance = eventDistance.snapshot.value.toString();
      print(distance);
    }

    DatabaseReference refMaxSpeed = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/max_speed");
    DatabaseEvent eventMaxSpeed = await refMaxSpeed.once();
    if (eventMaxSpeed.snapshot.value != null) {
      maxSpeed = eventMaxSpeed.snapshot.value.toString();
      print(maxSpeed);
    }

    DatabaseReference refVertical = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/vertical");
    DatabaseEvent eventVertical = await refVertical.once();
    if (eventVertical.snapshot.value != null) {
      vertical = eventVertical.snapshot.value.toString();
      print(vertical);
    }

    DatabaseReference refTime = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/time");
    DatabaseEvent eventTime = await refTime.once();
    if (eventTime.snapshot.value != null) {
      time = eventTime.snapshot.value.toString();
      print(time);
    }

    DatabaseReference refRuns = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/runs");
    DatabaseEvent eventRuns = await refRuns.once();
    if (eventRuns.snapshot.value != null) {
      runs = eventRuns.snapshot.value.toString();
      print(runs);
    }

    DatabaseReference refEnergy = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/energy");
    DatabaseEvent eventEnergy = await refEnergy.once();
    if (eventEnergy.snapshot.value != null) {
      energy = eventEnergy.snapshot.value.toString();
      print(energy);
    }

    final users = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('session')
        .doc(now.toString());
    final json = {
      'date & time': now,
      'location': location,
      'distance': distance,
      'max speed': maxSpeed,
      'vertical': vertical,
      'time on slopes': time,
      'runs': runs,
      'energy': energy,
    };

    await users.set(json);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('session')
        .get()
        .then((event) {
      for (var doc in event.docs) {
        firebase_data = "${doc.id} => ${doc.data()}";
      }
    });
    if (firebase_data != "") {
      ref.remove();
    }
  }
}
