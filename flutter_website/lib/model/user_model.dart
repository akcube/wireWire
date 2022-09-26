import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? name;
  String? thingSpeakChannel;
  UserModel({this.uid, this.email, this.name, this.thingSpeakChannel});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      thingSpeakChannel: map['thingSpeakChannel'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'thingSpeakChannel': thingSpeakChannel,
    };
  }
}
