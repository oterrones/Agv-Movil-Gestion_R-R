import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

/*

import 'package:rrhh/db/database.dart';
import 'package:rrhh/modelos/area.dart';
import 'package:rrhh/modelos/categoria_cultivo.dart';
import 'package:rrhh/modelos/check_list.dart';
import 'package:rrhh/modelos/fotos_cl.dart';
import 'package:rrhh/modelos/local_log.dart';
import 'package:rrhh/modelos/visita_campo.dart';
import 'package:rrhh/src/firma/firma.dart';
import 'package:rrhh/src/tema/primary.dart';
*/


import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:proyectoryr/db/database.dart';
import 'package:proyectoryr/modelos/registro_foto.dart';
import 'package:proyectoryr/modelos/tareo_lider_zona.dart';
import 'package:proyectoryr/modelos/trabajadores_pistoleado.dart';
import 'package:proyectoryr/src/providers/input_decorations.dart';
import 'package:proyectoryr/src/tema/primary.dart';
import 'package:signature/signature.dart';

import '../../modelos/detalle_tareo_lider_zona.dart';
import '../../modelos/personal_reclutado.dart';
import '../../modelos/trabajadores.dart';

class registrarReclutamientoPersonal extends StatefulWidget {
  registrarReclutamientoPersonal(this.id_ed);

  int id_ed;

  @override
  State<registrarReclutamientoPersonal> createState() => _registrarReclutamientoPersonalState();
}

class _registrarReclutamientoPersonalState extends State<registrarReclutamientoPersonal> {
  String error = "hola";
  bool isCargando = true;
  bool isCargandoBtn = true;
  bool isError = false;
  bool isSuccess = false;
  bool isFirma = false;
  bool cargandoLL = false;
  bool cargandoCBSearchDniApi = false;
  bool cargandoSearchDniApi = false;
  bool loadingLimpiandoCabecera = false;
  bool loadingLimpiandoDetalleTareo = false;
  bool loadingRegistrantoAll = false;
  bool loadingContinuando = false;
  bool frmTareoDiarioCabeceraDetalle = true;
  bool frmTareoVistaNuevoUpdate = true;
  bool loadingAgregandoDetalle = false;
  bool loadingNuevoCabecera = false;
  bool loadingNuevoDetalle = false;
  bool loadingCargaDetalleTareo = false;


  String cosechaSem = "";
  String descripcion = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyH = GlobalKey<ScaffoldState>();

  /*
  late List<LocalLog> localhost;
  late List<CheckList> che_lis;
  */

  TextEditingController dateinput = TextEditingController();
  TextEditingController horaInicialC = TextEditingController();

  TextEditingController cultivo_area = TextEditingController();

  String hoy = "";
  TextEditingController txt_nombre_lider_principal= TextEditingController();
  TextEditingController txt_apellidos_reclutado = TextEditingController();
  TextEditingController txt_numero_dni_reclutado = TextEditingController();
  TextEditingController txt_nombres_reclutado = TextEditingController();
  TextEditingController txt_telefono_reclutado = TextEditingController();
  TextEditingController txt_paradero = TextEditingController();
  TextEditingController txt_centro_poblado = TextEditingController();
  TextEditingController txt_numero_placa = TextEditingController();
  TextEditingController latitud = TextEditingController();
  TextEditingController longitud = TextEditingController();
  TextEditingController txt_numero_dni_sear_reclutado = TextEditingController();
  TextEditingController descripcion_c = TextEditingController();
  TextEditingController estado_c = TextEditingController();
  TextEditingController txt_dni_lider_buscar = TextEditingController();

  TextEditingController txt_dni_lider_buscar_read = TextEditingController();
  TextEditingController txt_nombre_lider_principal_read = TextEditingController();
  TextEditingController txt_fecha_read = TextEditingController();
  TextEditingController txt_hora_read = TextEditingController();
  TextEditingController txt_region_read = TextEditingController();
  TextEditingController txt_provincia_read = TextEditingController();
  TextEditingController txt_distrito_read = TextEditingController();
  TextEditingController txt_centro_p_read = TextEditingController();
  TextEditingController txt_paradero_read = TextEditingController();
  TextEditingController txt_placa_read = TextEditingController();
  TextEditingController txt_latitud_read = TextEditingController();
  TextEditingController txt_longitud_read = TextEditingController();


  int codigoTareoLiderZonaCabecera = 0;
  int id_lider_zona_principal = 0;
  int id_lider_zona_logeado = 0;
  int id_vc = 0;
  String dni_lider_zona_principal = "";
  String dni_lider_zona_logeado = "";

  List<File> imagenes = [];
  int total_fotos = 0;




  bool activar = true;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );
  late Uint8List? foto_firma;

  late List<Map<String, dynamic>> registrosRe = [];
  late List<Map<String, dynamic>> reg = [];
  late List<Map<String, dynamic>> registrosDetalleTareo = [];
  late List<Map<String, dynamic>> objRegistroDetalle = [];

  late List<Map<String, dynamic>> registrosTareoReclutado = [];
  late List<Map<String, dynamic>> registrosUltimoTareoReclutado = [];

  List<String> estados = ['Activo', 'Inactivo'];
  String? estadoSelected = 'Activo';

  List<String> regiones = ['Seleccionar...'];
  String? regionesSelected = 'Seleccionar...';

  late List<Map<String, dynamic>> registrosProvincia = [];
  List<String> provincias = ['Seleccionar...'];
  String? provinciasSelected = 'Seleccionar...';

  late List<Map<String, dynamic>> registrosDistrito = [];
  List<String> distrito = ['Seleccionar...'];
  String? distritoSelected = 'Seleccionar...';

  late List<Map<String, dynamic>> registrosCentroPoblado = [];
  List<String> optCentroPoblado = ['Seleccionar...'];
  String? centroPobladoSelected = 'Seleccionar...';


  late List<Map<String, dynamic>> registrosParadero = [];
  List<String> optParadero = ['Seleccionar...'];
  String? paraderoSelected = 'Seleccionar...';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
    obtenerFecha();
    traerRegiones();
    traerDatosTareos();
    traerDatosUltimoTareos();
    hola();
    dateinput.text = DateFormat("dd/MM/yyy").format(DateFormat("yyyy-MM-dd HH:mm:ss").parseUTC(DateTime.now().toString()).toUtc());;
  }

  Future traerRegiones() async{
    this.registrosRe = await AgrovisionDataBase.bd.obtenerRegiones();

    var i = 0;
    this.reg = [];
    var regProv = "";

    for(var spd in this.registrosRe){
      if(i!=spd['id']){
        regProv = spd['nombre'].toString().toUpperCase();
        setState(() {
          this.regiones.add(regProv);
        });
        i = spd['id'];
        //print(i);
      }
    }



  }

  Future<int> traerProvincias(String region) async{
    this.registrosProvincia = await AgrovisionDataBase.bd.obtenerProvincias(region);

    List<String> objProvincias = ['Seleccionar...'];
    List<String> objDistrito = ['Seleccionar...'];
    List<String> objCenPoblado= ['Seleccionar...'];
    List<String> objParadero= ['Seleccionar...'];
    var i = 0;
    this.reg = [];
    var regProv = "";
    for(var spd in this.registrosProvincia){
      if(i!=spd['id']){
        regProv = spd['nombre'].toString().toUpperCase();
        objProvincias.add(regProv);
        i = spd['id'];
      }
    }
    setState(() {
      this.provincias = objProvincias;
      this.provinciasSelected = this.provincias.first;
      this.distrito = objDistrito;
      this.distritoSelected = this.distrito.first;
      this.optCentroPoblado = objCenPoblado;
      this.centroPobladoSelected = this.optCentroPoblado.first;
      this.optParadero = objParadero;
      this.paraderoSelected = this.optParadero.first;
    });


    return 1;

  }

  Future<int> traerDistritos(String provincia) async{
    this.registrosDistrito = await AgrovisionDataBase.bd.obtenerDistritos(provincia);
    List<String> objDistritos = ['Seleccionar...'];
    List<String> objCenPoblado= ['Seleccionar...'];
    List<String> objParadero= ['Seleccionar...'];

    var i = 0;
    this.reg = [];
    var regProv = "";

    for(var spd in this.registrosDistrito){
      if(i!=spd['id']){
        regProv = spd['nombre'].toString().toUpperCase();
        objDistritos.add(regProv);
        i = spd['id'];
        //print(i);
      }
    }
    setState(() {
      this.distrito = objDistritos;
      this.distritoSelected = this.distrito.first;
      this.optCentroPoblado = objCenPoblado;
      this.centroPobladoSelected = this.optCentroPoblado.first;
      this.optParadero = objParadero;
      this.paraderoSelected = this.optParadero.first;
    });
    return 1;

  }
  Future<int> traerCentroPoblados(String centroPoblado) async{
    this.registrosCentroPoblado = await AgrovisionDataBase.bd.obtenerCentroPoblados(centroPoblado);

    List<String> objCentPoblado = ['Seleccionar...'];
    List<String> objParadero= ['Seleccionar...'];

    var i = 0;
    this.reg = [];
    var regProv = "";

    for(var spd in this.registrosCentroPoblado){
      if(i!=spd['id']){
        regProv = spd['nombre'].toString().toUpperCase();
        objCentPoblado.add(regProv);
        i = spd['id'];
        //print(i);
      }
    }
    setState(() {
      this.optCentroPoblado = objCentPoblado;
      this.centroPobladoSelected = this.optCentroPoblado.first;
      this.optParadero = objParadero;
      this.paraderoSelected = this.optParadero.first;
    });

    return 1;



  }
  Future<int> traerParaderos(String paradero) async{
    this.registrosParadero = await AgrovisionDataBase.bd.obtenerParaderos(paradero);
    List<String> objParadero = ['Seleccionar...'];

    var i = 0;
    this.reg = [];
    var regProv = "";

    for(var spd in this.registrosParadero){
      if(i!=spd['id']){
        regProv = spd['nombre'].toString().toUpperCase();
        objParadero.add(regProv);
        i = spd['id'];
        //print(i);
      }
    }
    setState(() {
      this.optParadero= objParadero;
      this.paraderoSelected = this.optParadero.first;
    });
    return 1;


  }

  Future<int> scanBarcodeNormal() async {
    setState(() => cargandoCBSearchDniApi = true);
    var resul = 0;
    String _scanBarcode = 'Unknown';
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      String resultado =  barcodeScanRes.toString();
      print("ini: "+resultado);
      this.txt_numero_dni_sear_reclutado.text = resultado.toString();

      if(resultado!="-1"){
        var rsultado = await obtenerTrabajadorPistoleoAws(resultado.toString());

        if(rsultado == 0){

          var resultado_searchGmoLocal = await obtenerTrabajadorGmoAws(resultado.toString());
          if(resultado_searchGmoLocal == 0){

            var resultado_searchApiAmazonPistoleo = await obtenerTrabajadorApiAmazon(resultado.toString());
            if(resultado_searchApiAmazonPistoleo == 0){
              rsultado = await obtenerTrabajadorApiReniec(resultado);
            }

          }

        }
      }else{
        setState(() => cargandoCBSearchDniApi = false);
      }
      resul = 1;
    } on PlatformException {
      barcodeScanRes = 'Sin respuesta';
     // await obtenerTrabajadorApiReniec('000');
      resul = 2;
      this.txt_nombres_reclutado.text = "Sin respuesta";
      this.txt_apellidos_reclutado.text = "Sin respuesta";
      this.txt_numero_dni_reclutado.text =  this.txt_numero_dni_sear_reclutado.text;
      this.txt_telefono_reclutado.text = "";
      setState(() => cargandoCBSearchDniApi = false);
    }
    //_scanBarcode = barcodeScanRes;
    setState(() => cargandoCBSearchDniApi = false);
    return resul;
  }
  Future<int> BuscarReclutadoDni(String dni) async {
    setState(() => cargandoSearchDniApi = true);


    var resul = 0;
    try {
      var rsultado = await obtenerTrabajadorPistoleoAws(dni.toString());

      print("Seguimiento");
      if(rsultado == 0){

        var resultado_searchGmoLocal = await obtenerTrabajadorGmoAws(dni.toString());
        if(resultado_searchGmoLocal == 0){

          var resultado_searchApiAmazonPistoleo = await obtenerTrabajadorApiAmazon(dni.toString());
          if(resultado_searchApiAmazonPistoleo == 0){
            await obtenerTrabajadorApiReniec(dni);
          }

        }

      }

      resul = 1;
    } on PlatformException {
      print("error");
      resul = 2;
    }


    //_scanBarcode = barcodeScanRes;
    print(resul);
    setState(() => cargandoSearchDniApi = false);
    return resul;
  }

  Future traerDatosDetalleTareo() async{
    setState(() => this.loadingCargaDetalleTareo = true);
    this.registrosDetalleTareo = await AgrovisionDataBase.bd.obtenerRegDetallePersonal();
    var i = 0;
    this.objRegistroDetalle = [];

    for(var spd in this.registrosDetalleTareo){
      if(i!=spd['id']){
        setState(() {
          this.objRegistroDetalle.add(spd);
        });
        i = spd['id'];
      }
    }


    setState(() => this.loadingCargaDetalleTareo = false);
  }

  Future traerDatosTareos() async{
    this.registrosTareoReclutado = await AgrovisionDataBase.bd.obtenerDatoTemporalTareo();
    var i = 0;
    this.objRegistroDetalle = [];

    for(var spd in this.registrosTareoReclutado){
      if(i!=spd['id']){
        setState(() {
          this.codigoTareoLiderZonaCabecera=spd['id'];
          this.txt_dni_lider_buscar_read.text=spd['dni_lider_zona'];
          this.txt_nombre_lider_principal_read.text=spd['nombre_lider_zona'];
          this.txt_region_read.text=spd['region'];
          this.txt_provincia_read.text=spd['provincia'];
          this.txt_distrito_read.text=spd['distrito'];
          this.txt_centro_p_read.text=spd['centro_poblado'];
          this.txt_paradero_read.text=spd['paradero'];
          this.txt_placa_read.text=spd['numero_placa'];
          this.txt_latitud_read.text=spd['latitud'];
          this.txt_longitud_read.text=spd['longitud'];
          this.txt_fecha_read.text=spd['fecha_registro'];
          this.txt_hora_read.text=spd['hora_registro'];
          this.frmTareoVistaNuevoUpdate = false;

          //this.objRegistroDetalle.add(spd);
        });
        i = spd['id'];
      }
    }
    if(this.registrosTareoReclutado.length<=0){
      this.frmTareoVistaNuevoUpdate = true;
    }

  }

  Future traerDatosUltimoTareos() async{
    this.registrosUltimoTareoReclutado = await AgrovisionDataBase.bd.obtenerUltimoTareoRegistrado();
    var resultProvincia;
    var resultDistrito;
    var resultCentroPoblado;
    var resultParadero;
    var i = 0;
    for(var spd in this.registrosUltimoTareoReclutado){
      if(i!=spd['id']){

        if(this.regiones.length>0){
          this.regionesSelected = spd['region'];
          resultProvincia = await traerProvincias(spd['region']);
          resultDistrito = await traerDistritos(spd['provincia']);
          resultCentroPoblado = await traerCentroPoblados(spd['distrito']);
          resultParadero = await traerParaderos(spd['centro_poblado']);
        }
        setState(() {
          if(this.regiones.length>0){
            this.regionesSelected = spd['region'];

          }
          if(resultProvincia==1){
            if(this.provincias.length>1){
              this.provinciasSelected = spd['provincia'];
            }
          }
          if(resultDistrito==1){
            if(this.distrito.length>1){
              this.distritoSelected = spd['distrito'];
            }
          }

          if(resultCentroPoblado==1){
            if(this.optCentroPoblado.length>1){
              this.centroPobladoSelected = spd['centro_poblado'];
            }
          }
          if(resultParadero==1){
            if(this.optParadero.length>1){
              this.paraderoSelected = spd['paradero'];
            }
          }
          this.txt_numero_placa.text = spd['numero_placa'];
          this.latitud.text = spd['latitud'];
          this.longitud.text = spd['longitud'];
          //
        });
        i = spd['id'];
      }
    }

  }

  @override
  void dispose() {
    super.dispose();

    //resetearInfoSE();
  }

  Future hola() async {
    setState(() => isCargando = true);
    this.txt_numero_dni_sear_reclutado.text = '';

    await Future.delayed(Duration(milliseconds: 600));
    //var responsable =  await AgrovisionDataBase.bd.obtenerResponsable();
    var responsable =  await AgrovisionDataBase.bd.obtenerResponsableLiderZona();

    this.txt_nombre_lider_principal.text = responsable[0].nombres + " " + responsable[0].apellidos;
    this.id_lider_zona_principal = responsable[0].id;
    this.dni_lider_zona_principal = responsable[0].dni;
    this.id_lider_zona_logeado = responsable[0].id;
    this.dni_lider_zona_logeado = responsable[0].dni;
    this.txt_dni_lider_buscar.text = responsable[0].dni;


    var nowTime = DateTime.now ();
    this.horaInicialC.text = DateFormat('HH:mm:ss').format(nowTime);

    //this.latitud.text  = "-6.7843" + Random().nextInt(999).toString();
    //this.longitud.text  = "-79.8424" + Random().nextInt(999).toString();

    setState(() => isCargando = false);
  }

  Future <int>BuscarDniLiderZona(String dni) async {

    var resul = 0;
    var responsable =  await AgrovisionDataBase.bd.buscarResponsableLiderZona(dni);

    if(responsable.length>0){
      this.txt_nombre_lider_principal.text = responsable[0].nombres + " " + responsable[0].apellidos;
      this.id_lider_zona_principal = responsable[0].id;
      this.dni_lider_zona_principal = responsable[0].dni;
      resul = 1;
    }else{
      resul = 2;
      toasty(this.context, "DNI no encontrado.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);


    }
    return resul;

  }

  Future obtenerUbicacion() async {
    setState(() => cargandoLL = true);
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    this.latitud.text = _locationData.latitude.toString();
    this.longitud.text = _locationData.longitude.toString();
    setState(() => cargandoLL = false);
  }

  Future obtenerTrabajadorApiReniec(String dni) async{
    setState(() => isCargandoBtn = true);

    var uro = Uri.parse('https://api.apis.net.pe/v1/dni?numero=$dni');

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        final resultado = jsonDecode(value.body);
        if(resultado.isNotEmpty){


          this.txt_nombres_reclutado.text = resultado["nombres"];
          this.txt_apellidos_reclutado.text = resultado["apellidoPaterno"]+" "+resultado["apellidoMaterno"];
          this.txt_numero_dni_reclutado.text = resultado["numeroDocumento"];

          //registraDetalleTareoTemporal(1,  this.txt_numero_dni_reclutado.text,  this.txt_nombres_reclutado.text,  this.txt_apellidos_reclutado.text,  this.txt_telefono_reclutado.text);


        }else{
          toasty(this.context, "DNI no encontrado.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
          this.txt_nombres_reclutado.text = "Sin respuesta";
          this.txt_apellidos_reclutado.text = "Sin respuesta";
          this.txt_numero_dni_reclutado.text = dni;
          this.txt_numero_dni_sear_reclutado.text = "";
          this.txt_telefono_reclutado.text = "";

        }
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        this.txt_nombres_reclutado.text = "Sin respuesta";
        this.txt_apellidos_reclutado.text = "Sin respuesta";
        this.txt_numero_dni_reclutado.text = dni;
        this.txt_telefono_reclutado.text = "";
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {

      print("sin internet");
      this.txt_nombres_reclutado.text = "Sin datos";
      this.txt_apellidos_reclutado.text = "Sin datos";
      this.txt_numero_dni_reclutado.text = dni;
      this.txt_telefono_reclutado.text = "";
      setState(() {
        isError = true;
        this.error = "sin codigo";
      });

    });


    setState(() => isCargandoBtn = false);
  }
  Future <int> obtenerTrabajadorApiAmazon(String dni) async{
    setState(() => isCargandoBtn = true);

    var respuesta_salida = 0;
    var uro = Uri.parse('http://35.175.69.142/backend/cosecha/personal/tareo/buscar/dni/agv/?dni_trabajador=$dni');

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      print("Luis");
      if (value.statusCode == 200) {
        final resultado = jsonDecode(value.body);
        if(resultado["rows"]>0){

          final response = resultado["response"];
          respuesta_salida = 1;
          this.txt_nombres_reclutado.text = response[0]["nombres"];
          this.txt_apellidos_reclutado.text = response[0]["apellidos"];
          this.txt_numero_dni_reclutado.text = response[0]["dni_reclutado"];
          this.txt_telefono_reclutado.text = response[0]["telefono_celular"];
          if(response[0]["telefono_celular"]!=""){
            registraDetalleTareoTemporal(this.txt_numero_dni_reclutado.text,  this.txt_nombres_reclutado.text,  this.txt_apellidos_reclutado.text,  this.txt_telefono_reclutado.text);
            this.limpiarDatosDetalle();

          }
          setState(() => isCargandoBtn = false);


        }
      }
    }).catchError((error, stackTrace) {

    });
    return respuesta_salida;
  }

  Future <int> obtenerTrabajadorPistoleoAws(String dni) async{
    setState(() => isCargandoBtn = true);

    var respuesta_salida = 0;


    try {
      late List<TrabajadorTareoPistoleado> trabajador_pistoleado ;
      trabajador_pistoleado = await AgrovisionDataBase.bd.buscarTrabajadorZonaPistoleoLocal(dni);

      if(trabajador_pistoleado.length>0){

        print(trabajador_pistoleado[0].nombres);

        respuesta_salida = 1;
        this.txt_nombres_reclutado.text = trabajador_pistoleado[0].nombres.toString();
        this.txt_apellidos_reclutado.text = trabajador_pistoleado[0].apellidos.toString();
        this.txt_numero_dni_reclutado.text = trabajador_pistoleado[0].dni_reclutado.toString();
        this.txt_telefono_reclutado.text = trabajador_pistoleado[0].telefono_celular.toString();
        if(trabajador_pistoleado[0].telefono_celular.toString()!=""){
          registraDetalleTareoTemporal(this.txt_numero_dni_reclutado.text,  this.txt_nombres_reclutado.text,  this.txt_apellidos_reclutado.text,  this.txt_telefono_reclutado.text);
          this.limpiarDatosDetalle();
        }

      }else{
        this.txt_nombres_reclutado.text = "";
        this.txt_apellidos_reclutado.text = "";
      //  this.txt_numero_dni_reclutado.text = dni;
        this.txt_telefono_reclutado.text = "";
      }
      setState(() => isCargandoBtn = false);



    } on PlatformException catch (e) {
      print('Falló lectura trabajador: $e');
    }

    return respuesta_salida;
  }
  Future <int> obtenerTrabajadorGmoAws(String dni) async{
    setState(() => isCargandoBtn = true);

    var respuesta_salida = 0;


    try {
      late List<Trabajador> objTrabajador ;
      objTrabajador = await AgrovisionDataBase.bd.buscarTrabajadorGMOLocal(dni);
      print(objTrabajador.length);

      if(objTrabajador.length>0){


        respuesta_salida = 1;
        this.txt_nombres_reclutado.text = objTrabajador[0].nombres.toString();
        this.txt_apellidos_reclutado.text = objTrabajador[0].appaterno.toString() +" "+objTrabajador[0].apmaterno.toString();
        this.txt_numero_dni_reclutado.text = objTrabajador[0].nrodocumento.toString();
        this.txt_telefono_reclutado.text = "";
      }else{
        this.txt_nombres_reclutado.text = "";
        this.txt_apellidos_reclutado.text = "";
        this.txt_numero_dni_reclutado.text = dni;
        this.txt_telefono_reclutado.text = "";
      }
      setState(() => isCargandoBtn = false);



    } on PlatformException catch (e) {
      print('Falló lectura trabajador: $e');
    }

    return respuesta_salida;
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source, imageQuality: 50);
      if (image == null) return;

      final imageTemporary = await saveImagePermanentemente(image.path);
      setState(() {
        setState(() {
          this.imagenes.add(imageTemporary);
          this.total_fotos = 1;
        });
      });
    } on PlatformException catch (e) {
      print('Falló la carga de imagen: $e');
    }
  }

  Future<File> saveImagePermanentemente(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  Future muchasImagenes() async {
    try {
      final image = await ImagePicker().pickMultiImage(imageQuality: 50);
      if (image == null) return;

      for (var value in image) {
        final imageTemporary = await saveImagePermanentemente(value.path);
        setState(() {
          this.imagenes.add(imageTemporary);
          this.total_fotos = 1;
        });
      }

    } on PlatformException catch (e) {
      print('Falló la carga de imagen: $e');
    }
  }

  Future registraCabeceraTareoPersonalTemporal() async {
    setState(() => loadingContinuando = true);
    var fechita = dateinput.text.split('/')[2]+"-"+dateinput.text.split('/')[1]+"-"+dateinput.text.split('/')[0];
    final registro = TareoLiderZona(fecha_registro: fechita,hora_registro:this.horaInicialC.text,
        region: regionesSelected!,provincia: provinciasSelected!,distrito: distritoSelected!,
        centro_poblado: centroPobladoSelected!.toUpperCase(),paradero: paraderoSelected!.toUpperCase(),
        latitud: latitud.text, longitud: longitud.text, estado: '-1',dni_lider_zona: this.dni_lider_zona_principal,
        rec_lider_zona:this.id_lider_zona_principal,numero_placa: txt_numero_placa.text.toUpperCase(),
        dni_usuario_logeado: this.dni_lider_zona_logeado,usuario_logeado: this.id_lider_zona_logeado);

    int regist = await AgrovisionDataBase.bd.crearTareozona(registro);
    this.codigoTareoLiderZonaCabecera = regist;

    setState(() => loadingContinuando = false);
    setState(() => frmTareoDiarioCabeceraDetalle = false);
    this.traerDatosDetalleTareo();

  }

  Future registraDetalleTareoTemporal(String strDni_reclutado,String strNombre,String strApellido, String strTelefono) async {
    setState(() => loadingAgregandoDetalle = true);
    final registro = DetalleTareoLiderZona(
      nombres: strNombre.toUpperCase(), apellidos: strApellido.toUpperCase(), dni_reclutado: strDni_reclutado, estado: '-1',telefono_celular: strTelefono,rec_tareo_lider_zona: this.codigoTareoLiderZonaCabecera,estado_sincronizado: '0');
    int regist = await AgrovisionDataBase.bd.crearDetalleTareozona(registro);
    this.traerDatosDetalleTareo();
    setState(() => loadingAgregandoDetalle = false);

  }

  Future registrarPersonalTareoLiderALl(int codigoTareo) async {
    setState(() => loadingRegistrantoAll = true);
    await AgrovisionDataBase.bd.IdUpdateTareoZona(codigoTareo,'0','-1');
    await AgrovisionDataBase.bd.AllUpdateDetalleTareoZona( codigoTareo,'0','-1');
    setState(() => frmTareoVistaNuevoUpdate = true);
    setState(() => loadingRegistrantoAll = false);
    setState(() => frmTareoDiarioCabeceraDetalle = true);


  }


  Future limpiarDatosCabecera() async {
    print("Limpiando");
    setState(() => loadingLimpiandoCabecera = true);

    await Future.delayed(Duration(milliseconds: 1000));
    List<String> objProvincias = ['Seleccionar...'];
    List<String> objDistritos = ['Seleccionar...'];
    List<String> objCentPoblado = ['Seleccionar...'];
    List<String> objParadero = ['Seleccionar...'];
    setState(() {
      this.regionesSelected = 'Seleccionar...';
      this.provincias = objProvincias;
      this.provinciasSelected = this.provincias.first;
      this.distrito = objDistritos;
      this.distritoSelected =  this.distrito.first;
      this.optCentroPoblado =objCentPoblado;
      this.centroPobladoSelected = this.optCentroPoblado.first;
      this.optParadero = objParadero;
      this.paraderoSelected = this.optParadero.first;
      this.txt_numero_placa.text = '';
      this.latitud.text = '';
      this.longitud.text = '';
      var nowTime = DateTime.now ();
      this.horaInicialC.text = DateFormat('HH:mm:ss').format(nowTime);
      this.hoy = DateFormat("dd MMM").format(DateFormat("yyyy-MM-dd HH:mm:ss").parseUTC(DateTime.now().toString()).toUtc());
      this.dateinput.text = DateFormat("dd/MM/yyyy").format(DateFormat("yyyy-MM-dd HH:mm:ss").parseUTC(DateTime.now().toString()).toUtc());

    });

    await traerDatosUltimoTareos();


     setState(() => loadingLimpiandoCabecera = false);

  }

  Future limpiarDatosDetalle() async {
    setState(() => loadingLimpiandoDetalleTareo = true);

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      this.txt_numero_dni_reclutado.text = '';
      this.txt_numero_dni_sear_reclutado.text  = '';
      this.txt_nombres_reclutado.text='';
      this.txt_apellidos_reclutado.text='';
      this.txt_telefono_reclutado.text='';

    });


    setState(() => loadingLimpiandoDetalleTareo = false);

  }


  /*

  */

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Primary.white.withOpacity(0),
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Primary.azul,
            systemNavigationBarIconBrightness: Brightness.light),
        child:  Container(
                color: Primary.background,
                child: Scaffold(
                  key: _scaffoldKeyH,
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: <Widget>[
                      getAppBarUI(),
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.topCenter,
                            child:
                            this.isCargando
                                ? Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Primary.azul,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Obteniendo datos, espere...",
                                    style: TextStyle(
                                        color: Primary.azul,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            )

                                : frmTareoDiarioCabeceraDetalle
                                ? Container(
                                child:this.frmTareoVistaNuevoUpdate
                                    ?Container(
                                height: MediaQuery.of(this.context).size.height - (MediaQuery.of(context).padding.bottom - MediaQuery.of(this.context).size.height * 0.11),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('DNI LIDER ZONA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      TextFormField(
                                                        controller: txt_dni_lider_buscar,
                                                        autocorrect: false,
                                                        keyboardType: TextInputType.number,
                                                        maxLength: 8,
                                                        cursorColor: Primary.azul,
                                                        textInputAction: TextInputAction.send,
                                                        textAlign: TextAlign.left,
                                                        //decoration: InputDecorations.loginInputDecoration(hintText: "DNI", labelText: "DNI"),
                                                        style: TextStyle(color: Primary.azul, fontWeight: FontWeight.bold, fontSize: 17),
                                                        textAlignVertical: TextAlignVertical.bottom,
                                                        validator: (value) {
                                                          String pattern = r'^\d{8}$';
                                                          RegExp regExp  = new RegExp(pattern);

                                                          return regExp.hasMatch(value ?? '')
                                                              ? null
                                                              : 'DNI lider incorrecto';
                                                        },
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
                                                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                                        ],

                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    if(txt_dni_lider_buscar.text.length == 8){
                                                      var resultado = await BuscarDniLiderZona(txt_dni_lider_buscar.text);
                                                      if(resultado==1){
                                                        FocusScope.of(context).unfocus();
                                                      }
                                                    }else{
                                                      toasty(this.context, "Completar dígitos.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                                                    }
                                                  },
                                                  child: Icon(Icons.search),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Primary.azul, onPrimary: Primary.white, fixedSize: Size(30, 20)
                                                  )
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('LIDER DE ZONA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      TextFormField(
                                                        controller: txt_nombre_lider_principal,
                                                        decoration: const InputDecoration(
                                                          hintText: 'Enter your email',
                                                        ),
                                                        validator: (String? value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Please enter some text';
                                                          }
                                                          return null;
                                                        },
                                                        readOnly: true,
                                                        enabled: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25,),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('FECHA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      TextFormField(
                                                        controller: dateinput,
                                                        readOnly: true,
                                                        onTap: () async {
                                                          DateTime? pickedDate = await showDatePicker(
                                                              context: context,
                                                              initialDate: DateTime.now(),
                                                              firstDate: DateTime(2022),
                                                              lastDate: DateTime.now(),
                                                              locale: Locale('es')
                                                          );

                                                          if(pickedDate != null ){
                                                            String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);

                                                            setState(() {
                                                              dateinput.text = formattedDate; //set output date to TextField value.
                                                            });
                                                          }

                                                        },
                                                        validator: (value){
                                                          if(value==''){
                                                            return 'Ingrese Fecha';
                                                          }else{
                                                            return null;
                                                          }
                                                        },
                                                        enabled: this.activar,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 25),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('HORA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      TextFormField(
                                                        controller: horaInicialC,
                                                        decoration: const InputDecoration(
                                                          hintText: 'Ingrese Hora',
                                                        ),
                                                        validator: (String? value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Favor ingrese hora';
                                                          }
                                                          return null;
                                                        },
                                                        readOnly: true,
                                                        enabled: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),


                                          SizedBox(height: 25,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('REGIÓN: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      DropdownButtonFormField(
                                                        isExpanded: true,
                                                        value: regionesSelected,
                                                        icon: Icon(
                                                          Icons.keyboard_arrow_down,
                                                        ),

                                                        onChanged: activar ? (dynamic newValue) {
                                                          setState(() {
                                                            regionesSelected = newValue;
                                                            traerProvincias(regionesSelected.toString());
                                                          });
                                                        } : null,
                                                        validator: (String? value) {
                                                          print(value);
                                                          if (value == null || value.isEmpty || value == 'Seleccionar...') {
                                                            return 'Región es requerido';
                                                          }
                                                          return null;
                                                        },

                                                        items: regiones.map((category) {
                                                          return DropdownMenuItem(
                                                            child: Text(category),
                                                            value: category,
                                                          );
                                                        }).toList(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('PROVINCIA: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      DropdownButtonFormField(
                                                        isExpanded: true,
                                                        value: provinciasSelected,
                                                        icon: Icon(
                                                          Icons.keyboard_arrow_down,
                                                        ),
                                                        onChanged: activar ? (dynamic newValue) {
                                                          setState(() {
                                                            provinciasSelected = newValue;
                                                            print(2);
                                                            traerDistritos(provinciasSelected.toString());
                                                          });
                                                        } : null,
                                                        validator: (String? value) {
                                                          if (value == null || value.isEmpty || value == 'Seleccionar...') {
                                                            return 'Provincia requerida';
                                                          }
                                                          return null;
                                                        },
                                                        items: provincias.map((category) {
                                                          return DropdownMenuItem(
                                                            child: Text(category),
                                                            value: category,
                                                          );
                                                        }).toList(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('DISTRITO: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      DropdownButtonFormField(
                                                        isExpanded: true,
                                                        value: distritoSelected,
                                                        icon: Icon(
                                                          Icons.keyboard_arrow_down,
                                                        ),
                                                        onChanged: activar ? (dynamic newValue) {
                                                          setState(() {
                                                            distritoSelected = newValue;
                                                            traerCentroPoblados(distritoSelected.toString());
                                                          });
                                                        } : null,
                                                        validator: (String? value) {
                                                          if (value == null || value.isEmpty || value == 'Seleccionar...') {
                                                            return 'Distrito requerido';
                                                          }
                                                          return null;
                                                        },
                                                        items: distrito.map((category) {
                                                          return DropdownMenuItem(
                                                            child: Text(category),
                                                            value: category,
                                                          );
                                                        }).toList(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('CENTRO POBLADO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      DropdownButtonFormField(
                                                        isExpanded: true,
                                                        value: centroPobladoSelected,
                                                        icon: Icon(
                                                          Icons.keyboard_arrow_down,
                                                        ),
                                                        onChanged: activar ? (dynamic newValue) {
                                                          setState(() {
                                                            centroPobladoSelected = newValue;
                                                            traerParaderos(centroPobladoSelected.toString());
                                                          });
                                                        } : null,
                                                        validator: (String? value) {
                                                          if (value == null || value.isEmpty || value == 'Seleccionar...') {
                                                            return 'Centro poblado requerido';
                                                          }
                                                          return null;
                                                        },
                                                        items: optCentroPoblado.map((category) {
                                                          return DropdownMenuItem(
                                                            child: Text(category),
                                                            value: category,
                                                          );
                                                        }).toList(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 25,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('PARADERO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      DropdownButtonFormField(
                                                        isExpanded: true,
                                                        value: paraderoSelected,
                                                        icon: Icon(
                                                          Icons.keyboard_arrow_down,
                                                        ),
                                                        onChanged: activar ? (dynamic newValue) {
                                                          setState(() {
                                                            paraderoSelected = newValue;
                                                          });
                                                        } : null,
                                                        validator: (String? value) {
                                                          if (value == null || value.isEmpty || value == 'Seleccionar...') {
                                                            return 'Paradero requerido';
                                                          }
                                                          return null;
                                                        },
                                                        items: optParadero.map((category) {
                                                          return DropdownMenuItem(
                                                            child: Text(category),
                                                            value: category,
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25,),

                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('NÚMERO PLACA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      TextFormField(
                                                        controller: txt_numero_placa,
                                                        decoration: const InputDecoration(
                                                          hintText: 'Número placa',
                                                        ),
                                                        onChanged: (value){
                                                          setState(() {
                                                            this.descripcion = value;
                                                          });
                                                        },
                                                        validator: (String? value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Número placa requerido';
                                                          }
                                                          return null;
                                                        },
                                                        textInputAction: TextInputAction.next,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25,),

                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('LATITUD: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      TextFormField(
                                                        controller: latitud,
                                                        keyboardType: TextInputType.number,
                                                        decoration: const InputDecoration(
                                                          hintText: 'Latitud',
                                                        ),
                                                        onChanged: (value){
                                                          setState(() {
                                                            this.descripcion = value;
                                                          });
                                                        },
                                                        textInputAction: TextInputAction.next,
                                                        readOnly: false,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
                                                          FilteringTextInputFormatter.allow(RegExp('[0-9.-]')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text('LONGITUD: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      TextFormField(
                                                        controller: longitud,
                                                        keyboardType: TextInputType.number,
                                                        decoration: const InputDecoration(
                                                          hintText: 'Longitud',
                                                        ),
                                                        onChanged: (value){
                                                          setState(() {

                                                          });
                                                        },
                                                        textInputAction: TextInputAction.next,
                                                        readOnly: false,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
                                                          FilteringTextInputFormatter.allow(RegExp('[0-9.-]')),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    await obtenerUbicacion();
                                                  },
                                                  child: cargandoLL
                                                      ? SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                      : Icon(Icons.refresh),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Primary.azul, onPrimary: Primary.white, fixedSize: Size(30, 20)
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25,),

                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50)),
                                                  disabledColor: Primary.azulc,
                                                  elevation: 0,
                                                  color: Primary.azul,
                                                  child: Container(
                                                      alignment: Alignment.center,
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: <Widget>[
                                                          loadingLimpiandoCabecera
                                                              ?SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                              :Icon(Icons.cleaning_services_rounded, color: Primary.white),
                                                          SizedBox(width: 10),
                                                          Expanded(child:
                                                          Text(
                                                            loadingLimpiandoCabecera
                                                                ?"Limpiando"
                                                                :"Limpiar"
                                                            ,
                                                            style: TextStyle(
                                                              color: Primary.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 17,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          )
                                                          )
                                                        ],
                                                      )
                                                  ),
                                                  onPressed:  () async {
                                                    await limpiarDatosCabecera();
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50)),
                                                  disabledColor: Primary.verded,
                                                  elevation: 0,
                                                  color: Primary.verde,
                                                  child: Container(
                                                      alignment: Alignment.center,
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: <Widget>[
                                                          SizedBox(width: 10),

                                                          Expanded(child:
                                                          Text(
                                                            loadingContinuando
                                                                ?"Guardando..."
                                                                :"Continuar"
                                                            ,
                                                            style: TextStyle(
                                                              color: Primary.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 17,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),

                                                          ),
                                                          loadingContinuando
                                                              ?SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                              :Icon(Icons.arrow_circle_right, color: Primary.white),
                                                        ],
                                                      )
                                                  ),
                                                  onPressed: () async {
                                                    print(22);
                                                    //Navigator.pushReplacementNamed(context, 'camara');
                                                    FocusScope.of(context).unfocus();
                                                    if(_formKey.currentState?.validate() ?? false){

                                                      await registraCabeceraTareoPersonalTemporal();
                                                      toasty(context, "Datos guardados correctamente.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);

                                                    }else{
                                                      return;
                                                    }
                                                    traerDatosDetalleTareo();

                                                  } ,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                    :Container(
                            height: MediaQuery.of(this.context).size.height - (MediaQuery.of(context).padding.bottom - MediaQuery.of(this.context).size.height * 0.11),
                          child: ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('DNI LIDER ZONA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_dni_lider_buscar_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('LIDER DE ZONA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_nombre_lider_principal_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('FECHA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_fecha_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 25),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('HORA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_hora_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),


                                    SizedBox(height: 25,),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('REGIÓN: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_region_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25,),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('PROVINCIA: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_provincia_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25,),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('DISTRITO: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_distrito_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25,),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('CENTRO POBLADO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_centro_p_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 25,),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('PARADERO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_paradero_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25,),

                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('NÚMERO PLACA:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_placa_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25,),

                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('LATITUD: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_latitud_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  child: Text('LONGITUD: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                  alignment: Alignment.centerLeft,
                                                ),
                                                TextFormField(
                                                  controller: txt_longitud_read,
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 25,),

                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(50)),
                                            disabledColor: Primary.azulc,
                                            elevation: 0,
                                            color: Primary.azul,
                                            child: Container(
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                child: Row(
                                                  children: <Widget>[
                                                    loadingNuevoCabecera
                                                        ?SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                        :Icon(Icons.add_outlined, color: Primary.white),
                                                    SizedBox(width: 10),
                                                    Expanded(child:
                                                    Text("Nuevo",
                                                      style: TextStyle(
                                                        color: Primary.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 17,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    )
                                                    )
                                                  ],
                                                )
                                            ),
                                            onPressed:  () async {
                                              setState(() => loadingNuevoCabecera = true);
                                              setState(() => frmTareoVistaNuevoUpdate = true);
                                              await AgrovisionDataBase.bd.IdUpdateTareoZona( this.codigoTareoLiderZonaCabecera,'-3','-1');
                                              await limpiarDatosCabecera();


                                              setState(() => loadingNuevoCabecera = false);

                                            },
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(50)),
                                            disabledColor: Primary.verded,
                                            elevation: 0,
                                            color: Primary.verde,
                                            child: Container(
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                child: Row(
                                                  children: <Widget>[
                                                    SizedBox(width: 10),

                                                    Expanded(child:
                                                    Text("Continuar"
                                                      ,
                                                      style: TextStyle(
                                                        color: Primary.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 17,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),

                                                    ),Icon(Icons.arrow_circle_right, color: Primary.white),
                                                  ],
                                                )
                                            ),
                                            onPressed: () async {
                                              //Navigator.pushReplacementNamed(context, 'camara');
                                              traerDatosDetalleTareo();
                                              FocusScope.of(context).unfocus();
                                              setState(() => frmTareoDiarioCabeceraDetalle = false);
                                            }
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ) ,
                            )

                                : Container(
                              height: MediaQuery.of(this.context).size.height - (MediaQuery.of(context).padding.bottom - MediaQuery.of(this.context).size.height * 0.11),
                              child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: MaterialButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50)),
                                                disabledColor: Primary.azulc,
                                                elevation: 0,
                                                color: Primary.azul,
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    width: double.infinity,
                                                    child: Row(
                                                      children: <Widget>[
                                                        loadingLimpiandoDetalleTareo
                                                            ?SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                            :Icon(Icons.cleaning_services_rounded, color: Primary.white),
                                                        SizedBox(width: 10),
                                                        Expanded(child:
                                                        Text(
                                                          loadingLimpiandoDetalleTareo
                                                              ?"Limpiando"
                                                              :"Limpiar"
                                                          ,
                                                          style: TextStyle(
                                                            color: Primary.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 17,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        )
                                                        )
                                                      ],
                                                    )
                                                ),
                                                onPressed:  () async {
                                                  await limpiarDatosDetalle();
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: MaterialButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50)),
                                                disabledColor: Primary.verded,
                                                elevation: 0,
                                                color: Primary.verde,
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    width: double.infinity,
                                                    child: Row(
                                                      children: <Widget>[
                                                        SizedBox(width: 10),
                                                        loadingRegistrantoAll
                                                            ?SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                            :Icon(Icons.file_open_rounded, color: Primary.white),
                                                        Expanded(child:
                                                        Text(
                                                          loadingRegistrantoAll
                                                              ?"Registrando..."
                                                              :"Registrar"
                                                          ,
                                                          style: TextStyle(
                                                            color: Primary.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 17,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),

                                                        ),
                                                      ],
                                                    )
                                                ),
                                                onPressed:() async {
                                                  //Navigator.pushReplacementNamed(context, 'camara');
                                                  FocusScope.of(context).unfocus();
                                                  if(this.objRegistroDetalle.length > 0){
                                                    await registrarPersonalTareoLiderALl(this.codigoTareoLiderZonaCabecera);
                                                    toasty(context, "Datos registrados correctamente.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                                                    this.limpiarDatosDetalle();
                                                    this.limpiarDatosCabecera();
                                                  }else{
                                                    toasty(context, "Debe registrar un personal al tareo diario!", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);

                                                  }

                                                }
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 25,),

                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text('DNI RECLUTADO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: txt_numero_dni_sear_reclutado,
                                                      autocorrect: false,
                                                      keyboardType: TextInputType.number,
                                                      maxLength: 8,
                                                      cursorColor: Primary.azul,
                                                      textInputAction: TextInputAction.send,
                                                      textAlign: TextAlign.center,
                                                      decoration: InputDecorations.loginInputDecoration(hintText: "DNI", labelText: "DNI"),
                                                      style: TextStyle(color: Primary.azul, fontWeight: FontWeight.bold, fontSize: 17),
                                                      textAlignVertical: TextAlignVertical.bottom,
                                                      validator: (value) {
                                                        String pattern = r'^\d{8}$';
                                                        RegExp regExp  = new RegExp(pattern);

                                                      },
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
                                                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            ElevatedButton(
                                              onPressed: () async {
                                                FocusScope.of(context).unfocus();
                                                var resultado = await scanBarcodeNormal();

                                                //await obtenerTrabajador(dni.text);
                                              },
                                              child: cargandoCBSearchDniApi
                                                  ? SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                  : Icon(Icons.qr_code_outlined),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Primary.azul, onPrimary: Primary.white, fixedSize: Size(30, 20)
                                              ),

                                            ),
                                            SizedBox(width: 5),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  if(txt_numero_dni_sear_reclutado.text.length == 8){
                                                    FocusScope.of(context).unfocus();
                                                    var resultado = await BuscarReclutadoDni(txt_numero_dni_sear_reclutado.text);
                                                    if(resultado == 1){
                                                      FocusScope.of(context).unfocus();
                                                    }
                                                  }else{
                                                    toasty(this.context, "Completar dígitos.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                                                  }


                                                },
                                                child:cargandoSearchDniApi
                                                    ? SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                    : Icon(Icons.search),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Primary.azul, onPrimary: Primary.white, fixedSize: Size(30, 20)
                                                )
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 25,),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text('NOMBRE(S) RECLUTADO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: txt_nombres_reclutado,
                                                      decoration: const InputDecoration(
                                                        hintText: 'Nombres',
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          this.descripcion = value;
                                                        });
                                                      },

                                                      textInputAction: TextInputAction.next,
                                                      readOnly: false,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 25,),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text('APELLIDOS RECLUTADO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: txt_apellidos_reclutado,
                                                      decoration: const InputDecoration(
                                                        hintText: 'Apellidos',
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          this.descripcion = value;
                                                        });
                                                      },

                                                      textInputAction: TextInputAction.next,
                                                      readOnly: false,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 25,),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text('NÚMERO DOCUMENTO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: txt_numero_dni_reclutado,
                                                      decoration: const InputDecoration(
                                                        hintText: 'Número documento',
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          this.descripcion = value;
                                                        });
                                                      },

                                                      maxLines: null,
                                                      keyboardType: TextInputType.multiline,
                                                      textInputAction: TextInputAction.next,
                                                      readOnly: true,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 25,),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text('TELÉFONO:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: txt_telefono_reclutado,
                                                      decoration: const InputDecoration(
                                                        hintText: 'Teléfono',
                                                      ),
                                                      onChanged: (value){

                                                      },

                                                      keyboardType: TextInputType.number,
                                                      maxLength: 9,
                                                      readOnly: false,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10,),

                                            Expanded(

                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 21.0), // this doesn't work for top and bottom

                                                  child: MaterialButton(
                                                    shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(50)),
                                                          disabledColor: Primary.azulc,
                                                          elevation: 5,
                                                          color: Primary.naranja,
                                                          child: Container(

                                                              alignment: Alignment.center,
                                                              width: double.infinity,
                                                              child: Row(
                                                                children: <Widget>[

                                                                  loadingAgregandoDetalle
                                                                      ?SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                                                                      :Icon(Icons.save_outlined, color: Primary.white),
                                                                  SizedBox(width: 10),
                                                                  Expanded(child:
                                                                  Text(
                                                                    loadingAgregandoDetalle
                                                                        ?"Agregando.."
                                                                        :"Agregar"
                                                                    ,
                                                                    style: TextStyle(
                                                                      color: Primary.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 17,
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                  )
                                                                  )
                                                                ],
                                                              )
                                                          ),
                                                          onPressed:  () async {

                                                            if(this.txt_nombres_reclutado.text =="" || this.txt_nombres_reclutado.text == "Sin respuesta" || this.txt_nombres_reclutado.text == "Sin datos" ){
                                                              toasty(this.context, "Ingrese nombre(s)", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                                                              return;
                                                            }else if(this.txt_apellidos_reclutado.text =="" || this.txt_apellidos_reclutado.text == "Sin respuesta" || this.txt_nombres_reclutado.text == "Sin datos"){
                                                              toasty(this.context, "Ingrese apellidos", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                                                              return;
                                                            }else if(this.txt_telefono_reclutado.text =="" || this.txt_telefono_reclutado.text == "Sin respuesta" || this.txt_nombres_reclutado.text == "Sin datos"){
                                                              toasty(this.context, "Ingrese teléfono", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                                                              return;

                                                            }
                                                            await registraDetalleTareoTemporal(this.txt_numero_dni_reclutado.text, this.txt_nombres_reclutado.text
                                                              , this.txt_apellidos_reclutado.text, this.txt_telefono_reclutado.text);
                                                            this.limpiarDatosDetalle();
                                                          },
                                                    ) ,

                                                )
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 25,),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                            child: Text('PERSONAL DE TAREO: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                            alignment: Alignment.center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(
                                                      color: Colors.black,
                                                      thickness: 2,
                                                    ),

                                                    Container(
                                                      height: MediaQuery.of(context).size.height * 0.4,
                                                      child:this.loadingCargaDetalleTareo
                                                          ? Container(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CircularProgressIndicator(
                                                              color: Primary.azul,
                                                            ),
                                                            SizedBox(height: 20),
                                                            Text(
                                                              "Obteniendo datos, espere...",
                                                              style: TextStyle(
                                                                  color: Primary.azul,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                      :ListView.separated(
                                                        itemCount: this.objRegistroDetalle.length,
                                                        itemBuilder: (context, index) => ListTile(
                                                            title: Text(this.objRegistroDetalle[index]['apellidos']+', '+this.objRegistroDetalle[index]['nombres'],style:TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                                            subtitle: Text(this.objRegistroDetalle[index]['dni_reclutado'],style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                                                        ),
                                                        separatorBuilder: (context, index) {
                                                          return Divider(
                                                            color: Theme.of(context).dividerColor,
                                                            height: 0,
                                                          );
                                                        },
                                                      )
                                                    ),
                                                    Divider(
                                                      color: Colors.black,
                                                      thickness: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 35,),




                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                      ),
                      /*
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 10, 30, 40),
                        child: Image.asset('static/images/inspeccion2.png', height: 265,),
                      ),
                      */
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom,
                      ),
                    ],
                  ),
                ),
              )
    );
  }

  Widget getAppBarUI() {
    return Container(
      height: MediaQuery.of(this.context).size.height * 0.11,
      decoration: BoxDecoration(
        color: Primary.azul.withOpacity(1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32.0),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Primary.azul.withOpacity(0.4 * 1),
              offset: const Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(this.context).padding.top,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Ingresar Registro',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: Primary.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        letterSpacing: 1.2,
                        color: Primary.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 28,
                  width: 28,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(32.0)),
                    onTap: () {
                      //Navigator.pushReplacementNamed(this.context, 'home');
                    },
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        color: Primary.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.calendar_today,
                          color: Primary.white,
                          size: 16,
                        ),
                      ),
                      Text(
                        hoy,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: Primary.fontName,
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          letterSpacing: -0.2,
                          color: Primary.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 28,
                  width: 28,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(32.0)),
                    onTap: () {},
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: Primary.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void obtenerFecha() {
    hoy = DateFormat("dd MMM").format(DateFormat("yyyy-MM-dd HH:mm:ss").parseUTC(DateTime.now().toString()).toUtc());
  }
}


Future mFormBottomSheet(BuildContext aContext, String titulo, int id_vc_, String fecha) async {
  await showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: aContext,
    isScrollControlled: true,
    isDismissible: false,
    builder: (BuildContext context) {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(50),
              ),
              color: Primary.background),
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SelectSync(titulo, id_vc_, fecha),
              ],
            ),
          )
      );
    },
  );
}

class SelectSync extends StatefulWidget {
  const SelectSync(this.titulo, this.id_vc, this.fechaSS);

  final String? titulo;
  final String? fechaSS;
  final int? id_vc;

  @override
  _SelectSyncState createState() => _SelectSyncState();
}

class _SelectSyncState extends State<SelectSync> {

  List<String> h_visita = ['De 6 a 10', 'De 10 a 1', 'De 1 a 4'];
  String? h_visitaSelected = 'De 6 a 10';

  // late List<Area> areas;
  String selectedIndexArea = 'Calidad';

  File? image;
  int total = 0;
  List<File> imagenes = [];

  String umbrles = "";
  String evaluadores = "";
  String variedades = "";
  String fundos_ = "";
  String campos = "";
  String campanas = "";
  String vigencias = "";
  String error = "";
  bool isLoading = false;
  bool isError = false;
  bool isSuccess = false;
  bool isValidator = false;

  bool isCheckedSi = true;
  bool isCheckedNo = false;

  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  TextEditingController dateinput = TextEditingController();
  TextEditingController responsableCon = TextEditingController();
  final myController = TextEditingController();
  final floController = TextEditingController();

  String descripcion = '';
  String responsable = '';
  String accion_correctiva = '';
  int plazo_lo = 0;

  //DateTime fecha = DateTime.parse(widget.fechaSS).add(const Duration(days: 2));

  bool borrar = true;

  int total_fotos = 0;

  String hora = '';

  @override
  void initState() {
    dateinput.text = "";
    super.initState();
    // datosSeleccion2();
  }

  @override
  void dispose() {
    super.dispose();
    eliminarImagenes();
  }

  /*
  Future datosSeleccion2() async {

    setState(() => isLoading = true);

    this.areas = await AgrovisionDataBase.bd.obtenerAreas();
    this.selectedIndexArea = this.areas[0].nombre;

    var nowTime = DateTime.now ();
    this.hora = DateFormat('HH:mm:ss').format(nowTime);

    setState(() => isLoading = false);
  }
  */

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source, imageQuality: 50);
      if (image == null) return;

      final imageTemporary = await saveImagePermanentemente(image.path);
      setState(() {
        setState(() {
          this.imagenes.add(imageTemporary);
          this.total_fotos = 1;
        });
      });
    } on PlatformException catch (e) {
      print('Falló la carga de imagen: $e');
    }
  }

  Future<File> saveImagePermanentemente(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  Future muchasImagenes() async {
    try {
      final image = await ImagePicker().pickMultiImage(imageQuality: 50);
      if (image == null) return;

      for (var value in image) {
        final imageTemporary = await saveImagePermanentemente(value.path);
        setState(() {
          this.imagenes.add(imageTemporary);
          this.total_fotos = 1;
        });
      }

    } on PlatformException catch (e) {
      print('Falló la carga de imagen: $e');
    }
  }

  Future eliminarImagenes() async {
    if (this.borrar){
      for (var value in this.imagenes) {
        value.delete();
      }
    }
  }

  /*
  Future registrarCheckList() async{
    setState(() => isLoading = true);

    var sino = this.isCheckedSi ? 'Si' : 'No';
    final ChekL = CheckList(categoria: widget.titulo!, respuesta: sino, hora_visita: this.hora, descripcion: this.descripcion, responsable: this.responsableCon.text, area: this.selectedIndexArea, accion_correctiva: this.accion_correctiva == '' ? null : this.accion_correctiva, plazo_dias_lo: this.plazo_lo == 0 ? null : this.plazo_lo, fecha_lo: (floController.text != '') ? DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(floController.text)) : null, estado: '0', visita_campo: widget.id_vc!);

    var idCheLis = await AgrovisionDataBase.bd.crearCheckList(ChekL);

    if (idCheLis > 0){
      for(var vaal in imagenes){
        var fo_cl = FotosCL(file: vaal.path, descripcion: 'OB', estado: '0', check_list: idCheLis);
        await AgrovisionDataBase.bd.crearFotosCL(fo_cl);
      }
    }

    setState(() { isLoading = false; isSuccess = true;});

  }
*/

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Container(
        child: Center(
            child:
            isSuccess
                ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.025),
              child: Column(
                children: <Widget>[
                  Icon(Icons.check, color: Primary.azul, size: 40),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  Text("Registro completado.",
                      style: TextStyle(
                          color: Primary.azul, fontWeight: FontWeight.bold))
                ],
              ),
            )
                : isLoading
                ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.025),
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(
                    color: Primary.azul,
                    semanticsLabel: "Guardando datos...",
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025),
                  Text("Guardando registros...",
                      style: TextStyle(
                          color: Primary.azul, fontWeight: FontWeight.bold))
                ],
              ),
            )
                : isError
                ? Container(
              padding: EdgeInsets.all(25),
              child: Column(
                children: <Widget>[
                  Icon(
                      Icons
                          .signal_wifi_statusbar_connected_no_internet_4_rounded,
                      size: 50,
                      color: Primary.azul),
                  SizedBox(height: 20),
                  Text(
                    "No tienes una conexión activa a internet o nuestros servidores se encuentran en mantenimiento. Inténtalo nuevamente más tarde.",
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    this.error,
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
            )
                : Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.titulo!,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 6,),
                    Container(
                      child: IconButton(
                          onPressed: () {
                            finish(context);
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 25,
                          )),
                    )
                  ],
                ),
                Divider(),
                Container(
                  height: MediaQuery.of(this.context).size.height * 0.65,
                  child: Form(
                    key: _formKey2,
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        SizedBox(height: MediaQuery.of(context).size.height * 0.010),
                        Row(
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                setState(() {
                                  isCheckedSi = !isCheckedSi;
                                  isCheckedNo = !isCheckedNo;

                                  this.isValidator = isCheckedNo ? true : false;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Text('Si: ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    fillColor: MaterialStateProperty.resolveWith(getColor),
                                    value: isCheckedSi,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isCheckedSi = value!;
                                        isCheckedNo = !value;

                                        this.isValidator = !value ? true : false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  isCheckedSi = !isCheckedSi;
                                  isCheckedNo = !isCheckedNo;

                                  this.isValidator = isCheckedNo ? true : false;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Text('No: ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                  Checkbox(
                                    checkColor: Colors.white,
                                    fillColor: MaterialStateProperty.resolveWith(getColor),
                                    value: isCheckedNo,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isCheckedNo = value!;
                                        isCheckedSi = !value;

                                        this.isValidator = value ? true : false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Horario de visita: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

                                TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your email',
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  enabled: false,
                                  initialValue: this.hora,
                                ),
                                /*
                                      DropdownButton(
                                        isExpanded: true,
                                        value: h_visitaSelected,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                        ),
                                        onChanged: (dynamic newValue) {
                                          setState(() {
                                            h_visitaSelected = newValue;
                                          });
                                        },
                                        items: h_visita.map((category) {
                                          return DropdownMenuItem(
                                            child: Text(category),
                                            value: category,
                                          );
                                        }).toList(),
                                      ),
                                      */
                              ],
                            ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                        Row(
                          children: <Widget>[
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Descripción de la Situación: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Descripción',
                                  ),
                                  onChanged: (value){
                                    setState(() {
                                      this.descripcion = value;
                                    });
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Descripción requerida';
                                    }
                                    return null;
                                  },
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                        Row(
                          children: <Widget>[
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Responsable: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                /*
                                      TextFormField(
                                        onChanged: (value){
                                          setState(() {
                                            this.responsable = value;
                                            myController.text = this.responsable;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Responsable',
                                        ),
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Responsable requerido';
                                          }
                                          return null;
                                        },
                                      ),
                                      */
                                TypeAheadFormField(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: this.responsableCon,
                                    ),
                                    suggestionsCallback: (pattern) async {
                                      return SugerenciasResponsable.getSuggestions(pattern);
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return ListTile(
                                        title: Text(suggestion.toString()),
                                      );
                                    },
                                    transitionBuilder: (context, suggestionsBox, controller) {
                                      return suggestionsBox;
                                    },
                                    onSuggestionSelected: (suggestion) {
                                      this.responsableCon.text = suggestion.toString();
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Responsable requerido';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      this.responsable = value!;
                                      FocusScope.of(context).nextFocus();
                                    }
                                )
                              ],
                            ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                        Row(
                          children: <Widget>[
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Área Responsable: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                /*
                                DropdownButton(
                                  isExpanded: true,
                                  value: selectedIndexArea,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                  ),
                                  onChanged: (dynamic newValue) {
                                    setState(() {
                                      this.selectedIndexArea = newValue;
                                    });
                                    FocusScope.of(context).nextFocus();
                                  },

                                  items: this.areas.map((f) {
                                    return DropdownMenuItem(
                                      child: Text(f.nombre),
                                      value: f.nombre,
                                    );
                                  }).toList(),
                                ),
                                */
                              ],
                            ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                        Row(
                          children: <Widget>[
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Accion Correctiva: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Accion correctiva',
                                  ),
                                  onChanged: (value){
                                    setState(() {
                                      this.accion_correctiva = value;
                                    });
                                  },
                                  validator: (String? value) {
                                    if (this.isValidator && (value == null || value.isEmpty)) {
                                      return 'Acción correctiva requerida';
                                    }
                                    return null;
                                  },
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                        /*
                            Row(
                              children: <Widget>[
                                Expanded(child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Firma Responsable: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                      Column(
                                        children: [
                                          Signature(
                                            controller: _controller,
                                            height: MediaQuery.of(context).size.height * 0.21,
                                            backgroundColor: Colors.white,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).size.height * 0.05,
                                            decoration: const BoxDecoration(color: Primary.verde),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                //SHOW EXPORTED IMAGE IN NEW ROUTE
                                                //CLEAR CANVAS
                                                IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  color: Primary.white,
                                                  onPressed: () {
                                                    setState(() => _controller.clear());
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.undo),
                                                  color: Primary.white,
                                                  onPressed: () {
                                                    setState(() => _controller.undo());
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.redo),
                                                  color: Primary.white,
                                                  onPressed: () {
                                                    setState(() => _controller.redo());
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.check),
                                                  color: Primary.white,
                                                  onPressed: () async {
                                                    if (_controller.isNotEmpty) {
                                                      final Uint8List? data = await _controller.toPngBytes();

                                                      if (data != null) {
                                                        setState(() {
                                                          this.foto_firma = data;
                                                        });
                                                        toasty(context, "Firma agregada.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);


                                                        /*
                                                        final directory = await getApplicationDocumentsDirectory();
                                                        var nowTime = DateTime.now ();
                                                        var a = nowTime.millisecondsSinceEpoch;
                                                        final name = basename('firma_$a.jpg');
                                                        final image = File('${directory.path}/$name').writeAsBytes(data);
                                                        print('${directory.path}/$name');
                                                        */

                                                        /*
                                                        await Navigator.of(context).push(
                                                          MaterialPageRoute<void>(
                                                            builder: (BuildContext context) {
                                                              return Scaffold(
                                                                appBar: AppBar(),
                                                                body: Center(
                                                                  child: Container(
                                                                    color: Colors.grey[300],
                                                                    child: Image.memory(data),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                        */
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            */
                        /*
                              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                              Row(
                                children: <Widget>[
                                  Expanded(child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Fecha de L.O: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      TextField(
                                          controller: dateinput,
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2101)
                                            );

                                            if(pickedDate != null ){
                                              String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);

                                              setState(() {
                                                dateinput.text = formattedDate; //set output date to TextField value.
                                              });
                                            }else{
                                              print("Date is not selected");
                                            }

                                          }
                                      ),
                                    ],
                                  ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Firma Conformidad: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          hintText: '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  ),
                                ],
                              ),
                              */
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Plazo de L.O: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Días',
                                  ),
                                  onChanged: (value){
                                    setState(() {
                                      if (value != '') {
                                        this.plazo_lo = value.toInt();
                                        floController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(widget.fechaSS!))).add(Duration(days: this.plazo_lo))).toString();
                                      }else{
                                        floController.text = '';
                                      }
                                    });
                                  },
                                  maxLength: 2,
                                  keyboardType: TextInputType.phone,
                                  validator: (String? value) {
                                    if (this.isValidator && (value == null || value.isEmpty)) {
                                      return 'Plazo de L.O requerido';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
                            ),
                            ),
                            SizedBox(width: 15),
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Fecha de L.O: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                TextFormField(
                                    controller: floController,
                                    decoration: const InputDecoration(
                                      hintText: 'Fecha L.O',
                                    ),
                                    validator: (String? value) {
                                      if (this.isValidator && (value == null || value.isEmpty)) {
                                        return 'Fecha de L.O requerida';
                                      }
                                      return null;
                                    },
                                    readOnly: true,
                                    enabled: false
                                ),
                              ],
                            ),
                            ),
                          ],
                        ),
                        SizedBox(height: 45, child: Divider()),
                        Text('Fotos:', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: GridView.count(
                            crossAxisCount: 1,
                            scrollDirection: Axis.horizontal,
                            children: List.generate(this.imagenes.length, (index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 8, bottom: 8),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    color: Primary.white,
                                    image: DecorationImage(
                                      image: Image.file(this.imagenes[index], fit: BoxFit.cover).image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      focusColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      splashColor: Primary.white.withOpacity(0.4),
                                      onTap: () { print ("corto");},
                                      onLongPress: () {
                                        setState(() {
                                          this.imagenes[index].delete();
                                          this.imagenes.removeAt(index);

                                          this.total_fotos = this.imagenes.length > 0 ? 1 : 0;

                                        });
                                      },
                                      child: SizedBox(),
                                    ),
                                  ),
                                ),
                              );

                            }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                disabledColor: Primary.azul,
                                elevation: 0,
                                color: Primary.azul,
                                child: Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  child: Icon(Icons.image_rounded, color: Primary.white),
                                ),
                                onPressed: () async {
                                  //Navigator.pushReplacementNamed(context, 'camara');
                                  muchasImagenes();

                                },
                              ),
                            ),
                            SizedBox(width: 15,),
                            Expanded(
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                disabledColor: Primary.azul,
                                elevation: 0,
                                color: Primary.azul,
                                child: Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  child: Icon(Icons.camera_alt_rounded, color: Primary.white),
                                ),
                                onPressed: () async {
                                  //Navigator.pushReplacementNamed(context, 'camara');
                                  pickImage(ImageSource.camera);
                                },
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                        disabledColor: Primary.azul,
                        elevation: 0,
                        color: Primary.azul,
                        child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text("Guardar",
                                        style: TextStyle(
                                            color: Primary.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17
                                        )
                                    )
                                ),
                                Icon(Icons.save, color: Primary.white,)
                              ],
                            )
                        ),
                        onPressed: () async {
                          //Navigator.pushReplacementNamed(context, 'camara');
                          //setState(() => this.borrar = false );

                          FocusScope.of(context).unfocus();
                          if(_formKey2.currentState?.validate() ?? false){
                            setState(() => this.borrar = false );
                            // registrarCheckList();
                            await Future.delayed(Duration(milliseconds: 1500));
                            finish(context);
                          }else{
                            return;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
        )
    );
  }
}

/*
class Sugerencias{
  static Future<List<CategoriaCultivo>> getSuggestions(String query) async {
    if (query.isEmpty && query.length < 2) {
      return Future.value([]);
    }

    late List<CategoriaCultivo> matches;

    matches = await AgrovisionDataBase.bd.obtenerCategoriaCultivo();

    matches.retainWhere((s) => s.nombre.toLowerCase().contains(query.toLowerCase()));

    return matches;

  }
}
*/

class SugerenciasResponsable{

  static List<String> getSuggestions(String query) {
    late List<String> data = [
      'ALVA ROBLES, ROMULO GREGORIO',
      'ANGELES SANCHEZ, LUIS ALBERTO',
      'ASCENCIO CARLOS, KARITO',
      'ATUSPARIA NAVARRETE, ESTEPHANY ALESANDRA',
      'BANCES PERALTA, JOSE LUIS',
      'BARRETO GUTIERREZ, JAIME ENRIQUE',
      'CAJJA MAGUIÑA ZAPATA, CESAR ANTONIO PEDRO SEBASTIAN',
      'CALDERON TOTORA, JULIO CESAR',
      'CALLE PALACIOS, HECTOR ENRIQUE',
      'CAMPOS FERNANDEZ JEFFERSON ALEXANDER',
      'CARRASCO AGURTO, JOSE JOAN',
      'CARRILLO DE LA CRUZ, CARLOS ALBERTO',
      'CASTAÑEDA RAMIREZ, JEAN CARLOS',
      'CASTILLO CORDOVA, JOSELYN NATALY',
      'CASTRILLO GONZALEZ, HUGO DAVID',
      'CHECA VILELA, GILBERTO GIANMARCO',
      'CHOMBA HERNANDEZ, TATIANA THALIA',
      'CORDOVA SANDOVAL, ESTEBAN ADRIAN',
      'DANIELA MERCEDES REYNA RUIZ',
      'ESCALANTE MANRIQUE, LEOPOLDO HUMBERTO',
      'FALEN JIMENEZ, MONICA DEL CARMEN',
      'FAYA RAMOS, WILLPER MAURILIO',
      'FUKUY BENITES, SILVIA YOLANDA',
      'GONZALES VASQUEZ, DEYVIS JUNNIOR',
      'GUARDADO TORRES, NELSON ULISES',
      'HOLGUIN LOPEZ, JORDY PETER',
      'HORNA CASTRO, EDUAR MANUEL',
      'LEONARDO AVELLANEDA, PAUL JESUS',
      'LLAJARUNA CORONEL, VICENTE',
      'MAQUEN MATALLANA, EDUAR JHONATAN',
      'MAYANGA PUPUCHE, ROXANA',
      'MEZA MENACHO, LUZ CAMILA',
      'MIJAHUANCA CHUQUILLANQUE, JASSON',
      'MIRANDA GALOC DANTE',
      'MONJA HUANCAS, SANTOS',
      'MORI GONZAGA, DAVID ALEJANDRO',
      'MOZO AGUILAR, MILAGRITOS YESENIA',
      'NUÑEZ VILLAR, ALFREDO ESTEBAN',
      'OCAMPO CHAVEZ, DIANA LIZET',
      'ORTIZ DELGADO, WALTER YONATAN',
      'PEÑA CHUQUILLANQUI, CINTHIA EDITH',
      'PERALTA PINGO, KENYI ALEXANDER',
      'PERALTA TORRES, IRVIN XAVIER',
      'PUPUCHE BENITES, HEBERT ALFONSO',
      'QUIROZ HUAMAN, HELLEN ESTEFHANY',
      'RAEZ VALLE, JUAN CARLOS',
      'RAZURI ODAR, CARLOS JHOAN',
      'REYES ARNALES, FRANK JUNIOR',
      'REYES RUIZ, LINDLEY GALINDO',
      'ROA SOTO, WILFREDO LEANDRO',
      'SALAZAR AVILA, JOSE CARLOS',
      'SALINAS QUISPE, ALBERTO FAUSTINO',
      'SANCHEZ AREVALO, JOSE MANUEL',
      'SANCHEZ TAMARA, RAY CESAR',
      'SERRATO OYOLA, ISMAEL',
      'SILVA CABANILLAS, JORGE ANTONI',
      'SOLIS ACOSTA, LILIANA',
      'SUAR DOMINGUEZ, JUANA',
      'TESEN PACHECO, JOSE WILLIAM',
      'TESEN PACHECO, YAKELINE DEL ROCIO',
      'TUÑOQUE CASTILLO, MAX ALEJANDRO',
      'URIARTE OLIVERA, ELBERT',
      'VICENTE LLAJARUNA CORONEL',
      'VICTOR PRETEL ALCÁNTARA',
      'VILCHEZ GONZALES, JUAN JOEL',
      'VINCES LA ROSA, ANTHONY JOEL'
    ];

    late List<String> matches;

    matches = data;

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));

    return matches;

  }
}