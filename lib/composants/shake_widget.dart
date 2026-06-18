import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double shakeCount;
  final double shakeOffset;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.shakeCount = 3,
    this.shakeOffset = 10,
  });

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        
        // Approximation simplifiée de la secousse
        double dx = 0;
        if (_controller.value > 0 && _controller.value < 1) {
          dx = (widget.shakeOffset * (1 - _controller.value)) * 
               ((_controller.value * widget.shakeCount * 10).toInt() % 2 == 0 ? 1 : -1);
        }

        return Transform.translate(
          offset: Offset(dx, 0),
          child: widget.child,
        );
      },
    );
  }
}
