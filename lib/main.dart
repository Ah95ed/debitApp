import 'package:debit_app/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_sizer/smart_sizer.dart';
import 'providers/debt_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await DatabaseHelper
      .instance
      .database; // Make sure to configure your firebase project
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _listener;
  late final DebtProvider _debtProvider;

  @override
  void initState() {
    super.initState();
    _debtProvider = DebtProvider();
    _listener = AppLifecycleListener(
      onStateChange: _debtProvider.didChangeAppLifecycleState,
    );

  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: _debtProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SizeBuilder(
            baseSize: Size(375, 812),
            height: context.screenHeight,
            width: context.screenWidth,
            child: MaterialApp(
              title: 'Debt Manager',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              home: const HomePage(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
