import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quiz_chart/quiz_chart_data/quiz_chart_data.dart';

const mainChartColor = Color(0xff8fd24e);
const secondChartColor = Color(0xffd9d9d9);
const firstBorderColor = Color(0xffd9d9d9);
const secondBorderColor = Color(0xffa9a9a8);
const barTextColor = Color(0xff696969);
const pointLineColor = Color(0xfffdbf44);

class SizeReporterNotification extends Notification {
  final Size size;

  const SizeReporterNotification(this.size);
}

class RenderSizeReporter extends RenderProxyBox {
  final BuildContext _context;
  Size? _oldSize;

  RenderSizeReporter({
    required BuildContext context,
    RenderBox? child,
  })  : _context = context,
        super(child);

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child!.size;
    if (_oldSize != newSize) {
      _oldSize = newSize;
      SizeReporterNotification(newSize).dispatch(_context);
    }
  }
}

class SizeReporter extends SingleChildRenderObjectWidget {
  const SizeReporter({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSizeReporter(context: context);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSizeReporter renderObject,
  ) {
    /// Update any additional properties added later.
  }
}

class XAxesDecoration extends Decoration {
  final Size leftAxesSize;
  final Size rightAxesSize;
  final BoxConstraints cstr;
  final void Function(bool shouldShow)? onUpdate;

  const XAxesDecoration({
    required this.leftAxesSize,
    required this.rightAxesSize,
    required this.cstr,
    this.onUpdate,
  });

  @override
  BoxPainter createBoxPainter([void Function()? onChanged]) {
    return XAxesDecorationPainter(
      leftAxesSize: leftAxesSize,
      rightAxesSize: rightAxesSize,
      cstr: cstr,
      onUpdate: onUpdate,
    );
  }
}

class XAxesDecorationPainter extends BoxPainter {
  final Size leftAxesSize;
  final Size rightAxesSize;
  final BoxConstraints cstr;
  final void Function(bool shouldShow)? onUpdate;

  XAxesDecorationPainter({
    required this.leftAxesSize,
    required this.rightAxesSize,
    required this.cstr,
    this.onUpdate,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = secondBorderColor
      ..strokeWidth = 1;
    final chartWidth = cstr.maxWidth - leftAxesSize.width - rightAxesSize.width;
    final shouldDrawTick = offset.dx >= leftAxesSize.width - configuration.size!.width - 8 && offset.dx <= leftAxesSize.width + chartWidth - configuration.size!.width - 8;
    final shouldShow = offset.dx >= leftAxesSize.width - 16 && offset.dx <= leftAxesSize.width + chartWidth - 16;
    final checkLast = offset.dx + configuration.size!.width + 8 >= chartWidth + leftAxesSize.width - 0.1;
    if (shouldDrawTick && !checkLast) {
      canvas.drawLine(Offset(offset.dx + configuration.size!.width + 8, offset.dy), Offset(offset.dx + configuration.size!.width + 8, 6), paint);
    }
    if (onUpdate != null) {
      onUpdate!(shouldShow);
    }
  }
}

class ChartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, -8)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, -8)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => oldClipper != this;
}

class ChartLinePainter extends CustomPainter {
  final List<QuizChartData> data;

  ChartLinePainter({super.repaint, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final painter = Paint()
      ..color = pointLineColor
      ..strokeWidth = 2;

    for (int i = 0; i < data.length - 1; i++) {
      final calcCurY = (1 - data[i].group![1].fromY!) * size.height;
      final calcNextY = (1 - data[i + 1].group![1].fromY!) * size.height;
      canvas.drawLine(Offset((40 / 2 + 8) * (1 + i * 2), calcCurY), Offset((40 / 2 + 8) * (3 + i * 2), calcNextY), painter);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => oldDelegate != this;
}

class LableChart extends StatefulWidget {
  final String labelText;
  final Size leftAxesSize;
  final Size rightAxesSize;
  final BoxConstraints cstr;

  const LableChart({
    super.key,
    required this.labelText,
    required this.leftAxesSize,
    required this.rightAxesSize,
    required this.cstr,
  });

  @override
  State<LableChart> createState() => _LableChartState();
}

class _LableChartState extends State<LableChart> {
  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);
  final ValueNotifier<Size?> longestText = ValueNotifier<Size?>(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: longestText,
        builder: (context, longest, child) {
          return Container(
            width: 40,
            height: (longest?.width ?? 0) * cos(pi / 2 - pi / 6) + 20,
            decoration: XAxesDecoration(
              leftAxesSize: widget.leftAxesSize,
              rightAxesSize: widget.rightAxesSize,
              cstr: widget.cstr,
              onUpdate: (shouldShow) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  isVisible.value = shouldShow;
                });
              },
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Transform.translate(
              offset: const Offset(-40 / 2, 8),
              child: Transform.rotate(
                angle: -pi / 6,
                alignment: Alignment.topRight,
                child: OverflowBox(
                  alignment: Alignment.topRight,
                  maxWidth: double.infinity,
                  child: ValueListenableBuilder<bool>(
                      valueListenable: isVisible,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value ? 1 : 0,
                          child: NotificationListener<SizeReporterNotification>(
                            onNotification: (notification) {
                              if (longest == null) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  longestText.value = notification.size;
                                });
                              }
                              if (longest != null && notification.size.width > longest.width) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  longestText.value = notification.size;
                                });
                              }

                              return true;
                            },
                            child: SizeReporter(
                              child: Text(
                                widget.labelText,
                                textAlign: TextAlign.end,
                                style: const TextStyle(height: 1, color: barTextColor, fontSize: 11),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          );
        });
  }
}

class QuizChart extends StatefulWidget {
  final List<QuizChartData> data;
  final double leftAxesPadding;
  final double rightAxesPadding;
  final int leftTickCount;
  final int rightTickCount;
  final int gridLineCount;

  const QuizChart({
    super.key,
    required this.data,
    this.leftAxesPadding = 16,
    this.rightAxesPadding = 16,
    this.leftTickCount = 5,
    this.rightTickCount = 10,
    this.gridLineCount = 10,
  });

  @override
  State<QuizChart> createState() => _QuizChartState();
}

class _QuizChartState extends State<QuizChart> {
  Size? _leftAxesSize;
  Size? _rightAxesSize;
  late ScrollController _chartBarSC;
  late ScrollController _chartLabelSC;

  @override
  void initState() {
    _chartBarSC = ScrollController();
    _chartLabelSC = ScrollController();
    _chartBarSC.addListener(() {
      _chartLabelSC.jumpTo(_chartBarSC.offset);
    });
    super.initState();
  }

  @override
  void dispose() {
    _chartBarSC.dispose();
    _chartLabelSC.dispose();
    super.dispose();
  }

  Widget chartBuild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              NotificationListener<SizeReporterNotification>(
                onNotification: (notify) {
                  if (_leftAxesSize?.width != notify.size.width) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _leftAxesSize = notify.size;
                      });
                    });
                  }

                  return true;
                },
                child: SizeReporter(
                  child: Container(
                    padding: EdgeInsets.only(left: widget.leftAxesPadding),
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: secondBorderColor)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(widget.leftTickCount, (idx) {
                            final value = ((1 - idx / widget.leftTickCount) * 100).round();
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: idx != widget.leftTickCount - 1
                                    ? Text('$value%', style: const TextStyle(color: barTextColor, height: -0.01, fontSize: 11))
                                    : Stack(
                                        children: [
                                          Text('$value%', style: const TextStyle(color: barTextColor, height: -0.01, fontSize: 11)),
                                          const Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Text('0%', style: TextStyle(color: barTextColor, height: -0.01, fontSize: 11)),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          }),
                        ),
                        Column(
                          children: List.generate(widget.leftTickCount, (idx) {
                            return Expanded(
                              child: Container(
                                width: 8,
                                decoration: BoxDecoration(
                                  border: idx != widget.leftTickCount - 1
                                      ? const Border(top: BorderSide(color: secondBorderColor))
                                      : const Border(
                                          top: BorderSide(color: secondBorderColor),
                                          bottom: BorderSide(color: secondBorderColor),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: List.generate(widget.gridLineCount, (idx) {
                        return Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: firstBorderColor)),
                            ),
                          ),
                        );
                      }),
                    ),
                    ClipPath(
                      clipBehavior: Clip.hardEdge,
                      clipper: ChartClipper(),
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        physics: const ScrollPhysics(parent: ClampingScrollPhysics()),
                        controller: _chartBarSC,
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: secondBorderColor)),
                          ),
                          child: Stack(
                            children: [
                              Row(
                                children: List.generate(widget.data.length, (i) {
                                  final firstStack = ((widget.data[i].group![0].toY! - widget.data[i].group![0].fromY!) * 100).round();
                                  final secondStack = ((widget.data[i].group![1].toY! - widget.data[i].group![1].fromY!) * 100).round();
                                  return Container(
                                    width: 40,
                                    height: double.infinity,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      children: [
                                        secondStack != 0
                                            ? Expanded(
                                                flex: secondStack,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  color: secondChartColor,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    widget.data[i].group![1].x!,
                                                    style: const TextStyle(fontSize: 10, color: barTextColor, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        firstStack != 0
                                            ? Expanded(
                                                flex: firstStack,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  color: mainChartColor,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    widget.data[i].group![0].x!,
                                                    style: const TextStyle(fontSize: 10, color: barTextColor, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              Positioned.fill(child: CustomPaint(painter: ChartLinePainter(data: widget.data))),
                              Positioned.fill(
                                child: Row(
                                  children: List.generate(widget.data.length, (i) {
                                    final firstStack = ((widget.data[i].group![0].toY! - widget.data[i].group![0].fromY!) * 100).round();
                                    final secondStack = ((widget.data[i].group![1].toY! - widget.data[i].group![1].fromY!) * 100).round();
                                    return Container(
                                      width: 40,
                                      height: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      child: LayoutBuilder(builder: (_, constraints) {
                                        return PointWithTooltip(
                                          secondStack: secondStack,
                                          firstStack: firstStack,
                                          constraints: constraints,
                                          data: widget.data[i],
                                        );
                                      }),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              NotificationListener<SizeReporterNotification>(
                onNotification: (notify) {
                  if (_rightAxesSize?.width != notify.size.width) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _rightAxesSize = notify.size;
                      });
                    });
                  }

                  return true;
                },
                child: SizeReporter(
                  child: Container(
                    padding: EdgeInsets.only(right: widget.rightAxesPadding),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: secondBorderColor)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: List.generate(widget.rightTickCount, (idx) {
                            return Expanded(
                              child: Container(
                                width: 8,
                                decoration: BoxDecoration(
                                  border: idx != widget.rightTickCount - 1
                                      ? const Border(top: BorderSide(color: secondBorderColor))
                                      : const Border(
                                          top: BorderSide(color: secondBorderColor),
                                          bottom: BorderSide(color: secondBorderColor),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(widget.rightTickCount, (idx) {
                            final value = ((1 - idx / widget.rightTickCount) * 100).round();
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: idx != widget.rightTickCount - 1
                                    ? Text('$value', style: const TextStyle(color: barTextColor, height: -0.01, fontSize: 11))
                                    : Stack(
                                        children: [
                                          Text('$value', style: const TextStyle(color: barTextColor, height: -0.01, fontSize: 11)),
                                          const Positioned(
                                            left: 0,
                                            bottom: 0,
                                            child: Text('0', style: TextStyle(color: barTextColor, height: -0.01, fontSize: 11)),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(builder: (_, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(left: _leftAxesSize?.width ?? 0, right: _rightAxesSize?.width ?? 0),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            controller: _chartLabelSC,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.data.length, (idx) {
                return _leftAxesSize != null && _rightAxesSize != null
                    ? LableChart(
                        labelText: widget.data[idx].x!,
                        leftAxesSize: _leftAxesSize!,
                        rightAxesSize: _rightAxesSize!,
                        cstr: constraints,
                      )
                    : const SizedBox();
              }),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return chartBuild(context);
  }
}

class PointWithTooltip extends StatefulWidget {
  const PointWithTooltip({
    super.key,
    required this.secondStack,
    required this.firstStack,
    required this.constraints,
    required this.data,
  });

  final int secondStack;
  final int firstStack;
  final QuizChartData data;
  final BoxConstraints constraints;

  @override
  State<PointWithTooltip> createState() => _PointWithTooltipState();
}

class _PointWithTooltipState extends State<PointWithTooltip> {
  final ValueNotifier<Size?> tooltipSize = ValueNotifier<Size?>(null);
  final ValueNotifier<Size?> hiddenLableSize = ValueNotifier<Size?>(null);
  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              widget.secondStack != 0
                  ? Expanded(
                      flex: widget.secondStack,
                      child: const SizedBox(),
                    )
                  : const SizedBox(),
              widget.firstStack != 0
                  ? Expanded(
                      flex: widget.firstStack,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          isVisible.value = !isVisible.value;
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            SizedBox(
                              width: widget.constraints.maxWidth,
                            ),
                            Positioned(
                              top: -8,
                              right: 0,
                              left: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: pointLineColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            ValueListenableBuilder<Size?>(
                                valueListenable: tooltipSize,
                                builder: (context, value, child) {
                                  final firstStackHeight = widget.firstStack / 100 * widget.constraints.maxHeight;
                                  return AnimatedPositioned(
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.easeInOut,
                                    top: value != null && firstStackHeight + value.height + 16 < widget.constraints.maxHeight ? -value.height - 16 : 16,
                                    child: NotificationListener<SizeReporterNotification>(
                                      onNotification: (notification) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          tooltipSize.value = notification.size;
                                        });
                                        return true;
                                      },
                                      child: SizeReporter(
                                        child: ValueListenableBuilder<bool>(
                                            valueListenable: isVisible,
                                            builder: (context, value, child) {
                                              return AnimatedOpacity(
                                                duration: const Duration(milliseconds: 100),
                                                curve: Curves.easeInOut,
                                                opacity: value ? 1 : 0,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 16,
                                                  ),
                                                  decoration: const BoxDecoration(
                                                    color: pointLineColor,
                                                    borderRadius: BorderRadius.all(Radius.circular(2)),
                                                  ),
                                                  child: Text(
                                                    '${widget.firstStack}%',
                                                    style: const TextStyle(fontSize: 10, color: barTextColor, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          Positioned(
            child: NotificationListener<SizeReporterNotification>(
              onNotification: (notification) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  hiddenLableSize.value = notification.size;
                });
                return true;
              },
              child: SizeReporter(
                child: ValueListenableBuilder(
                    valueListenable: hiddenLableSize,
                    builder: (context, size, child) {
                      final secondStackHeight = widget.secondStack / 100 * widget.constraints.maxHeight;
                      return Opacity(
                        opacity: size != null && secondStackHeight != 0 && size.height >= secondStackHeight ? 1 : 0,
                        child: Container(
                          width: widget.constraints.maxWidth - 4,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                            color: secondChartColor,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                            boxShadow: [
                              BoxShadow(color: Color(0x33333333), blurRadius: 1),
                            ],
                          ),
                          child: Text(
                            "${widget.data.group![1].x}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, color: barTextColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
