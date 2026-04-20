import 'package:flutter/material.dart';

class AppRefreshWidgetController {
  VoidCallback? onRefresh;

  void refresh() {
    onRefresh?.call();
  }

  void dispose() {
    onRefresh = null;
  }
}

class AppRefreshWidget extends StatefulWidget {
  final AppRefreshWidgetController controller;
  final Widget Function(BuildContext ctx) builder;

  const AppRefreshWidget({super.key, required this.controller, required this.builder,});

  @override
  State<AppRefreshWidget> createState() => _AppRefreshWidgetState();
}

class _AppRefreshWidgetState extends State<AppRefreshWidget> {
  @override
  Widget build(BuildContext context) {
    widget.controller.onRefresh = _onRefresh;
    return widget.builder(context);
  }

  void _onRefresh() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
