import 'package:flutter/material.dart';

import 'story.dart';

class StoryCarousel extends StatefulWidget {
  @override
  _StoryCarouselState createState() => _StoryCarouselState();
}

class _StoryCarouselState extends State<StoryCarousel>
    with SingleTickerProviderStateMixin {
  AnimationController _carouselController;
  Animation _animation;
  Duration _duration;
  double deviceWidth;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _carouselController.value += -details.primaryDelta / deviceWidth;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    double _kMinFlingVelocity = 700;

    if (_carouselController.isDismissed || _carouselController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      if (details.velocity.pixelsPerSecond.dx > 0)
        _carouselController.reverse();
      else
        _carouselController.forward();
    } else if (_carouselController.value > 0.5)
      _carouselController.forward();
    else
      _carouselController.reverse();
  }

  void nextCarousel() {
    _carouselController.forward();
  }

  void prevCarousel() {
    _carouselController.reverse();
  }

  @override
  void initState() {
    super.initState();
    _duration = Duration(milliseconds: 400);
    _carouselController = AnimationController(vsync: this, duration: _duration);
    _animation = CurvedAnimation(
      parent: _carouselController,
      curve: Curves.easeInOutQuad,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Container(
        color: Theme.of(context).canvasColor,
        child: Center(
          child: LayoutBuilder(
            builder: (_, size) => Stack(
              children: [
                MainStory(
                  width: size.maxWidth,
                  animation: _animation,
                  images: [
                    Image.asset('assets/1.jpg'),
                    Image.asset('assets/2.jpg'),
                  ],
                  prevCarousel: prevCarousel,
                  nextCarousel: nextCarousel,
                ),
                RightStory(
                  width: size.maxWidth,
                  animation: _animation,
                  images: [Image.asset('assets/3.jpg')],
                  prevCarousel: prevCarousel,
                  nextCarousel: nextCarousel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
