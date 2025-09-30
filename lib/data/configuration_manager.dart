import 'dart:io';

import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';

abstract class ConfigurationManager{
  static bool reconfig(){
    final String path = Platform.isWindows ? "${DPath.groundStationFolder}Release/Local/" : Platform.isLinux ? "${DPath.groundStationFolder}bundle/Local/" : throw Exception("Unsupported platform");
    final Map data = FileSystem.tryLoadMapFromLocalSync(path, "SESSION");

    final String dbcPath = ""; // TODO
    final String netCodePath = ""; // TODO
    final String remotePath = ""; // TODO

    if(data.containsKey("dbcPaths") && data["dbcPaths"] is List){
      if(!data["dbcPaths"].cast<String>().contains(dbcPath)){
        data["dbcPaths"].add(dbcPath);
      }
    }
    else{
      data["dbcPaths"] = [dbcPath];
    }

    data["netCodePath"] = netCodePath;
    data["remotePath"] = remotePath;

    FileSystem.trySaveMapToLocalSync(path, "SESSION", data);
    return true;
  }
}