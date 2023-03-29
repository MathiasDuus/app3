
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocationService extends StatefulWidget {
  const GeoLocationService({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GeoLocationServiceState();
}


class GeoLocationServiceState extends State<GeoLocationService> {
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
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
        }else if(permission == LocationPermission.deniedForever){
          if (kDebugMode) {
            print("'Location permissions are permanently denied");
          }
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }

      if(haspermission){
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    }else{
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

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

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: const Text("☺☻☺☻☺☻ GPS ☺☻☺☻☺☻"),
            backgroundColor: Colors.redAccent
        ),
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            child: Column(
                children: [
                  Text("Longitude: $long", style:const TextStyle(fontSize: 20)),
                  Text("Latitude: $lat", style: const TextStyle(fontSize: 20),)
                ]
            )
        )
    );
  }
}
