import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_website/model/entry_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';

class SkinConductivityScreen extends StatefulWidget {
  SkinConductivityScreen({Key? key}) : super(key: key);

  @override
  _SkinConductivityScreenState createState() => _SkinConductivityScreenState();
}

class _SkinConductivityScreenState extends State<SkinConductivityScreen> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00564D),
      ),
      body: SkinConductivityScreen(),
    );
  }

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior =
        ZoomPanBehavior(enablePinching: true, enableDoubleTapZooming: true);
    fetchThingSpeakData();
    const oneMin = Duration(seconds: 60);
    Timer.periodic(oneMin, (Timer t) => fetchThingSpeakData());
  }

  Uri thingSpeakURL = Uri.parse(
      'https://api.thingspeak.com/channels/${dotenv.env['THINGSPEAK_CHANNEL']!}/feeds.json?results=1000');
  List<EntryModel> thingSpeakData = [];

  void fetchThingSpeakData() async {
    try {
      thingSpeakData.clear();
      final response = await get(thingSpeakURL);
      final jsonData = jsonDecode(response.body)['feeds'];
      for (var entry in jsonData) {
        setState(() {
          thingSpeakData.add(EntryModel.fromMap(entry));
        });
      }
    } catch (err) {}
  }

  Widget SkinConductivityScreen() {
    return SfCartesianChart(
      title: ChartTitle(text: 'Skin Conductivity Chart \n'),
      legend:
          Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: _tooltipBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      series: <ChartSeries>[
        LineSeries<EntryModel, DateTime>(
          dataSource: thingSpeakData,
          xValueMapper: (EntryModel data, _) => data.createTime,
          yValueMapper: (EntryModel data, _) => data.skinConductivity,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          name: "Skin Resistance",
          enableTooltip: true,
        ),
      ],
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
    );
  }
}
