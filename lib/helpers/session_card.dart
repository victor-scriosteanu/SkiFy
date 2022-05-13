import 'package:flutter/material.dart';
import 'package:skify1/models/Session.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class SessionCard extends StatelessWidget {
  final Session _session;

  SessionCard(this._session);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text("${_session.location}".capitalize(),
                      style: const TextStyle(color: Colors.white)),
                  const Spacer(),
                  Text("${_session.now?.toDate().toString().substring(0, 10)}",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              const Divider(
                color: Color.fromARGB(255, 255, 255, 255),
                height: 20,
              ),
              Row(
                children: [
                  Text(
                      'distance: ${double.parse(_session.distance!).toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white)),
                  Spacer(),
                  Text(
                      'max speed: ${(double.parse(_session.maxSpeed!) * 3.6).round()}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  Text('vertical: ${_session.vertical!}',
                      style: const TextStyle(color: Colors.white)),
                  Spacer(),
                  Text('ski time: ${_session.time!}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  Text('runs: ${_session.runs!}',
                      style: const TextStyle(color: Colors.white)),
                  Spacer(),
                  Text('energy: ${_session.energy!}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
