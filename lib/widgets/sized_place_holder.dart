import 'package:flutter/material.dart';

class SizedPlaceHolder extends StatelessWidget {
  double height;
  double width;
  Color color;

  SizedPlaceHolder(
      {Key? key,
      required this.color,
      required this.height,
      required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Placeholder(
        color: color,
      ),
    );
  }
}
