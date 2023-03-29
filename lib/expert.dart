import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_compass/utils/src/compass_ui.dart';

class ExpertStuff extends StatefulWidget {
  const ExpertStuff({super.key});

  @override
  ExpertStuffState createState() => ExpertStuffState();
}

class ExpertStuffState extends State<ExpertStuff> {
  // Some qr stuff

  bool paused = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
        } else if (permission == LocationPermission.deniedForever) {
          if (kDebugMode) {
            print("'Location permissions are permanently denied");
          }
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adventure time')),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // children: const [
                //   Text("If compass not loading try pausing qr scanner"),
                // ],
              ),
            ),
            Expanded(
              flex: 2,
              child: SmoothCompass(
                compassBuilder: (context, snapshot, child) {
                  return Column(
                    children: [
                      AnimatedRotation(
                        turns: snapshot?.data?.turns ?? 0,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          height: 250,
                          width: 250,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                    "assets/images/compass.png",
                                  ),
                                  fit: BoxFit.fill)),
                        ),
                      ),

                      // show the current direction
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                            "${snapshot?.data?.angle.toStringAsFixed(2) ?? 0}"),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(flex: 2, child: _buildQrView(context)),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: (result != null)
                          ? Text('${result!.code}')
                          : const Text('Scan a code'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: paused
                                ? null
                                : () async {
                                    await controller?.pauseCamera();
                                    setState(() {
                                      paused = true;
                                    });
                                  },
                            child: const Text('Pause',
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () async {
                              await controller?.resumeCamera();
                              setState(() {
                                paused = false;
                              });
                            },
                            child: const Text('Resume',
                                style: TextStyle(fontSize: 20)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Some more QR Stuff
  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() async {
        result = scanData;
        if (result != null) {
          await this.controller?.pauseCamera();
          sendGpsToAPI();
          setState(() {
            paused = true;
          });
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  Future<http.Response> sendGpsToAPI() async {
    // http.MultipartRequest(‘POST’, Uri.parse(urlToInsertImage));
    String url = 'http://10.130.68.0:8000/api/gps';
    // double lon = result.
    return http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'lon': long,
        'lat': lat,
      }),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
