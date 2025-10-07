import 'package:flutter/material.dart';

class CustomIconData {
  final IconData iconData;

  const CustomIconData(this.iconData);
}

class CustomIcons {
  static const CustomIconData user = CustomIconData(Icons.person);
  static const CustomIconData settings = CustomIconData(Icons.settings);
  static const CustomIconData lock = CustomIconData(Icons.lock);
  static const CustomIconData email = CustomIconData(Icons.email);
}

class CustomIcon extends StatelessWidget {
  final CustomIconData iconData;
  final Size size;
  final Color? color;

  const CustomIcon({
    super.key,
    required this.iconData,
    this.size = const Size(24, 24),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData.iconData,
      size: size.width,
      color: color ?? Colors.black87,
    );
  }
}
