import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import '../utils/app_theme.dart';
import '../utils/theme_provider.dart';

/// =============================================================================
///              AUDIRA CYBERPUNK & NEO-BRUTALIST MOBILE WIDGET SUITE
///                   Created by Agus Dwi Rianto (AUDIRA)
///                   Organization: Audira Multimedia Digital
/// =============================================================================

/// 1. Cyber Pulse Dot (Indikator Status Online Berdenyut Real-time)
class CyberPulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const CyberPulseDot({
    super.key,
    this.color = AppTheme.neonGreen,
    this.size = 10.0,
  });

  @override
  State<CyberPulseDot> createState() => _CyberPulseDotState();
}

class _CyberPulseDotState extends State<CyberPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.8),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 2. Cyber Badge (Monospace Technical Tag)
class CyberBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool isMonospace;

  const CyberBadge({
    super.key,
    String? text,
    String? label,
    this.color = AppTheme.neonCyan,
    this.icon,
    this.isMonospace = true,
  }) : text = text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              fontFamily: isMonospace ? 'monospace' : null,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Cyber Card (Kartu Neo-Brutalis Berkontras Tinggi dengan Aksen Neon)
class CyberCard extends StatelessWidget {
  final Widget child;
  final String? badgeText;
  final Color? badgeColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool glow;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CyberCard({
    super.key,
    required this.child,
    this.badgeText,
    this.badgeColor,
    Color? borderColor,
    Color? accentColor,
    this.backgroundColor,
    this.glow = false,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  }) : borderColor = borderColor ?? accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppTheme.cyberSurfaceCard : Colors.white;
    final defaultBorder = isDark
        ? (glow ? AppTheme.neonCyan : AppTheme.cyberBorder)
        : (glow ? AppTheme.signalBlue : const Color(0xFFCBD5E1));
    final effectiveBorderColor = borderColor ?? defaultBorder;

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveBorderColor,
          width: 1.5,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: effectiveBorderColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: isDark ? const Color(0x66000000) : const Color(0x0A000000),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeText != null) ...[
            Align(
              alignment: Alignment.topRight,
              child: CyberBadge(
                text: badgeText!,
                color: badgeColor ?? (isDark ? AppTheme.neonCyan : AppTheme.signalBlue),
              ),
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.neonCyan.withValues(alpha: 0.15),
          highlightColor: AppTheme.neonCyan.withValues(alpha: 0.05),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// 4. Tactical HUD Header (Header Terminal Telemetri Jaringan)
class TacticalHudHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String nodeId;
  final String latencyMs;
  final Color? accentColor;
  final VoidCallback? onNotificationTap;
  final List<Widget>? customActions;

  const TacticalHudHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.nodeId = "JKT-01 // CORE",
    this.latencyMs = "4 ms",
    this.accentColor,
    this.onNotificationTap,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberOledBg : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Telemetry Live Ribbon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CyberPulseDot(color: AppTheme.neonGreen, size: 8),
                  const SizedBox(width: 8),
                  Text(
                    "NODE: $nodeId",
                    style: TextStyle(
                      color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cyberObsidian : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.zap,
                      color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      latencyMs,
                      style: TextStyle(
                        color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Baris 2: User Identification & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? AppTheme.textSecondary : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick Theme Switch Button (Light / Dark)
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      final bool darkActive = themeProvider.isDarkMode ||
                          (themeProvider.isSystemMode && isDark);
                      return IconButton(
                        tooltip: darkActive
                            ? 'Ganti ke Mode Terang (Light)'
                            : 'Ganti ke Mode Gelap (Dark)',
                        onPressed: () => themeProvider.toggleTheme(context),
                        icon: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Icon(
                            darkActive ? LucideIcons.sun : LucideIcons.moon,
                            color: darkActive ? AppTheme.neonAmber : AppTheme.signalBlue,
                            size: 19,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  if (onNotificationTap != null)
                    IconButton(
                      onPressed: onNotificationTap,
                      icon: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Icon(
                          LucideIcons.bell,
                          color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                          size: 19,
                        ),
                      ),
                    ),
                  if (customActions != null) ...customActions!,
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 5. Cyber Stat Tile (Metrik Telemetri Taktis)
class CyberStatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color accentColor;
  final VoidCallback? onTap;

  const CyberStatTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.accentColor = AppTheme.neonCyan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? accentColor.withValues(alpha: 0.25)
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(icon, color: accentColor, size: 18),
                  ),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? AppTheme.textSecondary : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: isDark ? accentColor : AppTheme.signalBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 6. Cyber Action Button (Tombol Aksi Neon Taktis)
class CyberActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final bool isSecondary;
  final bool fullWidth;

  const CyberActionButton({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.icon,
    Color? primaryColor,
    Color? color,
    this.isSecondary = false,
    bool? fullWidth,
    bool? isFullWidth,
  })  : label = label ?? text ?? '',
        primaryColor = primaryColor ?? color ?? AppTheme.neonCyan,
        fullWidth = fullWidth ?? isFullWidth ?? true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEnabled = onPressed != null;
    final Color effectiveColor = isEnabled ? primaryColor : (isDark ? AppTheme.textMuted : const Color(0xFF94A3B8));

    final buttonWidget = Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: !isEnabled || isSecondary
            ? null
            : LinearGradient(
                colors: [
                  primaryColor,
                  AppTheme.signalBlue,
                ],
              ),
        color: !isEnabled
            ? (isDark ? AppTheme.cyberObsidian : const Color(0xFFE2E8F0))
            : (isSecondary ? (isDark ? AppTheme.cyberObsidian : const Color(0xFFF1F5F9)) : null),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSecondary && !isDark ? const Color(0xFFCBD5E1) : effectiveColor,
          width: 1.5,
        ),
        boxShadow: !isEnabled || isSecondary
            ? null
            : [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: !isEnabled
                        ? (isDark ? AppTheme.textMuted : const Color(0xFF94A3B8))
                        : (isSecondary
                            ? (isDark ? primaryColor : (primaryColor == AppTheme.neonCyan ? AppTheme.signalBlue : primaryColor))
                            : Colors.white),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: !isEnabled
                        ? (isDark ? AppTheme.textMuted : const Color(0xFF94A3B8))
                        : (isSecondary ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.white),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }
    return buttonWidget;
  }
}

/// 7. Cyber Command Tile (Menu Aksi Kotak Taktis Eksekutif)
class CyberCommandTile extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final List<Color>? gradientColors;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const CyberCommandTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.gradientColors,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> activeGradient = gradientColors ?? [
      color,
      color.withValues(alpha: 0.8),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: activeGradient.first.withValues(alpha: 0.16),
        highlightColor: activeGradient.first.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? activeGradient.first.withValues(alpha: 0.22)
                  : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: activeGradient.first.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0x0A0F172A),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: activeGradient.first.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gradient Glass Icon Squircle
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: activeGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: activeGradient.first.withValues(alpha: 0.38),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Gloss Specular Highlight
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.32),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.65],
                                ),
                              ),
                            ),
                          ),
                          // The Crisp Centered Icon
                          _buildIconWidget(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  top: -6,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppTheme.neonCrimson,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: (badgeColor ?? AppTheme.neonCrimson).withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWidget() {
    if (icon is Widget) return icon as Widget;
    if (icon is IconData) {
      return Icon(icon as IconData, color: Colors.white, size: 23);
    }
    return HugeIcon(
      icon: icon,
      color: Colors.white,
      size: 23,
    );
  }
}
