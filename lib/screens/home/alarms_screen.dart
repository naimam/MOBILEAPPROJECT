import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:project/models/alarm.dart';
import 'package:project/screens/add_alarm/select_meds_screen.dart';
import 'package:project/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'alarm_info_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth.User firebaseUser = Provider.of<auth.User>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: AppColors.secondary,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .collection('alarms')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<DocumentSnapshot> docs = snapshot.data.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No alarms'),
            );
          }

          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot doc = docs[index];
              Alarm alarm = Alarm.fromDocument(doc);
              String freqTitle = ' ';
              String timeTitle = ' ';
              DateTime startTime = alarm.start_time;
              DateTime? endTime = alarm.end_time;
              final FormatterTime = DateFormat.jm();
              final FormatterDate = DateFormat.yMMMMd('en_US');

              String startTimeHour = FormatterTime.format(startTime);
              String endTimeHour = ' ';
              if (endTime != null) {
                endTimeHour = FormatterTime.format(endTime);
              }
              String startTimeDate = FormatterDate.format(startTime);
              String endTimeDate = ' ';
              if (endTime != null) {
                endTimeDate = FormatterDate.format(endTime);
              }

              if (alarm.freq_num == 0) {
                freqTitle = ' once at ';
              } else {
                freqTitle = ' every ' +
                    alarm.freq_num.toString() +
                    ' ' +
                    alarm.freq_unit +
                    ' at ';
              }

              if (alarm.freq_num == 0) {
                timeTitle = startTimeHour;
              } else {
                timeTitle = startTimeHour + ' to ' + endTimeHour;
              }

              return Card(
                  child: ListTile(
                title: Text(alarm.name + freqTitle),
                subtitle: Text(timeTitle,
                    style: const TextStyle(
                        fontSize: 23.0, fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AlarmInfo(alarm: alarm)));
                },
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SelectMedsScreen(uid: firebaseUser.uid)));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}
