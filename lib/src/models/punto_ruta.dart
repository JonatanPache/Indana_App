import 'dart:convert';

class Punto {
  String idPunto;
  String nombre;
  int? link;
  List<List<double>> coordinates;

  Punto({
    required this.idPunto,
    required this.nombre,
    required this.link,
    required this.coordinates,
  });

  Punto copyWith({
    String? idPunto,
    String? nombre,
    int? link,
    List<List<double>>? coordinates,
  }) =>
      Punto(
        idPunto: idPunto ?? this.idPunto,
        nombre: nombre ?? this.nombre,
        link: link ?? this.link,
        coordinates: coordinates ?? this.coordinates,
      );

  factory Punto.fromJson(String str) => Punto.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Punto.fromMap(Map<String, dynamic> json) => Punto(
        idPunto: json['properties']['FID'].toString() ?? '',
        nombre: json['properties']['FID'].toString() ?? '',
        link: json['link_FID'] ?? 0,
        coordinates: List<List<double>>.from(json["coordinates"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
      );

  Map<String, dynamic> toMap() => {
        "idPunto": idPunto,
        "Nombre": nombre,
        "link": link,
        "coordinates": List<dynamic>.from(
            coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}
