import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NotificationBell extends StatelessWidget {
  final bool hasNotifications;
  final VoidCallback onPress;

  const NotificationBell({Key? key, required this.hasNotifications, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications, size: 30),
          onPressed: onPress,
        ),
        if (hasNotifications) 
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                maxWidth: 15,
                maxHeight: 15,
              ),
            ),
          ),
      ],
    );
  }
}
