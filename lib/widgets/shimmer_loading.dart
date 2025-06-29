import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class ShimmerLoading extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsetsGeometry? margin;

  const ShimmerLoading({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 12,
    this.baseColor,
    this.highlightColor,
    this.margin,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get theme-appropriate shimmer colors
    final shimmerColors = AppColors.getShimmerColors(isDark);
    final defaultBaseColor = widget.baseColor ?? shimmerColors[0];
    final defaultHighlightColor = widget.highlightColor ?? shimmerColors[1];

    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
            width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, -0.5),
                end: Alignment(_animation.value + 1, 0.5),
              colors: [
                  defaultBaseColor,
                  defaultHighlightColor,
                  AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                  defaultHighlightColor,
                  defaultBaseColor,
                ],
                stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              ),
              border: Border.all(
                color: AppColors.getBorderColor(isDark),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(isDark ? 0.05 : 0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
          ),
        );
      },
      ),
    );
  }
}
