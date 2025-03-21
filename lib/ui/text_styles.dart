// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final defaultFontStyle = GoogleFonts.poppins();
TextStyle bigTextStyle(
  BuildContext context, {
  double opacity = 1,
  bool bold = true,
}) {
  return defaultFontStyle.copyWith(
    fontSize: 30,
    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(opacity),
    fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
  );
}

TextStyle mediumTextStyle(
  BuildContext context, {
  double opacity = 1,
  bool bold = true,
}) {
  return defaultFontStyle.copyWith(
    fontSize: 24,
    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(opacity),
    fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
  );
}

TextStyle textStyle(
  BuildContext context, {
  double opacity = 1,
  bool bold = true,
}) {
  return defaultFontStyle.copyWith(
    fontSize: 19,
    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(opacity),
    fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
  );
}

TextStyle subtitleTextStyle(
  BuildContext context, {
  double opacity = 1,
  bool bold = false,
}) {
  return defaultFontStyle.copyWith(
    fontSize: 15,
    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(opacity),
    fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
  );
}

TextStyle smallTextStyle(
  BuildContext context, {
  double opacity = 1,
  bool bold = false,
}) {
  return defaultFontStyle.copyWith(
    fontSize: 13,
    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(opacity),
    fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
  );
}

TextStyle tinyTextStyle(
  BuildContext context, {
  double opacity = 1,
  bool bold = false,
}) {
  return defaultFontStyle.copyWith(
    fontSize: 11,
    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(opacity),
    fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
  );
}

TextStyle customTextStyle(
  BuildContext context, {
  double opacity = 1,
  bool bold = false,
  double? fontSize,
}) {
  return defaultFontStyle.copyWith(
    fontSize: fontSize,
    color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(opacity),
    fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
  );
}
