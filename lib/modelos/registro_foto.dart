import 'dart:convert';

final String tableRegistros = 'registros';
final String tableFotos = 'fotos';

List<Registro> registroFromJson(String str) => List<Registro>.from(json.decode(str).map((x) => Registro.fromJson(x)));

String registroToJson(List<Registro> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RegistroFields {
  static final List<String> values = [
    id,
    fecha,
    dniTrabajador,
    nombreTrabajador,
    observacion,
    estadoE,
    latitud,
    longitud,
    estado,
    idResponsable,
    idBd,
    fotos,
  ];

  static final String id = 'id';
  static final String fecha = 'fecha';
  static final String dniTrabajador = 'dni_trabajador';
  static final String nombreTrabajador = 'nombre_trabajador';
  static final String observacion = 'observacion';
  static final String estadoE = 'estado_e';
  static final String latitud = 'latitud';
  static final String longitud = 'longitud';
  static final String estado = 'estado';
  static final String idResponsable = 'id_responsable';
  static final String idBd = 'id_bd';
  static final String fotos = 'fotos_ryr';
}

class Registro {
  Registro({
    this.id,
    required this.fecha,
    required this.dniTrabajador,
    required this.nombreTrabajador,
    required this.observacion,
    required this.estadoE,
    required this.latitud,
    required this.longitud,
    required this.estado,
    required this.idResponsable,
    this.idBd,
    required this.fotos_ryr,
  });

  int? id;
  String fecha;
  String dniTrabajador;
  String nombreTrabajador;
  String observacion;
  String estadoE;
  String latitud;
  String longitud;
  String estado;
  int idResponsable;
  int? idBd;
  List<Foto> fotos_ryr;

  factory Registro.fromJson(Map<String, dynamic> json) => Registro(
    id: json[RegistroFields.id],
    fecha: json[RegistroFields.fecha],
    dniTrabajador: json[RegistroFields.dniTrabajador],
    nombreTrabajador: json[RegistroFields.nombreTrabajador],
    observacion: json[RegistroFields.observacion],
    estadoE: json[RegistroFields.estadoE],
    latitud: json[RegistroFields.latitud],
    longitud: json[RegistroFields.longitud],
    estado: json[RegistroFields.estado],
    idResponsable: json[RegistroFields.idResponsable],
    idBd: json[RegistroFields.idBd],
    fotos_ryr: List<Foto>.from(json[RegistroFields.fotos].map((x) => Foto.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    RegistroFields.id: id,
    RegistroFields.fecha: fecha,
    RegistroFields.dniTrabajador: dniTrabajador,
    RegistroFields.nombreTrabajador: nombreTrabajador,
    RegistroFields.observacion: observacion,
    RegistroFields.estadoE: estadoE,
    RegistroFields.latitud: latitud,
    RegistroFields.longitud: longitud,
    RegistroFields.estado: estado,
    RegistroFields.idResponsable: idResponsable,
    RegistroFields.idBd: idBd,
    RegistroFields.fotos: List<dynamic>.from(fotos_ryr.map((x) => x.toJson())),
  };
}

class FotoFields {
  static final List<String> values = [
    id,
    file,
    estado,
    idRegistro,
    idBd,
  ];

  static final String id = 'id';
  static final String file = 'file';
  static final String estado = 'estado';
  static final String idRegistro = 'id_registro';
  static final String idBd = 'id_bd';
}

class Foto {
  Foto({
    this.id,
    required this.file,
    required this.estado,
    this.idRegistro,
    this.idBd,
  });

  int? id;
  String file;
  String estado;
  int? idRegistro;
  int? idBd;

  factory Foto.fromJson(Map<String, dynamic> json) => Foto(
    id: json[FotoFields.id],
    file: json[FotoFields.file],
    estado: json[FotoFields.estado],
    idRegistro: json[FotoFields.idRegistro],
    idBd: json[FotoFields.idBd],
  );

  Map<String, dynamic> toJson() => {
    FotoFields.id: id,
    FotoFields.file: file,
    FotoFields.estado: estado,
    FotoFields.idRegistro: idRegistro,
    FotoFields.idBd: idBd,
  };
}
