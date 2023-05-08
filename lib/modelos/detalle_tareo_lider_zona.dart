import 'dart:convert';

final String tableDetalleTareoLiderZona = 'detalleTareoLiderZona';

List<DetalleTareoLiderZona> detalleTareoLiderZonaFromJson(String str) => List<DetalleTareoLiderZona>.from(json.decode(str).map((x) => DetalleTareoLiderZona.fromJson(x)));

String detalleTareoLiderZonaToJson(List<DetalleTareoLiderZona> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DetalleTareoLiderZonaFields {
  static final List<String> values = [
    id,
    dni_reclutado,
    nombres,
    apellidos,
    telefono_celular,
    estado,
    estado_sincronizado,
    rec_tareo_lider_zona,

  ];

  static final String id = 'id';
  static final String dni_reclutado = 'dni_reclutado';
  static final String nombres = 'nombres';
  static final String apellidos = 'apellidos';
  static final String telefono_celular = 'telefono_celular';
  static final String estado = 'estado';
  static final String estado_sincronizado = 'estado_sincronizado';

  static final String rec_tareo_lider_zona = 'rec_tareo_lider_zona';

}

class DetalleTareoLiderZona {
  DetalleTareoLiderZona({
    this.id,
    required this.dni_reclutado,
    required this.nombres,
    required this.apellidos,
    required this.telefono_celular,
    required this.estado,
    required this.estado_sincronizado,
    required this.rec_tareo_lider_zona,

  });

  int? id;
  String dni_reclutado;
  String nombres;
  String apellidos;
  String telefono_celular;
  String estado;
  String estado_sincronizado;
  int rec_tareo_lider_zona;


  factory DetalleTareoLiderZona.fromJson(Map<String, dynamic> json) => DetalleTareoLiderZona(
    id: json[DetalleTareoLiderZonaFields.id],
    dni_reclutado: json[DetalleTareoLiderZonaFields.dni_reclutado],
    nombres: json[DetalleTareoLiderZonaFields.nombres],
    apellidos: json[DetalleTareoLiderZonaFields.apellidos],
    telefono_celular: json[DetalleTareoLiderZonaFields.telefono_celular],
    estado: json[DetalleTareoLiderZonaFields.estado],
    estado_sincronizado: json[DetalleTareoLiderZonaFields.estado_sincronizado],
    rec_tareo_lider_zona: json[DetalleTareoLiderZonaFields.rec_tareo_lider_zona],

  );

  Map<String, dynamic> toJson() => {
    DetalleTareoLiderZonaFields.id : id,
    DetalleTareoLiderZonaFields.dni_reclutado : dni_reclutado,
    DetalleTareoLiderZonaFields.nombres : nombres,
    DetalleTareoLiderZonaFields.apellidos : apellidos,
    DetalleTareoLiderZonaFields.telefono_celular : telefono_celular,
    DetalleTareoLiderZonaFields.estado : estado,
    DetalleTareoLiderZonaFields.estado_sincronizado : estado_sincronizado,
    DetalleTareoLiderZonaFields.rec_tareo_lider_zona : rec_tareo_lider_zona,

  };
}
