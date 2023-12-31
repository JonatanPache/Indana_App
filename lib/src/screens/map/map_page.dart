import 'package:appcomercial/src/config/utils/my_color.dart';
import 'package:appcomercial/src/models/producto.dart';

import 'package:appcomercial/src/screens/map/map_controller.dart';
import 'package:appcomercial/src/screens/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/comercio.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MapPage> {
  final MapController _con = MapController();
  int _currentIndex = 0;
  BitmapDescriptor? customIcon;
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,//metros
  );
  bool tracking = false;
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  bool _usarAutocompletarProductos = true;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
    super.initState();
  }

  void refresh() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: PreferredSize(
              preferredSize: const Size.fromHeight(70.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Column(children: [
                  const SizedBox(
                    height: 9,
                  ),
                  _usarAutocompletarProductos
                      ? Autocomplete<Producto>(
                          optionsBuilder: (TextEditingValue value) {
                            return _con.listP
                                .where((suggestion) => suggestion.productos
                                    .toLowerCase()
                                    .contains(value.text.toLowerCase()))
                                .toList();
                          },
                          displayStringForOption: (Producto option) =>
                              "${option.productos} (${option.color} )",
                          onSelected: (Producto selectedOption) async {
                            _con.removeComSearch();
                            _con.removeProdSearch();
                            await _con.showPolygonComercios(selectedOption);
                            refresh();
                            print(selectedOption.idNegocio);
                            // Limpia el texto del controlador
                            // _textEditingController.clear();
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            _textEditingController =
                                textEditingController; // Asigna el controlador aquí
                            _focusNode = focusNode;
                            return Input(
                              enabled: true,
                              controller: _textEditingController,
                              iconData: FontAwesomeIcons.searchengin,
                              color: MyColor.iconFillDark,
                              focusNode: _focusNode,
                              hintText: 'Buscar productos',
                            );
                          },
                        )
                      : Autocomplete<Comercio>(
                          optionsBuilder: (TextEditingValue value) {
                            return _con.listC
                                .where((suggestion) => suggestion.nombre
                                    .toLowerCase()
                                    .contains(value.text.toLowerCase()))
                                .toList();
                          },
                          displayStringForOption: (Comercio option) =>
                              "${option.nombre} (${option.sigla} ) ",
                          onSelected: (Comercio selectedOption) async {
                            _con.removeComSearch();
                            _con.removeProdSearch();
                            await _con
                                .showPolygonComercioSearch(selectedOption);
                            refresh();
                            print(selectedOption.idNegocio);
                            // Limpia el texto del controlador
                            // _textEditingController.clear();
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            _textEditingController2 =
                                textEditingController; // Asigna el controlador aquí
                            _focusNode2 = focusNode;
                            return Input(
                              enabled: true,
                              controller: _textEditingController2,
                              iconData: FontAwesomeIcons.searchengin,
                              color: MyColor.iconFillDark,
                              focusNode: _focusNode2,
                              hintText: 'Buscar Negocios',
                            );
                          },
                        ),
                ]),
              ),
            ),
          ),
          _googleMaps(),
        ],
      ),
      bottomNavigationBar: _buttonNavigator(),
    );
  }

  Widget _buttonNavigator() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) async {
        print(index);
        if (index == 0) {
          _con.ubicStream = false;

          _con.clearMarkers();
          _con.removeComSearch();
          _con.removeProdSearch();
          _con.removerutaalCom();
          _currentIndex = index;
          setState(() {
            _usarAutocompletarProductos = false;
          });
          _textEditingController2.clear();
          _textEditingController.clear();

          setState(() {
            if (_focusNode2.hasFocus) {
              _focusNode2.unfocus();
            } else {
              _focusNode2.requestFocus();
            }
          });
          print('search negocio');
        }
        if (index == 1) {

          _con.clearMarkers();
          _con.ubicStream = false;
          _con.removeComSearch();
          _con.removeProdSearch();
          _con.removerutaalCom();
          _currentIndex = index;
          setState(() {
            _usarAutocompletarProductos = true;
          });

          _textEditingController.clear();
          _textEditingController2.clear();
          //  _focusNode.unfocus();
          setState(() {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            } else {
              _focusNode.requestFocus();
            }
          });
          print('search prod');
        }

        if (index == 2) {
          _con.clearMarkers();
          //_con.ubicStream = true;
          _con.removerutaalCom();
          _currentIndex = index;
          _con.checkGPS();
        } else if (index == 3) {
          _con.removerutaalCom();
          tracking = true;
          _con.ubicStream = true;
          _currentIndex = index;
          refresh();
        } else if (index == 4) {
          _con.ubicStream = false;
          _con.removerutaalCom();
          _currentIndex = index;
          //_con.clearPolyline();
          _con.clearMarkers();
          _con.showMarker(
              'centComer',
              double.parse(_con.listCC.firstOrNull!.latitud),
              double.parse(_con.listCC.firstOrNull!.longitud),
              _con.listCC.firstOrNull!.nombre,
              _con.listCC.firstOrNull!.direccion,
              _con.shopMarker!,
              myZoom: 10);
          if (_con.ubic) {
            await _con.createPolylines();
          }

          tracking = false;

          refresh();
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.add_business_rounded),
          label: 'Negoc',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_shopping_cart_rounded),
          label: 'b. prod',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_searching_outlined),
          label: 'd. estoy',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.alt_route),
          label: 'route',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.not_listed_location_rounded),
          label: 'ubic',
        ),
      ],
    );
  }

  void addManualMarker() {
    Marker manualMarker = Marker(
      markerId: MarkerId('manual_marker'),
      position: LatLng(-17.792714, -63.204901),
      infoWindow: InfoWindow(
        title: 'Marcador Manual',
        snippet: 'Este es un marcador añadido manualmente.',
      ),
    );

    // setState(() {
    //   markers.add(manualMarker);
    // });
  }

  // Widget _googleMaps() {
  //   return GoogleMap(
  //     mapType: MapType.normal,
  //     markers: Set<Marker>.of(_con.markers.values),
  //     polylines: _con.polylines,
  //     polygons: _con.polygons,
  //     onMapCreated: _con.onMapCreated,
  //     initialCameraPosition: _con.defaultPosition,
  //     zoomControlsEnabled: true,
  //   );
  // }

  Widget _googleMaps() {
    return StreamBuilder<Position>(
      stream: Geolocator.getPositionStream(locationSettings: locationSettings),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // final position = snapshot.data;
          _con.ubicStream ? _con.updateSource(snapshot.data) : null;
          return Expanded(
              child: GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: _con.defaultPosition,
            onMapCreated: _con.onMapCreated,
            polygons: _con.polygons,
            polylines: _con.polylines,
            markers: Set<Marker>.of(_con.markers.values),
            zoomControlsEnabled: true,
          ));
        }
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Cargando mapa... Conceda permisos,Internet,Ubicaion'),
          ],
        );
      },
    );
  }

  Widget googleMaps2() {
    return StreamBuilder<Position>(
      stream: Geolocator.getPositionStream(locationSettings: locationSettings),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Position position = snapshot.data as Position;
          print(
              'Latitud desde streaMS: ${position.latitude}, Longitud DESD: ${position.longitude}');
          // Si hay datos, actualiza la posición si el seguimiento está habilitado
          //tracking ? _con.updateSource(snapshot.data) : null;
          _con.ubicStream ? _con.updateSource(snapshot.data) : null;
          print(_con.ubicStream);
        }

        // Muestra el mapa incluso si no hay datos de ubicación
        return Expanded(
          child: GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: _con.defaultPosition,
            onMapCreated: _con.onMapCreated,
            polygons: _con.polygons,
            polylines: _con.polylines,
            markers: Set<Marker>.of(_con.markers.values),
            zoomControlsEnabled: true,
          ),
        );
      },
    );
  }
}



// final Completer<GoogleMapController> _controller =
//     Completer<GoogleMapController>();
// Set<Marker> markers = {};
// Set<Polyline> polylines = {};
// List<LatLng> polylinePoints = [];
// Set<Polygon> polygons = Set();
// Future<void> loadCustomIcon() async {
//   customIcon = await BitmapDescriptor.fromAssetImage(
//     const ImageConfiguration(size: Size(48, 48)),
//     'lib/images/custom_marker.png',
//   );
// }
//
// Future<void> loadKmlFile() async {
//   // Icono personalizado para el marcador
//   final ByteData imageData = await rootBundle.load('assets/icons/mark.png');
//   final Uint8List bytes = imageData.buffer.asUint8List();
//   final img.Image? originalImage = img.decodeImage(bytes);
//   final img.Image resizedImage =
//       img.copyResize(originalImage!, width: 20, height: 30);
//   final resizedImageData = img.encodePng(resizedImage);
//   final BitmapDescriptor bitmapDescriptor =
//       BitmapDescriptor.fromBytes(resizedImageData);
//
//   // Lee el archivo KML (puedes cargarlo desde la red o localmente)
//   print("cargado marcadores");
//   String kmlString = await DefaultAssetBundle.of(context)
//       .loadString('lib/images/tiendaspuntos.kml');
//   // Analiza el archivo KML
//   var document = xml.XmlDocument.parse(kmlString);
//   var placemarks = document.findAllElements('Placemark');
//   // Actualiza el conjunto de marcadores
//   Set<Marker> updatedMarkers = Set();
//   int i = 1;
//   // Recorre los placemarks y agrega las geometrías al conjunto de marcadores
//   for (var placemark in placemarks) {
//     // var multiGeometryElement = placemark.findElements('MultiGeometry').first;
//     var lineStringElement = placemark.findElements('Point').first;
//     var coordinatesElement =
//         lineStringElement.findElements('coordinates').first;
//
//     var coordinates = coordinatesElement.text.trim();
//     var coords = coordinates.split(',');
//     markers.add(Marker(
//       markerId:
//           MarkerId(placemark.findElements('name').first.text + i.toString()),
//       position: LatLng(double.parse(coords[1]), double.parse(coords[0])),
//       icon: bitmapDescriptor,
//       infoWindow: InfoWindow(
//         title: placemark.findElements('name').first.text,
//         snippet: placemark.findElements('name').first.text,
//       ),
//     ));
//
//     polylinePoints
//         .add(LatLng(double.parse(coords[1]), double.parse(coords[0])));
//     i++;
//   }
//   polylines.add(
//     Polyline(
//       polylineId: PolylineId('line_id'),
//       points: polylinePoints,
//       color: Colors.blue, // Color de la polilínea
//       width: 3, // Ancho de la polilínea
//     ),
//   );
//
//   // Actualiza el estado con el nuevo conjunto de marcadores
//   setState(() {});
//   for (var marker in updatedMarkers) {
//     print(marker.markerId.value); // Imprime los ID de los marcadores
//   }
// }
//
// Future<void> loadKmlPoligonos() async {
//   String kmlString = await DefaultAssetBundle.of(context)
//       .loadString('lib/images/kmlpoligonostienda.kml');
//   var document = xml.XmlDocument.parse(kmlString);
//   var placemarks = document.findAllElements('Placemark');
//   Set<Marker> updatedMarkers = Set();
//   int i = 1;
//   for (var placemark in placemarks) {
//     // var multiGeometryElement = placemark.findElements('MultiGeometry').first;
//     var lineStringElement = placemark.findElements('MultiGeometry').first;
//     var coordinatesElement = lineStringElement
//         .findElements('Polygon')
//         .first
//         .findElements('outerBoundaryIs')
//         .first
//         .findElements('LinearRing')
//         .first
//         .findElements('coordinates')
//         .first;
//
//     var coordinates = coordinatesElement.text.trim();
//     var coords = coordinates.split(' ');
//     i++;
//
//     List<LatLng> polygonCoordinates = coords.map((coord) {
//       var latLng = coord.split(',');
//       return LatLng(double.parse(latLng[1]), double.parse(latLng[0]));
//     }).toList();
//
//     polygons.add(
//           Polygon(
//             polygonId:
//                 PolygonId('polygon_${polygons.length}$i'),
//             points: polygonCoordinates,
//             fillColor: const Color.fromARGB(69, 245, 204, 39),
//             strokeColor: const Color.fromARGB(255, 247, 28, 28),
//             strokeWidth: 1,
//           ),
//         );
//   }
//
//   // Actualiza el estado con el nuevo conjunto de marcadores
//   setState(() {});
//   for (var marker in updatedMarkers) {
//     print(marker.markerId.value); // Imprime los ID de los marcadores
//   }
// }
