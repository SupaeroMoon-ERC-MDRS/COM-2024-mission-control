import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data/configuration_manager.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/data/ftp.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';
import 'package:supaeromoon_mission_control/notifications/notification_logic.dart' as noti;
import 'package:supaeromoon_mission_control/ui/theme.dart';

abstract class DownloadHandler{
  static Future<bool> groundStation(final Version v) async {
    final GroundStationDescriptor desc = Database.groundStationDescriptors.firstWhere((e) => e.version == v);
    if(desc.requiredDBC > (Database.localdbc ?? Version.fromString("0.0.0"))){
      noti.NotificationController.add(noti.Notification.persistent(LogEntry.error("Ground station version ${v.toString()} requires dbc version at least ${desc.requiredDBC.toString()} which is not installed")));
      return false;
    }
    if(desc.requiredNetCode > (Database.localNetCode ?? Version.fromString("0.0.0"))){
      noti.NotificationController.add(noti.Notification.persistent(LogEntry.error("Ground station version ${v.toString()} requires netcode version at least ${desc.requiredNetCode.toString()} which is not installed")));
      return false;
    }

    final List<FileSystemEntity> elems = await FileSystem.tryListElementsInLocalAsync(DPath.groundStationFolder);
    for(final FileSystemEntity e in elems){
      await e.delete(recursive: true);
    }

    await FTP.downloadZip(DPath.groundStationFolder, "${Database.remoteGroundStationFolder}${v.toString()}/ground_station_${v.toString()}.tar");
    await FTP.download(DPath.groundStationFolder, DPath.attributesFile, "${Database.remoteGroundStationFolder}${v.toString()}/${DPath.attributesFile}");

    Database.localGroundStation = v;
    return true;
  }

 static Future<bool> remote(final Version v) async {
    final List<FileSystemEntity> elems = await FileSystem.tryListElementsInLocalAsync(DPath.remoteFolder);
    for(final FileSystemEntity e in elems){
      await e.delete(recursive: true);
    }

    final List<SftpName> files = await manager.sftp.listdir("${Database.remoteRemoteFolder}${v.toString()}/");
    files.removeWhere((e) => ["..", "."].contains(e.filename));
    for(final String name in files.map((e) => e.filename).toSet()){
      await FTP.download(DPath.remoteFolder, name, "${Database.remoteRemoteFolder}${v.toString()}/$name");
    }

    Database.localRemote = v;
    return true;
  }

  static Future<bool> netcode(final Version v) async {
    final Version gsReqNetcode = GroundStationDescriptor.fromMap(await FileSystem.tryLoadMapFromLocalAsync(DPath.groundStationFolder, DPath.attributesFile)).requiredNetCode;
    if(gsReqNetcode > v){
      noti.NotificationController.add(noti.Notification.persistent(LogEntry.error("Currently installed Ground station version ${Database.localGroundStation.toString()} requires netcode version at least ${gsReqNetcode.toString()}")));
      return false;
    }

    final List<FileSystemEntity> elems = await FileSystem.tryListElementsInLocalAsync(DPath.netCodeFolder);
    for(final FileSystemEntity e in elems){
      await e.delete(recursive: true);
    }

    final List<SftpName> files = await manager.sftp.listdir("${Database.remoteNetCodeFolder}${v.toString()}/");
    files.removeWhere((e) => ["..", "."].contains(e.filename));
    for(final String name in files.map((e) => e.filename).toSet()){
      await FTP.download(DPath.netCodeFolder, name, "${Database.remoteNetCodeFolder}${v.toString()}/$name");
    }

    Database.localNetCode = v;
    return true;
  }

  static Future<bool> dbc(final Version v) async {
    final Version gsReqDBC = GroundStationDescriptor.fromMap(await FileSystem.tryLoadMapFromLocalAsync(DPath.groundStationFolder, DPath.attributesFile)).requiredDBC;
    if(gsReqDBC > v){
      noti.NotificationController.add(noti.Notification.persistent(LogEntry.error("Currently installed Ground station version ${Database.localGroundStation.toString()} requires dbc version at least ${gsReqDBC.toString()}")));
      return false;
    }

    final List<FileSystemEntity> elems = await FileSystem.tryListElementsInLocalAsync(DPath.dbcFolder);
    for(final FileSystemEntity e in elems){
      await e.delete(recursive: true);
    }

    final List<SftpName> files = await manager.sftp.listdir("${Database.remoteDbcFolder}${v.toString()}/");
    files.removeWhere((e) => ["..", "."].contains(e.filename));
    for(final String name in files.map((e) => e.filename).toSet()){
      await FTP.download(DPath.dbcFolder, name, "${Database.remoteDbcFolder}${v.toString()}/$name");
    }

    Database.localdbc = v;
    return true;
  }
}

class UpdateControls extends StatefulWidget {
  const UpdateControls({super.key, required this.title, required this.getCurrent, required this.getOptions, required this.onChanged});

  final String title;
  final Version? Function() getCurrent;
  final List<Version?> Function() getOptions;
  final Future<void> Function(Version) onChanged;

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
          onChanged: (final Version? v) async {
            if(v == null){
              return;
            }
            await widget.onChanged(v);
            ConfigurationManager.reconfig();
          }
        )
      ],
    );
  }
}