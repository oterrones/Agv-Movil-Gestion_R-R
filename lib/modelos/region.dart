import 'dart:convert';

final String tableRegion = 'region';

List<Region> regionFromJson(String str) => List<Region>.from(json.decode(str).map((x) => Region.fromJson(x)));

String regionToJson(List<Region> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RegionFields {
  static final List<String> values = [
    id,
    nombre,
    estado,
    rec_pais
  ];

  static final String id = 'id';
  static final String nombre = 'nombre';
  static final String estado = 'estado';
  static final String rec_pais = 'rec_pais';
}

class Region {
  Region({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.rec_pais,
  });

  int id;
  String nombre;
  String estado;
  int rec_pais;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    id: json[RegionFields.id],
    nombre: json[RegionFields.nombre],
    estado: json[RegionFields.estado],
    rec_pais: json[RegionFields.rec_pais],
  );

  Map<String, dynamic> toJson() => {
    RegionFields.id : id,
    RegionFields.nombre : nombre,
    RegionFields.estado : estado,
    RegionFields.rec_pais : rec_pais,
  };
}
