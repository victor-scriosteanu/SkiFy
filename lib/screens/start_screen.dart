import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skify1/screens/history_scrren.dart';
import 'package:skify1/screens/signin_screen.dart';
import 'package:skify1/services/ski_resort_service.dart';
import 'package:uuid/uuid.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../utils/color_utils.dart';
import 'home_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _locationController = TextEditingController();
  String skiResort = '';
  var uuid = const Uuid();
  final stopwatch = Stopwatch();
  var currentUser = FirebaseAuth.instance.currentUser;
  var session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("0080fe"),
          hexStringToColor("00308a")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.place,
                      color: Colors.white70,
                    ),
                    labelText: "Ski Resort/Location",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                            width: 0, style: BorderStyle.none)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              stopwatch.start();
              skiResort = _locationController.text;
              session = uuid.v1();
              ski_resort.updateSkiResort(skiResort, session);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(
                          skiResort: skiResort,
                          session: session,
                          stopwatch: stopwatch)));
            },
            child: skiButtonWidget('assets/images/skis.png'),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.white,
          child: Container(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                    icon: const Icon(Icons.history, size: 40),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HistoryScreen()));
                    }),
                SizedBox(width: 40), // The dummy child
                IconButton(
                    icon: const Icon(Icons.logout, size: 40),
                    onPressed: () {
                      Fluttertoast.showToast(msg: "Signed Out");
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInScreen()));
                      });
                    }),
              ],
            ),
          )),
    );
  }
}
