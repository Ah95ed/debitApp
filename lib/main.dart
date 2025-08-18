
import 'package:debit_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_sizer/smart_sizer.dart';

import 'providers/debt_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // Make sure to configure your firebase project
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SizeBuilder(
            baseSize: Size(375, 812),
            height: context.screenHeight,
            width: context.screenWidth,
            child:  MaterialApp(
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
