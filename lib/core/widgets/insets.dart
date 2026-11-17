import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Space to leave at the bottom so content clears both the on-screen
/// keyboard and the system navigation bar (gesture pill or 3-button bar).
///
/// Android 15+ draws apps edge-to-edge, so bottom sheets and full-screen
/// lists must add this themselves or their last button hides under the bar.
/// The keyboard inset already covers the nav bar area, hence `max`, not sum.
double safeBottom(BuildContext context) => math.max(
  MediaQuery.viewInsetsOf(context).bottom,
  MediaQuery.viewPaddingOf(context).bottom,
);
