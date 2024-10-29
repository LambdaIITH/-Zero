import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetName;
  final double? size;

  const SvgIcon(this.assetName, {super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return size != null
        ? SvgPicture.asset(
            assetName,
            height: size,
            width: size,
          )
        : SvgPicture.asset(
            assetName,
          );
  }
}