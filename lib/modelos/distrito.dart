import 'dart:convert';

final String tableDistrito = 'distrito';

List<Distrito> distritoFromJson(String str) => List<Distrito>.from(json.decode(str).map((x) => Distrito.fromJson(x)));

String distritoToJson(List<Distrito> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DistritoFields {
  static final List<String> values = [
    id,
    nombre,
    estado,
    rec_provincia
  ];

  static final String id = 'id';
  static final String nombre = 'nombre';
  static final String estado = 'estado';
  static final String rec_provincia = 'rec_provincia';
}

class Distrito {
  Distrito({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.rec_provincia,
  });

  int id;
  String nombre;
  String estado;
  int rec_provincia;

  factory Distrito.fromJson(Map<String, dynamic> json) => Distrito(
    id: json[DistritoFields.id],
    nombre: json[DistritoFields.nombre],
    estado: json[DistritoFields.estado],
    rec_provincia: json[DistritoFields.rec_provincia],
  );

  Map<String, dynamic> toJson() => {
    DistritoFields.id : id,
    DistritoFields.nombre : nombre,
    DistritoFields.estado : estado,
    DistritoFields.rec_provincia : rec_provincia,
  };
}
