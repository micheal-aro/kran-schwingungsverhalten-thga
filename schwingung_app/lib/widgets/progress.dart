import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppProgressIndicator extends StatelessWidget {
  final double radius;
  final bool centered;

  const AppProgressIndicator({
    this.radius = 50,
    this.centered = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      alignment: centered ? Alignment.center : null,
      child: Platform.isIOS
          ? CupertinoActivityIndicator(radius: radius)
          : const CircularProgressIndicator(),
    );
  }
}
