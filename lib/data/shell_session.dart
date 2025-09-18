import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';

abstract class SingleCommandShell{
  static String get sh => Platform.isWindows ? "cmd.exe" : Platform.isLinux ? "bash" : throw Exception();

  static Future<bool> execute(final String cmd) async {
    final Pty pty = Pty.start(sh);
    Uint8List? _;
    bool sent = false;
    await for(final Uint8List bytes in pty.output){
      final bool wait = _ == null;
      if(_ == null && bytes.length > 10){ // TODO contains some character sequence like ": "
        _ = bytes;
      }
      if(!sent && _ != null){
        pty.write(utf8.encode(cmd));
        sent = true;
      }
      if(wait){
        continue;
      }
      if(utf8.decode(bytes).substring(bytes.length ~/ 2) == utf8.decode(_!).substring(bytes.length ~/ 2)){
        break;
      }
    }
    pty.kill();
    return true;
  }
}