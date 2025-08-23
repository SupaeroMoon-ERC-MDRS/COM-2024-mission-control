import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/notifications/notification_widgets.dart';
import 'package:supaeromoon_mission_control/ui/dialog/dialog_base.dart';
import 'package:supaeromoon_mission_control/ui/dialog/update_dialog.dart';
import 'package:supaeromoon_mission_control/ui/screens/main_screen.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ComponentDeveloperView(
          getOptions: () => Database.groundStationVersions,
          reuploadVersion: (final Version version) {/* TODO */},
          updateAttrsVersion: (final Version version) {/* TODO */},
          deleteVersion: (final Version version) {/* TODO */},
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new Ground Station version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(hasRequiredDBC: true, hasRequiredNetCode: true),
                    updateHandler: UpdateHandler.groundStation,
                  ),
                );
              }
            );
          },
        ),
        ComponentDeveloperView(
          getOptions: () => Database.remoteVersions,
          reuploadVersion: (final Version version) {/* TODO */},
          updateAttrsVersion: (final Version version) {/* TODO */},
          deleteVersion: (final Version version) {/* TODO */},
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new Remote Control version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(hasRequiredNetCode: true),
                    updateHandler: UpdateHandler.remote,
                  ),
                );
              }
            );
          },
        ),
        ComponentDeveloperView(
          getOptions: () => Database.netCodeVersions,
          reuploadVersion: (final Version version) {/* TODO */},
          updateAttrsVersion: (final Version version) {/* TODO */},
          deleteVersion: (final Version version) {/* TODO */},
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new netcode version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(),
                    updateHandler: UpdateHandler.netcode,
                  ),
                );
              }
            );
          },
        ),
        ComponentDeveloperView(
          getOptions: () => Database.dbcVersions,
          reuploadVersion: (final Version version) {/* TODO */},
          updateAttrsVersion: (final Version version) {/* TODO */},
          deleteVersion: (final Version version) {/* TODO */},
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new dbc version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(),
                    updateHandler: UpdateHandler.dbc,
                  ),
                );
              }
            );
          },
        )
      ],
    );
  }
}

class ComponentDeveloperView extends StatefulWidget {
  const ComponentDeveloperView({super.key, required this.getOptions, required this.reuploadVersion, required this.updateAttrsVersion, required this.deleteVersion, required this.addNewVersion});

  final List<Version> Function() getOptions;
  final void Function(Version) reuploadVersion;
  final void Function(Version) updateAttrsVersion;
  final void Function(Version) deleteVersion;
  final void Function() addNewVersion;

  @override
  State<ComponentDeveloperView> createState() => _ComponentDeveloperViewState();
}

class _ComponentDeveloperViewState extends State<ComponentDeveloperView> {
  final List<Version> options = [];
  
  @override
  void initState() {
    options.addAll(widget.getOptions());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 350,
          width: 250,
          child: Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemExtent: 50,
              itemBuilder: (final BuildContext context, final int index){
                return Row(
                  children: [
                    Text(options[index].toString(), style: ThemeManager.textStyle,),
                    const Spacer(),
                    IconButton(
                      onPressed: (){
                        widget.reuploadVersion(options[index]);
                      },
                      icon: const Icon(Icons.update),
                      splashRadius: 20,
                    ),
                    IconButton(
                      onPressed: (){
                        widget.updateAttrsVersion(options[index]);
                      },
                      icon: const Icon(Icons.receipt),
                      splashRadius: 20,
                    ),
                    IconButton(
                      onPressed: (){
                        widget.deleteVersion(options[index]);
                        options.remove(options[index]);
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete),
                      splashRadius: 20,
                    ),
                  ],
                );
              }
            ),
          ),
        ),
        TextButton(
          onPressed: (){
            widget.addNewVersion();
            options.clear();
            options.addAll(widget.getOptions());
            setState(() {});
          },
          child: Text("Add new", style: ThemeManager.subTitleStyle,)
        )
      ],
    );
  }
}