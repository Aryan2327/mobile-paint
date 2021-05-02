import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  List<PaintPoint> points = [];
  Color selectedColor;

  @override
  void initState(){
    super.initState();
    selectedColor = Colors.black;
  }

  void selectColor(){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Color Picker"),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color){
              this.setState(() {
                selectedColor = color;
              });
            },
          )
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close")
          )
        ]
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(51, 102, 204, 1.0),
                            Color.fromRGBO(0, 204, 0, 1.0),
                          ]
                      )
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: width*0.8,
                      height: height*0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                            color:Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0
                          )
                        ]
                      ),
                      child: GestureDetector(
                        onPanDown: (details){
                          this.setState(() {
                            points.add(PaintPoint(
                              details.localPosition,
                              Paint()
                                ..isAntiAlias = true
                                ..strokeCap = StrokeCap.round
                                ..color = selectedColor
                                ..strokeWidth = 2.0
                            ));
                          });
                        },
                        onPanUpdate: (details){
                          this.setState(() {
                            points.add(PaintPoint(
                                details.localPosition,
                                Paint()
                                  ..isAntiAlias = true
                                  ..strokeCap = StrokeCap.round
                                  ..color = selectedColor
                                  ..strokeWidth = 2.0
                            ));
                          });
                        },
                        onPanEnd: (details){
                          this.setState(() {
                            points.add(PaintPoint(null, Paint()));
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: CustomPaint(
                            painter: Painter(points),
                          )
                        )
                      ),
                    ),
                    SizedBox(
                      height: 10
                    ),
                    Container(
                      width: width*0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Row(
                        children: <Widget>[
                          IconButton(icon: Icon(Icons.color_lens, color: selectedColor), onPressed: (){
                            selectColor();
                          }),
                          IconButton(icon: Icon(Icons.layers_clear), onPressed: (){
                            this.setState(() {
                              points.clear();
                            });
                          }),
                        ],
                      )
                    )
                  ]
                ),
              )
            ]
        )
    );
  }
}

class Painter extends CustomPainter{

  List<PaintPoint> points;

  Painter(points){
    this.points = points;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint bground = Paint()..color = Colors.white;  // same as bground.color = Colors.white;
    Rect area = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(area, bground);

    for (int i = 0; i < points.length-1; i++){
      Paint paint = points[i].paint;
      if (points[i].point != null && points[i+1].point != null){
        canvas.drawLine(points[i].point, points[i+1].point, paint);
      }
      else if (points[i].point != null && points[i+1].point == null) {
        canvas.drawPoints(PointMode.points, [points[i].point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    //throw UnimplementedError();
    return true;
  }
  
}

class PaintPoint { // Essentially make a paint object corresponding to each offset
  Paint paint;
  Offset point;

  PaintPoint(point, paint){
    this.paint = paint;
    this.point = point;
  }
}
