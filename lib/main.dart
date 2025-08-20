import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/io/localization.dart';
import 'package:supaeromoon_mission_control/lifecycle.dart';
import 'package:supaeromoon_mission_control/ui/common.dart';
import 'package:supaeromoon_mission_control/ui/screens/main_screen.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() async {
  await LifeCycle.preInit();
  runApp(const App());

  doWhenWindowReady(() {
    const initialSize = Size(1200, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;

    appWindow.show();
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener {

  @override
  void initState() {
    ThemeManager.notifier.addListener(_update);
    LifeCycle.postInit(this);
    setState(() {});
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return MaterialApp(
      navigatorKey: mainWindowNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: Loc.get("mission_control_title"),
      theme: ThemeManager.getThemeData(context),
      routes: {
        "/": (context) => const MainScreen(),
        //"/settings" : ,
      },
      initialRoute: "/",
    );
  }

  @override
  void onWindowClose() async {
    await LifeCycle.shutdown();
  }
}
