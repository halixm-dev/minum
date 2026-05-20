import 'package:flutter/material.dart';

/// A class that holds a set of related colors for a custom color scheme.
class ExtendedColor {
  /// The seed color used to generate the other colors.
  final Color seed;

  /// A vibrant color.
  final Color vibrant;

  /// A tonal variant of the vibrant color.
  final Color vibrantTonal;

  /// A color that is easy to see on top of [vibrant].
  final Color onVibrant;

  /// A color that is easy to see on top of [vibrantTonal].
  final Color onVibrantTonal;

  /// Creates an `ExtendedColor` object.
  ExtendedColor({
    required this.seed,
    required this.vibrant,
    required this.vibrantTonal,
    required this.onVibrant,
    required this.onVibrantTonal,
  });
}

/// A class that holds a color and its corresponding "on" color, container color,
/// and "on container" color.
class ColorFamily {
  /// The main color.
  final Color color;

  /// A color that is easy to see on top of [color].
  final Color onColor;

  /// A container color derived from [color].
  final Color container;

  /// A color that is easy to see on top of [container].
  final Color onContainer;

  /// Creates a `ColorFamily` object.
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
  });
}
