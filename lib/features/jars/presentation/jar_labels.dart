import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme.dart';
import '../../../core/constants.dart';
import '../../../core/money.dart';
import '../data/jar.dart';

/// Localized display name of a glass. Built-in glasses use translated names;
/// custom ones keep the name the user typed. With [family] the Rent glass is
/// called "Home contribution".
String jarName(
  AppLocalizations l,
  JarType type,
  String storedName, {
  required bool family,
}) {
  switch (type) {
    case JarType.savings:
      return l.jarSavings;
    case JarType.rent:
      return family ? l.jarHome : l.jarRent;
    case JarType.food:
      return l.jarFood;
    case JarType.travel:
      return l.jarTravel;
    case JarType.fun:
      return l.jarFun;
    case JarType.custom:
      return storedName;
  }
}

/// Screen-reader description, e.g. "Food glass, ₹1,200 left of ₹2,500".
String glassSemantics(
  AppLocalizations l,
  String name,
  int remaining,
  int total,
) {
  if (remaining < 0) {
    return l.glassSemanticsOverspent(name, formatRupees(-remaining));
  }
  return l.glassSemantics(name, formatRupees(remaining), formatRupees(total));
}

/// Liquid colour: amber for Savings, pink for Fun, blue for the others,
/// and the chosen colour for custom glasses.
Color jarColor(BuildContext context, JarType type, {String? colorHex}) {
  final pp = context.pp;
  switch (type) {
    case JarType.savings:
      return pp.savings;
    case JarType.fun:
      return pp.fun;
    case JarType.custom:
      final v = int.tryParse(colorHex ?? '', radix: 16);
      return v == null ? pp.jar : Color(v);
    case JarType.rent:
    case JarType.food:
    case JarType.travel:
      return pp.jar;
  }
}

/// Halo colour: golden for Savings, pink→purple for Fun, soft blue otherwise.
Color jarGlow(BuildContext context, JarType type, {String? colorHex}) {
  if (type == JarType.fun) return PPColors.funPurple;
  return jarColor(context, type, colorHex: colorHex);
}

/// Colour choices offered for custom glasses.
const List<String> customJarColors = [
  'FF8FD3C8',
  'FFB08FE5',
  'FF9AD36F',
  'FFF2A65A',
  'FF6FC3E8',
];
