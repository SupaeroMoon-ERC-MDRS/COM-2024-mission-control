import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/notifications/notification_widgets.dart';
import 'package:supaeromoon_mission_control/ui/screens/main_screen.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

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
                DeveloperContent(),
                NotificationOverlay()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperContent extends StatelessWidget {
  const DeveloperContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

      ],
    );
  }
}

class ComponentDeveloperView extends StatefulWidget {
  const ComponentDeveloperView({super.key});

  @override
  State<ComponentDeveloperView> createState() => _ComponentDeveloperViewState();
}

class _ComponentDeveloperViewState extends State<ComponentDeveloperView> {
  @override
  Widget build(BuildContext context) {
    // Listview of available versions
    // each with delete, update/reupload, updateattrs iconbuttons

    // then below it an upload new version button
    return Container();
  }
}