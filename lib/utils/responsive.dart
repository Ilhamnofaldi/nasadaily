import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Screen type enum
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }
  
  // Check screen types
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }
  
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }
  
  // Responsive values
  static T valueWhen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
  
  // Grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    return valueWhen(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }
  
  // Padding based on screen size
  static EdgeInsets getPadding(BuildContext context) {
    return EdgeInsets.all(valueWhen(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    ));
  }
  
  // Margin based on screen size
  static EdgeInsets getMargin(BuildContext context) {
    return EdgeInsets.all(valueWhen(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    ));
  }
  
  // Font size scaling
  static double scaleFontSize(BuildContext context, double baseSize) {
    final scaleFactor = valueWhen(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    
    return baseSize * scaleFactor;
  }
  
  // Icon size scaling
  static double scaleIconSize(BuildContext context, double baseSize) {
    final scaleFactor = valueWhen(
      context: context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.4,
    );
    
    return baseSize * scaleFactor;
  }
  
  // App bar height
  static double getAppBarHeight(BuildContext context) {
    return valueWhen(
      context: context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }
  
  // Card elevation
  static double getCardElevation(BuildContext context) {
    return valueWhen(
      context: context,
      mobile: 2.0,
      tablet: 4.0,
      desktop: 6.0,
    );
  }
  
  // Border radius
  static double getBorderRadius(BuildContext context) {
    return valueWhen(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }
  
  // Maximum content width for desktop
  static double getMaxContentWidth(BuildContext context) {
    return valueWhen(
      context: context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }
  
  // Responsive widget builder
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return valueWhen(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Screen type enumeration
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Responsive widget that rebuilds based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Responsive.builder(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Responsive layout builder
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;
  
  const ResponsiveLayoutBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final screenType = Responsive.getScreenType(context);
    return builder(context, screenType);
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final EdgeInsets? padding;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  
  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.childAspectRatio,
    this.padding,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final columns = Responsive.getGridColumns(context);
    
    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio ?? 1.0,
      padding: padding ?? Responsive.getPadding(context),
      mainAxisSpacing: mainAxisSpacing ?? 8.0,
      crossAxisSpacing: crossAxisSpacing ?? 8.0,
      children: children,
    );
  }
}

/// Responsive container with max width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  
  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.getMaxContentWidth(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? Responsive.getPadding(context),
      margin: margin ?? Responsive.getMargin(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}