import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:skify1/services/max_speed_service.dart';
import 'package:skify1/screens/home_screen.dart';
import 'package:skify1/screens/start_screen.dart';
import 'package:skify1/services/time_session_service.dart';
import 'package:skify1/services/total_distance_service.dart';
import 'package:skify1/services/vertical_service.dart';
import 'package:skify1/reusable_widgets/duration_h_format.dart';
import 'package:skify1/services/runs_service.dart';

import '../utils/color_utils.dart';

class PauseScreen extends StatefulWidget {
  const PauseScreen({Key? key, this.skiResort, this.session, this.stopwatch})
      : super(key: key);
// ignore: prefer_typing_uninitialized_variables
  final skiResort;
  // ignore: prefer_typing_uninitialized_variables
  final session;
  // ignore: prefer_typing_uninitialized_variables
  final stopwatch;
  @override
  State<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends State<PauseScreen> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // ignore: deprecated_member_use
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool _isListenLocation = false, _isGetLocation = false;

  double maxSpeed = 0;
  late double maxSpeedCheck;
  double distance = 0;
  late double distanceCheck;
  double vertical = 0;
  late double verticalCheck;
  int runs = 0;
  late int runsCheck;

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
    verticalCheck = (await vertical_service.checkVertical(
        altitude, false, widget.session))!;
    distanceCheck =
        (await total_distance.checkDistance(long, lat, false, widget.session))!;
    maxSpeedCheck =
        (await max_speed.checkMaxSpeed(speed, false, widget.session))!;
    runsCheck =
        (await runs_service.checkRuns(altitude, false, widget.session))!;
    setState(() {
      vertical = verticalCheck;
      distance = distanceCheck;
      maxSpeed = maxSpeedCheck;
      runs = runsCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
    locPermission();

    Duration elapsed = widget.stopwatch.elapsed;
    final now = elapsed;

    if (currentUser != null) {
      // print(currentUser.uid);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter TextField Example'),
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            child: Container(
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
                        stats(data.speed, data.longitude, data.latitude,
                            data.altitude);
                        time_session.updateTime(
                            widget.stopwatch, widget.session);
                        return GridView(
                          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 30, 2, 0),
                                    child: Text(
                                      '${double.parse((distance).toStringAsFixed(1))} km',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(2, 10, 2, 0),
                                    child: Text(
                                      'distance',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color:
                                            Color.fromARGB(255, 188, 188, 188),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 30, 2, 0),
                                    child: Text(
                                      '${(maxSpeed * 3.6).round()} km/h',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
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
                                        color:
                                            Color.fromARGB(255, 188, 188, 188),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 30, 2, 0),
                                    child: Text(
                                      '${vertical.round()} m',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
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
                                        color:
                                            Color.fromARGB(255, 188, 188, 188),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 30, 2, 0),
                                    child: Text(
                                      printDuration.printDurationH(now),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
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
                                        color:
                                            Color.fromARGB(255, 188, 188, 188),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 30, 2, 0),
                                    child: Text(
                                      '$runs',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
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
                                        color:
                                            Color.fromARGB(255, 188, 188, 188),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 30, 2, 0),
                                    child: Text(
                                      '${(widget.stopwatch.elapsedMilliseconds / 1000 * 0.1).round()} cal',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
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
                                        color:
                                            Color.fromARGB(255, 188, 188, 188),
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
            //Use this as if it were the body
          ),
          //Setup the position however you like
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              heroTag: null, //Must be null to avoid hero animation errors
              child: const Icon(Icons.flag, size: 35),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => StartScreen()));
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              widget.stopwatch.start();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(
                            skiResort: widget.skiResort,
                            session: widget.session,
                            stopwatch: widget.stopwatch,
                          )));
            },
            child: Icon(Icons.play_arrow, size: 50),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          // ignore: sized_box_for_whitespace
          child: Container(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                    icon: const Icon(Icons.history, size: 40),
                    onPressed: () {}),
                const SizedBox(width: 40), // The dummy child
                IconButton(
                    icon: const Icon(Icons.map, size: 40), onPressed: () {}),
              ],
            ),
          )),
    );
  }
}
