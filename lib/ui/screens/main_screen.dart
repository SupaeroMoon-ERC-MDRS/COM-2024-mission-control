import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/io/localization.dart';
import 'package:supaeromoon_mission_control/lifecycle.dart';
import 'package:supaeromoon_mission_control/notifications/notification_widgets.dart';
import 'package:supaeromoon_mission_control/ui/components/main_screen_terminal.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          TopMenu(),
          Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                MainScreenContent(),
                NotificationOverlay()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopMenu extends StatelessWidget {
  const TopMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: ThemeManager.globalStyle.secondaryColor,
      child: Row(
        children: [          
          Expanded(
            child: Container(
              color: ThemeManager.globalStyle.secondaryColor,
              child: MoveWindow(
                child: Row(
                  children: [
                    Text(Loc.get("mission_control_title"),
                      style: ThemeManager.subTitleStyle.copyWith(color: ThemeManager.globalStyle.primaryColor, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            )
          ),
          IconButton(
            onPressed: (){
              ThemeManager.changeStyle(ThemeManager.activeStyle == "DARK" ? "BRIGHT" : "DARK");
            },
            iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
            padding: EdgeInsets.zero,
            splashColor: Colors.grey,
            icon: Icon(ThemeManager.activeStyle == "DARK" ? Icons.dark_mode : Icons.light_mode)
          ),
          MinimizeWindowButton(colors: ThemeManager.windowButtonColors,),
          appWindow.isMaximized
            ? RestoreWindowButton(colors: ThemeManager.windowButtonColors,
                onPressed: appWindow.maximizeOrRestore,
              )
            : MaximizeWindowButton(colors: ThemeManager.windowButtonColors,
                onPressed: appWindow.maximizeOrRestore,
              ),
          CloseWindowButton(
            colors: ThemeManager.windowButtonColors..mouseOver = Colors.red,
            onPressed: () async {
              await LifeCycle.shutdown();
            },
          ),
        ],
      ),
    );
  }
}

class MainScreenContent extends StatelessWidget {
  const MainScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: MainScreenTerminal()
        ),
        SizedBox(
          width: 400,
          child: Container(
            color: Colors.red
          )
        ),
      ],
    );
  }
}