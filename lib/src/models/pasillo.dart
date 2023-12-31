import 'dart:convert';

class Pasillo {
  String idNegocio;
  String nombre;
  List<List<double>> coordinates;

  Pasillo({
    required this.idNegocio,
    required this.nombre,
    required this.coordinates,
  });

  Pasillo copyWith({
    String? idNegocio,
    String? nombre,
    List<List<double>>? coordinates,
  }) =>
      Pasillo(
        idNegocio: idNegocio ?? this.idNegocio,
        nombre: nombre ?? this.nombre,
        coordinates: coordinates ?? this.coordinates,
      );

  factory Pasillo.fromJson(String str) => Pasillo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Pasillo.fromMap(Map<String, dynamic> json) => Pasillo(
        idNegocio: json['properties']['FID'].toString() ?? '',
        nombre: json['properties']['FID'].toString() ?? '',
        coordinates: List<List<double>>.from(json["coordinates"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
      );

  Map<String, dynamic> toMap() => {
        "IdNegocio": idNegocio,
        "Nombre": nombre,
        "coordinates": List<dynamic>.from(
            coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}
