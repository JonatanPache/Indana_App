import 'dart:convert';

class CenComercial {
  String idCentro;
  String nombre;
  String direccion;
  String telefono;
  String pagina;
  String longitud;
  String latitud;

  CenComercial({
    required this.idCentro,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.pagina,
    required this.longitud,
    required this.latitud,
  });

  CenComercial copyWith({
    String? idCentro,
    String? nombre,
    String? direccion,
    String? telefono,
    String? pagina,
    String? longitud,
    String? latitud,
  }) =>
      CenComercial(
        idCentro: idCentro ?? this.idCentro,
        nombre: nombre ?? this.nombre,
        direccion: direccion ?? this.direccion,
        telefono: telefono ?? this.telefono,
        pagina: pagina ?? this.pagina,
        longitud: longitud ?? this.longitud,
        latitud: latitud ?? this.latitud,
      );

  factory CenComercial.fromJson(String str) => CenComercial.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CenComercial.fromMap(Map<String, dynamic> json) => CenComercial(
    idCentro: json["IdCentro"] ?? '',
    nombre: json["Nombre"] ?? '',
    direccion: json["Direccion"] ?? '',
    telefono: json["Telefono"] ?? '',
    pagina: json["Pagina"] ?? '',
    longitud: json["Longitud"] ?? '',
    latitud: json["Latitud"] ?? '',
  );

  Map<String, dynamic> toMap() => {
    "IdCentro": idCentro,
    "Nombre": nombre,
    "Direccion": direccion,
    "Telefono": telefono,
    "Pagina": pagina,
    "Longitud": longitud,
    "Latitud": latitud,
  };
}
