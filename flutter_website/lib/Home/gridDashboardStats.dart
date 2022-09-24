import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_website/Charts/blood_pressure.dart';
import 'package:flutter_website/Charts/heart_rate.dart';
import 'package:flutter_website/Charts/oxygen.dart';
import 'package:flutter_website/Charts/skin_conductivity.dart';
import 'package:flutter_website/Charts/temperature.dart';
import 'package:flutter_website/Home/home.dart';
import 'package:flutter_website/model/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import '../model/entry_model.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class GridDashboardStats extends StatefulWidget {
  const GridDashboardStats({Key? key}) : super(key: key);
  @override
  _GridDashboardStatsState createState() => _GridDashboardStatsState();
}

class _GridDashboardStatsState extends State<GridDashboardStats> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  DateTime lastEntry = DateTime(1999, 1, 1); // Some old date
  @override
  void initState() {
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
    const oneMin = Duration(seconds: 60);
    Timer.periodic(oneMin, (Timer t) => fetchThingSpeakData());
  }

  Items item1 = Items(
      title: "Blood Pressure",
      subtitle: 0,
      event: "",
      unit: " mm",
      route: BloodPressureScreen());

  Items item2 = Items(
      title: "Heart Rate",
      subtitle: 0,
      event: "",
      unit: " bpm",
      route: HeartRateScreen());

  Items item3 = Items(
      title: "Temperature",
      subtitle: 0,
      event: "",
      unit: " °C",
      route: TemperatureScreen());

  Items item4 = Items(
      title: "SPO2", subtitle: 0, event: "", unit: " %", route: OxygenScreen());
  Items item5 = Items(
      title: "Skin Conductivity",
      subtitle: 0,
      event: "",
      unit: " ",
      route: SkinConductivityScreen());
  Items item6 = Items(
      title: "More Stats",
      subtitle: 0,
      event: "assets/home/stats.png",
      unit: "See more in-depth stats",
      route: HomePage());
  List<EntryModel> thingSpeakData = [];
  List<List<EntryModel>> separateRecordings = [[]];
  void fetchThingSpeakData() async {
    try {
      Uri thingSpeakURL = Uri.parse(
          'https://api.thingspeak.com/channels/${loggedInUser.thingSpeakChannel ?? 0}/feeds.json?results=1000');
      thingSpeakData.clear();
      List<List<EntryModel>> temp2 = [];
      final response = await get(thingSpeakURL);
      final jsonData = jsonDecode(response.body)['feeds'];
      List<EntryModel> temp = [];
      for (var entry in jsonData) {
        EntryModel data = EntryModel.fromMap(entry);
        if (!data.isErroneousDataPoint()) {
          // thingSpeakData.add(data);
          setState(() {
            item1.subtitle = data.systolic!;
            item2.subtitle = data.heartRate!;
            item3.subtitle = data.temperature!;
            item4.subtitle = data.oxygen!;
            item5.subtitle = data.skinConductivity!;
            lastEntry = data.createTime!;
          });
        }
      }
    } catch (err) {}
  }

  Widget dashboard() {
    List<Items> myList = [
      item1,
      item2,
      item3,
      item4,
      item5,
    ];
    var color = 0xff453658;
    List<Widget> abc = myList.map((data) {
      return Container(
        foregroundDecoration: const BoxDecoration(
          color: Colors.transparent,
          backgroundBlendMode: BlendMode.saturation,
        ),
        decoration: BoxDecoration(
          color: Color(color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return data.route;
            }));
          },
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Image.asset(data.img, width: 42),
              const SizedBox(height: 14),
              Text(
                data.title,
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "${data.subtitle}${data.unit}",
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                data.event,
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
    abc.add(Container(
      foregroundDecoration: const BoxDecoration(
        color: Colors.transparent,
        backgroundBlendMode: BlendMode.saturation,
      ),
      decoration: BoxDecoration(
        color: Color(color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return item6.route;
          }));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(item6.event, width: 42),
            const SizedBox(height: 14),
            Text(
              item6.title,
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item6.unit,
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    ));
    return GridView.count(
      childAspectRatio: 1.0,
      padding: const EdgeInsets.only(left: 16, right: 16),
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      //   children: myList.map((data) {
      //     return Container(
      //       foregroundDecoration: const BoxDecoration(
      //         color: Colors.transparent,
      //         backgroundBlendMode: BlendMode.saturation,
      //       ),
      //       decoration: BoxDecoration(
      //         color: Color(color),
      //         borderRadius: BorderRadius.circular(10),
      //       ),
      //       child: InkWell(
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (context) {
      //             return data.route;
      //           }));
      //         },
      //         child: Column(
      //           // mainAxisAlignment: MainAxisAlignment.center,
      //           // crossAxisAlignment: CrossAxisAlignment.center,
      //           children: <Widget>[
      //             // Image.asset(data.img, width: 42),
      //             const SizedBox(height: 14),
      //             Text(
      //               data.title,
      //               style: GoogleFonts.openSans(
      //                 textStyle: const TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 16,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(height: 30),
      //             Text(
      //               "${data.subtitle}${data.unit}",
      //               style: GoogleFonts.openSans(
      //                 textStyle: const TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 34,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(height: 14),
      //             Text(
      //               data.event,
      //               style: GoogleFonts.openSans(
      //                 textStyle: const TextStyle(
      //                   color: Colors.white70,
      //                   fontSize: 11,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   }).toList(),
      children: abc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(child: dashboard());
    //   return Scaffold(
    //       backgroundColor: const Color(0xff392850), body: dashboard());
  }
}

class Items {
  String title;
  double subtitle;
  String event;
  String unit;
  Widget route;
  Items(
      {required this.title,
      required this.subtitle,
      required this.event,
      required this.unit,
      required this.route});
}
