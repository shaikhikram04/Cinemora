import 'package:flutter/material.dart';

class DeviceUtils {
  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;
}
