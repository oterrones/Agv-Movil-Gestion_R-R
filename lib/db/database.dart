import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:proyectoryr/modelos/centro_poblado.dart';
import 'package:proyectoryr/modelos/detalle_tareo_lider_zona.dart';
import 'package:proyectoryr/modelos/distrito.dart';
import 'package:proyectoryr/modelos/evaluadores.dart';
import 'package:proyectoryr/modelos/lider_zona.dart';
import 'package:proyectoryr/modelos/paradero.dart';
import 'package:proyectoryr/modelos/personal_reclutado.dart';
import 'package:proyectoryr/modelos/provincia.dart';
import 'package:proyectoryr/modelos/region.dart';
import 'package:proyectoryr/modelos/registro_foto.dart';
import 'package:proyectoryr/modelos/sesion_log.dart';
import 'package:proyectoryr/modelos/tareo_lider_zona.dart';
import 'package:proyectoryr/modelos/trabajadores.dart';
import 'package:proyectoryr/modelos/trabajadores_pistoleado.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/enviarServidor.dart';

class AgrovisionDataBase {
  static final AgrovisionDataBase bd = AgrovisionDataBase._init();

  static Database? _database;
  AgrovisionDataBase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('agrovision08.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 4, onCreate: _createTabla);
  }

  Future _createTabla(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final textTypeN = 'TEXT NULL';
    final integerType = 'INTEGER NOT NULL';
    final integerTypeN = 'INTEGER NULL';

    await db.execute(
        '''
        CREATE TABLE $tableEvaluadores (
          ${EvaluadorFields.id} $idType,
          ${EvaluadorFields.nombres} $textType,
          ${EvaluadorFields.apellidos} $textType,
          ${EvaluadorFields.dni} $textType,
          ${EvaluadorFields.estado} $textType,
          ${EvaluadorFields.usuario} $integerType,
          ${EvaluadorFields.categoriaEvaluadores} $integerType,
          ${EvaluadorFields.idBd} $integerTypeN
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableRegistros (
          ${RegistroFields.id} $idType,
          ${RegistroFields.fecha} $textType,
          ${RegistroFields.dniTrabajador} $textType,
          ${RegistroFields.nombreTrabajador} $textType,
          ${RegistroFields.observacion} $textType,
          ${RegistroFields.estadoE} $textType,
          ${RegistroFields.latitud} $textType,
          ${RegistroFields.longitud} $textType,
          ${RegistroFields.estado} $textType,
          ${RegistroFields.idResponsable} $integerType,
          ${RegistroFields.idBd} $integerTypeN
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableFotos (
          ${FotoFields.id} $idType,
          ${FotoFields.file} $textType,
          ${FotoFields.estado} $textType,
          ${FotoFields.idRegistro} $integerType,
          ${FotoFields.idBd} $integerTypeN
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableSesionLog (
          ${SesionLogFields.id} $idType,
          ${SesionLogFields.visited} $textType,
          ${SesionLogFields.app} $textType,
          ${SesionLogFields.estado} $textType,
          ${SesionLogFields.idBdEvaluador} $integerTypeN,
          ${SesionLogFields.idEvaluador} $integerTypeN
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableTrabajadores (
          ${TrabajadorFields.id} $idType,
          ${TrabajadorFields.nombresall} $textTypeN,
          ${TrabajadorFields.nrodocumento} $textTypeN,
          ${TrabajadorFields.appaterno} $textTypeN,
          ${TrabajadorFields.apmaterno} $textTypeN,
          ${TrabajadorFields.nombres} $textTypeN
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableLiderZona (
          ${LiderZonaFields.id} $idType,
          ${LiderZonaFields.nombres} $textTypeN,
          ${LiderZonaFields.apellidos} $textTypeN,
          ${LiderZonaFields.dni} $textTypeN,
          ${LiderZonaFields.estado} $textType
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableRegion (
          ${RegionFields.id} $idType,
          ${RegionFields.nombre} $textTypeN,
          ${RegionFields.rec_pais} $integerTypeN,
          ${RegionFields.estado} $textType
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableProvincia (
          ${ProvinciaFields.id} $idType,
          ${ProvinciaFields.nombre} $textTypeN,
          ${ProvinciaFields.rec_region} $integerTypeN,
          ${ProvinciaFields.estado} $textType
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableDistrito (
          ${DistritoFields.id} $idType,
          ${DistritoFields.nombre} $textTypeN,
          ${DistritoFields.rec_provincia} $integerTypeN,
          ${DistritoFields.estado} $textType
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tablePersonalReclutado (
          ${PersonalReclutadoFields.id} $idType,
          ${PersonalReclutadoFields.fecha_registro} $textTypeN,
          ${PersonalReclutadoFields.hora_registro} $textTypeN,
          ${PersonalReclutadoFields.nombres} $textTypeN,
          ${PersonalReclutadoFields.apellidos} $textTypeN,
          ${PersonalReclutadoFields.dni_reclutado} $textTypeN,
          ${PersonalReclutadoFields.region} $textTypeN,
          ${PersonalReclutadoFields.provincia} $textTypeN,
          ${PersonalReclutadoFields.distrito} $textTypeN,
          ${PersonalReclutadoFields.centro_poblado} $textTypeN,
          ${PersonalReclutadoFields.paradero} $textTypeN,
          ${PersonalReclutadoFields.latitud} $textTypeN,
          ${PersonalReclutadoFields.longitud} $textTypeN,
          ${PersonalReclutadoFields.lider_zona} $textTypeN,
          ${PersonalReclutadoFields.dni_lider_zona} $textTypeN,
          ${PersonalReclutadoFields.estado} $textTypeN,
          ${PersonalReclutadoFields.rec_lider_zona_id} $integerTypeN,
          ${PersonalReclutadoFields.numero_placa} $textTypeN,
          ${PersonalReclutadoFields.rec_lider_zona_logeado} $integerTypeN
          
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableCentroPoblado (
          ${CentroPobladoFields.id} $idType,
          ${CentroPobladoFields.nombre} $textTypeN,
          ${CentroPobladoFields.estado} $textTypeN,
          ${CentroPobladoFields.rec_distrito} $integerTypeN    
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableParadero (
          ${ParaderoFields.id} $idType,
          ${ParaderoFields.nombre} $textTypeN,
          ${ParaderoFields.estado} $textTypeN,
          ${ParaderoFields.rec_centro_poblado} $integerTypeN    
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableTareoLiderZona (
          ${TareoLiderZonaFields.id} $idType,
          ${TareoLiderZonaFields.numero_placa} $textTypeN,
          ${TareoLiderZonaFields.fecha_registro} $textTypeN,
          ${TareoLiderZonaFields.hora_registro} $textTypeN,
          ${TareoLiderZonaFields.region} $textTypeN,
          ${TareoLiderZonaFields.provincia} $integerTypeN,    
          ${TareoLiderZonaFields.distrito} $integerTypeN,   
          ${TareoLiderZonaFields.centro_poblado} $textTypeN,
          ${TareoLiderZonaFields.paradero} $textTypeN,
          ${TareoLiderZonaFields.latitud} $textTypeN,
          ${TareoLiderZonaFields.longitud} $textTypeN,
          ${TareoLiderZonaFields.dni_lider_zona} $textTypeN,
          ${TareoLiderZonaFields.rec_lider_zona} $integerTypeN,
          ${TareoLiderZonaFields.dni_usuario_logeado} $textTypeN,
          ${TareoLiderZonaFields.usuario_logeado} $integerTypeN,
          ${TareoLiderZonaFields.estado} $textTypeN
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableDetalleTareoLiderZona (
          ${DetalleTareoLiderZonaFields.id} $idType,
          ${DetalleTareoLiderZonaFields.dni_reclutado} $textTypeN,
          ${DetalleTareoLiderZonaFields.nombres} $textTypeN,
          ${DetalleTareoLiderZonaFields.apellidos} $textTypeN,   
          ${DetalleTareoLiderZonaFields.telefono_celular} $textTypeN,   
          ${DetalleTareoLiderZonaFields.estado} $textTypeN,  
          ${DetalleTareoLiderZonaFields.estado_sincronizado} $textTypeN,            
          ${DetalleTareoLiderZonaFields.rec_tareo_lider_zona} $integerType   
        );
      '''
    );

    await db.execute(
        '''
        CREATE TABLE $tableTrabajadorPistoleado (
          ${TrabajadorPistoleadoFields.dni_reclutado} $textTypeN,
          ${TrabajadorPistoleadoFields.nombres} $textTypeN,
          ${TrabajadorPistoleadoFields.apellidos} $textTypeN,
          ${TrabajadorPistoleadoFields.telefono_celular} $textTypeN    
        );
      '''
    );


  }

  //Evaluadores
  Future<List<Evaluador>> obtenerEvaluadores() async {
    final db = await bd.database;
    final orderBy = '${EvaluadorFields.id} ASC';
    final result = await db.query(tableEvaluadores, orderBy: orderBy);

    return result.map((json) => Evaluador.fromJson(json)).toList();
  }

  Future<bool> obtenerEvaluador(String dni) async {
    final db = await bd.database;
    final result = await db.query(tableEvaluadores, where: 'dni = ? and con_categoria_evaluadores = ?', whereArgs: [dni, 2]);

    final evalu = result.map((json) => Evaluador.fromJson(json)).toList();

    if(evalu.isNotEmpty){
      final Batch batch = db.batch();
      batch.insert(tableSesionLog, SesionLog(visited: DateTime.now(), app: "R y R", estado: '0', idBdEvaluador: evalu[0].idBd, idEvaluador: evalu[0].id).toJson());
      await batch.commit();
      return true;
    }else{
      return false;
    }
  }

  crearEvaluador(List<Evaluador> nuevoEvaluador) async {
    await borrarTodosEvaluadores();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final Evaluador item in nuevoEvaluador){
      batch.insert(tableEvaluadores, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosEvaluadores() async {
    final db = await bd.database;
    await db.delete(tableEvaluadores);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableEvaluadores'");
    return 0;
  }


  //Trabajadores
  crearTrabajador(List<Trabajador> nuevoTrabajador) async {
    await borrarTodosTrabajadores();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final Trabajador item in nuevoTrabajador){
      batch.insert(tableTrabajadores, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  //Trabajadores Tareo Pistoleo
  crearTrabajadorTareoPistoleo(List<TrabajadorTareoPistoleado> nuevoTrabajadorPistoleo) async {
    await borrarTodosTrabajadoresPistoleo();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final TrabajadorTareoPistoleado item in nuevoTrabajadorPistoleo){
      batch.insert(tableTrabajadorPistoleado, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosTrabajadores() async {
    final db = await bd.database;
    await db.delete(tableTrabajadores);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableTrabajadores'");
    return 0;
  }

  Future<int> borrarTodosTrabajadoresPistoleo() async {
    final db = await bd.database;
    await db.delete(tableTrabajadorPistoleado);
    return 0;
  }

  Future<List<Trabajador>> obtenerTrabajador(String dni) async {
    final db = await bd.database;
    final result = await db.query(tableTrabajadores, where: 'nrodocumento = ? and nrodocumento != ""', whereArgs: [dni]);

    return result.map((json) => Trabajador.fromJson(json)).toList();
  }


  //Responsable
  Future<List<Evaluador>> obtenerResponsable() async {
    final db = await bd.database;
    final result = await db.rawQuery("select eva.* from sesion_log sl inner join evaluador eva on eva.id = sl.id_evaluador order by sl.id desc limit 1;");
    return result.map((e) => Evaluador.fromJson(e)).toList();
  }

  //Responsable Lider Zona
  Future<List<LiderZona>> obtenerResponsableLiderZona() async {
    final db = await bd.database;
    final result = await db.rawQuery("select eva.* from sesion_log sl inner join liderZona eva on eva.id = sl.id_evaluador order by sl.id desc limit 1;");
    return result.map((e) => LiderZona.fromJson(e)).toList();
  }

  //Responsable Lider Zona
  Future<List<LiderZona>> buscarResponsableLiderZona(String dni) async {
    final db = await bd.database;
    final result = await db.rawQuery("select * from liderZona where dni = '$dni' limit 1;");
    return result.map((e) => LiderZona.fromJson(e)).toList();
  }


  //Registro Foto
  crearRegFot(Registro nuevoRegistro) async {
    final db = await bd.database;
    final Batch batch = db.batch();

    batch.insert(tableRegistros, {
      RegistroFields.fecha: nuevoRegistro.fecha,
      RegistroFields.dniTrabajador: nuevoRegistro.dniTrabajador,
      RegistroFields.nombreTrabajador: nuevoRegistro.nombreTrabajador,
      RegistroFields.observacion: nuevoRegistro.observacion,
      RegistroFields.estadoE: nuevoRegistro.estadoE,
      RegistroFields.latitud: nuevoRegistro.latitud,
      RegistroFields.longitud: nuevoRegistro.longitud,
      RegistroFields.estado: nuevoRegistro.estado,
      RegistroFields.idResponsable: nuevoRegistro.idResponsable,
    });

    var result = await batch.commit();
    var idReg = result.first as int;

    final Batch batch2 = db.batch();


    for(final Foto fotos in nuevoRegistro.fotos_ryr){
      batch2.insert(tableFotos, {
        FotoFields.file: fotos.file,
        FotoFields.estado: fotos.estado,
        FotoFields.idRegistro: idReg,
      });
    }

    await batch2.commit(noResult: true);
  }

  Future<List<Registro>> obtenerRegistros() async {
    final db = await bd.database;
    List<Map> result = await db.rawQuery("select r.id as id_r, r.fecha, r.dni_trabajador, r.nombre_trabajador, r.observacion, r.estado_e, r.latitud, r.longitud, r.estado as estado_r, r.id_responsable, r.id_bd as bd_r, f.id, f.file, f.estado, f.id_registro, f.id_bd  from registros r inner join fotos f on r.id = f.id_registro;");

    var newMap = groupBy(result, (Map obj) => obj['id_r']);

    List<Map<String, dynamic>> newMap2 = [];

    newMap.forEach((key, value) {
      newMap2.add({
        RegistroFields.id: value[0]['id_r'],
        RegistroFields.fecha: value[0]['fecha'],
        RegistroFields.dniTrabajador: value[0]['dni_trabajador'],
        RegistroFields.nombreTrabajador: value[0]['nombre_trabajador'],
        RegistroFields.observacion: value[0]['observacion'],
        RegistroFields.estadoE: value[0]['estado_e'],
        RegistroFields.latitud: value[0]['latitud'],
        RegistroFields.longitud: value[0]['longitud'],
        RegistroFields.estado: value[0]['estado_r'],
        RegistroFields.idResponsable: value[0]['id_responsable'],
        RegistroFields.idBd: value[0]['bd_r'],
        RegistroFields.fotos: value,
      });
    });

    return newMap2.map((json) => Registro.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerRegFot() async {
    final db = await bd.database;
    return await db.rawQuery("select reg.id, reg.fecha, reg.dni_trabajador, reg.nombre_trabajador, reg.observacion, reg.estado_e, reg.latitud, reg.longitud, reg.estado, eva.nombres, eva.apellidos, fot.file from registros reg inner join fotos fot on reg.id = fot.id_registro inner join evaluador eva on reg.id_responsable = eva.id order by reg.id desc;");
  }

  Future<List<Foto>> obtenerFotos(int idReg) async {
    final db = await bd.database;
    final orderBy = '${FotoFields.id} ASC';
    final result = await db.query(tableFotos, orderBy: orderBy, where: 'id_registro = ?', whereArgs: [idReg]);

    return result.map((json) => Foto.fromJson(json)).toList();
  }

  Future actualizarReg(int idLocal, int idBD) async {
    final db = await bd.database;
    await db.update(tableRegistros, {'estado': '1', 'id_bd': idBD}, where: 'id = ?', whereArgs: [idLocal]);
  }

  Future actualizarFot(int idLocal, int idBD) async {
    final db = await bd.database;
    await db.update(tableFotos, {'estado': '1', 'id_bd': idBD}, where: 'id = ?', whereArgs: [idLocal]);
  }


  // Lideres de Zona

  crearLiderZona(List<LiderZona> nuevoLideresZona) async {
    await borrarTodosLideresZona();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final LiderZona item in nuevoLideresZona){
      batch.insert(tableLiderZona, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosLideresZona() async {
    final db = await bd.database;
    await db.delete(tableLiderZona);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableLiderZona'");
    return 0;
  }

  // Región

  crearRegion(List<Region> nuevoRegion) async {
    await borrarTodosRegion();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final Region item in nuevoRegion){
      batch.insert(tableRegion, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosRegion() async {
    final db = await bd.database;
    await db.delete(tableRegion);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableRegion'");
    return 0;
  }

  // Provincia

  crearProvincia(List<Provincia> nuevoProvincia) async {
    await borrarTodosProvincia();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final Provincia item in nuevoProvincia){
      batch.insert(tableProvincia, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosProvincia() async {
    final db = await bd.database;
    await db.delete(tableProvincia);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableProvincia'");
    return 0;
  }

  crearDistrito(List<Distrito> nuevoDistrito) async {
    await borrarTodosDistrito();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final Distrito item in nuevoDistrito){
      batch.insert(tableDistrito, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosDistrito() async {
    final db = await bd.database;
    await db.delete(tableDistrito);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableDistrito'");
    return 0;
  }

  Future<List<Map<String, dynamic>>> obtenerProvincias(String nombre) async {
    final db = await bd.database;
    final query = """
          select  prov.id,prov.nombre  from provincia prov 
          inner join region reg on (prov.rec_region = reg.id)
          where UPPER(reg.nombre) = '$nombre' ;
        """;
    return await db.rawQuery(query);
  }
  Future<List<Map<String, dynamic>>> obtenerRegiones() async {
    final db = await bd.database;
    final query = "Select * from region order by nombre ";
    return await db.rawQuery(query);
  }
  Future<List<Map<String, dynamic>>> obtenerDistritos(String nombre) async {
    final db = await bd.database;
    final query = """
          select  prov.id,prov.nombre  from distrito prov 
          inner join provincia reg on (prov.rec_provincia = reg.id)
          where UPPER(reg.nombre) = '$nombre' 
          order by prov.nombre ;
        """;
    return await db.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> obtenerCentroPoblados(String nombre) async {
    final db = await bd.database;
    final query = """
          select  prov.id,prov.nombre  from centroPoblado prov 
          inner join distrito reg on (prov.rec_distrito = reg.id)
          where UPPER(reg.nombre) = UPPER('$nombre')  
          order by prov.nombre  ;
        """;
    return await db.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> obtenerParaderos(String nombre) async {
    final db = await bd.database;
    final query = """
          select  par.id,par.nombre  from paradero par 
          inner join centroPoblado reg on (par.rec_centro_poblado = reg.id)
          where UPPER(reg.nombre) = UPPER('$nombre') order by par.nombre ;
        """;
    return await db.rawQuery(query);
  }

  Future<List<Trabajador>> obtenerReclutadoReniec(String dni) async {
    final db = await bd.database;
    final result = await db.query(tableTrabajadores, where: 'nrodocumento = ? and nrodocumento != ""', whereArgs: [dni]);

    return result.map((json) => Trabajador.fromJson(json)).toList();
  }

  //Registro Foto
  Future <int> crearPersonalReclatado(PersonalReclutado nuevoPersonalReclutado) async {
    final db = await bd.database;
    final Batch batch = db.batch();

    batch.insert(tablePersonalReclutado, {
      PersonalReclutadoFields.fecha_registro: nuevoPersonalReclutado.fecha_registro,
      PersonalReclutadoFields.hora_registro: nuevoPersonalReclutado.hora_registro,
      PersonalReclutadoFields.nombres: nuevoPersonalReclutado.nombres,
      PersonalReclutadoFields.apellidos: nuevoPersonalReclutado.apellidos,
      PersonalReclutadoFields.dni_reclutado: nuevoPersonalReclutado.dni_reclutado,
      PersonalReclutadoFields.region: nuevoPersonalReclutado.region,
      PersonalReclutadoFields.provincia: nuevoPersonalReclutado.provincia,
      PersonalReclutadoFields.distrito: nuevoPersonalReclutado.distrito,
      PersonalReclutadoFields.centro_poblado: nuevoPersonalReclutado.centro_poblado,
      PersonalReclutadoFields.paradero: nuevoPersonalReclutado.paradero,
      PersonalReclutadoFields.latitud: nuevoPersonalReclutado.latitud,
      PersonalReclutadoFields.longitud: nuevoPersonalReclutado.longitud,
      PersonalReclutadoFields.lider_zona: nuevoPersonalReclutado.lider_zona,
      PersonalReclutadoFields.dni_lider_zona: nuevoPersonalReclutado.dni_lider_zona,
      PersonalReclutadoFields.estado: nuevoPersonalReclutado.estado,
      PersonalReclutadoFields.rec_lider_zona_id: nuevoPersonalReclutado.rec_lider_zona_id,
      PersonalReclutadoFields.numero_placa: nuevoPersonalReclutado.numero_placa,
      PersonalReclutadoFields.rec_lider_zona_logeado: nuevoPersonalReclutado.rec_lider_zona_logeado,
    });

    var result = await batch.commit();
    var idReg = result.first as int;
    return idReg;


  }

  Future<List<Map<String, dynamic>>> obtenerRegPersonalReclutado() async {
    final db = await bd.database;
    final query = """
        SELECT
          id
          ,fecha_registro
          ,hora_registro
          ,lider_zona
          ,region
          ,provincia
          ,distrito
          ,centro_poblado
          ,paradero
          ,latitud
          ,longitud
          ,estado
          ,total_reclutado
          
          from 
            (select  tar.id,fecha_registro,hora_registro,lid.apellidos||lid.nombres as lider_zona,region,provincia,distrito,centro_poblado,paradero,latitud,longitud,tar.estado
                from tareoLiderZona tar   
                inner join  liderZona lid on (tar.dni_lider_zona = lid.dni) 
                where tar.estado = '0' ) as tbl_01
            inner join 
            (select  rec_tareo_lider_zona, count(*) as total_reclutado  
            from detalleTareoLiderZona  where  estado = '0'  
            group by rec_tareo_lider_zona
            ) as tbl_02
            on (tbl_01.id = tbl_02.rec_tareo_lider_zona)
 
        """;
    return await db.rawQuery(query);
  }

  Future<List<TareoLiderZonaAws>?> getAllPersonalTareoLiderMovilAws() async {
    final db = await database;
    final sql = '''
                 SELECT 
                  fecha_registro
                  , hora_registro
                  , region
                  , provincia
                  , distrito
                  , centro_poblado
                  , paradero
                  , numero_placa
                  , latitud
                  , longitud
                  , dni_lider_zona
                  , rec_lider_zona as rec_lider_zona_id
                  , dni_usuario_logeado
                  , usuario_logeado as usuario_logeado_id
                  , '1' as estado
                  FROM tareoLiderZona                  
                  where estado = '0' 
 
                ''';
    final res = await db.rawQuery(sql);
    return res.isNotEmpty
        ? res.map((s) => TareoLiderZonaAws.fromJson(s)).toList()
        : [];
  }
  Future<List<Map<String, dynamic>>> ListaGetAllPersonalTareoLiderMovilAws() async {
    final db = await database;
    final sql = '''
                 SELECT 
                  id
                  , fecha_registro
                  , hora_registro
                  , region
                  , provincia
                  , distrito
                  , centro_poblado
                  , paradero
                  , numero_placa
                  , latitud
                  , longitud
                  , dni_lider_zona
                  , rec_lider_zona as rec_lider_zona_id
                  , dni_usuario_logeado
                  , usuario_logeado as usuario_logeado_id
                  , '1' as estado
                  FROM tareoLiderZona                  
                  where estado = '0' 
 
                ''';
    final resultado = await db.rawQuery(sql);
    return resultado;
  }


  Future<void> AllUpdatePersonalReclutado() async {
    final db = await database;
    final sql = "UPDATE personalReclutado set estado = '1' where estado = '0'";
    final res = await db.rawUpdate(sql);
  }

  //Lideres Zona
  Future<List<LiderZona>> obtenerLideresZona() async {
    final db = await bd.database;
    final orderBy = '${LiderZonaFields.id} ASC';
    final result = await db.query(tableLiderZona, orderBy: orderBy);

    return result.map((json) => LiderZona.fromJson(json)).toList();
  }

  Future<bool> obtenerLiderZona(String dni) async {
    final db = await bd.database;
    final result = await db.query(tableLiderZona, where: 'dni = ? ', whereArgs: [dni]);

    final evalu = result.map((json) => LiderZona.fromJson(json)).toList();
    print(evalu);

    if(evalu.isNotEmpty){
      final Batch batch = db.batch();
      batch.insert(tableSesionLog, SesionLog(visited: DateTime.now(), app: "R y R", estado: '0', idBdEvaluador: evalu[0].id, idEvaluador: evalu[0].id).toJson());
      await batch.commit();
      return true;
    }else{
      return false;
    }
  }

  crearCentroPoblado(List<CentroPoblado> nuevoCentroPoblado) async {
    await borrarTodosCentroPoblado();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final CentroPoblado item in nuevoCentroPoblado){
      batch.insert(tableCentroPoblado, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosCentroPoblado() async {
    final db = await bd.database;
    await db.delete(tableCentroPoblado);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableCentroPoblado'");
    return 0;
  }

  crearParadero(List<Paradero> nuevoParadero) async {
    await borrarTodosParadero();
    final db = await bd.database;
    final Batch batch = db.batch();
    for(final Paradero item in nuevoParadero){
      batch.insert(tableParadero, item.toJson());
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrarTodosParadero() async {
    final db = await bd.database;
    await db.delete(tableParadero);

    await db.rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableParadero'");
    return 0;
  }

  Future<void> AllUpdateDetalleTareoZona(int codigoTareoLocal,String valor,String valorCondicional) async {
    // -1: VALOR TEMPORAL - 1: VALOR SINCRONIZADO
    final db = await database;
    final sql = "UPDATE detalleTareoLiderZona set estado = '$valor' where estado = '$valorCondicional' and rec_tareo_lider_zona = $codigoTareoLocal ";
    final res = await db.rawUpdate(sql);
  }

  Future<void> AllUpdateDetalleTareoZonaZincronizadoId(int codigoTareoLocal,String valor,String valorCondicional) async {
    // -1: VALOR TEMPORAL - 1: VALOR SINCRONIZADO
    final db = await database;
    final sql = "UPDATE detalleTareoLiderZona set estado_sincronizado = '$valor' where estado = '$valorCondicional' and rec_tareo_lider_zona = $codigoTareoLocal ";
    final res = await db.rawUpdate(sql);

  }

  Future<void> AllUpdateDetalleTareoZonaZincronizadoAll() async {
    // -1: VALOR TEMPORAL - 1: VALOR SINCRONIZADO
    final db = await database;
    final sql = "UPDATE detalleTareoLiderZona set estado_sincronizado = '2' where estado_sincronizado != '2'";
    final res = await db.rawUpdate(sql);

  }

  Future<List<DetalleTareoLiderZonaAws>?> getAllDetalleTareoMovilServer(int codigoTareoLocal, int codigoTareoServer) async {
    final db = await database;
    final sql = '''
                SELECT
                    dni_reclutado 
                   	, nombres
                    , apellidos
                    , telefono_celular
                    , '1' as estado
                    , $codigoTareoServer as rec_tareo_lider_zona_id
                  FROM detalleTareoLiderZona                  
                  where estado = '0' and rec_tareo_lider_zona = $codigoTareoLocal
 
                ''';
    final res = await db.rawQuery(sql);
    return res.isNotEmpty
        ? res.map((s) => DetalleTareoLiderZonaAws.fromJson(s)).toList()
        : [];
  }

  Future<List<TareoLiderZonaAws>?> getAllTareoMovil() async {
    final db = await database;
    final sql = '''
                SELECT
                     fecha_registro
                    , hora_registro
                    , region
                    , provincia
                    , distrito
                    , centro_poblado
                    , paradero
                    , numero_placa
                    , latitud
                    , longitud
                    , dni_lider_zona                    
                    , rec_lider_zona as rec_lider_zona_id
                    , dni_usuario_logeado
                    , usuario_logeado as usuario_logeado_id
                    , '1' as estado
                  FROM tareoLiderZona                  
                  where estado = '0' 
 
                ''';
    final res = await db.rawQuery(sql);
    return res.isNotEmpty
        ? res.map((s) => TareoLiderZonaAws.fromJson(s)).toList()
        : [];
  }

  Future<void> IdUpdateTareoZona(int codigoTareoLocal,String valor,String valorCondicional) async {
    final db = await database;
    final sql = "UPDATE tareoLiderZona set estado = '$valor'  where estado = '$valorCondicional' and id = $codigoTareoLocal ";
    final res = await db.rawUpdate(sql);
  }

  Future<List<Map<String, dynamic>>> obtenerRegDetallePersonal() async {
    final db = await bd.database;
    final query = """
          select  * from detalleTareoLiderZona where estado = '-1' order by id desc  ;
        """;
    return await db.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> obtenerDatoTemporalTareo() async {
    final db = await bd.database;
    final query = """
          select dni_lider_zona, tar.id,fecha_registro,hora_registro,lid.apellidos||lid.nombres as nombre_lider_zona,region,provincia,distrito,centro_poblado,paradero,latitud,longitud,tar.estado,numero_placa
          from tareoLiderZona tar   inner join  liderZona lid on (tar.dni_lider_zona = lid.dni)  where tar.estado = '-1' order by tar.id desc limit 1 ;
        """;
    return await db.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> obtenerRegTareo() async {
    final db = await bd.database;
    final query = """
          select  * from tareoLiderZona where estado = '0'  ;
        """;
    return await db.rawQuery(query);
  }

  Future <int> crearTareozona(TareoLiderZona nuevoTareoZona) async {
    final db = await bd.database;
    final Batch batch = db.batch();

    batch.insert(tableTareoLiderZona, {
      TareoLiderZonaFields.fecha_registro: nuevoTareoZona.fecha_registro,
      TareoLiderZonaFields.hora_registro: nuevoTareoZona.hora_registro,
      TareoLiderZonaFields.region: nuevoTareoZona.region,
      TareoLiderZonaFields.provincia: nuevoTareoZona.provincia,
      TareoLiderZonaFields.distrito: nuevoTareoZona.distrito,
      TareoLiderZonaFields.centro_poblado: nuevoTareoZona.centro_poblado,
      TareoLiderZonaFields.paradero: nuevoTareoZona.paradero,
      TareoLiderZonaFields.numero_placa: nuevoTareoZona.numero_placa,
      TareoLiderZonaFields.latitud: nuevoTareoZona.latitud,
      TareoLiderZonaFields.longitud: nuevoTareoZona.longitud,
      TareoLiderZonaFields.dni_lider_zona: nuevoTareoZona.dni_lider_zona,
      TareoLiderZonaFields.rec_lider_zona: nuevoTareoZona.rec_lider_zona,
      TareoLiderZonaFields.dni_usuario_logeado: nuevoTareoZona.dni_usuario_logeado,
      TareoLiderZonaFields.usuario_logeado: nuevoTareoZona.usuario_logeado,
      TareoLiderZonaFields.estado: nuevoTareoZona.estado,
    });

    var result = await batch.commit();
    var idReg = result.first as int;
    print(idReg);
    return idReg;
  }

  Future <int> crearDetalleTareozona(DetalleTareoLiderZona nuevoDetalleZona) async {
    final db = await bd.database;
    final Batch batch = db.batch();

    batch.insert(tableDetalleTareoLiderZona, {
      DetalleTareoLiderZonaFields.dni_reclutado: nuevoDetalleZona.dni_reclutado,
      DetalleTareoLiderZonaFields.nombres: nuevoDetalleZona.nombres,
      DetalleTareoLiderZonaFields.apellidos: nuevoDetalleZona.apellidos,
      DetalleTareoLiderZonaFields.telefono_celular: nuevoDetalleZona.telefono_celular,
      DetalleTareoLiderZonaFields.rec_tareo_lider_zona: nuevoDetalleZona.rec_tareo_lider_zona,
      DetalleTareoLiderZonaFields.estado: nuevoDetalleZona.estado,
    });

    var result = await batch.commit();
    var idReg = result.first as int;
    print(idReg);
    return idReg;
  }

  Future<List<Map<String, dynamic>>> obtenerUltimoTareoRegistrado() async {
    final db = await bd.database;
    final query = """
          select  * from tareoLiderZona  order by id desc limit 1  ;
        """;
    return await db.rawQuery(query);
  }

  //Responsable Trabajador Zona Pistoleado
  Future<List<TrabajadorTareoPistoleado>> buscarTrabajadorZonaPistoleoLocal(String dni) async {
    final db = await bd.database;
    final result = await db.rawQuery("select * from trabajadorPistoleado where dni_reclutado = '$dni' limit 1;");
    return result.map((e) => TrabajadorTareoPistoleado.fromJson(e)).toList();
  }

  //Responsable Trabajador Zona Pistoleado
  Future<List<Trabajador>> buscarTrabajadorGMOLocal(String dni) async {
    final db = await bd.database;
    final result = await db.rawQuery("select * from trabajador where nrodocumento = '$dni' limit 1;");
    return result.map((e) => Trabajador.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>>  getDatosResumenes() async {

    final db = await bd.database;
    final result = await db.rawQuery("""
        select count(*) as total_pistoleados,
        COUNT(CASE WHEN estado_sincronizado  IN ('3') THEN estado_sincronizado  END)  as total_ultima_sincronizacion,
        COUNT( CASE WHEN estado  IN ('0') THEN estado  END)  as pendiente_sincronizar
        from detalleTareoLiderZona
        """);

    return result;
  }

}