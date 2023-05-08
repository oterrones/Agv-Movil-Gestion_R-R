import 'dart:convert';

final String tableTareoLiderZona = 'tareoLiderZona';

List<TareoLiderZona> tareoLiderZonaFromJson(String str) => List<TareoLiderZona>.from(json.decode(str).map((x) => TareoLiderZona.fromJson(x)));

String tareoLiderZonaToJson(List<TareoLiderZona> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TareoLiderZonaFields {
  static final List<String> values = [
    id,
    fecha_registro,
    hora_registro,
    region,
    provincia,
    distrito,
    centro_poblado,
    paradero,
    numero_placa,
    latitud,
    longitud,
    dni_lider_zona,
    rec_lider_zona,
    dni_usuario_logeado,
    usuario_logeado,
    estado,

  ];

  static final String id = 'id';
  static final String fecha_registro = 'fecha_registro';
  static final String hora_registro = 'hora_registro';
  static final String region = 'region';
  static final String provincia = 'provincia';
  static final String distrito = 'distrito';
  static final String centro_poblado = 'centro_poblado';
  static final String paradero = 'paradero';
  static final String numero_placa = 'numero_placa';
  static final String latitud = 'latitud';
  static final String longitud = 'longitud';
  static final String dni_lider_zona = 'dni_lider_zona';
  static final String rec_lider_zona = 'rec_lider_zona';
  static final String dni_usuario_logeado = 'dni_usuario_logeado';
  static final String usuario_logeado = 'usuario_logeado';
  static final String estado = 'estado';

}

class TareoLiderZona {
  TareoLiderZona({
    this.id,
    required this.fecha_registro,
    required this.hora_registro,
    required this.region,
    required this.provincia,
    required this.distrito,
    required this.centro_poblado,
    required this.paradero,
    required this.numero_placa,
    required this.latitud,
    required this.longitud,
    required this.dni_lider_zona,
    required this.rec_lider_zona,
    required this.dni_usuario_logeado,
    required this.usuario_logeado,
    required this.estado,

  });

  int? id;
  String fecha_registro;
  String hora_registro;
  String region;
  String provincia;
  String distrito;
  String centro_poblado;
  String paradero;
  String numero_placa;
  String latitud;
  String longitud;
  String dni_lider_zona;
  int rec_lider_zona;
  String dni_usuario_logeado;
  int usuario_logeado;
  String estado;


  factory TareoLiderZona.fromJson(Map<String, dynamic> json) => TareoLiderZona(
    id: json[TareoLiderZonaFields.id],
    fecha_registro: json[TareoLiderZonaFields.fecha_registro],
    hora_registro: json[TareoLiderZonaFields.hora_registro],
    region: json[TareoLiderZonaFields.region],
    provincia: json[TareoLiderZonaFields.provincia],
    distrito: json[TareoLiderZonaFields.distrito],
    centro_poblado: json[TareoLiderZonaFields.centro_poblado],
    paradero: json[TareoLiderZonaFields.paradero],
    numero_placa: json[TareoLiderZonaFields.numero_placa],
    latitud: json[TareoLiderZonaFields.latitud],
    longitud: json[TareoLiderZonaFields.longitud],
    dni_lider_zona: json[TareoLiderZonaFields.dni_lider_zona],
    rec_lider_zona: json[TareoLiderZonaFields.rec_lider_zona],
    dni_usuario_logeado: json[TareoLiderZonaFields.dni_usuario_logeado],
    usuario_logeado: json[TareoLiderZonaFields.usuario_logeado],
    estado: json[TareoLiderZonaFields.estado],

  );

  Map<String, dynamic> toJson() => {
    TareoLiderZonaFields.id : id,
    TareoLiderZonaFields.fecha_registro : fecha_registro,
    TareoLiderZonaFields.hora_registro : hora_registro,
    TareoLiderZonaFields.region : region,
    TareoLiderZonaFields.provincia : provincia,
    TareoLiderZonaFields.distrito : distrito,
    TareoLiderZonaFields.centro_poblado : centro_poblado,
    TareoLiderZonaFields.paradero : paradero,
    TareoLiderZonaFields.numero_placa : numero_placa,
    TareoLiderZonaFields.latitud : latitud,
    TareoLiderZonaFields.longitud : longitud,
    TareoLiderZonaFields.dni_lider_zona : dni_lider_zona,
    TareoLiderZonaFields.rec_lider_zona : rec_lider_zona,
    TareoLiderZonaFields.dni_usuario_logeado : dni_usuario_logeado,
    TareoLiderZonaFields.usuario_logeado : usuario_logeado,
    TareoLiderZonaFields.estado : estado,


  };
}
