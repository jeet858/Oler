import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oler/widgets/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MapScreen extends StatefulWidget {
  static String id = 'mapscreen';
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(22.694839, 88.379373),
    zoom: 14,
  );
  GoogleMapController _googleMapController;
  List<Marker> markers = [];
  Position pos;
  CameraPosition _newCameraPosition;
  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          Image.asset('asset/images/car.png'),
          TextButton(
            onPressed: () async {
              pos = await _determinePosition();
              _newCameraPosition = CameraPosition(
                target: LatLng(pos.latitude, pos.longitude),
                zoom: 14,
              );

              _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(_newCameraPosition),
              );
              setState(() {
                markers.clear();
                _addMarker(LatLng(pos.latitude, pos.longitude));
              });
            },
            child: const Text(
              'MyLocation',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w900,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
          TextButton(
            onPressed: () => {
              if (markers.isNotEmpty) {_goto(0)},
            },
            child: const Text(
              'Origin',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w900,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
          TextButton(
            onPressed: () => {
              if ((markers.isNotEmpty) && (markers.length == 2)) {_goto(1)}
            },
            child: const Text(
              'Destination',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w900,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
          TextButton(
            onPressed: () => {
              setState(() {
                markers.clear();
              })
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w900,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
        markers: markers.toSet(),
        onLongPress: (LatLng pos) {
          setState(() {
            _addMarker(pos);
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        isExtended: true,
        onPressed: () {
          Alert(
              context: context,
              type: AlertType.error,
              title: "Api Unavailable",
              desc:
                  "🙏🙇‍♂ Due to limited access to Api's and extremely lazy dev group the app couldn't be developed any further",
              style: const AlertStyle(
                backgroundColor: Colors.white,
                alertBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
              )).show();
        },
        child: const Icon(Icons.car_rental),
      ),
    );
  }

  _addMarker(LatLng pos) async {
    if ((markers.isEmpty) || (markers.length == 2)) {
      markers.clear();
      Marker origin = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pos,
      );

      markers.add(origin);
    } else {
      Marker destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: pos,
      );
      markers.add(destination);
    }
  }

  _goto(int num) {
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: markers[num].position,
          zoom: 14.5,
          tilt: 50.0,
        ),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
