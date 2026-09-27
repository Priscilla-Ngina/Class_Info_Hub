import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createAnnouncement({
    required String classId,
    required String title,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    await firestore
        .collection('classes')
        .doc(classId)
        .collection('announcements')
        .add({
      'title': title,
      'content': content,
      'postedBy': user.uid,
      'postedAt': FieldValue.serverTimestamp(),
      'isPinned': false,
    });
  }

  Future<QuerySnapshot> getAnnouncements(String classId) async {
    return await firestore
        .collection('classes')
        .doc(classId)
        .collection('announcements')
        .orderBy('postedAt', descending: true)
        .get();
  }

  Future<void> updateAnnouncement({
    required String classId,
    required String announcementId,
    required String title,
    required String content,
  }) async {
    await firestore
        .collection('classes')
        .doc(classId)
        .collection('announcements')
        .doc(announcementId)
        .update({
      'title': title,
      'content': content,
    });
  }

  Future<void> deleteAnnouncement({
    required String classId,
    required String announcementId,
  }) async {
    await firestore
        .collection('classes')
        .doc(classId)
        .collection('announcements')
        .doc(announcementId)
        .delete();
  }

  Future<void> setPinned({
    required String classId,
    required String announcementId,
    required bool isPinned,
  }) async {
    await firestore
        .collection('classes')
        .doc(classId)
        .collection('announcements')
        .doc(announcementId)
        .update({
      'isPinned': isPinned,
    });
  }
}