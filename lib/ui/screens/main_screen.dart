import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:logging_utils/logging_utils.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/io/localization.dart';
import 'package:supaeromoon_mission_control/lifecycle.dart';
import 'package:supaeromoon_mission_control/notifications/notification_logic.dart' as noti;
import 'package:supaeromoon_mission_control/notifications/notification_widgets.dart';
import 'package:supaeromoon_mission_control/ui/components/main_screen_terminal.dart';
import 'package:supaeromoon_mission_control/ui/components/update_controls.dart';
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
          /*IconButton(
            onPressed: (){
              ThemeManager.changeStyle(ThemeManager.activeStyle == "DARK" ? "BRIGHT" : "DARK");
            },
            iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
            padding: EdgeInsets.zero,
            splashColor: Colors.grey,
            icon: Icon(ThemeManager.activeStyle == "DARK" ? Icons.dark_mode : Icons.light_mode)
          ),*/
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
    return const Row(
      children: [
        Expanded(
          child: MainScreenTerminal()
        ),
        MainScreenSideMenu()
      ],
    );
  }
}

class MainScreenSideMenu extends StatefulWidget {
  const MainScreenSideMenu({super.key});

  @override
  State<MainScreenSideMenu> createState() => _MainScreenSideMenuState();
}

class _MainScreenSideMenuState extends State<MainScreenSideMenu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  if(await Database.isLocked()){
                    noti.NotificationController.add(noti.Notification.persistent(LogEntry.error("Someone is already editing the database")));
                    return;
                  }
                  await Database.lock();
                  // ignore: use_build_context_synchronously
                  Navigator.pushNamed(context, '/dev');
                },
                icon: const Icon(Icons.construction),
                splashRadius: 20,
              ),
              IconButton(
                onPressed: () async {
                  if(await Database.isLocked()){
                    noti.NotificationController.add(noti.Notification.persistent(LogEntry.error("Someone is already editing the database")));
                    return;
                  }
                  
                  noti.NotificationController.add(noti.Notification.decaying(LogEntry.error("Fetch started"), 2000));
                  await Database.discover();
                  noti.NotificationController.add(noti.Notification.decaying(LogEntry.error("Fetch finished"), 2000));
                  setState(() {});
                },
                icon: const Icon(Icons.update)
              )
              // TODO go to task screen
            ],
          ),
          UpdateControls(
            title: "Ground Station",
            getCurrent: () => Database.localGroundStation,
            getOptions: () => Database.groundStationVersions,
            onChanged: (final Version v) async {
              if(v != Database.localGroundStation){
                if(await DownloadHandler.groundStation(v)){
                  setState(() {});
                }
              }
            }
          ),
          UpdateControls(
            title: "Remote Control",
            getCurrent: () => Database.localRemote,
            getOptions: () => Database.remoteVersions,
            onChanged: (final Version v) async {
              if(v != Database.localRemote){
                if(await DownloadHandler.remote(v)){
                  setState(() {});
                }
              }
            }
          ),
          UpdateControls(
            title: "Netcode",
            getCurrent: () => Database.localNetCode,
            getOptions: () => Database.netCodeVersions,
            onChanged: (final Version v) async {
              if(v != Database.localNetCode){
                if(await DownloadHandler.netcode(v)){
                  setState(() {});
                }
              }
            }
          ),
          UpdateControls(
            title: "DBC",
            getCurrent: () => Database.localdbc,
            getOptions: () => Database.dbcVersions,
            onChanged: (final Version v) async {
              if(v != Database.localdbc){
                if(await DownloadHandler.dbc(v)){
                  setState(() {});
                }
              }
            }
          )
        ],
      )
    );
  }
}