import 'package:debit_app/services/database_helper.dart';
import 'package:debit_app/ui/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_sizer/smart_sizer.dart';
import 'providers/debt_provider.dart';
import 'ui/screens/home_page.dart';
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 prefs = await SharedPreferences.getInstance();
  await DatabaseHelper.instance.database;
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _listener;
  late final DebtProvider _debtProvider;
  late final ValueNotifier<ThemeMode> _themeNotifier;

  @override
  void initState() {
    super.initState();
    _debtProvider = DebtProvider();
    _themeNotifier = ValueNotifier(widget.isDarkMode ? ThemeMode.dark : ThemeMode.light);
    _listener = AppLifecycleListener(
      onStateChange: _debtProvider.didChangeAppLifecycleState,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _debtProvider,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeNotifier,
        builder: (context, currentMode, child) {
          return SizeBuilder(
            baseSize: Size(375, 812),
            height: context.screenHeight,
            width: context.screenWidth,
            child: MaterialApp(
              title: 'مدير الديون',
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: currentMode,
              home: HomePage(themeNotifier: _themeNotifier),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
