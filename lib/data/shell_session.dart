import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';

abstract class SingleCommandShell{
  static String get sh => Platform.isWindows ? "cmd.exe" : Platform.isLinux ? "bash" : throw Exception("Unsupported platform");

  static List<int> get termination => Platform.isWindows ? throw Exception("TODO") : Platform.isLinux ? [36,32] : throw Exception("Unsupported platform");

  static bool _isGoodTermination(final Uint8List bytes, final List<int> term){
    for(int i = 0; i < term.length; i++){
      if(bytes[bytes.length - term.length + i] != term[i]){
        return false;
      }
    }
    return true;
  }

  static Future<bool> execute(final String cmd) async {
    final Pty pty = Pty.start(sh);
    Uint8List? _;
    bool sent = false;
    final List<int> term = termination;
    await for(final Uint8List bytes in pty.output){
      final bool wait = _ == null;
      if(_ == null && _isGoodTermination(bytes, term)){
        _ = bytes;
      }
      if(!sent && _ != null){
        pty.write(utf8.encode(cmd));
        sent = true;
      }
      if(wait){
        continue;
      }
      if(_isGoodTermination(bytes, term)){
        break;
      }
    }
    pty.kill();
    return true;
  }
}