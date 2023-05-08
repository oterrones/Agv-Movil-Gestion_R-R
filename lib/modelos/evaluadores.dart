import 'dart:convert';

final String tableEvaluadores = 'evaluador';

List<Evaluador> evaluadorFromJson(String str) => List<Evaluador>.from(json.decode(str).map((x) => Evaluador.fromJson(x)));

String evaluadorToJson(List<Evaluador> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EvaluadorFields {
  static final List<String> values = [
    id,
    nombres,
    apellidos,
    dni,
    estado,
    usuario,
    categoriaEvaluadores,
    idBd,
  ];

  static final String id = 'id';
  static final String nombres = 'nombres';
  static final String apellidos = 'apellidos';
  static final String dni = 'dni';
  static final String estado = 'estado';
  static final String usuario = 'con_usuario';
  static final String categoriaEvaluadores = 'con_categoria_evaluadores';
  static final String idBd = 'id_bd';
}

class Evaluador {
  Evaluador({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.estado,
    required this.usuario,
    required this.categoriaEvaluadores,
    required this.idBd,
  });

  int id;
  String nombres;
  String apellidos;
  String dni;
  String estado;
  int usuario;
  int categoriaEvaluadores;
  int idBd;

  factory Evaluador.fromJson(Map<String, dynamic> json) => Evaluador(
    id: json[EvaluadorFields.id],
    nombres: json[EvaluadorFields.nombres],
    apellidos: json[EvaluadorFields.apellidos],
    dni: json[EvaluadorFields.dni],
    estado: json[EvaluadorFields.estado],
    usuario: json[EvaluadorFields.usuario],
    categoriaEvaluadores: json[EvaluadorFields.categoriaEvaluadores],
    idBd: json[EvaluadorFields.id],
  );

  Map<String, dynamic> toJson() => {
    EvaluadorFields.id : id,
    EvaluadorFields.nombres : nombres,
    EvaluadorFields.apellidos : apellidos,
    EvaluadorFields.dni : dni,
    EvaluadorFields.estado : estado,
    EvaluadorFields.usuario : usuario,
    EvaluadorFields.categoriaEvaluadores : categoriaEvaluadores,
    EvaluadorFields.idBd : idBd,
  };
}
