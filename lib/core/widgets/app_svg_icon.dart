import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Drop-in replacement for [Icon] that renders an SVG from `assets/icons/`.
///
/// Like [Icon], size and color fall back to the ambient [IconTheme], so it
/// picks up the colors that buttons and input decorations provide.
class AppSvgIcon extends StatelessWidget {
  final String asset;
  final double? size;
  final Color? color;

  const AppSvgIcon(this.asset, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final dimension = size ?? iconTheme.size ?? 24;
    final tint = color ?? iconTheme.color;
    // Outer box + Center mirror Icon's layout when a parent enforces a min size.
    return SizedBox.square(
      dimension: dimension,
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: dimension,
          height: dimension,
          colorFilter: tint == null
              ? null
              : ColorFilter.mode(tint, BlendMode.srcIn),
        ),
      ),
    );
  }
}
