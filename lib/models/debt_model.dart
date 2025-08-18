
import 'package:cloud_firestore/cloud_firestore.dart';

class Debt {
  String? id; // Firestore document ID
  final String phoneNumber;
  String name;
  double amount;
  DateTime date;
  String note;
  String status;
  Timestamp lastUpdated; // For sync conflict resolution

  Debt({
    this.id,
    required this.phoneNumber,
    required this.name,
    required this.amount,
    required this.date,
    this.note = '',
    this.status = 'pending',
    required this.lastUpdated,
  });

  // Convert a Debt object into a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'status': status,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  // Create a Debt object from a Map from SQLite
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      status: map['status'],
      lastUpdated: Timestamp.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  // Convert a Debt object into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'status': status,
      'lastUpdated': lastUpdated,
    };
  }

  // Create a Debt object from a Firestore DocumentSnapshot
  factory Debt.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Debt(
      id: snapshot.id,
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
      status: data['status'] ?? 'pending',
      lastUpdated: data['lastUpdated'] as Timestamp,
    );
  }
}
