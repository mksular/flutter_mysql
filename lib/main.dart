import 'package:flutter/material.dart';
import 'slaytPage.dart';
void main()=>runApp(MyApp());

class MyApp extends StatelessWidget {

final String title="Mysql App";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.purple
      ),

      initialRoute: "/",

      routes: {
        "/": (context)=> SlaytPage(title),
      },
    );
  }
}