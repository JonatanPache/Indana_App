import 'dart:convert';

class Producto {
  String idPoducto;
  String productos;
  String idCatalogo;
  String color;
  String precio;
  String cantidad;
  String dsponible;
  String idNegocio;

  Producto({
    required this.idPoducto,
    required this.productos,
    required this.idCatalogo,
    required this.color,
    required this.precio,
    required this.cantidad,
    required this.dsponible,
    required this.idNegocio,
  });

  Producto copyWith({
    String? idPoducto,
    String? productos,
    String? idCatalogo,
    String? color,
    String? precio,
    String? cantidad,
    String? dsponible,
    String? idNegocio,
  }) =>
      Producto(
        idPoducto: idPoducto ?? this.idPoducto,
        productos: productos ?? this.productos,
        idCatalogo: idCatalogo ?? this.idCatalogo,
        color: color ?? this.color,
        precio: precio ?? this.precio,
        cantidad: cantidad ?? this.cantidad,
        dsponible: dsponible ?? this.dsponible,
        idNegocio: idNegocio ?? this.idNegocio,
      );

  factory Producto.fromJson(String str) => Producto.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Producto.fromMap(Map<String, dynamic> json) => Producto(
    idPoducto: json["IdPoducto"] ?? '',
    productos: json["productos"] ?? '',
    idCatalogo: json["IdCatalogo"] ?? '',
    color: json["Color"] ?? '',
    precio: json["Precio"] ?? '',
    cantidad: json["Cantidad"] ?? '',
    dsponible: json["Dsponible"] ?? '',
    idNegocio: json["IdNegocio"] ?? '',
  );

  Map<String, dynamic> toMap() => {
    "IdPoducto": idPoducto,
    "productos": productos,
    "IdCatalogo": idCatalogo,
    "Color": color,
    "Precio": precio,
    "Cantidad": cantidad,
    "Dsponible": dsponible,
    "IdNegocio": idNegocio,
  };
}

