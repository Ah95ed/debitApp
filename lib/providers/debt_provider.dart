
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debt_model.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';

class DebtProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirestoreService _firestoreService = FirestoreService();

  List<Debt> _debts = [];
  double _totalDebt = 0.0;

  List<Debt> get debts => _debts;
  double get totalDebt => _totalDebt;

  DebtProvider() {
    _init();
  }

  void _init() async {
    await _loadDebtsFromLocalDB();
  }

  Future<void> _loadDebtsFromLocalDB() async {
    _debts = await _dbHelper.getAllDebts();
    _calculateTotalDebt();
    notifyListeners();
  }

  void _calculateTotalDebt() {
    _totalDebt = _debts.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> addDebt(Debt debt) async {
    debt.lastUpdated = Timestamp.now();
    await _dbHelper.addOrUpdateDebt(debt);
    await _firestoreService.addOrUpdateDebt(debt);
    await _loadDebtsFromLocalDB();
  }

  Future<void> updateDebt(Debt debt) async {
    debt.lastUpdated = Timestamp.now();
    await _dbHelper.addOrUpdateDebt(debt);
    await _firestoreService.addOrUpdateDebt(debt);
    await _loadDebtsFromLocalDB();
  }

  Future<void> deleteDebt(String phoneNumber) async {
    await _dbHelper.deleteDebt(phoneNumber);
    await _firestoreService.deleteDebt(phoneNumber);
    await _loadDebtsFromLocalDB();
  }

  Future<void> syncWithFirestore() async {
    // Upload local changes to Firestore
    final localDebts = await _dbHelper.getAllDebts();
    for (var localDebt in localDebts) {
      final remoteDebtSnapshot = await _firestoreService.getDebt(localDebt.phoneNumber);
      if (remoteDebtSnapshot.exists) {
        final remoteDebt = Debt.fromFirestore(remoteDebtSnapshot as DocumentSnapshot<Map<String, dynamic>>);
        if (localDebt.lastUpdated.millisecondsSinceEpoch > remoteDebt.lastUpdated.millisecondsSinceEpoch) {
          await _firestoreService.addOrUpdateDebt(localDebt);
        }
      } else {
        await _firestoreService.addOrUpdateDebt(localDebt);
      }
    }

    // Download remote changes to local DB
    final firestoreDebts = await _firestoreService.getDebtsFuture();
    for (var remoteDebt in firestoreDebts) {
      final localDebt = await _dbHelper.getDebtByPhoneNumber(remoteDebt.phoneNumber);
      if (localDebt == null || remoteDebt.lastUpdated.millisecondsSinceEpoch > localDebt.lastUpdated.millisecondsSinceEpoch) {
        await _dbHelper.addOrUpdateDebt(remoteDebt);
      }
    }

    await _loadDebtsFromLocalDB();
  }

}
