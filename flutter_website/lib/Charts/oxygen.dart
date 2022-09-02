import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_website/model/entry_model.dart';

class OxygenScreen extends StatefulWidget {
  List<EntryModel> thingSpeakData;
  OxygenScreen({Key? key, required this.thingSpeakData}) : super(key: key);

  @override
  _OxygenScreenState createState() => _OxygenScreenState();
}

class _OxygenScreenState extends State<OxygenScreen> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00564D),
      ),
      body: OxygenScreen(),
    );
  }

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior =
        ZoomPanBehavior(enablePinching: true, enableDoubleTapZooming: true);
  }

  Widget OxygenScreen() {
    return SfCartesianChart(
      title: ChartTitle(text: 'SpO2 Chart (%) \n'),
      legend:
          Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: _tooltipBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      series: <ChartSeries>[
        LineSeries<EntryModel, DateTime>(
          dataSource: widget.thingSpeakData,
          xValueMapper: (EntryModel data, _) => data.createTime,
          yValueMapper: (EntryModel data, _) => data.oxygen,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          enableTooltip: true,
        ),
      ],
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
    );
  }
}
