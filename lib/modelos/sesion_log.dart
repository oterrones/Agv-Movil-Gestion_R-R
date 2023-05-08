import 'dart:convert';

final String tableSesionLog = 'sesion_log';

List<SesionLog> logFromJson(String str) => List<SesionLog>.from(json.decode(str).map((x) => SesionLog.fromJson(x)));

String logToJson(List<SesionLog> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SesionLogFields {
  static final List<String> values = [
    id,
    visited,
    app,
    estado,
    idBdEvaluador,
    idEvaluador,
  ];

  static final String id = 'id';
  static final String visited = 'visited';
  static final String app = 'app';
  static final String estado = 'estado';
  static final String idBdEvaluador = 'id_bd_evaluador';
  static final String idEvaluador = 'id_evaluador';
}

class SesionLog {
  SesionLog({
    this.id,
    required this.visited,
    required this.app,
    required this.estado,
    required this.idBdEvaluador,
    required this.idEvaluador,
  });

  int? id;
  DateTime visited;
  String app;
  String estado;
  int idBdEvaluador;
  int idEvaluador;

  factory SesionLog.fromJson(Map<String, dynamic> json) => SesionLog(
    id: json[SesionLogFields.id],
    visited: DateTime.parse(json[SesionLogFields.visited]),
    app: json[SesionLogFields.app],
    estado: json[SesionLogFields.estado],
    idBdEvaluador: json[SesionLogFields.idBdEvaluador],
    idEvaluador: json[SesionLogFields.idEvaluador],
  );

  Map<String, dynamic> toJson() => {
    SesionLogFields.id: id,
    SesionLogFields.visited: visited.toIso8601String(),
    SesionLogFields.app: app,
    SesionLogFields.estado: estado,
    SesionLogFields.idBdEvaluador: idBdEvaluador,
    SesionLogFields.idEvaluador: idEvaluador,
  };
}
