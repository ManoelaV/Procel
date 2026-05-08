import 'package:flutter/material.dart';

void main() {
  runApp(const MobileEntryApp());
}

class MobileEntryApp extends StatelessWidget {
  const MobileEntryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('PROCEL Mobile')),
        body: const Center(
          child: Text('Android OK'),
        ),
      ),
    );
  }
}
