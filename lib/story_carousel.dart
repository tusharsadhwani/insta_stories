import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'story_indicator.dart';

class StoryCarousel extends StatefulWidget {
  @override
  _StoryCarouselState createState() => _StoryCarouselState();
}

class _StoryCarouselState extends State<StoryCarousel>
    with TickerProviderStateMixin {
  AnimationController _carouselController;
  AnimationController _storyController;
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

  @override
  void initState() {
    super.initState();
    _duration = Duration(milliseconds: 400);
    _carouselController = AnimationController(vsync: this, duration: _duration);
    _animation = CurvedAnimation(
      parent: _carouselController,
      curve: Curves.easeInOutQuad,
    );
    _storyController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );
    _storyController.forward();
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
                  story: _storyController,
                ),
                RightStory(
                  width: size.maxWidth,
                  animation: _animation,
                  story: _storyController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BaseStory extends StatelessWidget {
  const BaseStory({
    Key key,
    @required this.animation,
    @required this.story,
    @required this.width,
    @required this.image,
    @required this.alignment,
    this.xOffset = 0,
  }) : super(key: key);

  final Animation animation;
  final Animation story;
  final double width;
  final double xOffset;
  final Alignment alignment;
  final Image image;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        double dragAmount = animation.value * width;
        return Transform.translate(
          offset: Offset(xOffset - dragAmount, 0),
          child: Transform(
            alignment: alignment,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi / 2 * (dragAmount - xOffset) / width),
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image,
                        ),
                        Positioned(
                          top: 0,
                          width: width,
                          child: AnimatedBuilder(
                            animation: story,
                            builder: (_, __) => StoryIndicator(
                              segmentCount: 2,
                              activeIndex: 1,
                              value: story.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  width: width,
                  child: MessageBox((_) {}),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MainStory extends StatelessWidget {
  const MainStory({
    Key key,
    @required this.animation,
    @required this.story,
    @required this.width,
  }) : super(key: key);

  final Animation animation;
  final Animation story;
  final double width;

  @override
  Widget build(BuildContext context) {
    return BaseStory(
      animation: animation,
      story: story,
      width: width,
      alignment: Alignment.centerRight,
      image: Image.asset('assets/1.jpg'),
    );
  }
}

class RightStory extends StatelessWidget {
  const RightStory({
    Key key,
    @required this.animation,
    @required this.story,
    @required this.width,
  }) : super(key: key);

  final Animation animation;
  final Animation story;
  final double width;

  @override
  Widget build(BuildContext context) {
    return BaseStory(
      animation: animation,
      story: story,
      width: width,
      xOffset: width,
      alignment: Alignment.centerLeft,
      image: Image.asset('assets/2.jpg'),
    );
  }
}

class MessageBox extends StatefulWidget {
  final void Function(String) addMessage;

  MessageBox(this.addMessage);

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  var _messageController = TextEditingController();

  void _sendMessage() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  controller: _messageController,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            ),
            GestureDetector(
              onTap: _sendMessage,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SvgPicture.asset(
                  'assets/send.svg',
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
