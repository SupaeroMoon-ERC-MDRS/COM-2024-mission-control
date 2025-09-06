import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/data/ftp.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

abstract class UpdateHandler{
  static Future<bool> groundStation(final Version version, final Version? requiredNetCode, final Version? requiredDBC) async {
    final String? dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Pick the remote control executable of this version",
      initialDirectory: FileSystem.getCurrentDirectory,
    );

    if(dir == null){
      return false;
    }

    await FTP.uploadZip(dir, "ground_station_${version.toString()}.tar", "${Database.remoteGroundStationFolder}${version.toString()}/");

    FileSystem.trySaveMapToLocalSync(FileSystem.tmpDir, "tmpgroundstationattr", {
      "version": version.toString(),
      "requiredNetCode": requiredNetCode!.toString(),
      "requiredDBC": requiredDBC!.toString()  
    });
    await FTP.upload(FileSystem.tmpDir, "tmpgroundstationattr", "${Database.remoteGroundStationFolder}${version.toString()}/", attributesFile);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpgroundstationattr");
    return true;
  }

  static Future<bool> remote(final Version version, final Version? requiredNetCode, final Version? _) async {
    final FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick the remote control executable of this version",
      initialDirectory: FileSystem.getCurrentDirectory,
      allowedExtensions: [".exe", ""],
      allowMultiple: false,
      withData: true
    );

    if(res == null){
      return false;
    }

    FileSystem.trySaveBytesToLocalSync(FileSystem.tmpDir, "tmpremote", res.files.first.bytes!);
    await FTP.upload(FileSystem.tmpDir, "tmpremote", "${Database.remoteRemoteFolder}${version.toString()}/", res.files.first.name);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpremote");

    FileSystem.trySaveMapToLocalSync(FileSystem.tmpDir, "tmpremoteattr", {"version": version.toString(), "requiredNetCode": requiredNetCode!.toString()});
    await FTP.upload(FileSystem.tmpDir, "tmpremoteattr", "${Database.remoteRemoteFolder}${version.toString()}/", attributesFile);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpremoteattr");
    return true;
  }

  static Future<bool> netcode(final Version version, final Version? _, final Version? __) async {
    final FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick the netcode dynamic library of this version",
      initialDirectory: FileSystem.getCurrentDirectory,
      allowedExtensions: [".dll", ".so", ".lib", ".a"],
      allowMultiple: true,
      withData: true
    );

    if(res == null || res.count != 2){
      return false;
    }

    FileSystem.trySaveBytesToLocalSync(FileSystem.tmpDir, "tmplib1", res.files.first.bytes!);
    await FTP.upload(FileSystem.tmpDir, "tmplib1", "${Database.remoteNetCodeFolder}${version.toString()}/", res.files.first.name);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmplib1");

    FileSystem.trySaveBytesToLocalSync(FileSystem.tmpDir, "tmplib2", res.files.last.bytes!);
    await FTP.upload(FileSystem.tmpDir, "tmplib2", "${Database.remoteNetCodeFolder}${version.toString()}/", res.files.last.name);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmplib2");

    FileSystem.trySaveMapToLocalSync(FileSystem.tmpDir, "tmpnetattr", {"version": version.toString()});
    await FTP.upload(FileSystem.tmpDir, "tmpnetattr", "${Database.remoteNetCodeFolder}${version.toString()}/", attributesFile);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpnetattr");
    return true;
  }

  static Future<bool> dbc(final Version version, final Version? _, final Version? __) async {
    final FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick the dbc file of this version",
      initialDirectory: FileSystem.getCurrentDirectory,
      allowedExtensions: [".dbc"],
      allowMultiple: false,
      withData: true
    );

    if(res == null){
      return false;
    }

    FileSystem.trySaveBytesToLocalSync(FileSystem.tmpDir, "tmpdbc", res.files.first.bytes!);
    await FTP.upload(FileSystem.tmpDir, "tmpdbc", "${Database.remoteDbcFolder}${version.toString()}/", "comms.dbc");
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpdbc");

    FileSystem.trySaveMapToLocalSync(FileSystem.tmpDir, "tmpdbcattr", {"version": version.toString()});
    await FTP.upload(FileSystem.tmpDir, "tmpdbcattr", "${Database.remoteDbcFolder}${version.toString()}/", attributesFile);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmpdbcattr");
    return true;
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
  const UpdateDialog({super.key, required this.config, required this.updateHandler, required this.checkIfExists});

  final UpdateDialogConfig config;
  final Future<bool> Function(Version, Version?, Version?) updateHandler;
  final bool Function(Version) checkIfExists;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  late final bool isNew;
  String statusMsg = "";
  final TextEditingController _version = TextEditingController();
  final TextEditingController _reqDBCVersion = TextEditingController();
  final TextEditingController _reqNetCodeVersion = TextEditingController();

  @override
  void initState() {
    isNew = widget.config.version == null;
    super.initState();
  }

  void _update() => setState(() {});

  bool _validate(){
    if(isNew){
      if(_version.text.split('.').length != 3){
        statusMsg = "Provide version of this module as major.minor.patch";
        _update();
        return false;
      }
      
      final Version tmp = Version.fromString(_version.text);
      if(widget.checkIfExists(tmp)){
        statusMsg = "This version already exists";
        _update();
        return false;
      }
    }

    if(isNew && widget.config.hasRequiredNetCode){
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

    if(isNew && widget.config.hasRequiredDBC){
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
              child: isNew ? 
                TextFormField(
                  controller: _version,
                )
                :
                Center(child: Text(widget.config.version!.toString(), style: ThemeManager.textStyle,))
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
              child: isNew && widget.config.hasRequiredNetCode ? 
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
              child: isNew && widget.config.hasRequiredDBC ? 
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
                  widget.config.version ?? Version.fromString(_version.text),
                  widget.config.hasRequiredNetCode ? widget.config.requiredNetCode ?? Version.fromString(_reqNetCodeVersion.text) : null,
                  widget.config.hasRequiredDBC ? widget.config.requiredDBC ?? Version.fromString(_reqDBCVersion.text) : null
                );

                if(success){
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
                else{
                  statusMsg = "Upload failed";
                  _update();
                  return;
                }
              },
              child: Text("Select", style: ThemeManager.textStyle,)
            )
          ],
        )
      ],
    );
  }
}