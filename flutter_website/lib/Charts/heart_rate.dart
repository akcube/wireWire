import 'dart:core';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_website/model/user_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_website/model/entry_model.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../notification_service.dart';

class HeartRateScreen extends StatefulWidget {
  HeartRateScreen({Key? key}) : super(key: key);

  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  DateTime lastEntry = DateTime(1999, 1, 1); // Some old date
  int currentSession = 0;
  // Min, Max, Avg
  List<double> sessionData = [0.0, 0.0, 0.0];

  late final NotificationService notificationService;
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {});

  void updateStats() {
    int currSession =
        [currentSession, separateRecordings.length - 1].reduce(min);
    setState(() {
      double? a = (separateRecordings[currSession].map((e) => e.heartRate))
          .reduce((a, b) {
        return min(a!, b!);
      });
      double? b = (separateRecordings[currSession].map((e) => e.heartRate))
          .reduce((a, b) {
        return max(a!, b!);
      });
      double? c =
          separateRecordings[currSession].map((e) => e.heartRate!).average;
      sessionData = [a!, b!, c];
    });
  }

  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
      fetchThingSpeakData();
    });
    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
        enableMouseWheelZooming: true);
    const oneMin = Duration(seconds: 60);
    Timer.periodic(oneMin, (Timer t) => fetchThingSpeakData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Heart Rate (bpm)"),
        elevation: 0,
        backgroundColor: const Color(0xFF00564D),
      ),
      body: HeartRateChart(),
    );
  }

  List<EntryModel> thingSpeakData = [];
  List<List<EntryModel>> separateRecordings = [[]];

  void fetchThingSpeakData() async {
    try {
      Uri thingSpeakURL = Uri.parse(
          'https://api.thingspeak.com/channels/${loggedInUser.thingSpeakChannel ?? 0}/feeds.json?results=1000');
      thingSpeakData.clear();
      List<List<EntryModel>> temp2 = [];
      DateTime previousEntry = DateTime(1999, 1, 1); // Some old date
      final response = await get(thingSpeakURL);
      final jsonData = jsonDecode(response.body)['feeds'];
      List<EntryModel> temp = [];
      for (var entry in jsonData) {
        EntryModel data = EntryModel.fromMap(entry);
        if (!data.isErroneousDataPoint()) {
          thingSpeakData.add(data);
          if (data.createTime!.difference(previousEntry).inMinutes > 20) {
            temp2.add(temp);
            temp = [];
          }
          previousEntry = data.createTime!;
          temp.add(data);
        }
      }
      temp2.add(temp);
      setState(() {
        currentSession = temp2.length - 1;
        if (temp2.length == 0) {
          separateRecordings = [[]];
        } else
          separateRecordings = temp2;
      });
      updateStats();
      if (thingSpeakData.last.createTime!.isAfter(lastEntry)) {
        lastEntry = thingSpeakData.last.createTime!;
        //   notificationService.showLocalNotification(
        //       id: 0,
        //       title: "Abnormal Readings",
        //       body: "Please Check your Blood Pressure",
        //       payload: "You just took water! Huurray!");
      }
    } catch (err) {}
  }

  String timeStamp(DateTime now) {
    now = now.add(const Duration(hours: 5, minutes: 30));
    String date = DateFormat('MMM dd HH:mm').format(now);
    return date;
  }

  Widget statsWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  "Heart Rate",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                Text(
                  "Min: ${sessionData[0].toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
                Text(
                  "Max: ${sessionData[1].toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
                Text(
                  "Avg: ${sessionData[2].toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget HeartRateChart() {
    String title = '';
    int currSession =
        [currentSession, separateRecordings.length - 1].reduce(min);
    if (separateRecordings[currSession].isNotEmpty) {
      DateTime now = separateRecordings[currSession].first.createTime!;
      DateTime later = separateRecordings[currSession].last.createTime!;
      String convertedDateTime = timeStamp(now);
      String convertedDateTimeLast = timeStamp(later);
      title += "$convertedDateTime to $convertedDateTimeLast";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  currentSession = [currentSession - 1, 1].reduce(max);
                });
                updateStats();
              }, // button pressed
              child: const Icon(Icons.arrow_back_ios), // icon
            ),
            Text(
              "Entry: $currSession/${separateRecordings.length - 1}",
              style: const TextStyle(fontSize: 20),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  currentSession = [
                    currentSession + 1,
                    separateRecordings.length - 1
                  ].reduce(min);
                });
                updateStats();
              }, // button pressed
              child: const Icon(Icons.arrow_forward_ios), // icon
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       title,
        //       style: const TextStyle(fontSize: 20),
        //     ),
        //   ],
        // ),
        SfCartesianChart(
          title: ChartTitle(text: title),
          legend: Legend(
              isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
          tooltipBehavior: _tooltipBehavior,
          zoomPanBehavior: _zoomPanBehavior,
          series: <ChartSeries>[
            LineSeries<EntryModel, DateTime>(
              dataSource: separateRecordings[currSession],
              xValueMapper: (EntryModel data, _) => data.createTime,
              yValueMapper: (EntryModel data, _) => data.heartRate,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
              name: "Heart Rate",
              enableTooltip: true,
            ),
          ],
          primaryXAxis: DateTimeAxis(),
          primaryYAxis:
              NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
        ),
        statsWidget(),
      ],
    );
  }
}
