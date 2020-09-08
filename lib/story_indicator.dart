import 'package:flutter/material.dart';

class StoryIndicator extends StatelessWidget {
  const StoryIndicator({
    Key key,
    @required this.segmentCount,
    @required this.activeIndex,
    @required this.value,
  }) : super(key: key);

  final double segmentCount;
  final double activeIndex;
  final double value;
  final _height = 1.5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < segmentCount; i++) ...[
                if (i > 0) SizedBox(width: 2),
                _StoryIndicatorSegment(
                  height: _height,
                  value: i < activeIndex ? 1 : i > activeIndex ? 0 : value,
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryIndicatorSegment extends StatelessWidget {
  const _StoryIndicatorSegment({
    Key key,
    @required double height,
    @required this.value,
  })  : _height = height,
        super(key: key);

  final double _height;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_height),
        child: Stack(
          children: [
            SizedBox(
              height: _height,
              child: Container(
                color: Colors.grey.shade500,
              ),
            ),
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: _height,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
