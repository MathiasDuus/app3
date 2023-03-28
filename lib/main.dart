import 'package:flutter/material.dart';
import 'package:my_app/gps.dart';
import 'package:my_app/qrReader.dart';
import 'package:my_app/apiCall.dart';
import 'package:my_app/takePic.dart';
import 'package:shake/shake.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  bool flashIsOn = false; //to set if flash light is on or off
  @override
  void initState() {
    super.initState();
    ShakeDetector detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        if (flashIsOn) {
          //if light is on, then turn off
          TorchLight.disableTorch();
          setState(() {
            flashIsOn = false;
          });
        } else {
          //if light is off, then turn on.
          TorchLight.enableTorch();
          setState(() {
            flashIsOn = true;
          });
        }
        // Do stuff on phone shake
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('This is my very coll app ☻')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Vibration.vibrate();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRViewExample(),
                ));
              },
              child: const Text('qrView'),
            ),
            ElevatedButton(
              onPressed: () {
                Vibration.vibrate();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GeoLocationService(),
                ));
              },
              child: const Text('gps stuff'),
            ),
            ElevatedButton(
              onPressed: () {
                Vibration.vibrate();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const callAPI(),
                ));
              },
              child: const Text('Calls api'),
            ),
            ElevatedButton(
              onPressed: () {
                Vibration.vibrate();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TakePic(),
                ));
              },
              child: const Text('Prøv at tage et billede good luck'),
            ),

            //all the children widgets that you need
          ],
        ),
      ),
    );
  }
}
