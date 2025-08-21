import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/data_misc/session.dart';
import 'package:xterm/xterm.dart';

final TerminalManager manager = TerminalManager();

class TerminalManager{
  final Terminal terminal = Terminal(inputHandler: defaultInputHandler);
  late final SSHClient pty;
  late final SSHSession session;
  late final int minCursorX;
  CellOffset lastReadCursor = const CellOffset(0, 0);
  String buffer = "";
  late final SftpClient sftp;
  bool isConnected = false;

  Future<void> connect() async {
    pty = SSHClient(
      await SSHSocket.connect(Session.ip, 22, timeout: const Duration(seconds: 3)),
      username: Session.user,
      onPasswordRequest: () => Session.pwd,
    );
    isConnected = true;
  }

  Future<void> initialize() async {
    sftp = await pty.sftp();

    session = await pty.shell(
      pty: SSHPtyConfig(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      ),
    );

    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      session.resizeTerminal(width, height, pixelWidth, pixelHeight);
    };

    session.stdout
      .cast<List<int>>()
      .transform(const Utf8Decoder())
      .listen((final String str){
        final CellOffset currentCursor = CellOffset(terminal.buffer.cursorX, terminal.buffer.cursorY);
        if(currentCursor != lastReadCursor){
          terminal.setCursor(lastReadCursor.x, lastReadCursor.y);
          terminal.buffer.eraseDisplayFromCursor();
          buffer = "";
        }

        terminal.write(str);
        lastReadCursor = CellOffset(terminal.buffer.cursorX, terminal.buffer.cursorY);
      });

    session.stderr
      .cast<List<int>>()
      .transform(const Utf8Decoder())
      .listen(terminal.write);

    int attempts = 100;
    while(attempts-- > 0){
      await Future.delayed(const Duration(milliseconds: 100));
      if(terminal.buffer.cursorX != 0){
        minCursorX = terminal.buffer.cursorX;
        return;
      }
    }

    throw Exception("Could not establish minCursorX");
  }
}

Future<bool> terminalSetup() async {
  try{
    await manager.connect();
    await manager.initialize();
  }
  catch(ex){
    logging.critical(ex.toString());
    return false;
  }
  return true;
}