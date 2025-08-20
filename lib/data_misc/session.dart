import 'package:supaeromoon_mission_control/io/file_system.dart';

abstract class Session{
  static String ip = "";
  static String user = "";
  static String pwd = "";

  static void save(){
    FileSystem.trySaveMapToLocalSync(FileSystem.topDir, "SESSION", {
      "ip": ip,
      "user": user,
      "pwd": pwd,
    });
  }
  
  static void load(){
    Map data = FileSystem.tryLoadMapFromLocalSync(FileSystem.topDir, "SESSION");

    if(data.containsKey("ip") && data["ip"] is String){
      ip = data["ip"];
    }

    if(data.containsKey("user") && data["user"] is String){
      user = data["user"];
    }

    if(data.containsKey("pwd") && data["pwd"] is String){
      pwd = data["pwd"];
    }
  }
}