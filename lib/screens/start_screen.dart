import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_place/google_place.dart';
import 'package:skify1/screens/history_screen.dart';
import 'package:skify1/screens/map_screen.dart';
import 'package:skify1/screens/signin_screen.dart';

import 'package:skify1/services/ski_resort_service.dart';
import 'package:uuid/uuid.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../utils/color_utils.dart';
import 'stats_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _locationController = TextEditingController();
  bool isButtonActive = false;
  String skiResort = '';
  var uuid = const Uuid();
  final stopwatch = Stopwatch();
  var currentUser = FirebaseAuth.instance.currentUser;
  var session;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  DetailsResult? position;
  late FocusNode focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyAeU5N_FI3VscF7Rgzr9IxmNwPVRjwfqRk';
    googlePlace = GooglePlace(apiKey);
    focusNode = FocusNode();
    _locationController.addListener(() {
      setState(() {
        isButtonActive = _locationController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
    focusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
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
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white.withOpacity(0.5),
                      autofocus: false,
                      focusNode: focusNode,
                      controller: _locationController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.place,
                          color: Colors.white70,
                        ),
                        labelText: "Ski Resort/Location",
                        labelStyle:
                            TextStyle(color: Colors.white.withOpacity(0.9)),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                      ),
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(Duration(milliseconds: 200), () {
                          if (value.isNotEmpty) {
                            autoCompleteSearch(value);
                          } else {
                            setState(() {
                              predictions = [];
                              position = null;
                            });
                          }
                        });
                      },
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(
                              Icons.place_outlined,
                              color: Colors.white,
                            ),
                            title:
                                Text(predictions[index].description.toString()),
                            textColor: Colors.white,
                            onTap: () async {
                              final placeId = predictions[index].placeId!;
                              final details =
                                  await googlePlace.details.get(placeId);
                              if (details != null &&
                                  details.result != null &&
                                  mounted) {
                                if (focusNode.hasFocus) {
                                  setState(() {
                                    position = details.result;
                                    _locationController.text =
                                        details.result!.name!;
                                    predictions = [];
                                  });
                                }
                              }
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              heroTag: null, //Must be null to avoid hero animation errors
              child: const Icon(Icons.my_location_sharp, size: 35),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 90,
        height: 90,
        child: FittedBox(
          child: FloatingActionButton(
              onPressed: isButtonActive ? () => submitData() : null,
              child:
                  skiButtonWidget('assets/images/skiMan.png', isButtonActive),
              backgroundColor: isButtonActive
                  ? Colors.blue
                  : Color.fromARGB(255, 26, 113, 184)),
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

  submitData() {
    stopwatch.start();
    skiResort = _locationController.text;
    session = uuid.v1();

    ski_resort.updateSkiResort(skiResort, session);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                skiResort: skiResort, session: session, stopwatch: stopwatch)));
  }
}
