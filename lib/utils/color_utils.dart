/// Utility functions for color operations
class ColorUtils {
  /// Safely calculates alpha value from opacity to prevent NaN or Infinity errors
  static int safeAlpha(double opacity) {
    final alpha = (255 * opacity).round();
    if (alpha.isNaN || alpha.isInfinite || alpha < 0 || alpha > 255) {
      return 76; // Default safe alpha value (0.3 * 255)
    }
    return alpha;
  }
}