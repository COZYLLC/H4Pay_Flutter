import 'package:animated_check/animated_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SuccessAnimation extends StatefulWidget {
  @override
  SuccessAnimationState createState() => SuccessAnimationState();
}

class SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = new Tween<double>(begin: 0, end: 1).animate(
      new CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _animationController!.forward();
    return AnimatedCheck(progress: _animation!, size: 200);
  }
}

class SuccessPage extends StatelessWidget {
  final bool canGoBack;
  final String successText;
  final String title;
  final List<Widget> bottomDescription;
  final List<Widget> actions;

  const SuccessPage(
      {Key? key,
      required this.canGoBack,
      required this.successText,
      required this.title,
      required this.bottomDescription,
      required this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              title,
            ),
            automaticallyImplyLeading: canGoBack,
          ),
          body: Container(
            padding: EdgeInsets.all(30),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.2),
                  child: SuccessAnimation(),
                ),
                Spacer(
                  flex: 1,
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        successText,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      ...bottomDescription
                    ],
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                ...actions
              ],
            ),
          ),
        ),
        onWillPop: () async {
          return canGoBack;
        });
  }
}
