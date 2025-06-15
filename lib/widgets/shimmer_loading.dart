import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class ShimmerLoading extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerLoading({
    Key? key,
    required this.height,
    this.width,
    this.borderRadius = 8,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 1500),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.3)),
                Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.5)),
                Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.3)),
              ],
            ),
          ),
        );
      },
    );
  }
}
