import 'package:flutter/material.dart';
import 'package:schwingung_app/screens/home.dart';
import 'package:schwingung_app/screens/data_table.dart';
import 'package:schwingung_app/screens/manual_input.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schwingung App',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        DataTableScreen.routeName: (_) => const DataTableScreen(),
        ManualInputScreen.routeName: (_) => const ManualInputScreen(),
      },
    );
  }
}
