import 'package:flutter/material.dart';

class AlertSettingsScreen extends StatelessWidget {
  const AlertSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert Settings')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Configure your notification alerts here.'),
      ),
    );
  }
}

