import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/src/services/predictive_back_event.dart';
import '../models/debt_model.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';

class DebtProvider
    with ChangeNotifier, Diagnosticable
    implements AppLifecycleListener {
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
    await loadDebtsFromLocalDB();
  }

  Future<void> loadDebtsFromLocalDB() async {
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
    await loadDebtsFromLocalDB();
    // notifyListeners();
  }

  Future<void> updateDebt(Debt debt) async {
    debt.lastUpdated = Timestamp.now();
    await _dbHelper.addOrUpdateDebt(debt);
    await _firestoreService.addOrUpdateDebt(debt);
    await loadDebtsFromLocalDB();
  }

  Future<void> deleteDebt(String phoneNumber) async {
    await _dbHelper.deleteDebt(phoneNumber);
    await _firestoreService.deleteDebt(phoneNumber);
    await loadDebtsFromLocalDB();
  }

  Future<void> syncWithFirestore() async {
    // Upload local changes to Firestore
    final localDebts = await _dbHelper.getAllDebts();
    for (var localDebt in localDebts) {
      final remoteDebtSnapshot = await _firestoreService.getDebt(
        localDebt.phoneNumber,
      );
      if (remoteDebtSnapshot.exists) {
        final remoteDebt = Debt.fromFirestore(
          remoteDebtSnapshot as DocumentSnapshot<Map<String, dynamic>>,
        );
        if (localDebt.lastUpdated.millisecondsSinceEpoch >
            remoteDebt.lastUpdated.millisecondsSinceEpoch) {
          await _firestoreService.addOrUpdateDebt(localDebt);
        }
      } else {
        await _firestoreService.addOrUpdateDebt(localDebt);
      }
    }

    // Download remote changes to local DB
    final firestoreDebts = await _firestoreService.getDebtsFuture();
    for (var remoteDebt in firestoreDebts) {
      final localDebt = await _dbHelper.getDebtByPhoneNumber(
        remoteDebt.phoneNumber,
      );
      if (localDebt == null ||
          remoteDebt.lastUpdated.millisecondsSinceEpoch >
              localDebt.lastUpdated.millisecondsSinceEpoch) {
        await _dbHelper.addOrUpdateDebt(remoteDebt);
      }
    }

    await loadDebtsFromLocalDB();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncWithFirestore();
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async => AppExitResponse.exit;

  @override
  void didChangePlatformBrightness() {
    /**/
  }

  @override
  void didHaveMemoryPressure() {
    /**/
  }

  @override
  void detached() {
    /**/
  }

  @override
  void inactive() {
    /**/
  }

  @override
  void paused() {
    /**/
  }

  @override
  void resumed() {
    /**/
  }

  @override
  void hidden() {
    /**/
  }

  @override
  void restored() {
    /**/
  }

  @override
  // TODO: implement binding
  WidgetsBinding get binding => throw UnimplementedError();

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // TODO: implement didChangeLocales
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
  }

  @override
  void didChangeTextScaleFactor() {
    // TODO: implement didChangeTextScaleFactor
  }

  @override
  void didChangeViewFocus(ViewFocusEvent event) {
    // TODO: implement didChangeViewFocus
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    // TODO: implement didPushRouteInformation
    throw UnimplementedError();
  }

  @override
  void handleCancelBackGesture() {
    // TODO: implement handleCancelBackGesture
  }

  @override
  void handleCommitBackGesture() {
    // TODO: implement handleCommitBackGesture
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    // TODO: implement handleStartBackGesture
    throw UnimplementedError();
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    // TODO: implement handleUpdateBackGestureProgress
  }

  @override
  // TODO: implement onDetach
  VoidCallback? get onDetach => throw UnimplementedError();

  @override
  // TODO: implement onExitRequested
  AppExitRequestCallback? get onExitRequested => throw UnimplementedError();

  @override
  // TODO: implement onHide
  VoidCallback? get onHide => throw UnimplementedError();

  @override
  // TODO: implement onInactive
  VoidCallback? get onInactive => throw UnimplementedError();

  @override
  // TODO: implement onPause
  VoidCallback? get onPause => throw UnimplementedError();

  @override
  // TODO: implement onRestart
  VoidCallback? get onRestart => throw UnimplementedError();

  @override
  // TODO: implement onResume
  VoidCallback? get onResume => throw UnimplementedError();

  @override
  // TODO: implement onShow
  VoidCallback? get onShow => throw UnimplementedError();

  @override
  // TODO: implement onStateChange
  ValueChanged<AppLifecycleState>? get onStateChange =>
      throw UnimplementedError();

  @override
  DiagnosticsNode toDiagnosticsNode({
    String? name,
    DiagnosticsTreeStyle? style,
  }) {
    // TODO: implement toDiagnosticsNode
    throw UnimplementedError();
  }

  @override
  String toStringShort() {
    // TODO: implement toStringShort
    throw UnimplementedError();
  }
}
