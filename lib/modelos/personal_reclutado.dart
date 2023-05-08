import 'dart:convert';

final String tablePersonalReclutado = 'personalReclutado';

List<PersonalReclutado> personalReclutadoFromJson(String str) => List<PersonalReclutado>.from(json.decode(str).map((x) => PersonalReclutado.fromJson(x)));

String personalReclutadoToJson(List<PersonalReclutado> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PersonalReclutadoFields {
  static final List<String> values = [
    id,
    fecha_registro,
    hora_registro,
    nombres,
    apellidos,
    dni_reclutado,
    region,
    provincia,
    distrito,
    centro_poblado,
    paradero,
    latitud,
    longitud,
    lider_zona,
    dni_lider_zona,
    estado,
    rec_lider_zona_id,
    numero_placa,
    rec_lider_zona_logeado,

  ];

  static final String id = 'id';
  static final String fecha_registro = 'fecha_registro';
  static final String hora_registro = 'hora_registro';
  static final String nombres = 'nombres';
  static final String apellidos = 'apellidos';
  static final String dni_reclutado = 'dni_reclutado';
  static final String region = 'region';
  static final String provincia = 'provincia';
  static final String distrito = 'distrito';
  static final String centro_poblado = 'centro_poblado';
  static final String paradero = 'paradero';
  static final String latitud = 'latitud';
  static final String longitud = 'longitud';
  static final String lider_zona = 'lider_zona';
  static final String dni_lider_zona = 'dni_lider_zona';
  static final String estado = 'estado';
  static final String rec_lider_zona_id = 'rec_lider_zona_id';
  static final String numero_placa = 'numero_placa';
  static final String rec_lider_zona_logeado = 'rec_lider_zona_logeado';

}

class PersonalReclutado {
  PersonalReclutado({
    this.id,
    required this.fecha_registro,
    required this.hora_registro,
    required this.nombres,
    required this.apellidos,
    required this.dni_reclutado,
    required this.region,
    required this.provincia,
    required this.distrito,
    required this.centro_poblado,
    required this.paradero,
    required this.latitud,
    required this.longitud,
    required this.lider_zona,
    required this.dni_lider_zona,
    required this.estado,
    required this.rec_lider_zona_id,
    required this.numero_placa,
    required this.rec_lider_zona_logeado,

  });

  int? id;
  String fecha_registro;
  String hora_registro;
  String nombres;
  String apellidos;
  String dni_reclutado;
  String region;
  String provincia;
  String distrito;
  String centro_poblado;
  String paradero;
  String latitud;
  String longitud;
  String lider_zona;
  String dni_lider_zona;
  String estado;
  int rec_lider_zona_id;
  String numero_placa;
  int rec_lider_zona_logeado;


  factory PersonalReclutado.fromJson(Map<String, dynamic> json) => PersonalReclutado(
    id: json[PersonalReclutadoFields.id],
    fecha_registro: json[PersonalReclutadoFields.fecha_registro],
    hora_registro: json[PersonalReclutadoFields.hora_registro],
    nombres: json[PersonalReclutadoFields.nombres],
    apellidos: json[PersonalReclutadoFields.apellidos],
    dni_reclutado: json[PersonalReclutadoFields.dni_reclutado],
    region: json[PersonalReclutadoFields.region],
    provincia: json[PersonalReclutadoFields.provincia],
    distrito: json[PersonalReclutadoFields.distrito],
    centro_poblado: json[PersonalReclutadoFields.centro_poblado],
    paradero: json[PersonalReclutadoFields.paradero],
    latitud: json[PersonalReclutadoFields.latitud],
    longitud: json[PersonalReclutadoFields.longitud],
    lider_zona: json[PersonalReclutadoFields.lider_zona],
    dni_lider_zona: json[PersonalReclutadoFields.dni_lider_zona],
    estado: json[PersonalReclutadoFields.estado],
    rec_lider_zona_id: json[PersonalReclutadoFields.rec_lider_zona_id],
    numero_placa: json[PersonalReclutadoFields.numero_placa],
    rec_lider_zona_logeado: json[PersonalReclutadoFields.rec_lider_zona_logeado],
  );

  Map<String, dynamic> toJson() => {
    PersonalReclutadoFields.id : id,
    PersonalReclutadoFields.fecha_registro : fecha_registro,
    PersonalReclutadoFields.hora_registro : hora_registro,
    PersonalReclutadoFields.nombres : nombres,
    PersonalReclutadoFields.apellidos : apellidos,
    PersonalReclutadoFields.dni_reclutado : dni_reclutado,
    PersonalReclutadoFields.region : region,
    PersonalReclutadoFields.provincia : provincia,
    PersonalReclutadoFields.distrito : distrito,
    PersonalReclutadoFields.centro_poblado : centro_poblado,
    PersonalReclutadoFields.paradero : paradero,
    PersonalReclutadoFields.paradero : paradero,
    PersonalReclutadoFields.latitud : latitud,
    PersonalReclutadoFields.longitud : longitud,
    PersonalReclutadoFields.lider_zona : lider_zona,
    PersonalReclutadoFields.dni_lider_zona : dni_lider_zona,
    PersonalReclutadoFields.estado : estado,
    PersonalReclutadoFields.rec_lider_zona_id : rec_lider_zona_id,
    PersonalReclutadoFields.numero_placa : numero_placa,
    PersonalReclutadoFields.rec_lider_zona_logeado : rec_lider_zona_logeado,


  };
}
