import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Stream<DocumentSnapshot> getFinancialStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('financial data')
        .doc('YsRBxBVPzsSLyF6vct1l')
        .snapshots();
  }

  static Stream<DocumentSnapshot> getUserStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }
}
