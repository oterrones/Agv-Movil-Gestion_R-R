import 'dart:convert';

final String tableParadero = 'paradero';

List<Paradero> paraderoFromJson(String str) => List<Paradero>.from(json.decode(str).map((x) => Paradero.fromJson(x)));

String paraderoToJson(List<Paradero> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ParaderoFields {
  static final List<String> values = [
    id,
    nombre,
    estado,
    rec_centro_poblado
  ];

  static final String id = 'id';
  static final String nombre = 'nombre';
  static final String estado = 'estado';
  static final String rec_centro_poblado = 'rec_centro_poblado';
}

class Paradero {
  Paradero({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.rec_centro_poblado,
  });

  int id;
  String nombre;
  String estado;
  int rec_centro_poblado;

  factory Paradero.fromJson(Map<String, dynamic> json) => Paradero(
    id: json[ParaderoFields.id],
    nombre: json[ParaderoFields.nombre],
    estado: json[ParaderoFields.estado],
    rec_centro_poblado: json[ParaderoFields.rec_centro_poblado],
  );

  Map<String, dynamic> toJson() => {
    ParaderoFields.id : id,
    ParaderoFields.nombre : nombre,
    ParaderoFields.estado : estado,
    ParaderoFields.rec_centro_poblado : rec_centro_poblado,
  };
}
