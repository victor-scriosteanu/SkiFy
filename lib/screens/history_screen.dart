import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skify1/helpers/session_card.dart';
import '../models/Session.dart';
import '../utils/color_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Object> _historyList = [];
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future getList() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('session')
        .orderBy('date & time', descending: true)
        .get();

    setStateIfMounted(() {
      _historyList =
          List.from(data.docs.map((doc) => Session.fromSnapshot(doc)));
    });
  }

  @override
  Widget build(BuildContext context) {
    getList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: hexStringToColor("0080fe"),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("0080fe"),
            hexStringToColor("00308a")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: ListView.builder(
            itemCount: _historyList.length,
            itemBuilder: (context, index) {
              return SessionCard(_historyList[index] as Session);
            },
          )),
    );
  }
}
