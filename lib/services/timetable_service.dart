import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addTimetableEntry({
    required String classId,
    required String day,
    required String unit,
    required String time,
    required String room,
  }) async {
    await firestore
        .collection('classes')
        .doc(classId)
        .collection('timetable')
        .add({
      'day': day,
      'unit': unit,
      'time': time,
      'room': room,
    });
  }

  Future<QuerySnapshot> getTimetable(String classId) async {
    return await firestore
        .collection('classes')
        .doc(classId)
        .collection('timetable')
        .get();
  }
}