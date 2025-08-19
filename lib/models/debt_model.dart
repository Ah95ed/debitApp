class Debt {
  final String phoneNumber;
  String name;
  double amount;
  DateTime date;
  String note;
  String status;
  DateTime lastUpdated;

  Debt({
    
    required this.phoneNumber,
    required this.name,
    required this.amount,
    required this.date,
    this.note = '',
    this.status = 'pending',
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
     
      'phoneNumber': phoneNumber,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      amount: double.tryParse(map['amount'].toString()) ?? 0.0,
      date: DateTime.parse(map['date']),
      note: map['note'],
      status: map['status'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}