import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

const double dialogTitleBarHeight = 50.0;

class DialogTitleBar extends StatelessWidget{
  const DialogTitleBar({super.key, required this.parentContext, required this.title});

  final BuildContext parentContext;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dialogTitleBarHeight,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: ThemeManager.globalStyle.primaryColor)), color: ThemeManager.globalStyle.secondaryColor),
      child: Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 4 * ThemeManager.globalStyle.padding), child: Text(title, style: TextStyle(fontSize: ThemeManager.globalStyle.subTitleFontSize),),),
          const Spacer(),
          IconButton(
            onPressed: (){
              Navigator.of(parentContext).pop();
            },
            splashRadius: 20.0,
            icon: Icon(Icons.close, color: ThemeManager.globalStyle.primaryColor,)
          )
        ],
      ),
    );
  }
}

class DialogBase extends StatelessWidget{
  final String title;
  final Widget dialog;
  final double width;
  final double height;

  const DialogBase({super.key, required this.title, required this.dialog, required this.width, required this.height});
  
  @override
  Widget build(BuildContext context) {
    return Dialog(  
      elevation: 10,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: ThemeManager.globalStyle.primaryColor, width: 1),
          color: ThemeManager.globalStyle.bgColor
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitleBar(parentContext: context, title: title),
            dialog
          ],
        ),
      ),
    );
  }
}