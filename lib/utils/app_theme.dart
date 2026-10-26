import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Cyan-Blue Theme for Audira Network
/// Professional, futuristic, and tech-oriented design
class AppTheme {
  /// Premium Sans Font (Plus Jakarta Sans) for Titles, Headers, and Content
  static TextStyle fontJakarta({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  /// Developer / Cyber Monospace Font (JetBrains Mono) for Telemetry, Metrics, Badges, dBm, FUP, and IPs
  static TextStyle fontMono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // Official AUDIRA Cyberpunk & Neo-Brutalism Design Tokens
  static const Color cyberOledBg = Color(0xFF05070D); // Pure Deep Midnight OLED Black
  static const Color cyberObsidian = Color(0xFF0A0E1A); // Tactical dark surface
  static const Color cyberSurfaceCard = Color(0xFF0F172A); // Elevated slate card surface
  static const Color cyberSurfaceElevated = Color(0xFF162032);
  static const Color cyberBorder = Color(0xFF1E293B);
  static const Color cyberBorderGlow = Color(0x3300F0FF);

  // Neon Accent Palette (Matches Web Tokens)
  static const Color neonCyan = Color(0xFF00F0FF); // Electric Neon Cyan
  static const Color neonPurple = Color(0xFF7928CA); // Acid Violet / Cyber Purple
  static const Color neonViolet = Color(0xFFA855F7);
  static const Color neonGreen = Color(0xFF00FF9D); // Laser Emerald (Online / Active)
  static const Color neonAmber = Color(0xFFFFB800); // Cyber Amber / Latency
  static const Color neonCrimson = Color(0xFFFF2A5F); // Electric Red Alert

  // Primary Color Palette (Preserved & elevated to vibrant electric shades)
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color brightCyan = Color(0xFF38BDF8);
  static const Color deepCyan = Color(0xFF0091EA);
  static const Color signalBlue = Color(0xFF0070F3);

  // Gradient Colors
  static const Color gradientStart = neonCyan;
  static const Color gradientEnd = signalBlue;

  // Neutral Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceGray = Color(0xFF0A0E1A); // Darker tactical surface
  static const Color borderGray = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF8FAFC); // Polar White
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500 (Muted Technical Text)
  static const Color muted = Color(0xFF64748B);

  // Status Colors
  static const Color successGreen = Color(0xFF00FF9D);
  static const Color warningOrange = Color(0xFFFFB800);
  static const Color errorRed = Color(0xFFFF2A5F);
  static const Color infoBlue = signalBlue;

  // Official AUDIRA Light Theme Design Tokens (Neo-Brutalism & High Contrast)
  static const Color lightScaffoldBg = Color(0xFFF1F5F9); // Clean slate-100 canvas
  static const Color lightSurfaceCard = Color(0xFFFFFFFF); // Pure crisp white card
  static const Color lightSurfaceElevated = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFCBD5E1); // Slate-300 border
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate-900 high contrast
  static const Color lightTextSecondary = Color(0xFF475569); // Slate-600
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate-400
  static const Color lightAccentBlue = Color(0xFF0070F3); // Signal Blue
  static const Color lightAccentTeal = Color(0xFF0284C7); // Tech Sky Blue

  // Responsive Theme Utility Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getScaffoldBg(BuildContext context) =>
      isDark(context) ? cyberOledBg : lightScaffoldBg;

  static Color getCardBg(BuildContext context) =>
      isDark(context) ? cyberSurfaceCard : lightSurfaceCard;

  static Color getSurfaceElevated(BuildContext context) =>
      isDark(context) ? cyberSurfaceElevated : lightSurfaceElevated;

  static Color getBorder(BuildContext context) =>
      isDark(context) ? cyberBorder : lightBorder;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? textSecondary : lightTextSecondary;

  static Color getTextMuted(BuildContext context) =>
      isDark(context) ? textMuted : lightTextMuted;

  // Dark Theme Colors
  static const Color darkBackground = cyberOledBg;
  static const Color darkSurface = cyberObsidian;
  static const Color darkSurfaceVariant = cyberSurfaceCard;
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkPrimaryCyan = neonCyan;
  static const Color darkBorder = cyberBorder;

  // Gradients
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonCyanGradient = LinearGradient(
    colors: [neonCyan, signalBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [cyberSurfaceCard, cyberObsidian],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonCyan, signalBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF0070F3), Color(0xFF0051B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00FF9D), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shared Typography Generator based on Plus Jakarta Sans with alphabetic baseline
  static TextTheme _buildTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        letterSpacing: -0.75,
        textBaseline: TextBaseline.alphabetic,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.5,
        textBaseline: TextBaseline.alphabetic,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.25,
        textBaseline: TextBaseline.alphabetic,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.2,
        textBaseline: TextBaseline.alphabetic,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.15,
        textBaseline: TextBaseline.alphabetic,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0,
        textBaseline: TextBaseline.alphabetic,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: 0.1,
        textBaseline: TextBaseline.alphabetic,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.1,
        textBaseline: TextBaseline.alphabetic,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.1,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        letterSpacing: 0.15,
        height: 1.45,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        letterSpacing: 0.15,
        height: 1.4,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.15,
        height: 1.35,
        textBaseline: TextBaseline.alphabetic,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: 0.3,
        textBaseline: TextBaseline.alphabetic,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.3,
        textBaseline: TextBaseline.alphabetic,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 0.4,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  // Material Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: signalBlue,
        secondary: neonPurple,
        surface: lightSurfaceCard,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
        outline: lightBorder,
      ),

      // Scaffold
      scaffoldBackgroundColor: lightScaffoldBg,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: lightSurfaceCard,
        foregroundColor: lightTextPrimary,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: lightBorder, width: 1.2),
        ),
        color: lightSurfaceCard,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: backgroundWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: signalBlue,
          side: const BorderSide(color: signalBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryCyan,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGray, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryCyan,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: primaryCyan,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          inherit: false,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          inherit: false,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryCyan,
        foregroundColor: backgroundWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightSurfaceElevated,
        deleteIconColor: lightTextSecondary,
        disabledColor: lightBorder,
        selectedColor: primaryCyan,
        secondarySelectedColor: signalBlue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          inherit: false,
          color: lightTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        secondaryLabelStyle: const TextStyle(
          inherit: false,
          color: backgroundWhite,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          textBaseline: TextBaseline.alphabetic,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: backgroundWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        titleTextStyle: TextStyle(
          inherit: false,
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          textBaseline: TextBaseline.alphabetic,
        ),
        contentTextStyle: TextStyle(
          inherit: false,
          color: lightTextSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: lightTextPrimary,
        contentTextStyle: TextStyle(
          inherit: false,
          color: backgroundWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderGray,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: signalBlue, size: 24),

      // ListTile Theme
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
          inherit: false,
          color: lightTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          textBaseline: TextBaseline.alphabetic,
        ),
        subtitleTextStyle: TextStyle(
          inherit: false,
          color: lightTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          textBaseline: TextBaseline.alphabetic,
        ),
        leadingAndTrailingTextStyle: TextStyle(
          inherit: false,
          color: lightTextSecondary,
          fontSize: 12,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(
        primaryColor: lightTextPrimary,
        secondaryColor: lightTextSecondary,
      ),
    );
  }

  // Helper Methods for Gradients
  static BoxDecoration primaryGradientDecoration({double radius = 16}) {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration blueGradientDecoration({double radius = 16}) {
    return BoxDecoration(
      gradient: blueGradient,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration successGradientDecoration({double radius = 16}) {
    return BoxDecoration(
      gradient: successGradient,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  // Cyberpunk & Neo-Brutalism Helpers
  static BoxDecoration cyberCardDecoration({
    Color? borderColor,
    Color? backgroundColor,
    double borderWidth = 1.5,
    double radius = 16,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? cyberSurfaceCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? (glow ? neonCyan : cyberBorder),
        width: borderWidth,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: (borderColor ?? neonCyan).withValues(alpha: 0.25),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ]
          : [
              const BoxShadow(
                color: Color(0x66000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
    );
  }

  static BoxDecoration cyberNeonBorder({
    Color color = neonCyan,
    double radius = 14,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: cyberObsidian,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Status Badge Helper
  static Container statusBadge({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Priority Colors
  static Color getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return errorRed;
      case 'medium':
        return warningOrange;
      case 'low':
        return successGreen;
      default:
        return textSecondary;
    }
  }

  // Status Colors
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'completed':
      case 'active':
        return successGreen;
      case 'in_progress':
      case 'progress':
      case 'pending':
        return warningOrange;
      case 'open':
      case 'new':
        return infoBlue;
      case 'cancelled':
      case 'failed':
        return errorRed;
      default:
        return textSecondary;
    }
  }

  /// Dark Theme Implementation
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.cyan,
      primaryColor: darkPrimaryCyan,
      scaffoldBackgroundColor: darkBackground,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryCyan,
        secondary: signalBlue,
        surface: darkSurface,
        error: errorRed,
        onPrimary: darkBackground,
        onSecondary: backgroundWhite,
        onSurface: darkOnSurface,
        onError: backgroundWhite,
        surfaceContainerHighest: darkSurfaceVariant,
        outline: darkBorder,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: darkOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: darkOnSurface),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: darkBorder, width: 1.2),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: cyberOledBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonCyan,
          side: const BorderSide(color: neonCyan, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonCyan,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),

      // Elevated Button Theme (Backward compatibility)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryCyan,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            inherit: false,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimaryCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: TextStyle(
          color: darkOnSurface.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        floatingLabelStyle: const TextStyle(
          color: darkPrimaryCyan,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimaryCyan,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          inherit: false,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          inherit: false,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonCyan,
        foregroundColor: cyberOledBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: cyberSurfaceElevated,
        deleteIconColor: textSecondary,
        disabledColor: borderGray,
        selectedColor: neonCyan,
        secondarySelectedColor: signalBlue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          inherit: false,
          color: darkOnSurface,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        secondaryLabelStyle: const TextStyle(
          inherit: false,
          color: cyberOledBg,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          textBaseline: TextBaseline.alphabetic,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: cyberSurfaceCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: cyberBorder, width: 1.2),
        ),
        titleTextStyle: TextStyle(
          inherit: false,
          color: darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          textBaseline: TextBaseline.alphabetic,
        ),
        contentTextStyle: TextStyle(
          inherit: false,
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),

      // SnackBar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: cyberSurfaceElevated,
        contentTextStyle: TextStyle(
          inherit: false,
          color: darkOnSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textBaseline: TextBaseline.alphabetic,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: cyberBorder, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: cyberBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: neonCyan, size: 24),

      // ListTile Theme
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
          inherit: false,
          color: darkOnSurface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          textBaseline: TextBaseline.alphabetic,
        ),
        subtitleTextStyle: TextStyle(
          inherit: false,
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          textBaseline: TextBaseline.alphabetic,
        ),
        leadingAndTrailingTextStyle: TextStyle(
          inherit: false,
          color: textSecondary,
          fontSize: 12,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(
        primaryColor: darkOnSurface,
        secondaryColor: textSecondary,
      ),

      // Accessibility & Semantic Labels
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Tooltip Theme
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: darkOnSurface,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(
          inherit: false,
          color: darkBackground,
          fontSize: 14,
        ),
      ),
    );
  }
}
