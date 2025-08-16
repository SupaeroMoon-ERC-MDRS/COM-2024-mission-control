import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/io/localization.dart';
import 'package:window_manager/window_manager.dart';

abstract class LifeCycle{
  static Future<void> preInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await FileSystem.getCurrentDirectory;
    logging.start();
    Loc.load();
    Loc.setLanguage("en-EN");
  }

  static void postInit(WindowListener root){
    appWindow.maximizeOrRestore();
    windowManager.addListener(root);
    windowManager.setPreventClose(true);
  }

  static Future<void> shutdown() async {
    await logging.stop();
    exit(0);
  }
}