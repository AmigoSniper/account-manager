import 'package:flutter/material.dart';
import 'page/home.dart';
import 'constrant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Account Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        fontFamily: 'Cairo',
        textTheme: Theme.of(context).textTheme.apply(displayColor: kTextColor),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
