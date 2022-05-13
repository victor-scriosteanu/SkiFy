import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:health/health.dart';

class energy_service {
  static Future<int> checkEnergy(Stopwatch time, String session) async {
    List<HealthDataPoint> _healthDataList = [];
    var currentUser = FirebaseAuth.instance.currentUser;

    HealthFactory health = HealthFactory();
    var types = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];
    final permissions = [
      HealthDataAccess.READ,
    ];

    final now = DateTime.now();
    final yesterday =
        now.subtract(Duration(milliseconds: time.elapsedMilliseconds));
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("/users/${currentUser?.uid}/sessions/$session/energy");

    if (requested) {
      try {
        // fetch health data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(yesterday, now, types);

        // save all the new data points (only the first 100)
        _healthDataList.addAll((healthData.length < 1000)
            ? healthData
            : healthData.sublist(0, 100));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
      var energy = 0.0;
      // print the results
      _healthDataList.forEach((x) {
        print(x);
        print(x.value);
        energy = energy + x.value;
      });
      if (energy == 0) {
        ref.set((time.elapsedMilliseconds / 1000 * 0.1).round());
        return ((time.elapsedMilliseconds / 1000 * 0.1).round());
      }
      print(energy.round());
      ref.set(energy.round());
      return energy.round();
      // update the UI to display the results

    } else {
      print("Authorization not granted");
      ref.set((time.elapsedMilliseconds / 1000 * 0.1).round());
      return ((time.elapsedMilliseconds / 1000 * 0.1).round());
    }
  }
}
