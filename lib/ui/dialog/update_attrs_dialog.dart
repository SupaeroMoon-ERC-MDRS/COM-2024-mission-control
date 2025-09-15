import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/data/ftp.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

abstract class UpdateAttrsHandler{
  static Future<bool> groundStation(final Version version, final Version? requiredNetCode, final Version? requiredDBC) async {
    FileSystem.trySaveMapToLocalSync(FileSystem.tmpDir, "tmpgroundstationattr", {
      "version": version.toString(),
      "requiredNetCode": requiredNetCode!.toString(),
      "requiredDBC": requiredDBC!.toString()  
    });
    await FTP.upload(FileSystem.tmpDir, "tmpgroundstationattr", "${Database.remoteGroundStationFolder}${version.toString()}/", DPath.attributesFile);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpgroundstationattr");

    final int ref = Database.groundStationDescriptors.indexWhere((e) => e.version == version);
    Database.groundStationDescriptors[ref] = GroundStationDescriptor.fromMap({
      "version": version,
      "requiredNetCode": requiredNetCode,
      "requiredDBC": requiredDBC
    });
    return true;
  }

  static Future<bool> remote(final Version version, final Version? requiredNetCode, final Version? _) async {
    FileSystem.trySaveMapToLocalSync(FileSystem.tmpDir, "tmpremoteattr", {"version": version.toString(), "requiredNetCode": requiredNetCode!.toString()});
    await FTP.upload(FileSystem.tmpDir, "tmpremoteattr", "${Database.remoteRemoteFolder}${version.toString()}/", DPath.attributesFile);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpremoteattr");

    final int ref = Database.remoteDescriptors.indexWhere((e) => e.version == version);
    Database.remoteDescriptors[ref] = RemoteControlDescriptor.fromMap({
      "version": version,
      "requiredNetCode": requiredNetCode,
    });
    return true;
  }

  static Future<bool> netcode(final Version version, final Version? _, final Version? __) async {
    // nothing to do
    return true;
  }

  static Future<bool> dbc(final Version version, final Version? _, final Version? __) async {
    // nothing to do
    return true;
  }
}

class UpdateAttrsDialogConfig {
  final bool hasRequiredDBC;
  final bool hasRequiredNetCode;
  final Version? requiredDBC;
  final Version? requiredNetCode;
  final Version version;

  UpdateAttrsDialogConfig({
    this.hasRequiredDBC = false,
    this.hasRequiredNetCode = false,
    this.requiredDBC,
    this.requiredNetCode,
    required this.version,
  });
}

class UpdateAttrsDialog extends StatefulWidget {
  const UpdateAttrsDialog({super.key, required this.config, required this.updateHandler, required this.checkIfExists});

  final UpdateAttrsDialogConfig config;
  final Future<bool> Function(Version, Version?, Version?) updateHandler;
  final bool Function(Version) checkIfExists;

  @override
  State<UpdateAttrsDialog> createState() => _UpdateAttrsDialogState();
}

class _UpdateAttrsDialogState extends State<UpdateAttrsDialog> {
  String statusMsg = "";
  final TextEditingController _reqDBCVersion = TextEditingController();
  final TextEditingController _reqNetCodeVersion = TextEditingController();

  @override
  void initState() {
    _reqDBCVersion.text = widget.config.requiredDBC?.toString() ?? "";
    _reqNetCodeVersion.text = widget.config.requiredNetCode?.toString() ?? "";
    super.initState();
  }

  void _update() => setState(() {});

  bool _validate(){
    if(widget.config.hasRequiredNetCode){
      if(_reqNetCodeVersion.text.split('.').length != 3){
        statusMsg = "Provide version of the netcode required as major.minor.patch";
        _update();
        return false;
      }

      final Version tmp = Version.fromString(_reqNetCodeVersion.text);
      if(!Database.netCodeVersions.contains(tmp)){
        statusMsg = "Required netcode version doesnt exist";
        _update();
        return false;
      }
    }

    if(widget.config.hasRequiredDBC){
      if(_reqDBCVersion.text.split('.').length != 3){
        statusMsg = "Provide version of the dbc required as major.minor.patch";
        _update();
        return false;
      }

      final Version tmp = Version.fromString(_reqDBCVersion.text);
      if(!Database.dbcVersions.contains(tmp)){
        statusMsg = "Required dbc version doesnt exist";
        _update();
        return false;
      }
    }
    return true;
  }

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
              height: 40,
              child: Center(child: Text(widget.config.version.toString(), style: ThemeManager.textStyle,))
            ),
          ],
        ),
        Row(
          children: [
            Text("Version of required netcode: ", style: ThemeManager.textStyle,),
            const Spacer(),
            SizedBox(
              width: 200,
              height: 40,
              child: widget.config.hasRequiredNetCode ? 
                TextFormField(
                  controller: _reqNetCodeVersion,
                )
                :
                Center(child: Text(widget.config.requiredNetCode?.toString() ?? "No netcode required", style: ThemeManager.textStyle,))
            ),
          ],
        ),
        Row(
          children: [
            Text("Version of required dbc: ", style: ThemeManager.textStyle,),
            const Spacer(),
            SizedBox(
              width: 200,
              height: 40,
              child: widget.config.hasRequiredDBC ? 
                TextFormField(
                  controller: _reqDBCVersion,
                )
                :
                Center(child: Text(widget.config.requiredDBC?.toString() ?? "No dbc required", style: ThemeManager.textStyle,))
            ),
          ],
        ),
        Row(
          children: [
            Text(statusMsg, style: ThemeManager.textStyle,),
            TextButton(
              onPressed: () async {
                if(!_validate()){
                  return;
                }
                
                final bool success = await widget.updateHandler(
                  widget.config.version,
                  widget.config.hasRequiredNetCode ? widget.config.requiredNetCode ?? Version.fromString(_reqNetCodeVersion.text) : null,
                  widget.config.hasRequiredDBC ? widget.config.requiredDBC ?? Version.fromString(_reqDBCVersion.text) : null
                );

                if(success){
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
                else{
                  statusMsg = "Updating attributes failed";
                  _update();
                  return;
                }
              },
              child: Text("Update attributes", style: ThemeManager.textStyle,)
            )
          ],
        )
      ],
    );
  }
}