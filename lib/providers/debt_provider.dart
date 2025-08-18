
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
  StreamSubscription? _firestoreSubscription;

  List<Debt> get debts => _debts;
  double get totalDebt => _totalDebt;

  DebtProvider() {
    _init();
  }

  void _init() async {
    await _loadDebtsFromLocalDB();
    _listenToFirestoreChanges();
  }

  Future<void> _loadDebtsFromLocalDB() async {
    _debts = await _dbHelper.getAllDebts();
    _calculateTotalDebt();
    notifyListeners();
  }

  void _listenToFirestoreChanges() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = _firestoreService.getDebtsStream().listen((firestoreDebts) async {
      for (var remoteDebt in firestoreDebts) {
        final localDebt = await _dbHelper.getDebtByPhoneNumber(remoteDebt.phoneNumber);
        if (localDebt == null || remoteDebt.lastUpdated.millisecondsSinceEpoch > localDebt.lastUpdated.millisecondsSinceEpoch) {
          await _dbHelper.addOrUpdateDebt(remoteDebt);
        }
      }
      await _loadDebtsFromLocalDB(); // Reload from local DB to ensure consistency
    });
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

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
