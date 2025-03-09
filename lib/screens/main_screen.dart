// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:titlebar_buttons/titlebar_buttons.dart';

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainScreen({super.key, required this.navigationShell});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isLinux && Process.runSync("which", ["mpv"]).exitCode != 0) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                title: Text("MVP not found"),
                content: Text(
                  "MVP is required to play music. Please install it and restart the app.",
                ),
                actions: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: () => exit(1),
                    child: Text("Exit", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
        );
      }
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Column(
        children: [
          if (Platform.isLinux)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                appWindow.startDragging();
              },
              child: WindowTitleBarBox(
                child: PreferredSize(
                  preferredSize: Size(
                    double.maxFinite,
                    appWindow.titleBarHeight,
                  ),
                  child: AppBar(
                    title: Text('Musiz Play'),
                    centerTitle: true,
                    actions: [
                      DecoratedMinimizeButton(onPressed: appWindow.minimize),
                      DecoratedMaximizeButton(
                        onPressed: appWindow.maximizeOrRestore,
                      ),
                      DecoratedCloseButton(onPressed: appWindow.close),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                if (screenWidth >= 450)
                  NavigationRail(
                    labelType: NavigationRailLabelType.none,
                    selectedIndex: widget.navigationShell.currentIndex,
                    destinations: [],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
