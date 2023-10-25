import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doc Cam"),
      ),
      body: Stack(
        children: [
          const Center(
            child: Column(
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
              ],
            ),
          ),
          Positioned(
              left: 100,
              top: 100,
              child: Container(
                width: 738 / 2,
                height: 524 / 2,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  shadows: [
                    const BoxShadow(
                      color: Color(0x2B000000),
                      blurRadius: 8,
                      offset: Offset(15, 15),
                      spreadRadius: -5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //<------------------------------------------------<Row 1>---------------------->
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'Camera 1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          const Spacer(),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const ShapeDecoration(
                              color: Color(0xFF656565),
                              shape: OvalBorder(),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //<------------------------------------------------<Row 2>---------------------->
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            // width: 661 / 2,
                            // height: 382 / 2,
                          margin: EdgeInsets.symmetric(horizontal: 20),

                            decoration: ShapeDecoration(
                              color: const Color(0xFFD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 25,
                            bottom: 5,
                            child:   Container(
                            width: 30,
                            height: 30,
                            decoration: const ShapeDecoration(
                              color: Color(0xFF656565),
                              shape: OvalBorder(),
                            ),
                            child: const Icon(
                              Icons.fullscreen_sharp,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),)
                        ],
                      ),
                    ),
                    //<------------------------------------------------<Row 3>---------------------->
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.flip,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.rotate_left,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 40,
                            child: VerticalDivider(
                              color: Colors.white,
                              width: 5,
                              thickness: 1,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ),
                          Icon(
                            Icons.severe_cold,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.camera_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 40,
                            child: VerticalDivider(
                              color: Colors.white,
                              width: 5,
                              thickness: 1,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ),
                          Icon(
                            Icons.brightness_6_outlined,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
