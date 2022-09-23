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

import '../notification_service.dart';

class BloodPressureScreen extends StatefulWidget {
  BloodPressureScreen({Key? key}) : super(key: key);

  @override
  _BloodPressureScreenState createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  DateTime lastEntry = DateTime(1999, 1, 1); // Some old date
  int currentSession = 10;

  late final NotificationService notificationService;
  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {});

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
        title: Text("Blood Pressure Chart (mmHg)"),
        elevation: 0,
        backgroundColor: const Color(0xFF00564D),
      ),
      body: BloodPressureChart(),
    );
  }

  List<EntryModel> thingSpeakData = [];
  List<List<EntryModel>> separateRecordings = [[]];

  void fetchThingSpeakData() async {
    try {
      Uri thingSpeakURL = Uri.parse(
          'https://api.thingspeak.com/channels/${loggedInUser.thingSpeakChannel ?? 0}/feeds.json?results=1000');
      thingSpeakData.clear();
      List<List<EntryModel>> temp2 = [[]];
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
        separateRecordings = temp2;
      });
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
    String date = DateFormat('MMM dd HH:mm').format(now);
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    // return convertedDateTime;
    return date;
  }

  Widget BloodPressureChart() {
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
              }, // button pressed
              child: const Icon(Icons.arrow_forward_ios), // icon
            ),
          ],
        ),
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
              yValueMapper: (EntryModel data, _) => data.systolic,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
              name: "Systole",
              enableTooltip: true,
            ),
            LineSeries<EntryModel, DateTime>(
              dataSource: separateRecordings[currSession],
              xValueMapper: (EntryModel data, _) => data.createTime,
              yValueMapper: (EntryModel data, _) => data.diastolic,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
              name: "Diastole",
              enableTooltip: true,
            ),
          ],
          primaryXAxis: DateTimeAxis(),
          primaryYAxis:
              NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
        )
      ],
    );
  }
}
