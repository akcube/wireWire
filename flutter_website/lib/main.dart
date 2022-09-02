import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_website/Home/home.dart';
import 'package:flutter_website/model/entry_model.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'Charts/blood_pressure.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wearable Device Analytics',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routes: {
        'home': (context) =>
            const MyHomePage(title: 'Wearable Device Analytics'),
        'dashboard': (context) => const HomePage(),
        // 'blood_pressure': (context) => BloodPressureScreen(),
      },
      initialRoute: 'dashboard',
      home: const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  // Uri thingSpeakURL = Uri.parse(
  //     'https://api.thingspeak.com/channels/${dotenv.env['THINGSPEAK_CHANNEL']!}/feeds.json?');
  // List<EntryModel> thingSpeakData = [];

  // void fetchThingSpeakData() async {
  //   try {
  //     final response = await get(thingSpeakURL);
  //     final jsonData = jsonDecode(response.body)['feeds'];
  //     for (var entry in jsonData) {
  //       setState(() {
  //         thingSpeakData.add(EntryModel.fromMap(entry));
  //       });
  //     }
  //   } catch (err) {}
  // }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior =
        ZoomPanBehavior(enablePinching: true, enableDoubleTapZooming: true);
    super.initState();
    // fetchThingSpeakData();
  }

  // Widget BloodPressureChart() {
  //   return SfCartesianChart(
  //     title: ChartTitle(text: 'Blood Pressure Chart \n'),
  //     legend:
  //         Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
  //     tooltipBehavior: _tooltipBehavior,
  //     zoomPanBehavior: _zoomPanBehavior,
  //     series: <ChartSeries>[
  //       LineSeries<EntryModel, DateTime>(
  //         dataSource: thingSpeakData,
  //         xValueMapper: (EntryModel data, _) => data.createTime,
  //         yValueMapper: (EntryModel data, _) => data.systolic,
  //         dataLabelSettings: const DataLabelSettings(isVisible: false),
  //         enableTooltip: true,
  //       ),
  //       LineSeries<EntryModel, DateTime>(
  //         dataSource: thingSpeakData,
  //         xValueMapper: (EntryModel data, _) => data.createTime,
  //         yValueMapper: (EntryModel data, _) => data.diastolic,
  //         dataLabelSettings: const DataLabelSettings(isVisible: false),
  //         enableTooltip: true,
  //       ),
  //     ],
  //     primaryXAxis: DateTimeAxis(),
  //     primaryYAxis: NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
  //   );
  // }

  // Widget HeartRateChart() {
  //   return SfCartesianChart(
  //     title: ChartTitle(text: 'Blood Pressure Chart \n'),
  //     legend:
  //         Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
  //     tooltipBehavior: _tooltipBehavior,
  //     series: <ChartSeries>[
  //       LineSeries<EntryModel, DateTime>(
  //         dataSource: thingSpeakData,
  //         xValueMapper: (EntryModel data, _) => data.createTime,
  //         yValueMapper: (EntryModel data, _) => data.heartRate,
  //         dataLabelSettings: const DataLabelSettings(isVisible: false),
  //         enableTooltip: true,
  //       ),
  //     ],
  //     primaryXAxis: DateTimeAxis(),
  //     primaryYAxis: NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold());
  }
}
