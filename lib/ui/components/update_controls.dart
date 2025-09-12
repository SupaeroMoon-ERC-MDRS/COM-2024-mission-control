import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

abstract class DownloadHandler{
  static Future<bool> groundStation(final Version v) async {
    // remove current version
    // download new one
    // update Database.local* fields
  }

 static Future<bool> remote(final Version v) async {

  }

  static Future<bool> netcode(final Version v) async {

  }

  static Future<bool> dbc(final Version v) async {

  }
}

class UpdateControls extends StatefulWidget {
  const UpdateControls({super.key, required this.title, required this.getCurrent, required this.getOptions, required this.onChanged});

  final String title;
  final Version? Function() getCurrent;
  final List<Version?> Function() getOptions;
  final void Function(Version) onChanged;

  @override
  State<UpdateControls> createState() => _UpdateControlsState();
}

class _UpdateControlsState extends State<UpdateControls> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(widget.title, style: ThemeManager.textStyle,),
        ),
        Text(widget.getCurrent().toString(), style: ThemeManager.textStyle,),
        DropdownButton(
          value: widget.getCurrent(),
          items: widget.getOptions().map((e) => DropdownMenuItem(value: e, child: Text(e?.toString() ?? "Select", style: ThemeManager.textStyle,),)).toList(),
          onChanged: (final Version? v){
            if(v == null){
              return;
            }
            widget.onChanged(v);
          }
        )
      ],
    );
  }
}