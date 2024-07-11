import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCheckboxTile extends StatefulWidget {
  final String studentName;
  final String studentCode;
  final bool isChecked;
  final Function(String,String, bool) onCheckboxChanged;

  CustomCheckboxTile({
    required this.studentName,
    required this.studentCode,
    required this.isChecked,
    required this.onCheckboxChanged,
  });

  @override
  _CustomCheckboxTileState createState() => _CustomCheckboxTileState();
}

class _CustomCheckboxTileState extends State<CustomCheckboxTile> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: _isChecked,
        onChanged: (bool? value) {
          setState(() {
            _isChecked = value ?? false;
          });
          widget.onCheckboxChanged(widget.studentCode,widget.studentName,  _isChecked);
        },
      ),
      title: Text(widget.studentName),
      subtitle: Text(widget.studentCode),
    );
  }
}