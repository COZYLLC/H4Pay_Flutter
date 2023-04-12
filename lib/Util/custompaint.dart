import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.shader = ui.Gradient.linear(
        Offset(size.width * -0.5380000, size.height * 0.5000000),
        Offset(size.width, size.height * 0.5000000),
        [Color(0xffd4ffe5).withOpacity(1), Color(0xfffbfffd).withOpacity(1)],
        [0, 1]);
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * -0.005380000, 0, size.width * 1.005380, size.height),
        paint_0_fill);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.08653000, size.height * 0.2006600),
        Offset(size.width * 0.3393000, size.height * 0.2006600), [
      Color(0xffffffff).withOpacity(1),
      Color(0xfffafffc).withOpacity(1),
      Color(0xffeafff2).withOpacity(1),
      Color(0xffd0ffe3).withOpacity(1),
      Color(0xffd0ffe3).withOpacity(1)
    ], [
      0,
      0.27,
      0.62,
      1,
      1
    ]);
    canvas.drawCircle(Offset(size.width * 0.2129100, size.height * 0.2006600),
        size.width * 0.1263800, paint_1_fill);

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.shader = ui.Gradient.linear(
        Offset(size.width * 5.977800, size.height * 3.446600),
        Offset(size.width * 9.761600, size.height * 3.446600), [
      Color(0xffffffff).withOpacity(1),
      Color(0xfffafffc).withOpacity(1),
      Color(0xffeafff2).withOpacity(1),
      Color(0xffd0ffe3).withOpacity(1),
      Color(0xffd0ffe3).withOpacity(1)
    ], [
      0,
      0.27,
      0.62,
      1,
      1
    ]);
    canvas.drawCircle(Offset(size.width * 0.7869700, size.height * 0.3446600),
        size.width * 0.1891900, paint_2_fill);

    Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
    paint_3_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.3399700, size.height * 0.3002300),
        Offset(size.width * 0.6785200, size.height * 0.3002300), [
      Color(0xffb66712).withOpacity(1),
      Color(0xffb16311).withOpacity(1),
      Color(0xffa1590e).withOpacity(1),
      Color(0xff87470a).withOpacity(1),
      Color(0xff632f04).withOpacity(1),
      Color(0xff4f2200).withOpacity(1)
    ], [
      0,
      0.17,
      0.38,
      0.62,
      0.88,
      1
    ]);
    canvas.drawCircle(Offset(size.width * 0.5092500, size.height * 0.3002300),
        size.width * 0.1692800, paint_3_fill);

    Paint paint_4_fill = Paint()..style = PaintingStyle.fill;
    paint_4_fill.shader = ui.Gradient.radial(
        Offset(size.width * 4.683900, size.height * 3.815500),
        size.width * 1.866500, [
      Color(0xffb66712).withOpacity(1),
      Color(0xffb16311).withOpacity(1),
      Color(0xffa1590e).withOpacity(1),
      Color(0xff87470a).withOpacity(1),
      Color(0xff632f04).withOpacity(1),
      Color(0xff4f2200).withOpacity(1)
    ], [
      0,
      0.17,
      0.38,
      0.62,
      0.88,
      1
    ]);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.3399700, size.height * 0.2757200,
                size.width * 0.3385500, size.height * 0.2627200),
            bottomRight: Radius.circular(size.width * 0.05247000),
            bottomLeft: Radius.circular(size.width * 0.05247000),
            topLeft: Radius.circular(size.width * 0.05247000),
            topRight: Radius.circular(size.width * 0.05247000)),
        paint_4_fill);

    Path path_5 = Path();
    path_5.moveTo(size.width * 0.5092500, size.height * 0.5167500);
    path_5.cubicTo(
        size.width * 0.4260600,
        size.height * 0.5167500,
        size.width * 0.3540000,
        size.height * 0.5888300,
        size.width * 0.3187400,
        size.height * 0.6940000);
    path_5.cubicTo(
        size.width * 0.3612800,
        size.height * 0.7442200,
        size.width * 0.4345800,
        size.height * 0.7774000,
        size.width * 0.5178900,
        size.height * 0.7774000);
    path_5.cubicTo(
        size.width * 0.5932900,
        size.height * 0.7774000,
        size.width * 0.6604900,
        size.height * 0.7502200,
        size.width * 0.7041200,
        size.height * 0.7078300);
    path_5.cubicTo(
        size.width * 0.6707000,
        size.height * 0.5952000,
        size.width * 0.5960000,
        size.height * 0.5167500,
        size.width * 0.5092500,
        size.height * 0.5167500);
    path_5.close();

    Paint paint_5_fill = Paint()..style = PaintingStyle.fill;
    paint_5_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.3187400, size.height * 0.6470800),
        Offset(size.width * 0.7041200, size.height * 0.6470800), [
      Color(0xffffdabf).withOpacity(1),
      Color(0xfffed5bb).withOpacity(1),
      Color(0xfffdc5ae).withOpacity(1),
      Color(0xfffbab99).withOpacity(1),
      Color(0xfffaa594).withOpacity(1)
    ], [
      0,
      0.25,
      0.57,
      0.93,
      1
    ]);
    canvas.drawPath(path_5, paint_5_fill);

    Paint paint_6_fill = Paint()..style = PaintingStyle.fill;
    paint_6_fill.shader = ui.Gradient.linear(
        Offset(size.width * 4.741800, size.height * 4.970500),
        Offset(size.width * 5.443100, size.height * 4.970500), [
      Color(0xffffdabf).withOpacity(1),
      Color(0xfffed5bb).withOpacity(1),
      Color(0xfffdc5ae).withOpacity(1),
      Color(0xfffbab99).withOpacity(1),
      Color(0xfffaa594).withOpacity(1)
    ], [
      0,
      0.25,
      0.57,
      0.93,
      1
    ]);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.4741800, size.height * 0.4597300,
                size.width * 0.07014000, size.height * 0.07463000),
            bottomRight: Radius.circular(size.width * 0.01664000),
            bottomLeft: Radius.circular(size.width * 0.01664000),
            topLeft: Radius.circular(size.width * 0.01664000),
            topRight: Radius.circular(size.width * 0.01664000)),
        paint_6_fill);

    Path path_7 = Path();
    path_7.moveTo(size.width * 0.5966400, size.height * 0.5450000);
    path_7.cubicTo(
        size.width * 0.5777200,
        size.height * 0.5663000,
        size.width * 0.5456400,
        size.height * 0.5803100,
        size.width * 0.5092500,
        size.height * 0.5803100);
    path_7.cubicTo(
        size.width * 0.4728600,
        size.height * 0.5803100,
        size.width * 0.4407700,
        size.height * 0.5663100,
        size.width * 0.4218500,
        size.height * 0.5450000);
    path_7.cubicTo(
        size.width * 0.3772700,
        size.height * 0.5753500,
        size.width * 0.3408000,
        size.height * 0.6281900,
        size.width * 0.3187300,
        size.height * 0.6940000);
    path_7.cubicTo(
        size.width * 0.3612800,
        size.height * 0.7442300,
        size.width * 0.4345800,
        size.height * 0.7774100,
        size.width * 0.5178900,
        size.height * 0.7774100);
    path_7.cubicTo(
        size.width * 0.5933000,
        size.height * 0.7774100,
        size.width * 0.6605000,
        size.height * 0.7502300,
        size.width * 0.7041200,
        size.height * 0.7078300);
    path_7.cubicTo(
        size.width * 0.6827000,
        size.height * 0.6356200,
        size.width * 0.6443100,
        size.height * 0.5774600,
        size.width * 0.5966400,
        size.height * 0.5450000);
    path_7.close();

    Paint paint_7_fill = Paint()..style = PaintingStyle.fill;
    paint_7_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.3187300, size.height * 0.6612200),
        Offset(size.width * 0.7041200, size.height * 0.6612200), [
      Color(0xff29abe2).withOpacity(1),
      Color(0xff2ba6e3).withOpacity(1),
      Color(0xff3296e7).withOpacity(1),
      Color(0xff3e7cee).withOpacity(1),
      Color(0xff4e58f6).withOpacity(1),
      Color(0xff5d35ff).withOpacity(1)
    ], [
      0,
      0.16,
      0.35,
      0.57,
      0.81,
      1
    ]);
    canvas.drawPath(path_7, paint_7_fill);

    Paint paint_8_fill = Paint()..style = PaintingStyle.fill;
    paint_8_fill.shader = ui.Gradient.radial(
        Offset(size.width * 0.4857600, size.height * 0.3467000),
        size.width * 0.1377900, [
      Color(0xfffff0e5).withOpacity(1),
      Color(0xffffdabf).withOpacity(1),
      Color(0xfffed5bb).withOpacity(1),
      Color(0xfffdc5ae).withOpacity(1),
      Color(0xfffbab99).withOpacity(1),
      Color(0xfffaa594).withOpacity(1)
    ], [
      0,
      0.48,
      0.61,
      0.78,
      0.96,
      1
    ]);
    canvas.drawCircle(Offset(size.width * 0.5092500, size.height * 0.3446600),
        size.width * 0.1371100, paint_8_fill);

    Paint paint_9_fill = Paint()..style = PaintingStyle.fill;
    paint_9_fill.shader = ui.Gradient.linear(
        Offset(size.width * 4.995000, size.height * 2.150500),
        Offset(size.width * 6.321500, size.height * 2.150500), [
      Color(0xffb66712).withOpacity(1),
      Color(0xffb16311).withOpacity(1),
      Color(0xffa1590e).withOpacity(1),
      Color(0xff87470a).withOpacity(1),
      Color(0xff632f04).withOpacity(1),
      Color(0xff4f2200).withOpacity(1)
    ], [
      0,
      0.17,
      0.38,
      0.62,
      0.88,
      1
    ]);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.4972700, size.height * 0.1533000,
                size.width * 0.1371000, size.height * 0.1234900),
            bottomRight: Radius.circular(size.width * 0.06175000),
            bottomLeft: Radius.circular(size.width * 0.06175000),
            topLeft: Radius.circular(size.width * 0.06175000),
            topRight: Radius.circular(size.width * 0.06175000)),
        paint_9_fill);

    Paint paint_10_fill = Paint()..style = PaintingStyle.fill;
    paint_10_fill.shader = ui.Gradient.linear(
        Offset(size.width * 3.923600, size.height * 2.150500),
        Offset(size.width * 5.259200, size.height * 2.150500), [
      Color(0xffb66712).withOpacity(1),
      Color(0xffb16311).withOpacity(1),
      Color(0xffa1590e).withOpacity(1),
      Color(0xff87470a).withOpacity(1),
      Color(0xff632f04).withOpacity(1),
      Color(0xff4f2200).withOpacity(1)
    ], [
      0,
      0.17,
      0.38,
      0.62,
      0.88,
      1
    ]);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.3905900, size.height * 0.1533000,
                size.width * 0.1371000, size.height * 0.1234900),
            bottomRight: Radius.circular(size.width * 0.06175000),
            bottomLeft: Radius.circular(size.width * 0.06175000),
            topLeft: Radius.circular(size.width * 0.06175000),
            topRight: Radius.circular(size.width * 0.06175000)),
        paint_10_fill);

    Path path_11 = Path();
    path_11.moveTo(size.width * 0.4777500, size.height * 0.4584200);
    path_11.lineTo(size.width * 0.4264500, size.height * 0.4584200);
    path_11.arcToPoint(Offset(size.width * 0.3668400, size.height * 0.3988100),
        radius: Radius.elliptical(
            size.width * 0.05961000, size.height * 0.05961000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_11.lineTo(size.width * 0.3668400, size.height * 0.3701900);
    path_11.lineTo(size.width * 0.3560500, size.height * 0.3701900);
    path_11.lineTo(size.width * 0.3560500, size.height * 0.4040700);
    path_11.arcToPoint(Offset(size.width * 0.4215000, size.height * 0.4695100),
        radius: Radius.elliptical(
            size.width * 0.06544000, size.height * 0.06544000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_11.lineTo(size.width * 0.4777500, size.height * 0.4695100);
    path_11.close();

    Paint paint_11_fill = Paint()..style = PaintingStyle.fill;
    paint_11_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.3560500, size.height * 0.4198500),
        Offset(size.width * 0.4777500, size.height * 0.4198500), [
      Color(0xff999999).withOpacity(1),
      Color(0xff646464).withOpacity(1),
      Color(0xff4d4d4d).withOpacity(1)
    ], [
      0,
      0.54,
      0.82
    ]);
    canvas.drawPath(path_11, paint_11_fill);

    Path path_12 = Path();
    path_12.moveTo(size.width * 0.3605400, size.height * 0.3120600);
    path_12.arcToPoint(Offset(size.width * 0.6579500, size.height * 0.3120600),
        radius:
            Radius.elliptical(size.width * 0.1487100, size.height * 0.1487100),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_12.lineTo(size.width * 0.6704800, size.height * 0.3120600);
    path_12.arcToPoint(Offset(size.width * 0.3480100, size.height * 0.3120600),
        radius:
            Radius.elliptical(size.width * 0.1612400, size.height * 0.1612400),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_12.close();

    Paint paint_12_fill = Paint()..style = PaintingStyle.fill;
    paint_12_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.3480100, size.height * 0.2314400),
        Offset(size.width * 0.6704800, size.height * 0.2314400), [
      Color(0xff999999).withOpacity(1),
      Color(0xff969696).withOpacity(1),
      Color(0xff8c8c8c).withOpacity(1),
      Color(0xff7a7a7a).withOpacity(1),
      Color(0xff626262).withOpacity(1),
      Color(0xff4d4d4d).withOpacity(1)
    ], [
      0,
      0.26,
      0.48,
      0.68,
      0.87,
      1
    ]);
    canvas.drawPath(path_12, paint_12_fill);

    Paint paint_13_fill = Paint()..style = PaintingStyle.fill;
    paint_13_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.3130500, size.height * 0.3198300),
        Offset(size.width * 0.3996200, size.height * 0.3698100), [
      Color(0xff999999).withOpacity(1),
      Color(0xff949494).withOpacity(1),
      Color(0xff848484).withOpacity(1),
      Color(0xff6a6a6a).withOpacity(1),
      Color(0xff4d4d4d).withOpacity(1)
    ], [
      0,
      0.2,
      0.46,
      0.75,
      1
    ]);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.3257700, size.height * 0.2809900,
                size.width * 0.06058000, size.height * 0.1273500),
            bottomRight: Radius.circular(size.width * 0.02298000),
            bottomLeft: Radius.circular(size.width * 0.02298000),
            topLeft: Radius.circular(size.width * 0.02298000),
            topRight: Radius.circular(size.width * 0.02298000)),
        paint_13_fill);

    Paint paint_14_fill = Paint()..style = PaintingStyle.fill;
    paint_14_fill.shader = ui.Gradient.linear(
        Offset(size.width * 6.194300, size.height * 3.198300),
        Offset(size.width * 7.054400, size.height * 3.694900), [
      Color(0xff999999).withOpacity(1),
      Color(0xff949494).withOpacity(1),
      Color(0xff848484).withOpacity(1),
      Color(0xff6a6a6a).withOpacity(1),
      Color(0xff4d4d4d).withOpacity(1)
    ], [
      0,
      0.2,
      0.46,
      0.75,
      1
    ]);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.6321500, size.height * 0.2809900,
                size.width * 0.06058000, size.height * 0.1273500),
            bottomRight: Radius.circular(size.width * 0.02298000),
            bottomLeft: Radius.circular(size.width * 0.02298000),
            topLeft: Radius.circular(size.width * 0.02298000),
            topRight: Radius.circular(size.width * 0.02298000)),
        paint_14_fill);

    Paint paint_15_fill = Paint()..style = PaintingStyle.fill;
    paint_15_fill.shader = ui.Gradient.radial(
        Offset(size.width * 4.993700, size.height * 4.576800),
        size.width * 0.3665000, [
      Color(0xff999999).withOpacity(1),
      Color(0xff949494).withOpacity(1),
      Color(0xff848484).withOpacity(1),
      Color(0xff6a6a6a).withOpacity(1),
      Color(0xff4d4d4d).withOpacity(1)
    ], [
      0,
      0.2,
      0.46,
      0.75,
      1
    ]);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.4748700, size.height * 0.4424500,
                size.width * 0.06875000, size.height * 0.03932000),
            bottomRight: Radius.circular(size.width * 0.01532000),
            bottomLeft: Radius.circular(size.width * 0.01532000),
            topLeft: Radius.circular(size.width * 0.01532000),
            topRight: Radius.circular(size.width * 0.01532000)),
        paint_15_fill);

    Paint paint_16_fill = Paint()..style = PaintingStyle.fill;
    paint_16_fill.shader = ui.Gradient.linear(
        Offset(size.width * -4.127000, size.height * 0.7919800),
        Offset(size.width * 0.3399700, size.height * 0.7919800), [
      Color(0xffffffff).withOpacity(1),
      Color(0xffb8ffe4).withOpacity(1),
      Color(0xffd0ffe3).withOpacity(1)
    ], [
      0,
      1,
      1
    ]);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.1493500, size.height * 0.7919800),
            width: size.width * 0.3812400,
            height: size.height * 0.3690800),
        paint_16_fill);

    Paint paint_17_fill = Paint()..style = PaintingStyle.fill;
    paint_17_fill.shader = ui.Gradient.linear(
        Offset(size.width * 0.6927300, size.height * 0.7471700),
        Offset(size.width * 0.8267700, size.height * 0.7471700), [
      Color(0xffffffff).withOpacity(1),
      Color(0xfffafffc).withOpacity(1),
      Color(0xffeafff5).withOpacity(1),
      Color(0xffd0ffe9).withOpacity(1),
      Color(0xffc2ffe3).withOpacity(1)
    ], [
      0,
      0.23,
      0.53,
      0.85,
      1
    ]);
    canvas.drawCircle(Offset(size.width * 0.7597500, size.height * 0.7471700),
        size.width * 0.06702000, paint_17_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
