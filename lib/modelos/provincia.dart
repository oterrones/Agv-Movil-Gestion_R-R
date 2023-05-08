import 'dart:convert';

final String tableProvincia = 'provincia';

List<Provincia> provinciaFromJson(String str) => List<Provincia>.from(json.decode(str).map((x) => Provincia.fromJson(x)));

String provinciaToJson(List<Provincia> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProvinciaFields {
  static final List<String> values = [
    id,
    nombre,
    estado,
    rec_region
  ];

  static final String id = 'id';
  static final String nombre = 'nombre';
  static final String estado = 'estado';
  static final String rec_region = 'rec_region';
}

class Provincia {
  Provincia({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.rec_region,
  });

  int id;
  String nombre;
  String estado;
  int rec_region;

  factory Provincia.fromJson(Map<String, dynamic> json) => Provincia(
    id: json[ProvinciaFields.id],
    nombre: json[ProvinciaFields.nombre],
    estado: json[ProvinciaFields.estado],
    rec_region: json[ProvinciaFields.rec_region],
  );

  Map<String, dynamic> toJson() => {
    ProvinciaFields.id : id,
    ProvinciaFields.nombre : nombre,
    ProvinciaFields.estado : estado,
    ProvinciaFields.rec_region : rec_region,
  };
}
