import 'dart:convert';

class Catalogo {
  String idCatalogo;
  String nombre;

  Catalogo({
    required this.idCatalogo,
    required this.nombre,
  });

  Catalogo copyWith({
    String? idCatalogo,
    String? nombre,
  }) =>
      Catalogo(
        idCatalogo: idCatalogo ?? this.idCatalogo,
        nombre: nombre ?? this.nombre,
      );

  factory Catalogo.fromJson(String str) => Catalogo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Catalogo.fromMap(Map<String, dynamic> json) => Catalogo(
    idCatalogo: json["IdCatalogo"],
    nombre: json["Nombre"],
  );

  Map<String, dynamic> toMap() => {
    "IdCatalogo": idCatalogo,
    "Nombre": nombre,
  };
}
