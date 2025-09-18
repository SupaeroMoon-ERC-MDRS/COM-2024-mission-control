import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/data_misc/session.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/io/localization.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';
import 'package:window_manager/window_manager.dart';

abstract class LifeCycle{
  static Future<void> preInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    FileSystem.getCurrentDirectory;
    logging.start();
    Session.load();
    Loc.load();
    Loc.setLanguage("en-EN");
    if(!await terminalSetup()){
      logging.critical("Failed to set up terminal");
    }
    FileSystem.trySaveMapToLocalSync(FileSystem.tmpDir, "tmp", {});
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, "tmp");
  }

  static void postInit(WindowListener root){
    windowManager.addListener(root);
    windowManager.setPreventClose(true);
    windowManager.setResizable(false);
  }

  static Future<void> shutdown() async {
    Database.unlock();
    Session.save();
    await logging.stop();
    exit(0);
  }
}