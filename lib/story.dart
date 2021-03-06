import 'dart:math' show pi;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'story_indicator.dart';

class BaseStory extends StatefulWidget {
  const BaseStory({
    Key key,
    @required this.animation,
    @required this.width,
    @required this.images,
    @required this.alignment,
    @required this.prevCarousel,
    @required this.nextCarousel,
    this.xOffset = 0,
  }) : super(key: key);

  final Animation animation;
  final double width;
  final double xOffset;
  final Alignment alignment;
  final List<Image> images;
  final VoidCallback prevCarousel;
  final VoidCallback nextCarousel;

  @override
  _BaseStoryState createState() => _BaseStoryState();
}

class _BaseStoryState extends State<BaseStory>
    with SingleTickerProviderStateMixin {
  AnimationController _storyController;

  int segmentCount;
  int activeIndex;

  void nextStory() {
    setState(() {
      if (activeIndex < segmentCount - 1) {
        activeIndex++;
        _storyController.reset();
        _storyController.forward();
      } else {
        widget.nextCarousel();
      }
    });
  }

  void prevStory() {
    setState(() {
      if (activeIndex > 0) {
        activeIndex--;
        _storyController.reset();
        _storyController.forward();
      } else {
        widget.prevCarousel();
      }
    });
  }

  void handleStoryTap(TapUpDetails details) {
    if (details.localPosition.dx / widget.width < 0.2)
      prevStory();
    else
      nextStory();
  }

  @override
  void initState() {
    super.initState();
    _storyController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );
    _storyController.forward();
    _storyController.addListener(() {
      if (_storyController.isCompleted) nextStory();
    });
    segmentCount = widget.images.length;
    activeIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (_, __) {
        double dragAmount = widget.animation.value * widget.width;
        return Transform.translate(
          offset: Offset(widget.xOffset - dragAmount, 0),
          child: Transform(
            alignment: widget.alignment,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi / 2 * (dragAmount - widget.xOffset) / widget.width),
            child: Stack(
              children: [
                GestureDetector(
                  onTapUp: handleStoryTap,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.images[activeIndex],
                      ),
                      Positioned(
                        top: 0,
                        width: widget.width,
                        child: AnimatedBuilder(
                          animation: _storyController,
                          builder: (_, __) => StoryIndicator(
                            segmentCount: segmentCount,
                            activeIndex: activeIndex,
                            value: _storyController.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
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
    @required this.width,
    @required this.images,
    @required this.prevCarousel,
    @required this.nextCarousel,
  }) : super(key: key);

  final Animation animation;
  final double width;
  final List<Image> images;
  final VoidCallback prevCarousel, nextCarousel;

  @override
  Widget build(BuildContext context) {
    return BaseStory(
      animation: animation,
      width: width,
      alignment: Alignment.centerRight,
      images: images,
      prevCarousel: prevCarousel,
      nextCarousel: nextCarousel,
    );
  }
}

class RightStory extends StatelessWidget {
  const RightStory({
    Key key,
    @required this.animation,
    @required this.width,
    @required this.images,
    @required this.prevCarousel,
    @required this.nextCarousel,
  }) : super(key: key);

  final Animation animation;
  final double width;
  final List<Image> images;
  final VoidCallback prevCarousel, nextCarousel;

  @override
  Widget build(BuildContext context) {
    return BaseStory(
      animation: animation,
      width: width,
      xOffset: width,
      alignment: Alignment.centerLeft,
      images: images,
      prevCarousel: prevCarousel,
      nextCarousel: nextCarousel,
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
                child: kIsWeb
                    ? Icon(Icons.send)
                    : SvgPicture.asset(
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
