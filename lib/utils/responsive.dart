import 'package:flutter/material.dart';

/// Responsive design utilities for different screen sizes
class Responsive {
  static const double _mobileBreakpoint = 480;
  static const double _desktopBreakpoint = 1024;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileBreakpoint;
  }

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= _mobileBreakpoint &&
        MediaQuery.of(context).size.width < _desktopBreakpoint;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Get responsive grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isDesktop(context)) {
      return (screenWidth - 96) / 3; // 3 cards with padding
    } else if (isTablet(context)) {
      return (screenWidth - 72) / 2; // 2 cards with padding
    } else {
      return screenWidth - 32; // Single card with padding
    }
  }

  /// Get responsive font size
  static double getHeadingFontSize(BuildContext context) {
    if (isDesktop(context)) {
      return 28.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 20.0;
    }
  }

  /// Get responsive subtitle font size
  static double getSubtitleFontSize(BuildContext context) {
    if (isDesktop(context)) {
      return 18.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 14.0;
    }
  }

  /// Get responsive body font size
  static double getBodyFontSize(BuildContext context) {
    if (isDesktop(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 15.0;
    } else {
      return 14.0;
    }
  }

  /// Responsive widget builder
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double scale = 1.0}) {
    double baseSize = 24.0;

    if (isDesktop(context)) {
      baseSize = 28.0;
    } else if (isTablet(context)) {
      baseSize = 26.0;
    }

    return baseSize * scale;
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 56.0;
    } else if (isTablet(context)) {
      return 52.0;
    } else {
      return 48.0;
    }
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isDesktop(context)) {
      return screenWidth * 0.4; // 40% of screen width
    } else if (isTablet(context)) {
      return screenWidth * 0.6; // 60% of screen width
    } else {
      return screenWidth * 0.9; // 90% of screen width
    }
  }

  /// Get responsive card elevation
  static double getCardElevation(BuildContext context) {
    if (isDesktop(context)) {
      return 6.0;
    } else if (isTablet(context)) {
      return 4.0;
    } else {
      return 2.0;
    }
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 72.0;
    } else if (isTablet(context)) {
      return 64.0;
    } else {
      return 56.0;
    }
  }

  /// Get responsive list tile height
  static double getListTileHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 80.0;
    } else if (isTablet(context)) {
      return 72.0;
    } else {
      return 64.0;
    }
  }

  /// Get responsive chart height
  static double getChartHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (isDesktop(context)) {
      return screenHeight * 0.4;
    } else if (isTablet(context)) {
      return screenHeight * 0.35;
    } else {
      return screenHeight * 0.3;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive navigation drawer width
  static double getDrawerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isDesktop(context)) {
      return 300.0;
    } else if (isTablet(context)) {
      return screenWidth * 0.6;
    } else {
      return screenWidth * 0.8;
    }
  }
}

/// Breakpoint constants for responsive design
class BreakPoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double large = 1440;
}

/// Responsive spacing utilities
class ResponsiveSpacing {
  /// Get vertical spacing based on screen size
  static double getVerticalSpacing(BuildContext context, {double scale = 1.0}) {
    double baseSpacing = 16.0;

    if (Responsive.isDesktop(context)) {
      baseSpacing = 24.0;
    } else if (Responsive.isTablet(context)) {
      baseSpacing = 20.0;
    }

    return baseSpacing * scale;
  }

  /// Get horizontal spacing based on screen size
  static double getHorizontalSpacing(
    BuildContext context, {
    double scale = 1.0,
  }) {
    double baseSpacing = 16.0;

    if (Responsive.isDesktop(context)) {
      baseSpacing = 24.0;
    } else if (Responsive.isTablet(context)) {
      baseSpacing = 20.0;
    }

    return baseSpacing * scale;
  }

  /// Get section spacing
  static double getSectionSpacing(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 48.0;
    } else if (Responsive.isTablet(context)) {
      return 36.0;
    } else {
      return 24.0;
    }
  }
}

/// Responsive typography helpers
class ResponsiveTypography {
  /// Get display text style based on screen size
  static TextStyle getDisplayStyle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.isDesktop(context)
          ? 32.0
          : Responsive.isTablet(context)
          ? 28.0
          : 24.0,
      fontWeight: FontWeight.bold,
    );
  }

  /// Get headline text style based on screen size
  static TextStyle getHeadlineStyle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.getHeadingFontSize(context),
      fontWeight: FontWeight.w600,
    );
  }

  /// Get subtitle text style based on screen size
  static TextStyle getSubtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.getSubtitleFontSize(context),
      fontWeight: FontWeight.w500,
    );
  }

  /// Get body text style based on screen size
  static TextStyle getBodyStyle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.getBodyFontSize(context),
      fontWeight: FontWeight.normal,
    );
  }

  /// Get caption text style based on screen size
  static TextStyle getCaptionStyle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.getBodyFontSize(context) - 2.0,
      fontWeight: FontWeight.w400,
    );
  }
}
