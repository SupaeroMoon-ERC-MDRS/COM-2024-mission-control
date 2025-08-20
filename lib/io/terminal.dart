import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/data_misc/session.dart';
import 'package:xterm/xterm.dart';

final Terminal mainScreenTerminal = Terminal(inputHandler: defaultInputHandler);
late final SSHClient mainScreenPty;
late final SSHSession mainScreenSession;
late final int minCursorX;
CellOffset lastReadCursor = const CellOffset(0, 0);
String mainScreenTerminalBuffer = "";

late final SftpClient backgroundFTP;

Future<void> _setupMain(final String sh) async {
  mainScreenPty = SSHClient(
    await SSHSocket.connect(Session.ip, 22, timeout: const Duration(seconds: 3)),
    username: Session.user,
    onPasswordRequest: () => Session.pwd,
  );

  mainScreenSession = await mainScreenPty.shell(
    pty: SSHPtyConfig(
      width: mainScreenTerminal.viewWidth,
      height: mainScreenTerminal.viewHeight,
    ),
  );

  mainScreenTerminal.onResize = (width, height, pixelWidth, pixelHeight) {
    mainScreenSession.resizeTerminal(width, height, pixelWidth, pixelHeight);
  };

  mainScreenSession.stdout
      .cast<List<int>>()
      .transform(const Utf8Decoder())
      .listen((final String str){
        final CellOffset currentCursor = CellOffset(mainScreenTerminal.buffer.cursorX, mainScreenTerminal.buffer.cursorY);
        if(currentCursor != lastReadCursor){
          mainScreenTerminal.setCursor(lastReadCursor.x, lastReadCursor.y);
          mainScreenTerminal.buffer.eraseDisplayFromCursor();
          mainScreenTerminalBuffer = "";
        }

        mainScreenTerminal.write(str);
        lastReadCursor = CellOffset(mainScreenTerminal.buffer.cursorX, mainScreenTerminal.buffer.cursorY);
      });

  mainScreenSession.stderr
      .cast<List<int>>()
      .transform(const Utf8Decoder())
      .listen(mainScreenTerminal.write);

  int attempts = 100;
  while(attempts-- > 0){
    await Future.delayed(const Duration(milliseconds: 100));
    if(mainScreenTerminal.buffer.cursorX != 0){
      minCursorX = mainScreenTerminal.buffer.cursorX;
      return;
    }
  }

  throw Exception("Could not establish minCursorX");
}

/*void _setupBackground(final String sh){
  backgroundPty = Pty.start(
    sh,
    columns: mainScreenTerminal.viewWidth,
    rows: mainScreenTerminal.viewHeight,
  );
}*/

Future<bool> terminalSetup() async {
  late final String sh;

  if(Platform.isLinux){
    sh = Platform.environment['SHELL'] ?? 'bash';
  }
  else if(Platform.isWindows){
    sh = 'cmd.exe';
  }
  else{
    return false;
  }

  try{
  await _setupMain(sh);
  //_setupBackground(sh);
  }
  catch(ex){
    logging.critical(ex.toString());
    return false;
  }
  return true;
}