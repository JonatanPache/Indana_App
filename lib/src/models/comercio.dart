import 'dart:convert';

class Comercio {
  String idNegocio;
  String nombre;
  String sigla;
  String direccion;
  String telefono;
  String longitud;
  String latitud;
  String idCenComercial;
  String idSig;
  String status;
  List<List<double>> coordinates;

  Comercio({
    required this.idNegocio,
    required this.nombre,
    required this.sigla,
    required this.direccion,
    required this.telefono,
    required this.longitud,
    required this.latitud,
    required this.idCenComercial,
    required this.idSig,
    required this.status,
    required this.coordinates,
  });

  Comercio copyWith({
    String? idNegocio,
    String? nombre,
    String? sigla,
    String? direccion,
    String? telefono,
    String? longitud,
    String? latitud,
    String? idCenComercial,
    String? idSig,
    String? status,
    List<List<double>>? coordinates,
  }) =>
      Comercio(
        idNegocio: idNegocio ?? this.idNegocio,
        nombre: nombre ?? this.nombre,
        sigla: sigla ?? this.sigla,
        direccion: direccion ?? this.direccion,
        telefono: telefono ?? this.telefono,
        longitud: longitud ?? this.longitud,
        latitud: latitud ?? this.latitud,
        idCenComercial: idCenComercial ?? this.idCenComercial,
        idSig: idSig ?? this.idSig,
        status: status ?? this.status,
        coordinates: coordinates ?? this.coordinates,
      );

  factory Comercio.fromJson(String str) => Comercio.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Comercio.fromMap(Map<String, dynamic> json) => Comercio(
        idNegocio: json["IdNegocio"] ?? '',
        nombre: json["Nombre"] ?? '',
        sigla: json["Sigla "] ?? '',
        direccion: json["Direccion"] ?? '',
        telefono: json["Telefono"] ?? '',
        longitud: json["longitud"] ?? '',
        latitud: json["latitud"] ?? '',
        idCenComercial: json["IdCenComercial"] ?? '',
        idSig: json["id SIG"] ?? '',
        status: json["Status"] ?? '',
        coordinates: List<List<double>>.from(json["coordinates"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
      );

  factory Comercio.fromMap222(Map<String, dynamic> json) => Comercio(
        idNegocio: json["FID"].toString() ?? '',
        nombre: json["nombre"] ?? '',
        //sigla: (json["nombre"] as String).substring(0, 3) ?? '',
        sigla: json["nombre"]?.toString()?.substring(0, 3) ?? '',
        direccion: json["Direccion"] ?? '3er anillo interno',
        telefono: json["Telefono"] ?? '70045431',
        longitud: (json["coordinates"].first)[0].toString() ?? '',
        latitud: (json["coordinates"].first)[1].toString() ?? '',
        idCenComercial: json["IdCenComercial"] ?? '1',
        idSig: json["id SIG"] ?? '2',
        status: json["Status"] ?? 'A',
        coordinates: List<List<double>>.from(json["coordinates"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
      );

  Map<String, dynamic> toMap() => {
        "IdNegocio": idNegocio,
        "Nombre": nombre,
        "Sigla ": sigla,
        "Direccion": direccion,
        "Telefono": telefono,
        "longitud": longitud,
        "latitud": latitud,
        "IdCenComercial": idCenComercial,
        "id SIG": idSig,
        "Status": status,
        "coordinates": List<dynamic>.from(
            coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}
