import 'package:flutter/material.dart';
import 'package:supaeromoon_mission_control/ui/theme.dart';

final GlobalKey<NavigatorState> mainWindowNavigatorKey = GlobalKey<NavigatorState>();

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }
  (context as Element).visitChildren(rebuild);
}

class AdvancedTooltip extends StatelessWidget{
  const AdvancedTooltip({super.key, required this.tooltipText, required this.child});

  final String tooltipText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipText,
      decoration: BoxDecoration(
        color: ThemeManager.globalStyle.secondaryColor,
        border: Border.all(color: ThemeManager.globalStyle.primaryColor, width: 0),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(7.5), bottomRight: Radius.circular(7.5))
      ),
      textStyle: TextStyle(color: ThemeManager.globalStyle.textColor),
      showDuration: const Duration(milliseconds: 0),
      waitDuration: const Duration(milliseconds: 1000),
      verticalOffset: 10,
      child: child,
    );
  }
}