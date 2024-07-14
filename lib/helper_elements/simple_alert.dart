import 'package:flutter/material.dart';
class SimpleAlert extends StatelessWidget {
  final String heading;
  final String explainer;
  const SimpleAlert({super.key, required this.heading, required this.explainer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(heading),
      content: Text(explainer),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
