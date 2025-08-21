import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';

const String pathPrefix = "Documents/version_control";
const String dbcFolder = "dbc";
const String netCodeFolder = "net";
const String remoteFolder = "remote";
const String groundStationFolder = "ground_station";

abstract class Database{
  static final List<Version> dbcVersions = []; // more recent versions at low index
  static final List<Version> netCodeVersions = [];
  static final List<Version> remoteVersions = [];
  static final List<Version> groundStationVersions = [];

  static Version? localdbc;
  static Version? localNetCode;
  static Version? localRemote;
  static Version? localGroundStation;

  static Future<bool> discover() async {
    final Map localdbcData = await FileSystem.tryLoadMapFromLocalAsync("$dbcFolder/", ".DESC");
    final Map localNetCodeData = await FileSystem.tryLoadMapFromLocalAsync("$netCodeFolder/", ".DESC");
    final Map localRemoteData = await FileSystem.tryLoadMapFromLocalAsync("$remoteFolder/", ".DESC");
    final Map localGroundStationData = await FileSystem.tryLoadMapFromLocalAsync("$groundStationFolder/", ".DESC");

    try{ localdbc = DBCDescriptor.fromMap(localdbcData).version; }
    catch(_){ logging.error("No dbc installed locally"); }

    try{ localNetCode = NetCodeDescriptor.fromMap(localNetCodeData).version; }
    catch(_){ logging.error("No netcode installed locally"); }

    try{ localRemote = RemoteControlDescriptor.fromMap(localRemoteData).version; }
    catch(_){ logging.error("No remote control installed locally"); }

    try{ localGroundStation = GroundStationDescriptor.fromMap(localGroundStationData).version; }
    catch(_){ logging.error("No ground station installed locally"); }

    try{
      final String platform = Platform.isWindows ? "win" : Platform.isLinux ? "linux" : throw Exception("Unsupported platform");
      final List<SftpName> dbcOptions = await manager.sftp.listdir("$pathPrefix/$platform/$dbcFolder");
      final List<SftpName> netCodeOptions = await manager.sftp.listdir("$pathPrefix/$platform/$netCodeFolder");
      final List<SftpName> remoteOptions = await manager.sftp.listdir("$pathPrefix/$platform/$remoteFolder");
      final List<SftpName> groundStationOptions = await manager.sftp.listdir("$pathPrefix/$platform/$groundStationFolder");

      dbcOptions.removeWhere((e) => ["..", "."].contains(e.filename));
      netCodeOptions.removeWhere((e) => ["..", "."].contains(e.filename));
      remoteOptions.removeWhere((e) => ["..", "."].contains(e.filename));
      groundStationOptions.removeWhere((e) => ["..", "."].contains(e.filename));

      dbcVersions.addAll(dbcOptions.map((e) => Version.fromString(e.filename)));
      netCodeVersions.addAll(netCodeOptions.map((e) => Version.fromString(e.filename)));
      remoteVersions.addAll(remoteOptions.map((e) => Version.fromString(e.filename)));
      groundStationVersions.addAll(groundStationOptions.map((e) => Version.fromString(e.filename)));

      dbcVersions.sort(Version.compareTo);
      netCodeVersions.sort(Version.compareTo);
      remoteVersions.sort(Version.compareTo);
      groundStationVersions.sort(Version.compareTo);
      return true;
    }
    catch(ex){
      logging.error(ex.toString());
      return false;
    }
  }
}