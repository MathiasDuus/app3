import 'package:flutter/material.dart';
import 'package:my_app/gps.dart';
import 'package:my_app/qrReader.dart';
import 'package:my_app/apiCall.dart';
import 'package:my_app/takePic.dart';
import 'package:vibration/vibration.dart';

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

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
