import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/src/services/predictive_back_event.dart';
import '../models/debt_model.dart';
import '../services/database_helper.dart';
import '../services/appwrite_service.dart';

class DebtProvider
    with ChangeNotifier, Diagnosticable
    implements AppLifecycleListener {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AppwriteService _appwriteService = AppwriteService();

  List<Debt> _debts = [];
  List<Debt> _searchResults = [];
  double _totalDebt = 0.0;
  StreamSubscription? _debtSubscription;

  List<Debt> get debts => _debts;
  List<Debt> get searchResults => _searchResults;
  double get totalDebt => _totalDebt;

  DebtProvider() {
    _init();
  }
  void _init() async {
    await loadDebtsFromLocalDB();
    await syncWithAppwrite();
    _debtSubscription = _appwriteService.subscribeToDebtChanges().listen((event) async {
      if (event.events.contains('databases.*.collections.*.documents.*.delete')) {
        final phoneNumber = event.payload['phoneNumber'];
        if (phoneNumber != null) {
          await _dbHelper.deleteDebt(phoneNumber);
          await loadDebtsFromLocalDB();
        }
      }
    });
  }

  @override
  void dispose() {
    _debtSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadDebtsFromLocalDB() async {
    _debts = await _dbHelper.getAllDebts();
    _searchResults = _debts;
    _calculateTotalDebt();
    notifyListeners();
  }

  void _calculateTotalDebt() {
    _totalDebt = _debts.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> addDebt(Debt debt) async {
    await _dbHelper.addOrUpdateDebt(debt);
    await _appwriteService.addOrUpdateDebt(debt);
    await loadDebtsFromLocalDB();
  }

  Future<void> updateDebt(Debt debt) async {
    await _dbHelper.addOrUpdateDebt(debt);
    await _appwriteService.addOrUpdateDebt(debt);
    await loadDebtsFromLocalDB();
  }

  Future<void> deleteDebt(String phoneNumber) async {
    await _dbHelper.deleteDebt(phoneNumber);
    await _appwriteService.deleteDebt(phoneNumber);
    await loadDebtsFromLocalDB();
  }

  void searchDebts(String query) {
    if (query.isEmpty) {
      _searchResults = _debts;
    } else {
      _searchResults = _debts
          .where((debt) =>
              debt.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> syncWithAppwrite() async {
    final localDebts = await _dbHelper.getAllDebts();
    final remoteDebts = await _appwriteService.getAllDebts();

    // Upload local changes to Appwrite
    for (var localDebt in localDebts) {
      Debt? remoteDebt;
      for (var debt in remoteDebts) {
        if (debt.phoneNumber == localDebt.phoneNumber) {
          remoteDebt = debt;
          break;
        }
      }

      if (remoteDebt == null || localDebt.lastUpdated.isAfter(remoteDebt.lastUpdated)) {
        await _appwriteService.addOrUpdateDebt(localDebt);
      }
    }

    // Identify debts deleted on Appwrite and delete them locally
    final remotePhoneNumbers = remoteDebts.map((d) => d.phoneNumber).toSet();
    for (var localDebt in localDebts) {
      if (!remotePhoneNumbers.contains(localDebt.phoneNumber)) {
        await _dbHelper.deleteDebt(localDebt.phoneNumber);
      }
    }

    // Download remote changes to local DB
    for (var remoteDebt in remoteDebts) {
      final localDebt = await _dbHelper.getDebtByPhoneNumber(
        remoteDebt.phoneNumber,
      );
      if (localDebt == null ||
          remoteDebt.lastUpdated.isAfter(localDebt.lastUpdated)) {
        await _dbHelper.addOrUpdateDebt(remoteDebt);
      }
    }

    await loadDebtsFromLocalDB();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncWithAppwrite();
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