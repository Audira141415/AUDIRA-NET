import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../utils/app_theme.dart';

/// A responsive card widget that adapts to different screen sizes
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableHover;
  final Duration animationDuration;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enableHover = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final responsivePadding =
        padding ??
        EdgeInsets.all(ResponsiveSpacing.getVerticalSpacing(context));

    final responsiveMargin =
        margin ??
        EdgeInsets.all(
          ResponsiveSpacing.getHorizontalSpacing(context, scale: 0.5),
        );

    final responsiveElevation =
        elevation ?? Responsive.getCardElevation(context);

    final responsiveBorderRadius =
        borderRadius ??
        BorderRadius.circular(
          Responsive.isDesktop(context)
              ? 16.0
              : Responsive.isTablet(context)
              ? 14.0
              : 12.0,
        );

    Widget cardContent = Container(
      margin: responsiveMargin,
      decoration: BoxDecoration(
        borderRadius: responsiveBorderRadius,
        color: backgroundColor ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: responsiveElevation * 2,
            offset: Offset(0, responsiveElevation / 2),
            spreadRadius: 1,
          ),
        ],
        border: isDark
            ? Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: responsiveBorderRadius,
        child: InkWell(
          borderRadius: responsiveBorderRadius,
          onTap: onTap,
          child: Padding(padding: responsivePadding, child: child),
        ),
      ),
    );

    if (enableHover && onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: animationDuration,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// A responsive grid card specifically for dashboard metrics
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveSpacing.getVerticalSpacing(context, scale: 0.5),
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Responsive.getIconSize(context),
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(
            height: ResponsiveSpacing.getVerticalSpacing(context, scale: 0.75),
          ),
          Text(
            value,
            style: ResponsiveTypography.getHeadlineStyle(context).copyWith(
              color: theme.textTheme.displayLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: ResponsiveSpacing.getVerticalSpacing(context, scale: 0.25),
          ),
          Text(
            title,
            style: ResponsiveTypography.getBodyStyle(context).copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(
              height: ResponsiveSpacing.getVerticalSpacing(
                context,
                scale: 0.25,
              ),
            ),
            Text(
              subtitle!,
              style: ResponsiveTypography.getCaptionStyle(
                context,
              ).copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

/// A responsive list tile for uniform list items
class ResponsiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;
  final EdgeInsets? contentPadding;

  const ResponsiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dense = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveHeight = Responsive.getListTileHeight(context);
    final responsivePadding =
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.getHorizontalSpacing(context),
          vertical: ResponsiveSpacing.getVerticalSpacing(context, scale: 0.5),
        );

    return Container(
      constraints: BoxConstraints(
        minHeight: dense ? responsiveHeight * 0.75 : responsiveHeight,
      ),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        dense: dense,
        contentPadding: responsivePadding,
      ),
    );
  }
}

/// A responsive app bar that adapts its height and content
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: ResponsiveTypography.getHeadlineStyle(context).copyWith(
          color: foregroundColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? AppTheme.primaryCyan,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      toolbarHeight: Responsive.getAppBarHeight(context),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

/// A responsive bottom navigation bar
class ResponsiveBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const ResponsiveBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // For desktop and tablet, consider using a rail navigation instead
    if (Responsive.isDesktop(context)) {
      return const SizedBox.shrink(); // Hide bottom nav on desktop
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryCyan,
      unselectedItemColor: Colors.grey,
      selectedFontSize: Responsive.getBodyFontSize(context),
      unselectedFontSize: Responsive.getBodyFontSize(context) - 1,
    );
  }
}
