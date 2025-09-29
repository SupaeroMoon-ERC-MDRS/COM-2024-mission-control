import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/data_misc/session.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

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
        SessionFormElement(name: "IP address", controller: _ip, get: () => Session.ip, hidden: false,),
        SessionFormElement(name: "Username", controller: _user, get: () => Session.user, hidden: false,),
        SessionFormElement(name: "Password", controller: _pwd, get: () => Session.pwd, hidden: true,),
        TextButton(
          onPressed: (){
            Session.ip = _ip.text;
            Session.user = _user.text;
            Session.pwd = _pwd.text;
            _ip.clear();
            _user.clear();
            _pwd.clear();
            Session.save();
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
  const SessionFormElement({super.key, required this.name, required this.controller, required this.get, required this.hidden});

  final String name;
  final TextEditingController controller;
  final String Function() get;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Padding(
          padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
          child: Text(name, style: ThemeManager.textStyle,),
        ),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: controller,
            obscureText: hidden,
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