import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'H4Pay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
              onPressed: () {
                print('Pressed Home');
              },
              child: Text(
                'OPEN',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(height: 160.0),
              items: [1, 2, 3, 4, 5].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Center(
                            child: Text(
                          'Advertisement $i',
                          style: TextStyle(fontSize: 16.0),
                        )));
                  },
                );
              }).toList(),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: List.generate(50, (index) {
                if (index % 2 == 0)
                  return Container(
                    margin: EdgeInsets.fromLTRB(22, 12, 18, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1a000000),
                          offset: Offset(0.0, 3.0),
                          blurRadius: 6.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Item $index',
                      ),
                    ),
                  );
                else
                  return Container(
                    margin: EdgeInsets.fromLTRB(0, 12, 22, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1a000000),
                          offset: Offset(0.0, 3.0),
                          blurRadius: 6.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Item $index',
                      ),
                    ),
                  );
              }),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Stack(children: [
                  CustomPaint(
                    size: Size(
                        MediaQuery.of(context).size.width,
                        (MediaQuery.of(context).size.width * 0.15)
                            .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                    painter: RPSCustomPainter(),
                  ),
                  Center(
                    heightFactor: 1.05,
                    child: Container(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.home),
                        color: Color(0xff00C2F7),
                      ),
                    ),
                  )
                ]),
                /* child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color(0x1a000000),
              offset: Offset(0.0, 3.0),
              blurRadius: 6.0,
              spreadRadius: 1.0,
            )
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: 40), // The dum
              ],
            ),
          ),
        ), */
              ),
            )
          ],
        ),
      ),
      //bottomNavigationBar:
      /* BottomNavigationBar(
        
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "지원"),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "선물"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "장바구니"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: "마이페이지")
        ],
        currentIndex: 2,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.white,
      ), */
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Color.fromARGB(255, 40, 190, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.4287500, 0);
    path_0.cubicTo(
        size.width * 0.4297750,
        size.height * -0.0030833,
        size.width * 0.4436875,
        size.height * 0.0486667,
        size.width * 0.4436375,
        size.height * 0.1254167);
    path_0.cubicTo(
        size.width * 0.4434500,
        size.height * 0.2658333,
        size.width * 0.4289750,
        size.height * 0.3298333,
        size.width * 0.4287500,
        size.height * 0.5000000);
    path_0.cubicTo(
        size.width * 0.4290125,
        size.height * 0.7301667,
        size.width * 0.4544125,
        size.height * 0.9759167,
        size.width * 0.5000000,
        size.height * 0.9833333);
    path_0.cubicTo(
        size.width * 0.5407625,
        size.height * 0.9693333,
        size.width * 0.5715000,
        size.height * 0.7646667,
        size.width * 0.5712500,
        size.height * 0.5000000);
    path_0.cubicTo(
        size.width * 0.5722000,
        size.height * 0.3235000,
        size.width * 0.5567875,
        size.height * 0.2644167,
        size.width * 0.5561875,
        size.height * 0.1229167);
    path_0.quadraticBezierTo(size.width * 0.5558500, size.height * 0.0512500,
        size.width * 0.5712500, 0);
    path_0.lineTo(size.width, 0);
    path_0.lineTo(size.width, size.height);
    path_0.lineTo(0, size.height);
    path_0.lineTo(0, 0);
    path_0.quadraticBezierTo(
        size.width * 0.1071875, 0, size.width * 0.4287500, 0);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
