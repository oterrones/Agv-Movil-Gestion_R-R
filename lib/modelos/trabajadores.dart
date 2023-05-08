import 'dart:convert';

final String tableTrabajadores = 'trabajador';

List<Trabajador> trabajadorFromJson(String str) => List<Trabajador>.from(json.decode(str).map((x) => Trabajador.fromJson(x)));

String evaluadorToJson(List<Trabajador> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TrabajadorFields {
  static final List<String> values = [
    id,
    nombresall,
    nrodocumento,
    appaterno,
    apmaterno,
    nombres,
  ];

  static final String id = 'id';
  static final String nombresall = 'nombresall';
  static final String nrodocumento = 'nrodocumento';
  static final String appaterno = 'appaterno';
  static final String apmaterno = 'apmaterno';
  static final String nombres = 'nombres';
}

class Trabajador {
  Trabajador({
    this.id,
    this.nombresall,
    this.nrodocumento,
    this.appaterno,
    this.apmaterno,
    this.nombres,
  });

  int? id;
  String? nombresall;
  String? nrodocumento;
  String? appaterno;
  String? apmaterno;
  String? nombres;


  factory Trabajador.fromJson(Map<String, dynamic> json) => Trabajador(
    id: json[TrabajadorFields.id],
    nombresall: json[TrabajadorFields.nombresall],
    nrodocumento: json[TrabajadorFields.nrodocumento],
    appaterno: json[TrabajadorFields.appaterno],
    apmaterno: json[TrabajadorFields.apmaterno],
    nombres: json[TrabajadorFields.nombres],
  );

  Map<String, dynamic> toJson() => {
    TrabajadorFields.id : id,
    TrabajadorFields.nombresall : nombresall,
    TrabajadorFields.nrodocumento : nrodocumento,
    TrabajadorFields.appaterno : appaterno,
    TrabajadorFields.apmaterno : apmaterno,
    TrabajadorFields.nombres : nombres,
  };
}

class Trabajador_model {
  final bool state;
  final List<Trabajador> trabajador;

  Trabajador_model({required this.state, required this.trabajador});

  factory Trabajador_model.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['response'] as List;
    List<Trabajador> response_sap_list = list.map((i) => Trabajador.fromJson(i)).toList();

    return Trabajador_model(
      state: parsedJson['state'],
      trabajador: response_sap_list,
    );
  }
}
