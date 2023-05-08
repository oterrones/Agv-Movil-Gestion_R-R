import 'dart:convert';


final String tableTrabajadorPistoleado= 'trabajadorPistoleado';

List<TrabajadorTareoPistoleado> trabajadorTareoPistoleadoFromJson(String str) => List<TrabajadorTareoPistoleado>.from(json.decode(str).map((x) => TrabajadorTareoPistoleado.fromJson(x)));

String trabajadorTareoPistoleadoToJson(List<TrabajadorTareoPistoleado> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TrabajadorPistoleadoFields {
  static final List<String> values = [
    dni_reclutado,
    nombres,
    apellidos,
    telefono_celular,
  ];

  static final String dni_reclutado = 'dni_reclutado';
  static final String nombres = 'nombres';
  static final String apellidos = 'apellidos';
  static final String telefono_celular = 'telefono_celular';
}

class TrabajadorTareoPistoleado {
  TrabajadorTareoPistoleado({
    this.dni_reclutado,
    this.nombres,
    this.apellidos,
    this.telefono_celular,
  });

  String? dni_reclutado;
  String? nombres;
  String? apellidos;
  String? telefono_celular;

  factory TrabajadorTareoPistoleado.fromJson(Map<String, dynamic> json) => TrabajadorTareoPistoleado(
    dni_reclutado: json[TrabajadorPistoleadoFields.dni_reclutado],
    nombres: json[TrabajadorPistoleadoFields.nombres],
    apellidos: json[TrabajadorPistoleadoFields.apellidos],
    telefono_celular: json[TrabajadorPistoleadoFields.telefono_celular],
  );

  Map<String, dynamic> toJson() => {
    TrabajadorPistoleadoFields.dni_reclutado : dni_reclutado,
    TrabajadorPistoleadoFields.nombres : nombres,
    TrabajadorPistoleadoFields.apellidos : apellidos,
    TrabajadorPistoleadoFields.telefono_celular : telefono_celular,
  };
}

class TrabajadorPistoleado_model {
  final int rows;
  final List<TrabajadorTareoPistoleado> trabajador_pistoleado;
  TrabajadorPistoleado_model({required this.rows, required this.trabajador_pistoleado});

  factory TrabajadorPistoleado_model.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['response'] as List;
    List<TrabajadorTareoPistoleado> response_aws_list = list.map((i) => TrabajadorTareoPistoleado.fromJson(i)).toList();

    return TrabajadorPistoleado_model(
      rows: parsedJson['rows'],
      trabajador_pistoleado: response_aws_list,
    );
  }

}
