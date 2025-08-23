import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data_misc/notifiers.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

abstract class UpdateHandler{
  static void groundStation(){

  }

  static void remote(){
    
  }

  static void netcode(){
    
  }

  static void dbc(){
    
  }
}

class UpdateDialogConfig {
  final bool hasRequiredDBC;
  final bool hasRequiredNetCode;
  final Version? requiredDBC;
  final Version? requiredNetCode;
  final Version? version;

  UpdateDialogConfig({
    this.hasRequiredDBC = false,
    this.hasRequiredNetCode = false,
    this.requiredDBC,
    this.requiredNetCode,
    this.version,
  });
}

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key, required this.config, required this.updateHandler});

  final UpdateDialogConfig config;
  final Function updateHandler;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  late final bool isNew;
  final UpdateableValueNotifier<String> statusMsg = UpdateableValueNotifier("");
  final TextEditingController _version = TextEditingController();
  final TextEditingController _reqDBCVersion = TextEditingController();
  final TextEditingController _reqNetCodeVersion = TextEditingController();

  @override
  void initState() {
    isNew = widget.config.version == null;
    statusMsg.addListener(update);
    super.initState();
  }

  void update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Version of this module: ", style: ThemeManager.textStyle,),
            const Spacer(),
            SizedBox(
              width: 200,
              child: isNew ? 
                TextFormField(
                  controller: _version,
                )
                :
                Text(widget.config.version!.toString(), style: ThemeManager.textStyle,)
            ),
          ],
        ),
        Row(
          children: [
            Text("Version of required netcode: ", style: ThemeManager.textStyle,),
            const Spacer(),
            SizedBox(
              width: 200,
              child: isNew && widget.config.hasRequiredNetCode ? 
                TextFormField(
                  controller: _reqNetCodeVersion,
                )
                :
                Text(widget.config.requiredNetCode?.toString() ?? "No netcode required", style: ThemeManager.textStyle,)
            ),
          ],
        ),
        Row(
          children: [
            Text("Version of required dbc: ", style: ThemeManager.textStyle,),
            const Spacer(),
            SizedBox(
              width: 200,
              child: isNew && widget.config.hasRequiredDBC ? 
                TextFormField(
                  controller: _reqDBCVersion,
                )
                :
                Text(widget.config.requiredDBC?.toString() ?? "No dbc required", style: ThemeManager.textStyle,)
            ),
          ],
        ),
        Row(
          children: [
            Text(statusMsg.value, style: ThemeManager.textStyle,),
            TextButton(
              onPressed: (){
                // TODO validate -> status msg
                // TODO upload file and attr using updatehandler
              },
              child: Text("Select", style: ThemeManager.textStyle,)
            )
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    statusMsg.removeListener(update);
    super.dispose();
  }
}