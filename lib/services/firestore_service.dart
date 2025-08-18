
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debt_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of debts with optional query parameters
  Stream<List<Debt>> getDebtsStream({String? orderBy, bool descending = false, int? limit, Map<String, dynamic>? where}) {
    Query query = _db.collection('debts');

    if (where != null) {
      where.forEach((key, value) {
        query = query.where(key, isEqualTo: value);
      });
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Debt.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Future<DocumentSnapshot> getDebt(String phoneNumber) {
    return _db.collection('debts').doc(phoneNumber).get();
  }

  Future<List<Debt>> getDebtsFuture() async {
    final snapshot = await _db.collection('debts').get();
    return snapshot.docs
        .map((doc) => Debt.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  // Add or update a debt in Firestore
  Future<void> addOrUpdateDebt(Debt debt) {
    final docRef = _db.collection('debts').doc(debt.phoneNumber);
    return docRef.set(debt.toJson(), SetOptions(merge: true));
  }

  // Delete a debt from Firestore
  Future<void> deleteDebt(String phoneNumber) {
    return _db.collection('debts').doc(phoneNumber).delete();
  }
}
