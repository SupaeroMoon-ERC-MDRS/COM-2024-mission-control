import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';
import 'package:xterm/xterm.dart';

final TerminalController _controller = TerminalController();

class MainScreenTerminal extends StatefulWidget {
  const MainScreenTerminal({super.key});

  @override
  State<MainScreenTerminal> createState() => _MainScreenTerminalState();
}

class _MainScreenTerminalState extends State<MainScreenTerminal> {
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (final KeyEvent event){
        if(event.character != null){
          mainScreenTerminal.write(event.character!);
          mainScreenTerminalBuffer = "$mainScreenTerminalBuffer${event.character!}";
        }
        else if(event.logicalKey == LogicalKeyboardKey.enter){
          mainScreenTerminal.setCursor(lastReadCursor.x, lastReadCursor.y);
          mainScreenTerminal.buffer.eraseDisplayFromCursor();

          mainScreenSession.write(utf8.encode("$mainScreenTerminalBuffer\n"));
          mainScreenTerminalBuffer = "";
        }
        /*else if(event.logicalKey == LogicalKeyboardKey.arrowLeft){
          if(mainScreenTerminal.buffer.cursorX <= minCursorX){
            return;
          }
          mainScreenTerminal.moveCursorX(-1);
          mainScreenTerminal.notifyListeners();
        }
        else if(event.logicalKey == LogicalKeyboardKey.arrowRight){
          mainScreenTerminal.moveCursorX(1);
          mainScreenTerminal.notifyListeners();
        }*/
        else if(event.logicalKey == LogicalKeyboardKey.backspace){
          if(mainScreenTerminal.buffer.cursorX <= minCursorX && !mainScreenTerminal.buffer.lines[mainScreenTerminal.buffer.absoluteCursorY].isWrapped){
            return;
          }

          if(mainScreenTerminal.buffer.lines[mainScreenTerminal.buffer.absoluteCursorY].isWrapped && mainScreenTerminal.buffer.cursorX == 0){
            mainScreenTerminal.moveCursorY(-1);
            mainScreenTerminal.moveCursorX(mainScreenTerminal.viewWidth);
          }
          else{
            mainScreenTerminal.moveCursorX(-1);
          }

          mainScreenTerminal.eraseChars(1);
          mainScreenTerminalBuffer = mainScreenTerminalBuffer.substring(0, mainScreenTerminalBuffer.length - 1);
          mainScreenTerminal.notifyListeners();
        }

        /*else if(event.logicalKey == LogicalKeyboardKey.delete){ // TO be figured out later once arrows are implemented
          if(mainScreenTerminal.buffer.cursorX <= minCursorX && !mainScreenTerminal.buffer.lines[mainScreenTerminal.buffer.absoluteCursorY].isWrapped){
            return;
          }

          mainScreenTerminal.eraseChars(1);
          mainScreenTerminal.notifyListeners();
        }*/
      },
      child: TerminalView(
        mainScreenTerminal,
        controller: _controller,
        onSecondaryTapDown: (details, offset) async {
          final selection = _controller.selection;
          if (selection != null) {
            final text = mainScreenTerminal.buffer.getText(selection);
            _controller.clearSelection();
            await Clipboard.setData(ClipboardData(text: text));
          } else {
            final data = await Clipboard.getData('text/plain');
            final text = data?.text;
            if (text != null) {
              mainScreenTerminal.write(text);
              mainScreenTerminalBuffer = "$mainScreenTerminalBuffer$text";
              mainScreenTerminal.notifyListeners();
            }
          }
        },
      )
    );
  }
}