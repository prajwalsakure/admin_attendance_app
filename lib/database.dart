import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  Database();
  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection("attendance");

  Future setSubject(String subject) {
    Timestamp myTime = Timestamp.fromDate(DateTime.now());
    return attendanceCollection.doc(subject).set({subject: myTime});
  }
}
