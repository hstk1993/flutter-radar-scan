import 'dart:math';

import 'package:flutter/material.dart';

import 'img_info_model.dart';
import 'radar_scan_config.dart';
import 'radar_scan_painter.dart';

class RadarScanView extends StatefulWidget {
  RadarScanConfig? config;
  Widget? midWidget;

  ///设置 midWidget 后无效
  VoidCallback? onPressed;

  RadarScanView({Key? key, this.config, this.midWidget, this.onPressed})
      : super(key: key);

  @override
  State<RadarScanView> createState() => _RadarScanViewState();
}

class _RadarScanViewState extends State<RadarScanView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // 雷达配置数据
  late RadarScanConfig _radarScanConfig;
  Size size = const Size(0, 0);

  // 中心图片size
  final double centerImageSize = 60;
  String tmpAngel = "";
  int scanCount = 0;
  List<Widget> imgWidgets = [];

  // 测试数据
  List<ImgPositionModel> avatars = [
    ImgPositionModel(1, 60, 4.0, "assets/3.png"),
    ImgPositionModel(1, 50, 0.8, "assets/1.png"),
    ImgPositionModel(1, 50, 2.2, "assets/2.png"),
    ImgPositionModel(2, 40, 2.8, "assets/2.png"),
    ImgPositionModel(2, 40, 1.0, "assets/3.png"),
    ImgPositionModel(2, 30, 6.0, "assets/1.png"),
    ImgPositionModel(2, 40, 5.4, "assets/3.png"),
    ImgPositionModel(3, 30, 6.2, "assets/2.png"),
    ImgPositionModel(3, 30, 2.5, "assets/3.png"),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.config == null) {
      _radarScanConfig = RadarScanConfig();
    } else {
      _radarScanConfig = widget.config!;
    }

    // 扫描动画
    _controller =
        AnimationController(vsync: this, duration: _radarScanConfig.duration);
    _animation = Tween(begin: 0.0, end: pi * 2).animate(_controller);
    _animation.addListener(() {
      tmpAngel = _animation.value.toStringAsFixed(1);
      if (_animation.value > 2 * pi - 0.1) {
        scanCount++;
      }
      if (scanCount < 1) {
        for (var element in avatars) {
          if (element.angel.toString() == tmpAngel) {
            calculateAvatarsPosition(element);
          }
        }
      }
    });

    _controller.repeat();
  }

  buildAvatarWidget(lx, ly, size, src, animation, animation1) {
    return Positioned(
        left: lx,
        top: ly,
        child: ScaleTransition(
          scale: animation1,
          child: ScaleTransition(
            scale: animation,
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Container(
                width: size,
                height: size,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    color: const Color(0xFF3585FE),
                    borderRadius: BorderRadius.circular(30)),
                child: Image.asset(src),
              ),
            ),
          ),
        ));
  }

  // 计算头像显示的x y坐标点
  calculateAvatarsPosition(ImgPositionModel model) {
    AnimationController controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    final an = CurvedAnimation(parent: controller, curve: Curves.linear);
    Animation<double> animation = Tween(begin: 0.2, end: 1.0).animate(an);
    AnimationController controller1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    final an1 = CurvedAnimation(parent: controller1, curve: Curves.linear);
    Animation<double> animation1 = Tween(begin: 0.7, end: 1.0).animate(an1);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller1.repeat(reverse: true);
      }
    });
    controller.forward(from: 0.0);
    final dWidth = size.width / 2 / 3;
    final radius = dWidth * model.circle;
    final lx = (size.width / 2 - (model.size / 2)) +
        cos(model.angel + _radarScanConfig.sectorAngle - 0.5) * radius;
    final ly = (size.width / 2 - (model.size / 2)) +
        sin(model.angel + _radarScanConfig.sectorAngle - 0.5) * radius;
    imgWidgets.add(buildAvatarWidget(
        lx, ly, model.size, model.src, animation, animation1));
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    // 雷达图 中间图标
    Widget buildMidWidget() {
      return Positioned(
          top: size.width / 2 - (centerImageSize / 2),
          left: size.width / 2 - (centerImageSize / 2),
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              width: centerImageSize,
              height: centerImageSize,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: const Color(0xFF3585FE),
                  borderRadius: BorderRadius.circular(30)),
              child: Image.asset("assets/1.png"),
            ),
          ));
    }

    return Stack(
      children: [
        AnimatedBuilder(
            animation: _animation,
            builder: (ctx, child) {
              return SizedBox(
                width: size.width,
                height: size.width,
                child: CustomPaint(
                  painter: RadarScanPainter(_animation.value,
                      sectorAngle: _radarScanConfig.sectorAngle,
                      showMiddleline: _radarScanConfig.showMiddleline,
                      circleCount: _radarScanConfig.circleCount,
                      circleWidth: _radarScanConfig.circleWidth,
                      scanLineWidth: _radarScanConfig.scanLineWidth,
                      scnaLineColor: _radarScanConfig.scnaLineColor,
                      bgLineWidth: _radarScanConfig.bgLineWidth,
                      bgLineColor: _radarScanConfig.bgLineColor,
                      shaderColors: _radarScanConfig.shaderColors),
                ),
              );
            }),
        buildMidWidget(),
        ...imgWidgets,
        Positioned(
            top: size.width + 80,
            left: 0,
            right: 0,
            child: const Column(
              children: [
                Text(
                  "",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                )
              ],
            ))
      ],
    );
  }
}
