import 'dart:convert';
import 'package:flutter/material.dart';

class EntryModel {
  DateTime? createTime;
  int? entryId;
  double? systolic, diastolic, heartRate, temperature, oxygen, skinConductivity;

  EntryModel({
    this.createTime,
    this.entryId,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.temperature,
    this.oxygen,
    this.skinConductivity,
  });

  factory EntryModel.fromMap(map) {
    return EntryModel(
      createTime: DateTime.parse(map['created_at']),
      entryId: map['entry_id'] ?? 0,
      systolic: double.tryParse(map['field1'] ?? "") ?? 0.0,
      diastolic: double.tryParse(map['field2'] ?? "") ?? 0.0,
      heartRate: double.tryParse(map['field3'] ?? "") ?? 0.0,
      temperature: double.tryParse(map['field4'] ?? "") ?? 0.0,
      oxygen: double.tryParse(map['field5'] ?? "") ?? 0.0,
      skinConductivity: double.tryParse(map['field6'] ?? "") ?? 0.0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'createTime': createTime,
      'entryId': entryId,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'temperature': temperature,
      'oxygen': oxygen,
      'skinConductivity': skinConductivity,
    };
  }
}
