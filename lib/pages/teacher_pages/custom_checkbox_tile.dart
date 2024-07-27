import 'package:blue_print/assets/my_color_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCheckboxTile extends StatefulWidget {
  final String studentName;
  final String studentCode;
  final bool isChecked;
  final Function(String, String, bool) onCheckboxChanged;

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
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        height: 60,
        decoration: const BoxDecoration(color: MyColorThemeTheme.blueColor),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: _isChecked,
            // fillColor: WidgetStateProperty.all(Colors.red),
            checkColor: Colors.green,
            activeColor: Colors.white,
            focusColor: Colors.white,
            overlayColor: WidgetStateProperty.all(Colors.white),
            onChanged: (bool? value) {
              setState(() {
                _isChecked = value ?? false;
              });
              widget.onCheckboxChanged(
                  widget.studentCode, widget.studentName, _isChecked);
            },
          ),
          title: Text(widget.studentName, style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 15
          ),),
          subtitle: Text(widget.studentCode,style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 12
          ),),
        )

    );
  }
}
