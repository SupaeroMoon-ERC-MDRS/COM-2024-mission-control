import 'dart:io';

import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/notifications/notification_logic.dart' as noti;

abstract class Launcher {

  static Future<ProcessResult>? gsHandle;

  static bool gs(){
    if(Platform.isWindows){
      throw Exception("TODO");
    }
    else if(Platform.isLinux){
      final String execPath = "${FileSystem.getCurrentDirectory}Local/ground_station/bundle/supaeromoon_ground_station";
      if(!File(execPath).existsSync()){
        logging.error("GS not installed");
        noti.NotificationController.add(noti.Notification.decaying(LogEntry.error("Ground station is not installed"), 2000));
        return false;
      }

      gsHandle = Process.run(execPath, []);
      return true;
    }
    else{
      throw Exception("Unsupported platform");
    }
  }

  static bool remote(){
    throw Exception("TODO");
  }
}