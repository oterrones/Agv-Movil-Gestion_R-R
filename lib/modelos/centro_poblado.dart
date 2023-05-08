import 'dart:convert';

final String tableCentroPoblado = 'centroPoblado';

List<CentroPoblado> centroPobladoFromJson(String str) => List<CentroPoblado>.from(json.decode(str).map((x) => CentroPoblado.fromJson(x)));

String centroPobladoToJson(List<CentroPoblado> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CentroPobladoFields {
  static final List<String> values = [
    id,
    nombre,
    estado,
    rec_distrito
  ];

  static final String id = 'id';
  static final String nombre = 'nombre';
  static final String estado = 'estado';
  static final String rec_distrito = 'rec_distrito';
}

class CentroPoblado {
  CentroPoblado({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.rec_distrito,
  });

  int id;
  String nombre;
  String estado;
  int rec_distrito;

  factory CentroPoblado.fromJson(Map<String, dynamic> json) => CentroPoblado(
    id: json[CentroPobladoFields.id],
    nombre: json[CentroPobladoFields.nombre],
    estado: json[CentroPobladoFields.estado],
    rec_distrito: json[CentroPobladoFields.rec_distrito],
  );

  Map<String, dynamic> toJson() => {
    CentroPobladoFields.id : id,
    CentroPobladoFields.nombre : nombre,
    CentroPobladoFields.estado : estado,
    CentroPobladoFields.rec_distrito : rec_distrito,
  };
}
