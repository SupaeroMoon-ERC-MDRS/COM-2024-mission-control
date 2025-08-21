import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supaeromoon_mission_control/data_misc/session.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';
import 'package:xterm/xterm.dart';

final TerminalController _controller = TerminalController();

void _onKeyEvent(final KeyEvent event){
  if(event.character != null){
    manager.terminal.write(event.character!);
    manager.buffer = "${manager.buffer}${event.character!}";
  }
  else if(event.logicalKey == LogicalKeyboardKey.enter){
    manager.terminal.setCursor(manager.lastReadCursor.x, manager.lastReadCursor.y);
    manager.terminal.buffer.eraseDisplayFromCursor();

    manager.session.write(utf8.encode("${manager.buffer}\n"));
    manager.buffer = "";
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
    if(manager.terminal.buffer.cursorX <= manager.minCursorX && !manager.terminal.buffer.lines[manager.terminal.buffer.absoluteCursorY].isWrapped){
      return;
    }

    if(manager.terminal.buffer.lines[manager.terminal.buffer.absoluteCursorY].isWrapped && manager.terminal.buffer.cursorX == 0){
      manager.terminal.moveCursorY(-1);
      manager.terminal.moveCursorX(manager.terminal.viewWidth);
    }
    else{
      manager.terminal.moveCursorX(-1);
    }

    manager.terminal.eraseChars(1);
    manager.buffer = manager.buffer.substring(0, manager.buffer.length - 1);
    manager.terminal.notifyListeners();
  }
  /*else if(event.logicalKey == LogicalKeyboardKey.delete){ // TO be figured out later once arrows are implemented
    if(mainScreenTerminal.buffer.cursorX <= minCursorX && !mainScreenTerminal.buffer.lines[mainScreenTerminal.buffer.absoluteCursorY].isWrapped){
      return;
    }

    mainScreenTerminal.eraseChars(1);
    mainScreenTerminal.notifyListeners();
  }*/
}

class MainScreenTerminal extends StatefulWidget {
  const MainScreenTerminal({super.key});

  @override
  State<MainScreenTerminal> createState() => _MainScreenTerminalState();
}

class _MainScreenTerminalState extends State<MainScreenTerminal> {
  @override
  Widget build(BuildContext context) {
    if(!manager.isConnected){
      return SessionForm(
        onFinalized: () async {
          await terminalSetup();
          setState(() {});
        }
      );
    }
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKeyEvent,
      child: TerminalView(
        manager.terminal,
        controller: _controller,
        onSecondaryTapDown: (details, offset) async {
          if(_controller.selection != null) {
            final String text = manager.terminal.buffer.getText(_controller.selection);
            _controller.clearSelection();
            await Clipboard.setData(ClipboardData(text: text));
          } 
          else{
            final String? text = (await Clipboard.getData('text/plain'))?.text;
            if (text != null) {
              manager.terminal.write(text);
              manager.buffer = "${manager.buffer}$text";
              manager.terminal.notifyListeners();
            }
          }
        },
      )
    );
  }
}

class SessionForm extends StatefulWidget {
  const SessionForm({super.key, required this.onFinalized});

  final void Function() onFinalized;

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final TextEditingController _ip = TextEditingController();
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Text("Connection was not possible, set these variables:", style: ThemeManager.subTitleStyle,),
        SessionFormElement(name: "IP address", controller: _ip, get: () => Session.ip),
        SessionFormElement(name: "Username", controller: _user, get: () => Session.user),
        SessionFormElement(name: "Password", controller: _pwd, get: () => Session.pwd),
        TextButton(
          onPressed: (){
            Session.ip = _ip.text;
            Session.user = _user.text;
            Session.pwd = _pwd.text;
            _ip.clear();
            _user.clear();
            _pwd.clear();
            widget.onFinalized();
          },
          child: Text("Done", style: ThemeManager.textStyle,)
        ),
        const Spacer(),
      ],
    );
  }
}

class SessionFormElement extends StatelessWidget {
  const SessionFormElement({super.key, required this.name, required this.controller, required this.get});

  final String name;
  final TextEditingController controller;
  final String Function() get;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Text(name, style: ThemeManager.textStyle,),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: get(),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}