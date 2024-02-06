
import 'package:flutter/material.dart';

class ThreeDotLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const ThreeDotLoadingIndicator({
    Key? key,
    this.color = Colors.blue,
    this.size = 50.0,
  }) : super(key: key);

  @override
  _ThreeDotLoadingIndicatorState createState() => _ThreeDotLoadingIndicatorState();
}

class _ThreeDotLoadingIndicatorState extends State<ThreeDotLoadingIndicator> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween(begin: 0.0, end: 8.0).animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: widget.size,
          width: widget.size / 4,
          margin: EdgeInsets.only(right: animation.value),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: widget.size,
          width: widget.size / 4,
          margin: EdgeInsets.symmetric(horizontal: animation.value),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: widget.size,
          width: widget.size / 4,
          margin: EdgeInsets.only(left: animation.value),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
