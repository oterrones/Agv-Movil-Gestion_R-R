
import 'dart:convert';

List<PersonalReclutadoAws> welcomeFromJson(String str) => List<PersonalReclutadoAws>.from(json.decode(str).map((x) => PersonalReclutadoAws.fromJson(x)));

String welcomeToJson(List<PersonalReclutadoAws> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PersonalReclutadoAws {
  PersonalReclutadoAws({
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
    required this.rec_lider_zona_logeado_id,

  });

  String? fecha_registro;
  String? hora_registro;
  String? nombres;
  String? apellidos;
  String? dni_reclutado;
  String? region;
  String? provincia;
  String? distrito;
  String? centro_poblado;
  String? paradero;
  String? latitud;
  String? longitud;
  String? lider_zona;
  String? dni_lider_zona;
  String? estado;
  int? rec_lider_zona_id;
  String? numero_placa;
  int? rec_lider_zona_logeado_id;

  factory PersonalReclutadoAws.fromJson(Map<String, dynamic> json) => PersonalReclutadoAws(

    fecha_registro: json["fecha_registro"],
    hora_registro: json["hora_registro"],
    nombres: json["nombres"],
    apellidos: json["apellidos"],
    dni_reclutado: json["dni_reclutado"],
    region: json["region"],
    provincia: json["provincia"],
    distrito: json["distrito"],
    centro_poblado: json["centro_poblado"],
    paradero: json["paradero"],
    latitud: json["latitud"],
    longitud: json["longitud"],
    lider_zona: json["lider_zona"],
    dni_lider_zona: json["dni_lider_zona"],
    estado: json["estado"],
    rec_lider_zona_id: json["rec_lider_zona_id"],
    numero_placa: json["numero_placa"],
    rec_lider_zona_logeado_id: json["rec_lider_zona_logeado_id"],
  );

  Map<String, dynamic> toJson() => {
    "fecha_registro": fecha_registro,
    "hora_registro": hora_registro,
    "nombres": nombres,
    "apellidos": apellidos,
    "dni_reclutado": dni_reclutado,
    "region": region,
    "provincia": provincia,
    "distrito": distrito,
    "centro_poblado": centro_poblado,
    "paradero":paradero,
    "latitud":latitud,
    "longitud":longitud,
    "lider_zona":lider_zona,
    "dni_lider_zona":dni_lider_zona,
    "estado":estado,
    "rec_lider_zona_id":rec_lider_zona_id,
    "numero_placa":numero_placa,
    "rec_lider_zona_logeado_id":rec_lider_zona_logeado_id
  };
}

////////////

List<TareoLiderZonaAws> tareoLiderZonaFromJson(String str) => List<TareoLiderZonaAws>.from(json.decode(str).map((x) => TareoLiderZonaAws.fromJson(x)));

String tareoLiderZonaToJson(List<TareoLiderZonaAws> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TareoLiderZonaAws {
  TareoLiderZonaAws({
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
    required this.rec_lider_zona_id,
    required this.dni_usuario_logeado,
    required this.usuario_logeado_id,
    required this.estado,

  });

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
  int rec_lider_zona_id;
  String dni_usuario_logeado;
  int usuario_logeado_id;
  String estado;

  factory TareoLiderZonaAws.fromJson(Map<String, dynamic> json) => TareoLiderZonaAws(

    fecha_registro: json["fecha_registro"],
    hora_registro: json["hora_registro"],
    region: json["region"],
    provincia: json["provincia"],
    distrito: json["distrito"],
    centro_poblado: json["centro_poblado"],
    paradero: json["paradero"],
    numero_placa: json["numero_placa"],
    latitud: json["latitud"],
    longitud: json["longitud"],
    dni_lider_zona: json["dni_lider_zona"],
    rec_lider_zona_id: json["rec_lider_zona_id"],
    dni_usuario_logeado: json["dni_usuario_logeado"],
    usuario_logeado_id: json["usuario_logeado_id"],
    estado: json["estado"],
  );

  Map<String, dynamic> toJson() => {
    "fecha_registro": fecha_registro,
    "hora_registro": hora_registro,
    "region": region,
    "provincia": provincia,
    "distrito": distrito,
    "centro_poblado": centro_poblado,
    "paradero":paradero,
    "numero_placa":numero_placa,
    "latitud":latitud,
    "longitud":longitud,
    "dni_lider_zona":dni_lider_zona,
    "rec_lider_zona_id":rec_lider_zona_id,
    "dni_usuario_logeado":dni_usuario_logeado,
    "usuario_logeado_id":usuario_logeado_id,
    "estado":estado,

  };
}

////////////

List<DetalleTareoLiderZonaAws> detalleTareoLiderZonaFromJson(String str) => List<DetalleTareoLiderZonaAws>.from(json.decode(str).map((x) => DetalleTareoLiderZonaAws.fromJson(x)));

String detalleTareoLiderZonaToJson(List<DetalleTareoLiderZonaAws> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DetalleTareoLiderZonaAws {
  DetalleTareoLiderZonaAws({
    required this.dni_reclutado,
    required this.nombres,
    required this.apellidos,
    required this.telefono_celular,
    required this.estado,
    required this.rec_tareo_lider_zona_id,
  });

  String dni_reclutado;
  String nombres;
  String apellidos;
  String telefono_celular;
  String estado;
  int rec_tareo_lider_zona_id;

  factory DetalleTareoLiderZonaAws.fromJson(Map<String, dynamic> json) => DetalleTareoLiderZonaAws(

    dni_reclutado: json["dni_reclutado"],
    nombres: json["nombres"],
    apellidos: json["apellidos"],
    telefono_celular: json["telefono_celular"],
    estado: json["estado"],
    rec_tareo_lider_zona_id: json["rec_tareo_lider_zona_id"],
  );

  Map<String, dynamic> toJson() => {
    "dni_reclutado": dni_reclutado,
    "nombres": nombres,
    "apellidos": apellidos,
    "telefono_celular": telefono_celular,
    "estado": estado,
    "rec_tareo_lider_zona_id": rec_tareo_lider_zona_id,
  };
}


