import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

class StringRef{
  final String s;

  StringRef({required this.s});
}

abstract class DeleteHandler{
  static Future<bool> groundStation(final Version version) async {
    for(final SftpName name in await manager.sftp.listdir("${Database.remoteGroundStationFolder}${version.toString()}")){
      await manager.sftp.remove("${Database.remoteGroundStationFolder}${version.toString()}/$name");
    }
    await manager.sftp.rmdir("${Database.remoteGroundStationFolder}${version.toString()}");

    Database.groundStationVersions.remove(version);
    Database.groundStationDescriptors.removeWhere((e) => e.version == version);
    return true;
  }

  static Future<bool> remote(final Version version) async {
    for(final SftpName name in await manager.sftp.listdir("${Database.remoteRemoteFolder}${version.toString()}")){
      await manager.sftp.remove("${Database.remoteRemoteFolder}${version.toString()}/$name");
    }
    await manager.sftp.rmdir("${Database.remoteRemoteFolder}${version.toString()}");

    Database.remoteVersions.remove(version);
    Database.remoteDescriptors.removeWhere((e) => e.version == version);
    return true;
  }

  static Future<bool> netcode(final Version version) async {
    for(final SftpName name in await manager.sftp.listdir("${Database.remoteNetCodeFolder}${version.toString()}")){
      await manager.sftp.remove("${Database.remoteNetCodeFolder}${version.toString()}/$name");
    }
    await manager.sftp.rmdir("${Database.remoteNetCodeFolder}${version.toString()}");

    Database.netCodeVersions.remove(version);
    Database.netCodeDescriptors.removeWhere((e) => e.version == version);
    return true;
  }

  static Future<bool> dbc(final Version version) async {
    for(final SftpName name in await manager.sftp.listdir("${Database.remoteDbcFolder}${version.toString()}")){
      await manager.sftp.remove("${Database.remoteDbcFolder}${version.toString()}/$name");
    }
    await manager.sftp.rmdir("${Database.remoteDbcFolder}${version.toString()}");

    Database.dbcVersions.remove(version);
    Database.dbcDescriptors.removeWhere((e) => e.version == version);
    return true;
  }
}

abstract class ReferenceChecker{
  static bool groundStation(final Version version, final StringRef ref){
    // not referenced by anything
    return false;
  }

  static bool remote(final Version version, final StringRef ref){
    // not referenced by anything
    return false;
  }

  static bool netcode(final Version version, final StringRef ref){
    return Database.groundStationDescriptors.any((e) => e.requiredNetCode == version) ||
    Database.remoteDescriptors.any((e) => e.requiredNetCode == version);
  }

  static bool dbc(final Version version, final StringRef ref){
    return Database.groundStationDescriptors.any((e) => e.requiredDBC == version);
  }
}


class DeleteDialog extends StatefulWidget {
  const DeleteDialog({super.key, required this.version, required this.deleteHandler, required this.checkIfExists, required this.checkIfIsRequired});

  final Version version;
  final Future<bool> Function(Version) deleteHandler;
  final bool Function(Version) checkIfExists;
  final bool Function(Version, StringRef) checkIfIsRequired;

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  String statusMsg = "";

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text("Are you sure you want to delete version ${widget.version.toString()} of this module", style: ThemeManager.textStyle,),),
        Row(
          children: [
            Text(statusMsg, style: ThemeManager.textStyle,),
            TextButton(
              onPressed: () async {
                if(!widget.checkIfExists(widget.version)){
                  statusMsg = "Idk how this happened but this version doesnt exist";
                  _update();
                  return;
                }

                final StringRef stringRef = StringRef(s: "");
                if(!widget.checkIfIsRequired(widget.version, stringRef)){
                  statusMsg = "This module version is required by ${stringRef.s}";
                  _update();
                  return;
                }
                
                final bool success = await widget.deleteHandler(widget.version);

                if(success){
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
                else{
                  statusMsg = "Delete failed failed";
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