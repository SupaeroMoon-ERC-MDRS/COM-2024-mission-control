import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data/components.dart';
import 'package:supaeromoon_mission_control/data/discovery.dart';
import 'package:supaeromoon_mission_control/notifications/notification_widgets.dart';
import 'package:supaeromoon_mission_control/ui/dialog/delete_dialog.dart';
import 'package:supaeromoon_mission_control/ui/dialog/dialog_base.dart';
import 'package:supaeromoon_mission_control/ui/dialog/update_attrs_dialog.dart';
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
          title: "Ground Station",
          getOptions: () => Database.groundStationVersions,
          reuploadVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update Ground Station version ${version.toString()}",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(
                      hasRequiredDBC: true,
                      hasRequiredNetCode: true,
                      requiredDBC: Database.groundStationReqDBC(version),
                      requiredNetCode: Database.groundStationReqNetCode(version),
                      version: version
                    ),
                    updateHandler: UpdateHandler.groundStation,
                    checkIfExists: Database.groundStationVersions.contains,
                  ),
                );
              }
            );
          },
          updateAttrsVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update Ground Station version ${version.toString()} attributes",
                  width: 500, height: 300, dialog: UpdateAttrsDialog(
                    config: UpdateAttrsDialogConfig(
                      hasRequiredDBC: true,
                      hasRequiredNetCode: true,
                      requiredDBC: Database.groundStationReqDBC(version),
                      requiredNetCode: Database.groundStationReqNetCode(version),
                      version: version
                    ),
                    updateHandler: UpdateAttrsHandler.groundStation,
                    checkIfExists: Database.groundStationVersions.contains,
                  ),
                );
              }
            );
          },
          deleteVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Remove Ground Station version",
                  width: 500, height: 300, dialog: DeleteDialog(
                    version: version,
                    deleteHandler: DeleteHandler.groundStation,
                    checkIfExists: Database.groundStationVersions.contains,
                    checkIfIsRequired: ReferenceChecker.groundStation,
                  ),
                );
              }
            );
          },
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new Ground Station version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(hasRequiredDBC: true, hasRequiredNetCode: true),
                    updateHandler: UpdateHandler.groundStation,
                    checkIfExists: Database.groundStationVersions.contains,
                  ),
                );
              }
            );
          },
        ),
        ComponentDeveloperView(
          title: "Remote Control",
          getOptions: () => Database.remoteVersions,
          reuploadVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update Remote Control version ${version.toString()}",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(
                      hasRequiredNetCode: true,
                      requiredNetCode: Database.remoteReqNetCode(version),
                      version: version
                    ),
                    updateHandler: UpdateHandler.remote,
                    checkIfExists: Database.remoteVersions.contains,
                  ),
                );
              }
            );
          },
          updateAttrsVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update Remote Control version ${version.toString()} attributes",
                  width: 500, height: 300, dialog: UpdateAttrsDialog(
                    config: UpdateAttrsDialogConfig(
                      hasRequiredNetCode: true,
                      requiredNetCode: Database.remoteReqNetCode(version),
                      version: version
                    ),
                    updateHandler: UpdateAttrsHandler.remote,
                    checkIfExists: Database.remoteVersions.contains,
                  ),
                );
              }
            );
          },
          deleteVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Remove Remote Control version",
                  width: 500, height: 300, dialog: DeleteDialog(
                    version: version,
                    deleteHandler: DeleteHandler.remote,
                    checkIfExists: Database.remoteVersions.contains,
                    checkIfIsRequired: ReferenceChecker.remote,
                  ),
                );
              }
            );
          },
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new Remote Control version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(hasRequiredNetCode: true),
                    updateHandler: UpdateHandler.remote,
                    checkIfExists: Database.remoteVersions.contains,
                  ),
                );
              }
            );
          },
        ),
        ComponentDeveloperView(
          title: "Netcode",
          getOptions: () => Database.netCodeVersions,
          reuploadVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update netcode version ${version.toString()}",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(version: version),
                    updateHandler: UpdateHandler.netcode,
                    checkIfExists: Database.netCodeVersions.contains,
                  ),
                );
              }
            );
          },
          updateAttrsVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update netcode version ${version.toString()} attributes",
                  width: 500, height: 300, dialog: UpdateAttrsDialog(
                    config: UpdateAttrsDialogConfig(version: version),
                    updateHandler: UpdateAttrsHandler.netcode,
                    checkIfExists: Database.netCodeVersions.contains,
                  ),
                );
              }
            );
          },
          deleteVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Remove Netcode version",
                  width: 500, height: 300, dialog: DeleteDialog(
                    version: version,
                    deleteHandler: DeleteHandler.netcode,
                    checkIfExists: Database.netCodeVersions.contains,
                    checkIfIsRequired: ReferenceChecker.netcode,
                  ),
                );
              }
            );
          },
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new netcode version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(),
                    updateHandler: UpdateHandler.netcode,
                    checkIfExists: Database.netCodeVersions.contains,
                  ),
                );
              }
            );
          },
        ),
        ComponentDeveloperView(
          title: "DBC",
          getOptions: () => Database.dbcVersions,
          reuploadVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update dbc version ${version.toString()}",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(version: version),
                    updateHandler: UpdateHandler.dbc,
                    checkIfExists: Database.dbcVersions.contains,
                  ),
                );
              }
            );
          },
          updateAttrsVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Update dbc version ${version.toString()} attributes",
                  width: 500, height: 300, dialog: UpdateAttrsDialog(
                    config: UpdateAttrsDialogConfig(version: version),
                    updateHandler: UpdateAttrsHandler.dbc,
                    checkIfExists: Database.dbcVersions.contains,
                  ),
                );
              }
            );
          },
          deleteVersion: (final Version version) async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Remove DBC version",
                  width: 500, height: 300, dialog: DeleteDialog(
                    version: version,
                    deleteHandler: DeleteHandler.dbc,
                    checkIfExists: Database.dbcVersions.contains,
                    checkIfIsRequired: ReferenceChecker.dbc,
                  ),
                );
              }
            );
          },
          addNewVersion: () async {
            await showDialog(
              context: context, builder: (context){
                return DialogBase(
                  title: "Upload new dbc version",
                  width: 500, height: 300, dialog: UpdateDialog(
                    config: UpdateDialogConfig(),
                    updateHandler: UpdateHandler.dbc,
                    checkIfExists: Database.dbcVersions.contains,
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
  const ComponentDeveloperView({super.key, required this.title, required this.getOptions, required this.reuploadVersion, required this.updateAttrsVersion, required this.deleteVersion, required this.addNewVersion});

  final String title;
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
        Text(widget.title, style: ThemeManager.subTitleStyle,), 
        SizedBox(
          height: 300,
          width: 250,
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