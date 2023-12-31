import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:appcomercial/src/config/theme/dark_mode.dart';
import 'package:appcomercial/src/config/utils/data.dart';
import 'package:appcomercial/src/config/utils/map_style.dart';
import 'package:appcomercial/src/config/utils/my_color.dart';
import 'package:appcomercial/src/models/cen_comercial.dart';
import 'package:appcomercial/src/models/comercio.dart';
import 'package:appcomercial/src/models/pasillo.dart';
import 'package:appcomercial/src/models/producto.dart';
import 'package:appcomercial/src/models/punto_ruta.dart';
import 'package:appcomercial/src/screens/map/grafos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController {
  BuildContext? context;
  Function? refresh;
  CameraPosition defaultPosition =
      const CameraPosition(target: LatLng(-17.792714, -63.204901), zoom: 18);
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _position;
  CameraPosition? initialPosition;
  String? addressName;
  LatLng? addressLatLng;
  BitmapDescriptor? destinationMarker;
  BitmapDescriptor? sourceMarker;
  BitmapDescriptor? shopMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Set<Polyline> polylines = {};
  Set<Polygon> polygons = {};
  Set<Point> pointsPass = {};

  List<LatLng> points = [];
  List<LatLng> pointsExtra = [];
  double? distanceBetween;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 1,
  );
  Timer? searchOnStoppedTyping;
  String productName = '';
  List<Point> puntosMatched = [];
  List<Point> allPuntos = [];
  TextEditingController locationCurrent = TextEditingController();
  List<CenComercial> listCC = [];
  List<Comercio> listC = [];
  List<Producto> listP = [];
  List<Pasillo> ListPasillo = [];
  List<Punto> ListPunto = [];

  List<LatLng> polylineCoordinates = [];
  bool ubic = false;
  bool ubicStream = false;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _loadBitmap();
    _loadData();
    _displayPolylines();
    _displayPolygons();
    refresh();
  }

  void actualizarcamarastream(dynamic data) {
    print(
        'Latitud streaM: ${data.latitude}, Longitud estram: ${data.longitude}');
    print({ubicStream});
    animateCameraToPosition(data!.latitude, data!.longitude);
  }

  void updateSource(dynamic data) {
    MarkerId keySource = const MarkerId("source");
    points.add(LatLng(data.latitude, data.longitude));
    if (!markers.containsKey(keySource)) {
      checkGPS(); // there is not source marker
    } else {
      //only update marker id, ex: source_13256, source_231467
      MarkerId oldMarkerId = MarkerId(keySource.toString() +
          (DateTime.now().millisecondsSinceEpoch).toString());
      //add old marker "source "with new id marker
      // addMarker(oldMarkerId.value, markers[keySource]!.position.latitude,
      // markers[keySource]!.position.longitude, markers[keySource]!.infoWindow.title!,
      // markers[keySource]!.infoWindow.snippet!, sourceMarker!);
      markers[oldMarkerId] = Marker(
        markerId: oldMarkerId,
        icon: sourceMarker!,
        position: LatLng(markers[keySource]!.position.latitude,
            markers[keySource]!.position.longitude),
        infoWindow: InfoWindow(
            title: markers[keySource]!.infoWindow.title,
            snippet: markers[keySource]!.infoWindow.snippet),
      );
      //now, remove the marker "source"
      markers.remove(keySource);
      // and then add the new "source" marker
      markers[keySource] = Marker(
        markerId: keySource,
        icon: destinationMarker!,
        position: LatLng(data.latitude, data.longitude),
        infoWindow: const InfoWindow(title: "Guest", snippet: "Mi Ubicacion"),
      );
      print(markers.length.toString() + "cantidad markers");
      initialPosition = CameraPosition(
          target: LatLng(data!.latitude, data!.longitude), zoom: 18);
      // setLocationDraggableInfo();
      animateCameraToPosition(data!.latitude, data!.longitude);

      //ahora trazar la linea
      removePolyline("myRoute");
      addPolyline('myRoute', MyColor.primaryColorDark, points,
          [PatternItem.dash(10), PatternItem.gap(10)], 4);
    }
  }

  /// Clear all markers and of course
  /// it must be clear its points
  void clearMarkers() {
    markers.clear();
    points.clear();
  }

  void clearPolyline() {
    polylines.clear();
  }

  void removePolyline(String idPolyline) {
    polylines.removeWhere((element) => element.polylineId.value == idPolyline);
  }

  void addPolyline(String idPolyline, Color color, List<LatLng> listPoints,
      List<PatternItem> listPatternItem, int width) {
    polylines.add(
      Polyline(
        polylineId: PolylineId(idPolyline),
        color: color,
        points: listPoints,
        patterns: listPatternItem,
        width: width,
      ),
    );
  }

  void _loadBitmap() async {
    destinationMarker = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/icons/marker_destination.png', 70));
    sourceMarker = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/icons/marker_source.png', 55));
    shopMarker = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/icons/marker_shop.png', 100));
  }

  _displayPolygons() {
    for (Comercio com in listC) {
      List<LatLng> polygonCoordinates = com.coordinates.map((item) {
        return LatLng(item[1], item[0]);
      }).toList();
      polygons.add(
        Polygon(
            polygonId: PolygonId('p_${com.idNegocio}'),
            points: polygonCoordinates,
            fillColor: const Color.fromARGB(69, 245, 204, 39).withOpacity(0.30),
            strokeColor: const Color.fromARGB(255, 247, 28, 28),
            strokeWidth: 1,
            geodesic: true,
            onTap: () {
              // alert;
            }),
      );
    }
  }

  _displayPolylines() {
    List<LatLng> polylinePoints = [];
    for (Pasillo pas in ListPasillo) {
      List<LatLng> polylinePoints = pas.coordinates.map((item) {
        return LatLng(item[1], item[0]);
      }).toList();
      polylines.add(
        Polyline(
          polylineId: PolylineId('line_id_${pas.idNegocio}'),
          points: polylinePoints,
          color: ui.Color.fromARGB(255, 6, 140, 250), // Color de la polilínea
          width: 1, // Ancho de la polilínea
        ),
      );
    }
  }

  _loadData() {
    //centro_com
    for (var item in cencom) {
      listCC.add(CenComercial.fromMap(item));
    }
    //comercios
    for (var item in comer) {
      listC.add(Comercio.fromMap222(item));
    }
    for (var item in pasillos) {
      ListPasillo.add(Pasillo.fromMap(item));
    }
    for (var item in puntos) {
      ListPunto.add(Punto.fromMap(item));
    }
    for (var item in prod) {
      listP.add(Producto.fromMap(item));
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void addMarker(String markerId, double lat, double lng, String title,
      String content, BitmapDescriptor iconMarker) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content));
    markers[id] = marker;
  }

  void showMarker(String markerId, double lat, double lng, String title,
      String content, BitmapDescriptor iconMarker,
      {double myZoom = 24}) {
    addMarker(markerId, lat, lng, title, content, iconMarker);
    animateCameraToPosition(lat, lng, myZoom: myZoom);
  }

  Marker? getMarkerSource() {
    Marker? item;
    MarkerId? key;
    markers.forEach((key, value) {
      if (value.markerId.value == 'source') {
        key = key;
        item = value;
      }
    });
    return item;
  }

  Marker? getMarkerDestino() {
    Marker? item;
    markers.forEach((key, value) {
      if (value.markerId.value == 'destino') {
        item = value;
      }
    });
    return item;
  }

  void selectRefPoint() {
    Map<String, dynamic> data = {
      'address': addressName,
      'lat': addressLatLng!.latitude,
      'lng': addressLatLng!.longitude
    };
    Navigator.pop(context!, data);
  }

  Future<BitmapDescriptor> createMarketFromAsset(String path) async {
    ImageConfiguration imageConfiguration = const ImageConfiguration();
    BitmapDescriptor descriptor =
        await BitmapDescriptor.fromAssetImage(imageConfiguration, path);
    return descriptor;
  }

  Future<Null> setLocationDraggableInfo() async {
    if (initialPosition != null) {
      double lat = initialPosition!.target.latitude;
      double lng = initialPosition!.target.longitude;
      List<Placemark> address = await placemarkFromCoordinates(lat, lng);
      if (address.isNotEmpty) {
        String? direction = address[0].thoroughfare;
        String? street = address[0].subThoroughfare;
        String? city = address[0].locality;
        String? department = address[0].administrativeArea;
        String? country = address[0].country;
        addressName = '$direction #$street, $city';
        addressLatLng = LatLng(lat, lng);
        locationCurrent.text = addressName!;
        refresh!();
      }
    }
  }

  /*void onMapCreated(GoogleMapController controller) {
    controller
        .setMapStyle(context!.isDarkMode ? MyMapStyle.dark : MyMapStyle.retro);
    _mapController.complete(controller);
  }
*/
  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        null); // Utilizar el estilo normal proporcionado por Google Maps
    _mapController.complete(controller);
  }

  void onChangeText(String text) {
    Duration duration = const Duration(milliseconds: 800);
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping!.cancel();
      refresh!();
    }
    searchOnStoppedTyping = Timer(duration, () {
      productName = text;
      refresh!();
    });
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getCurrentPosition();
      addMarker("source", _position!.latitude, _position!.longitude, 'Guest',
          'Mi ubicación', sourceMarker!);
      initialPosition = CameraPosition(
          target: LatLng(_position!.latitude, _position!.longitude), zoom: 14);
      setLocationDraggableInfo();
      animateCameraToPosition(_position!.latitude, _position!.longitude);
      refresh!();
    } catch (e) {
      print('Error: $e');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      updateLocation();
      ubic = true;
    } else {
      ubic = false;
      bool locationGPS = false;
      if (locationGPS) {
        updateLocation();
      }
    }
  }

  Future animateCameraToPosition(double lat, double lng,
      {double myZoom = 19}) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: myZoom, bearing: 0)));
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
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void removeProdSearch() {
    PolygonId polygonIdToRemove = PolygonId('Prod_Search');

    // Elimina el polígono según el ID especificado
    polygons.removeWhere((polygon) => polygon.polygonId == polygonIdToRemove);
  }

  Future<void> showPolygonComercios(Producto prod_abuscar) async {
    for (Comercio com in listC) {
      if (com.idNegocio == prod_abuscar.idNegocio) {
        List<LatLng> polygonCoordinates = com.coordinates.map((item) {
          return LatLng(item[1], item[0]);
        }).toList();
        polygons.add(
          Polygon(
              polygonId: PolygonId('Prod_Search'),
              points: polygonCoordinates,
              fillColor: ui.Color.fromARGB(160, 67, 245, 44),
              strokeColor: const Color.fromARGB(255, 247, 28, 28),
              strokeWidth: 3,
              geodesic: true,
              onTap: () {
                print('ok');
              }),
        );

        animateCameraToPosition(
            double.parse(com.latitud), double.parse(com.longitud),
            myZoom: 19);
      }
    }
  }

  void removeComSearch() {
    PolygonId polygonIdToRemove = PolygonId('Com_Search');

    // Elimina el polígono según el ID especificado
    polygons.removeWhere((polygon) => polygon.polygonId == polygonIdToRemove);
  }

  Future<void> showPolygonComercioSearch(Comercio com_abuscar) async {
    List<LatLng> polygonCoordinates = com_abuscar.coordinates.map((item) {
      return LatLng(item[1], item[0]);
    }).toList();
    polygons.add(
      Polygon(
          polygonId: PolygonId('Com_Search'),
          points: polygonCoordinates,
          fillColor: ui.Color.fromARGB(159, 250, 6, 238),
          strokeColor: const Color.fromARGB(255, 247, 28, 28),
          strokeWidth: 3,
          geodesic: true,
          onTap: () {
            print('ok');
          }),
    );
    animateCameraToPosition(
        double.parse(com_abuscar.latitud), double.parse(com_abuscar.longitud),
        myZoom: 19);

    if (false) {
      Grafo grafo = Grafo();
      for (Punto point in ListPunto) {
        grafo.agregarNodo(int.parse(point.idPunto));
      }
      for (Punto point in ListPunto) {
        grafo.agregarConexion(int.parse(point.idPunto), point.link ?? 0, 5);
      }
      int inicio = 3;
      int fin = 1;

      List<int> rutaMasCorta = grafo.dijkstra(inicio, fin);

      print('Ruta más corta desde $inicio hasta $fin: $rutaMasCorta');

      for (int i = 0; i < rutaMasCorta.length; i++) {
        print(rutaMasCorta[i]);
      }
      //await displayruta(rutaMasCorta);
      //muestra la ruta pero hay que insertar todos los datos al mismo tiempo ,los links hacia donde , y sesignarle nombre , o
    }
  }

  Future<void> displayruta(List<int> ruta) async {
    List<LatLng> polylinePoints = [];
    for (int i = 0; i < ruta.length - 1; i++) {
      Punto puntoInicio = ListPunto[ruta[i]];
      Punto puntoFin = ListPunto[ruta[i + 1]];

      // Agregar los puntos de la ruta actual a la lista de puntos de la polilínea
      polylinePoints.add(
          LatLng(puntoInicio.coordinates[0][1], puntoInicio.coordinates[0][0]));
      polylinePoints
          .add(LatLng(puntoFin.coordinates[0][1], puntoFin.coordinates[0][0]));
    }

    polylines.add(
      Polyline(
        polylineId: PolylineId('ruta_id'),
        points: polylinePoints,
        color: ui.Color.fromARGB(255, 1, 247, 54), // Color de la polilínea
        width: 5, // Ancho de la polilínea
      ),
    );
  }

  void removerutaalCom() {
    PolylineId polylineIdToRemove = PolylineId('line_ruta');
    polylines
        .removeWhere((polyline) => polyline.polylineId == polylineIdToRemove);
    polylineCoordinates = [];
  }

  Future<void> createPolylines() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyD4qN5UVBG_R1tlIC4IldWL11YbgbqZgGU",
      PointLatLng(_position!.latitude, _position!.longitude),
      PointLatLng(-17.792714, -63.204901),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      polylines.add(
        Polyline(
          polylineId: const PolylineId('line_ruta'),
          points: polylineCoordinates,
          color: const ui.Color.fromARGB(
              255, 6, 140, 250), // Color de la polilínea
          width: 3, // Ancho de la polilínea
        ),
      );
    }
  }

  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros

    double dLat = radians(lat2 - lat1);
    double dLon = radians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
  }

  double radians(double degrees) {
    return degrees * pi / 180;
  }

  Punto? encontrarPuntoMasCercano(double miLatitud, double miLongitud) {
    double distanciaMinima = 9999999999;
    Punto? puntoCercano = null;

    for (Punto punto in ListPunto) {
      double latitud = punto.coordinates[0][1];
      double longitud = punto.coordinates[0][0];

      double distancia = haversineDistance(
        miLatitud,
        miLongitud,
        latitud,
        longitud,
      );

      if (distancia < distanciaMinima) {
        distanciaMinima = distancia;
        puntoCercano = punto;
      }
    }

    return puntoCercano;
  }
}







// void addMarketPoint(Point point) {
//   MarkerId id = const MarkerId('destino');
//   if (getMarkerDestino() != null) {
//     markers.update(
//       id,
//           (value) => Marker(
//         markerId: id,
//         icon: destinationMarker!,
//         position: LatLng(point.latitud, point.longitud),
//         infoWindow: InfoWindow(
//             title: "${point.descripcion} (${point.localidad})",
//             snippet: point.grupo
//         ),
//       ),
//     );
//   } else {
//     Marker marker = Marker(
//         markerId: id,
//         icon: destinationMarker!,
//         position: LatLng(point.latitud, point.longitud),
//         infoWindow: InfoWindow(
//             title: "${point.descripcion} (${point.localidad})",
//             snippet: point.grupo));
//     markers[id] = marker;
//   }
//   animateCameraToPosition(point.latitud, point.longitud);
//   refresh!();
// }

// void updateMarket(Point point) {
//   MarkerId id = MarkerId(point.sigla);
//   markers.update(
//       id,
//           (value) => Marker(
//           markerId: id,
//           icon: destinationMarker!,
//           position: LatLng(point.latitud, point.longitud),
//           infoWindow:
//           InfoWindow(title: point.descripcion, snippet: point.grupo)));
//   animateCameraToPosition(point.latitud, point.longitud);
//   refresh!();
// }

// Future<void> setPolylines(LatLng from, LatLng to, int type) async {
//   PointLatLng pointFrom = PointLatLng(from.latitude, from.longitude);
//   PointLatLng pointTo = PointLatLng(to.latitude, to.longitude);
//   PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
//     Environment.API_KEY_MAPS,
//     pointFrom,
//     pointTo,
//     optimizeWaypoints: true,
//     travelMode: type == 0 ? TravelMode.walking : TravelMode.driving,
//   );
//   points.clear();
//   for (PointLatLng point in result.points) {
//     points.add(LatLng(point.latitude, point.longitude));
//   }
//   Polyline polyline = type == 0
//       ? Polyline(
//       polylineId: const PolylineId('myRoute'),
//       color: Colors.yellow,
//       points: points,
//       patterns: [PatternItem.dash(10), PatternItem.gap(10)],
//       width: 4)
//       : Polyline(
//       polylineId: const PolylineId('myRoute'),
//       color: Colors.red,
//       points: points,
//       width: 4);
//   if (polylines.isEmpty) {
//     polylines.add(polyline);
//   } else {
//     polylines.clear();
//     polylines.add(polyline);
//   }
//
//   double totalDistance = 0;
//   for (var i = 0; i < points.length - 1; i++) {
//     totalDistance += calculateDistance(points[i].latitude,
//         points[i].longitude, points[i + 1].latitude, points[i + 1].longitude);
//   }
//   distanceBetween = totalDistance;
//
//   if (type == 1) {
//     //auto
//     PointLatLng pointFrom1 =
//     PointLatLng(points.last.latitude, points.last.longitude);
//     PolylineResult result1 =
//     await PolylinePoints().getRouteBetweenCoordinates(
//       Environment.API_KEY_MAPS,
//       pointFrom1,
//       pointTo,
//       optimizeWaypoints: true,
//       travelMode: TravelMode.walking,
//     );
//     pointsExtra.clear();
//     print(result1.points.length);
//     for (PointLatLng point in result1.points) {
//       pointsExtra.add(LatLng(point.latitude, point.longitude));
//     }
//     Polyline pol = Polyline(
//         polylineId: const PolylineId('myRouteExtra'),
//         color: Colors.red,
//         points: pointsExtra,
//         patterns: [PatternItem.dash(10), PatternItem.gap(5)],
//         width: 4);
//     polylines.add(pol);
//   }
//   refresh!();
// }
