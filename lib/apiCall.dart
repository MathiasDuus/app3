import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class callAPI extends StatefulWidget {
  const callAPI({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => callAPIState();
}

class callAPIState extends State<callAPI> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String normalPos = "";
  double long = 0, lat = 0;
  late StreamSubscription<Position> positionStream;
  late StreamSubscription<String> nameStream;
  final ValueNotifier<String> _notify = ValueNotifier<String>("");

  void handleFuture() async {
    String text = await getNormalName();
    _notify.value = text;
    normalPos = text;
  }


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
    long = position.longitude;
    lat = position.latitude;
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
            .listen((Position position) async {
      long = position.longitude;
      lat = position.latitude;
      normalPos = await getNormalName();
      setState(() {
        //refresh UI on update
      });
    });

  }

  Future<String> getNormalName() async {
    var httpResponse = await fetchPOI();
    Map<String, dynamic> jsonData = jsonDecode(httpResponse.body);
    print(jsonData['features'][0]['properties']['name']);
    var lel = jsonData['features'][0]['properties']['name'];
    return lel;
  }

  Future<http.Response> fetchPOI() {
    String url = 'https://api.openrouteservice.org/geocode/reverse?'
        'api_key=5b3ce3597851110001cf6248d758c8e18f31418d804b2b9cf66aa46f'
        '&point.lon=${long.toString()}&point.lat=${lat.toString()}';
    return http.get(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text("☺☻♥♦♣♠"), backgroundColor: Colors.amber),
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            child: Column(children: [
              const Text("Henter location fra openroute services",
                  style: TextStyle(fontSize: 20)),
              Text("Place: $normalPos", style: const TextStyle(fontSize: 20)),
            ])));
  }
}
