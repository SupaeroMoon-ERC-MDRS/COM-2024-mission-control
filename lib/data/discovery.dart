import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/io/serdes.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';

abstract class DPath{
  static const String pathPrefix = "Documents/version_control/";
  static const String dbcFolder = "dbc/";
  static const String netCodeFolder = "net/";
  static const String remoteFolder = "remote/";
  static const String groundStationFolder = "ground_station/";
  static const String lockFile = ".lock";
  static const String attributesFile = ".attrs";
}

abstract class Database{
  static final List<Version> dbcVersions = []; // more recent versions at low index
  static final List<Version> netCodeVersions = [];
  static final List<Version> remoteVersions = [];
  static final List<Version> groundStationVersions = [];  
  
  static final List<DBCDescriptor> dbcDescriptors = []; // more recent versions at low index
  static final List<NetCodeDescriptor> netCodeDescriptors = [];
  static final List<RemoteControlDescriptor> remoteDescriptors = [];
  static final List<GroundStationDescriptor> groundStationDescriptors = [];

  static String get remoteDbcFolder {
    final String platform = Platform.isWindows ? "win/" : Platform.isLinux ? "linux/" : throw Exception("Unsupported platform");
    return "${DPath.pathPrefix}$platform${DPath.dbcFolder}";
  }

  static String get remoteNetCodeFolder {
    final String platform = Platform.isWindows ? "win/" : Platform.isLinux ? "linux/" : throw Exception("Unsupported platform");
    return "${DPath.pathPrefix}$platform${DPath.netCodeFolder}";
  }

  static String get remoteRemoteFolder {
    final String platform = Platform.isWindows ? "win/" : Platform.isLinux ? "linux/" : throw Exception("Unsupported platform");
    return "${DPath.pathPrefix}$platform${DPath.remoteFolder}";
  }

  static String get remoteGroundStationFolder {
    final String platform = Platform.isWindows ? "win/" : Platform.isLinux ? "linux/" : throw Exception("Unsupported platform");
    return "${DPath.pathPrefix}$platform${DPath.groundStationFolder}";
  }

  static Version groundStationReqDBC(final Version v) => groundStationDescriptors[groundStationVersions.indexOf(v)].requiredDBC;
  static Version groundStationReqNetCode(final Version v) => groundStationDescriptors[groundStationVersions.indexOf(v)].requiredNetCode;

  static Version? localdbc;
  static Version? localNetCode;
  static Version? localRemote;
  static Version? localGroundStation;

  static Future<bool> isLocked() async {
    return (await manager.sftp.listdir(DPath.pathPrefix)).any((e) => e.filename == DPath.lockFile);
  }

  static Future<void> lock() async {
    await (await manager.sftp.open("${DPath.pathPrefix}/${DPath.lockFile}", mode: SftpFileOpenMode.create)).close();
  }

  static Future<void> unlock() async {
    try{ await manager.sftp.remove("${DPath.pathPrefix}/${DPath.lockFile}"); }
    catch(_){}
  }

  static Future<bool> discover() async {
    groundStationDescriptors.clear();
    remoteDescriptors.clear();
    netCodeDescriptors.clear();
    dbcDescriptors.clear();

    groundStationVersions.clear();
    remoteVersions.clear();
    netCodeVersions.clear();
    dbcVersions.clear();

    await fetchLocal();
    return await fetchRemote();
  }

  static Future<bool> fetchRemote() async {
    try{
      if(await isLocked()){
        return false;
      }

      final String platform = Platform.isWindows ? "win/" : Platform.isLinux ? "linux/" : throw Exception("Unsupported platform");
      final List<SftpName> dbcOptions = await manager.sftp.listdir("${DPath.pathPrefix}$platform${DPath.dbcFolder}");
      final List<SftpName> netCodeOptions = await manager.sftp.listdir("${DPath.pathPrefix}$platform${DPath.netCodeFolder}");
      final List<SftpName> remoteOptions = await manager.sftp.listdir("${DPath.pathPrefix}$platform${DPath.remoteFolder}");
      final List<SftpName> groundStationOptions = await manager.sftp.listdir("${DPath.pathPrefix}$platform${DPath.groundStationFolder}");

      dbcOptions.removeWhere((e) => ["..", "."].contains(e.filename));
      netCodeOptions.removeWhere((e) => ["..", "."].contains(e.filename));
      remoteOptions.removeWhere((e) => ["..", "."].contains(e.filename));
      groundStationOptions.removeWhere((e) => ["..", "."].contains(e.filename));

      for(final String v in dbcOptions.map((e) => e.filename)){
        final SftpFile f = await manager.sftp.open("${DPath.pathPrefix}$platform${DPath.dbcFolder}$v/${DPath.attributesFile}", mode: SftpFileOpenMode.read);
        dbcDescriptors.add(DBCDescriptor.fromMap(SerDes.jsonFromBytes(await f.readBytes()) as Map));
        f.close();
      }

      for(final String v in netCodeOptions.map((e) => e.filename)){
        final SftpFile f = await manager.sftp.open("${DPath.pathPrefix}$platform${DPath.netCodeFolder}$v/${DPath.attributesFile}", mode: SftpFileOpenMode.read);
        netCodeDescriptors.add(NetCodeDescriptor.fromMap(SerDes.jsonFromBytes(await f.readBytes()) as Map));
        f.close();
      }

      for(final String v in remoteOptions.map((e) => e.filename)){
        final SftpFile f = await manager.sftp.open("${DPath.pathPrefix}$platform${DPath.remoteFolder}$v/${DPath.attributesFile}", mode: SftpFileOpenMode.read);
        remoteDescriptors.add(RemoteControlDescriptor.fromMap(SerDes.jsonFromBytes(await f.readBytes()) as Map));
        f.close();
      }

      for(final String v in groundStationOptions.map((e) => e.filename)){
        final SftpFile f = await manager.sftp.open("${DPath.pathPrefix}$platform${DPath.groundStationFolder}$v/${DPath.attributesFile}", mode: SftpFileOpenMode.read);
        groundStationDescriptors.add(GroundStationDescriptor.fromMap(SerDes.jsonFromBytes(await f.readBytes()) as Map));
        f.close();
      }

      dbcDescriptors.sort((a, b) => Version.compareTo(a.version, b.version));
      netCodeDescriptors.sort((a, b) => Version.compareTo(a.version, b.version));
      remoteDescriptors.sort((a, b) => Version.compareTo(a.version, b.version));
      groundStationDescriptors.sort((a, b) => Version.compareTo(a.version, b.version));

      dbcVersions.addAll(dbcDescriptors.map((e) => e.version));
      netCodeVersions.addAll(netCodeDescriptors.map((e) => e.version));
      remoteVersions.addAll(remoteDescriptors.map((e) => e.version));
      groundStationVersions.addAll(groundStationDescriptors.map((e) => e.version));
      return true;
    }
    catch(ex){
      logging.error(ex.toString());
      return false;
    }
  }

  static Future<void> fetchLocal() async {
    final Map localdbcData = await FileSystem.tryLoadMapFromLocalAsync(DPath.dbcFolder, DPath.attributesFile);
    final Map localNetCodeData = await FileSystem.tryLoadMapFromLocalAsync(DPath.netCodeFolder, DPath.attributesFile);
    final Map localRemoteData = await FileSystem.tryLoadMapFromLocalAsync(DPath.remoteFolder, DPath.attributesFile);
    final Map localGroundStationData = await FileSystem.tryLoadMapFromLocalAsync(DPath.groundStationFolder, DPath.attributesFile);
    
    try{ localdbc = DBCDescriptor.fromMap(localdbcData).version; }
    catch(_){ logging.error("No dbc installed locally"); }
    
    try{ localNetCode = NetCodeDescriptor.fromMap(localNetCodeData).version; }
    catch(_){ logging.error("No netcode installed locally"); }
    
    try{ localRemote = RemoteControlDescriptor.fromMap(localRemoteData).version; }
    catch(_){ logging.error("No remote control installed locally"); }
    
    try{ localGroundStation = GroundStationDescriptor.fromMap(localGroundStationData).version; }
    catch(_){ logging.error("No ground station installed locally"); }
  }
}