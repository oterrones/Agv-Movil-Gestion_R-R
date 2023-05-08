import 'dart:convert';

final String tableLiderZona = 'liderZona';

List<LiderZona> liderZonaFromJson(String str) => List<LiderZona>.from(json.decode(str).map((x) => LiderZona.fromJson(x)));

String liderZonaToJson(List<LiderZona> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LiderZonaFields {
  static final List<String> values = [
    id,
    nombres,
    apellidos,
    dni,
    estado
  ];

  static final String id = 'id';
  static final String nombres = 'nombres';
  static final String apellidos = 'apellidos';
  static final String dni = 'dni';
  static final String estado = 'estado';
}

class LiderZona {
  LiderZona({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.estado,
  });

  int id;
  String nombres;
  String apellidos;
  String dni;
  String estado;

  factory LiderZona.fromJson(Map<String, dynamic> json) => LiderZona(
    id: json[LiderZonaFields.id],
    nombres: json[LiderZonaFields.nombres],
    apellidos: json[LiderZonaFields.apellidos],
    dni: json[LiderZonaFields.dni],
    estado: json[LiderZonaFields.estado],
  );

  Map<String, dynamic> toJson() => {
    LiderZonaFields.id : id,
    LiderZonaFields.nombres : nombres,
    LiderZonaFields.apellidos : apellidos,
    LiderZonaFields.dni : dni,
    LiderZonaFields.estado : estado,
  };
}
