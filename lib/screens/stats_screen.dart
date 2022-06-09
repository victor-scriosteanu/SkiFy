// ignore_for_file: unused_field, prefer_const_constructors

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:skify1/services/max_speed_service.dart';
import 'package:skify1/screens/pause_screen.dart';
import 'package:flutter/material.dart';
import 'package:skify1/services/runs_service.dart';
import 'package:skify1/services/vertical_service.dart';
import '../utils/color_utils.dart';
import 'package:skify1/services/total_distance_service.dart';
import 'package:skify1/services/time_session_service.dart';
import 'package:skify1/reusable_widgets/duration_h_format.dart';
import 'package:skify1/services/energy_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.skiResort, this.session, this.stopwatch})
      : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final skiResort;
  // ignore: prefer_typing_uninitialized_variables
  final session;
  // ignore: prefer_typing_uninitialized_variables
  final stopwatch;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // ignore: deprecated_member_use, unnecessary_new
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  // ignore: prefer_final_fields
  bool _isListenLocation = false, _isGetLocation = false;
  double maxSpeed = 0;
  late double maxSpeedCheck;
  double distance = 0;
  late double distanceCheck;
  double vertical = 0;
  late double verticalCheck;
  int runs = 0;
  late int runsCheck;
  int cal = 0;
  late int calCheck;

  Future<void> locPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _isListenLocation = true;
    });
  }

  Future<void> stats(
      double? speed, double? long, double? lat, double? altitude) async {
    verticalCheck =
        (await vertical_service.checkVertical(altitude, true, widget.session))!;
    distanceCheck =
        (await total_distance.checkDistance(long, lat, true, widget.session))!;
    maxSpeedCheck =
        (await max_speed.checkMaxSpeed(speed, true, widget.session))!;
    runsCheck = (await runs_service.checkRuns(altitude, true, widget.session))!;
    calCheck =
        (await energy_service.checkEnergy(widget.stopwatch, widget.session));
    setState(() {
      vertical = verticalCheck;
      distance = distanceCheck;
      maxSpeed = maxSpeedCheck;
      runs = runsCheck;
      cal = calCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
    locPermission();

    Duration elapsed = widget.stopwatch.elapsed;
    final now = elapsed;
    if (currentUser != null) {
      //print(currentUser.uid);
    }
    location.enableBackgroundMode(enable: true);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("0080fe"),
          hexStringToColor("00308a")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder(
              stream: location.onLocationChanged,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting) {
                  var data = snapshot.data as LocationData;
                  stats(
                      data.speed, data.longitude, data.latitude, data.altitude);
                  time_session.updateTime(widget.stopwatch, widget.session);
                  return GridView(
                    padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 50),
                    children: <Widget>[
                      //Total distance
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 30, 2, 0),
                              child: Text(
                                '${double.parse((distance).toStringAsFixed(1))} km',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
                              child: Text(
                                'distance',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 188, 188, 188),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      //Max speed
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 30, 2, 0),
                              child: Text(
                                '${(maxSpeed * 3.6).round()} km/h',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
                              child: Text(
                                'max speed',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 188, 188, 188),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      //vertical
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 30, 2, 0),
                              child: Text(
                                '${vertical.round()} m',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
                              child: Text(
                                'vertical',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 188, 188, 188),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      //time on slopes
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 30, 2, 0),
                              child: Text(
                                printDuration.printDurationH(now),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
                              child: Text(
                                'time on slopes',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 188, 188, 188),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      //runs
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 30, 2, 0),
                              child: Text(
                                '$runs',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
                              child: Text(
                                'runs',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 188, 188, 188),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      //cal burned
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 30, 2, 0),
                              child: Text(
                                '$cal cal',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
                              child: Text(
                                'energy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 188, 188, 188),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              widget.stopwatch.stop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PauseScreen(
                          skiResort: widget.skiResort,
                          session: widget.session,
                          stopwatch: widget.stopwatch)));
            },
            child: Icon(Icons.pause, size: 50),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.white,
          child: Container(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(width: 40), // The dummy child
              ],
            ),
          )),
    );
  }
}
