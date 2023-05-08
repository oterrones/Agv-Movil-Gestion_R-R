import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:proyectoryr/db/database.dart';
import 'package:proyectoryr/modelos/personal_reclutado.dart';
import 'package:proyectoryr/modelos/registro_foto.dart';
import 'package:proyectoryr/src/tema/primary.dart';
import 'package:proyectoryr/src/var/var.dart';
import 'package:signature/signature.dart';

import 'dart:io';
import 'dart:async';

import '../../modelos/enviarServidor.dart';
import '../../modelos/enviarServidor.dart';
import '../../modelos/enviarServidor.dart';
import '../../modelos/enviarServidor.dart';
import '../../modelos/enviarServidor.dart';

class listRegistrosReclutamientoPersonal extends StatefulWidget {
  @override
  State<listRegistrosReclutamientoPersonal> createState() => _listRegistrosReclutamientoPersonalState();
}

class _listRegistrosReclutamientoPersonalState extends State<listRegistrosReclutamientoPersonal> with TickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKeyRe = GlobalKey<ScaffoldState>();

  String hoy = "";
  String error = "";
  // late List<VisitaCampo2> _visitaCampo = [];
  bool loading = false;
  bool loading2 = false;
  bool loadingDatos = false;
  bool isError = false;
  late List<Map<String, dynamic>> registrosT = [];
  late List<Map<String, dynamic>> registrosResumen = [];

  late List<Map<String, dynamic>> reg = [];
  late List<Map<String, dynamic>> fotos = [];
  late Map<String, dynamic> regResumen = this.regResumen = {
    "total": "0",
    "sincronizados": "0",
    "pendiente": "0",
  };

  late List<TareoLiderZonaAws> registrosSinEnviar = [];
  late List<DetalleTareoLiderZonaAws> registrosSinEnviardos = [];

  late Map stringVCDevueta;
  late Map stringCLDevueta;

  @override
  void initState() {
    super.initState();
    obtenerFecha();
    traerDatos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future traerDatos() async{
    setState(() => this.loading2 = true);
    this.registrosT = await AgrovisionDataBase.bd.obtenerRegPersonalReclutado();
    this.registrosResumen =  await AgrovisionDataBase.bd.getDatosResumenes();

    var i = 0;
    this.reg = [];

    for(var spd in this.registrosT){
      if(i!=spd['id']){
        setState(() {
          this.reg.add(spd);
        });
        i = spd['id'];
      }
    }
    for(var spds in this.registrosResumen){
      setState(() {
        this.regResumen = {
          "total": spds['total_pistoleados'],
          "sincronizados": spds['total_ultima_sincronizacion'],
          "pendiente": spds['pendiente_sincronizar'],
        };
      });
    }

    setState(() => this.loading2 = false);
    print("tam: "+ this.reg.length.toString());
    if(this.reg.length>0){
      setState(() => this.loadingDatos = false);
    }else{
      setState(() => this.loadingDatos = true);
    }
  }

  Future <String>  enviarRegistrosReclutamientoServidor() async{
    var salida = "inicio";
    try {

      final resultado = (await AgrovisionDataBase.bd.ListaGetAllPersonalTareoLiderMovilAws());



      var headers = {
        'Content-Type': 'application/json; charset=utf-8'
      };




      for (int i = 0; i < resultado.length; i++) {
        var idtareo_local = resultado[i]["id"];
        var request = http.Request('POST', Uri.parse('http://35.175.69.142/backend/cosecha/personal/crear/tareo/diario'));
        request.body = json.encode({
          "numero_placa": resultado[i]["numero_placa"],
          "fecha_registro": resultado[i]["fecha_registro"],
          "hora_registro": resultado[i]["hora_registro"],
          "region": resultado[i]["region"],
          "provincia": resultado[i]["distrito"],
          "distrito": resultado[i]["distrito"],
          "centro_poblado": resultado[i]["centro_poblado"],
          "paradero": resultado[i]["paradero"],
          "latitud": resultado[i]["latitud"],
          "longitud": resultado[i]["longitud"],
          "dni_lider_zona": resultado[i]["dni_lider_zona"],
          "rec_lider_zona": resultado[i]["rec_lider_zona_id"],
          "dni_usuario_logeado": resultado[i]["dni_usuario_logeado"],
          "usuario_logeado": resultado[i]["usuario_logeado_id"],
          "estado": resultado[i]["estado"]
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          var responseString = await response.stream.bytesToString();

          Map<String, dynamic> contJson = jsonDecode(responseString);
          var codigoWeb = contJson["id"];
          if(i==0){
            await AgrovisionDataBase.bd.AllUpdateDetalleTareoZonaZincronizadoAll();
          }

          enviarRegistrosReclutamientoDetalleServidor(idtareo_local,codigoWeb,i,resultado.length);
          salida = "ok";
        }
        else {
          print("error");
          salida = "error";

        }
      }



  } on SocketException {
      print("No Internet connection");
      salida = "sin_internet";

  } on HttpException {

    print("Couldn't find the post");
    salida = "no_se_encontro_solicitud_http";
  } on FormatException {

    print('Bad response format');
    salida = "formato_incorrecto";
  }




   // await this.traerDatos();
    return salida;
  }
  Future enviarRegistrosReclutamientoDetalleServidor(int codigoTareoLocal, int codigoTareoServer,int i,int registros) async{
    List<Map<String, dynamic>> _respuestasInsert = [];
    try {


      this.registrosSinEnviardos= (await AgrovisionDataBase.bd.getAllDetalleTareoMovilServer(codigoTareoLocal, codigoTareoServer))!;
      String jsonPersonalReclutado= jsonEncode( this.registrosSinEnviardos);



      String url =  "http://35.175.69.142/backend/reclutamiento/personal/detalle/tareo/recibir/movil/";

      final respuesta = await http.post(Uri.parse(url),headers: {'Content-Type': 'application/json; charset=utf-8'},body: jsonPersonalReclutado);

      var respuestaRegistro = (respuesta.body);
      if (respuesta.statusCode == 200) {

        await AgrovisionDataBase.bd.AllUpdateDetalleTareoZonaZincronizadoId(codigoTareoLocal,'3', '0');
        await AgrovisionDataBase.bd.AllUpdateDetalleTareoZona(codigoTareoLocal, '2', '0');
        await AgrovisionDataBase.bd.IdUpdateTareoZona(codigoTareoLocal,'2','0');

        print((i+1));
        print(registros);

        if((i+1) == registros){
          await this.traerDatos();
        }




      } else {
        throw Exception('Failed to load album');
      }
      //fin ok

    } on SocketException {
      print("No Internet connection");

    } on HttpException {

      print("Couldn't find the post");
    } on FormatException {

      print('Bad response format');
    }

      setState(() {
        this.loading = false;
      });





  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Primary.white.withOpacity(0),
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Primary.azul,
            systemNavigationBarIconBrightness: Brightness.light),
        child: Container(
          color: Primary.background,
          child: Scaffold(
            key: _scaffoldKeyRe,
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[
                getAppBarUI(),
                getResumenDatos(this.regResumen["total"].toString(),this.regResumen["sincronizados"].toString(),this.regResumen["pendiente"].toString()),
                Container(
                  height: MediaQuery.of(context).size.height -
                      (MediaQuery.of(this.context).size.height * 0.22 + MediaQuery.of(context).padding.bottom),
                  child:
                    this.loading2
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
                      :this.loadingDatos
                    ?Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.height * 0.025),
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.more_horiz, color: Primary.azul, size: 40),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                          Text("No se encuentrarón registros por enviar.",
                              style: TextStyle(
                                  color: Primary.azul, fontWeight: FontWeight.bold))
                        ],
                      ),
                    )
                    :ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: this.reg.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () async {
                              // print(index);
                              await mFormBottomSheet(context, this.reg[index]['id']);
                              //await traerDatos();
                            },
                            child: Container(
                              padding: EdgeInsets.only(bottom: 2.5, top: 10, left: 10, right: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Lider zona: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['lider_zona'], textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.004),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Fecha: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text('${DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(this.reg[index]['fecha_registro']))}', textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Hora: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['hora_registro'] , textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.height * 0.004),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Provincia: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['provincia'], textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.004),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Distrito: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['distrito'], textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.height * 0.004),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Latitud: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['latitud'], textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Longitud: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['longitud'], textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.004),
                                  Row(
                                    children: <Widget>[
                                      /*
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Fotos: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('3', textAlign: TextAlign.justify),
                                        ],
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                      */

                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('N° Reclutados: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text(this.reg[index]['total_reclutado'].toString(), textAlign: TextAlign.justify),
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Enviado: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['estado'] == '1' ? ' Sí ' : ' No ' , style: TextStyle(backgroundColor: this.reg[index]['estado'] == '0' ? Primary.naranja : Primary.verde , color: Primary.white)))
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.004),
                                  Divider(),
                                ],
                              ),
                            ),
                          );
                        }
                    )
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
            floatingActionButton: Row(
              children: <Widget>[
                Expanded(child: SizedBox()),
                MaterialButton(
                  onPressed: () async {

                    //await Future.delayed(Duration(milliseconds: 5000));
                    //await enviarDatosServidorVC();
                    //await traerDatos();
                    if(this.reg.length > 0){
                      _buildAlertDialog(context);
                    }else{
                      toasty(context, "No existen registros por enviar.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                    }

                    /*


                    setState(() {
                      this.loading = false;
                    });
                    toasty(context, "Registros guardados en el servidor.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                    */
                  },
                  color: Primary.azulb,
                  child:
                    this.loading
                      ? Row(
                        children: [
                          CircularProgressIndicator(
                            color: Primary.white,
                            strokeWidth: 3,
                          ),
                          SizedBox(width: 10),
                          Text("Guardando...", style: TextStyle(color: Primary.white)),
                        ],
                      )

                      : Row(
                        children: [
                          Icon(Icons.save_rounded, color: Primary.white),
                          SizedBox(width: 10),
                          Text("Guardar", style: TextStyle(color: Primary.white)),
                        ],
                      ),

                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget getAppBarUI() {
    return Container(
      height: MediaQuery.of(this.context).size.height * 0.13,
      decoration: BoxDecoration(
        color: Primary.azul.withOpacity(0),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(this.context).padding.top,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Ver registros',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: Primary.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        letterSpacing: 1.2,
                        color: Primary.azul,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 28,
                  width: 28,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                    onTap: () {
                      //Navigator.pushReplacementNamed(this.context, 'registro');
                      //_buildAlertDialog2(this.context);
                      traerDatos();
                    },
                    child: Center(
                      child: Icon(
                        Icons.refresh_rounded,
                        color: Primary.azul,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 28,
                  width: 28,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                    onTap: () {
                      Navigator.pushReplacementNamed(this.context, 'registro');
                    },
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        color: Primary.azul,
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
                          color: Primary.azul,
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
                          color: Primary.azul,
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
                    borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                    onTap: () {
                      //Navigator.pushReplacementNamed(this.context, 'registro');

                    },
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: Primary.azul,
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
  Widget getResumenDatos(String total,String sincronizados,String pendiente) {
    return
      Container(
        padding: EdgeInsets.only(left: 10,right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.app_registration_outlined, color: Primary.azul,size: 18,),
                    Text(' '+total),

                  ],
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 1,
                  color: Primary.azul,
                  child:Text("TOTAL",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),),
                  onPressed: () async {


                  },
                ),
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, color: Colors.cyan[600],size: 18,),
                    Text(' '+sincronizados),

                  ],
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 1,
                  color: Color.fromRGBO(91, 192, 222, 1),
                  child:Text("SINCRONIZADOS",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),),
                  onPressed: () async {


                  },
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.send_outlined,color: Colors.orange[500],size: 18,),
                    Text(' '+pendiente),

                  ],
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 1,
                  color: Color.fromRGBO(240, 173, 78 , 1),
                  child:Text("POR ENVIAR",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),),
                  onPressed: () async {


                  },
                ),
              ],
            ),
          ],
        ),
      );

  }

  void obtenerFecha() {
    hoy = DateFormat("dd MMM").format(DateFormat("yyyy-MM-dd HH:mm:ss").parseUTC(DateTime.now().toString()).toUtc());
  }

  void _buildAlertDialog(BuildContext context) {

    showGeneralDialog(
      context: context,
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              backgroundColor: Primary.white.withOpacity(0),
              content: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(7),
                        bottomLeft: Radius.circular(7)
                    ),
                    color: Primary.white
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(height: 100, decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(50),
                            ),
                            color: Primary.naranja
                        )),
                        Column(
                          children: [
                            Icon(Icons.warning, color: white, size: 32),
                            8.height,
                            Text('¡Alerta!', textAlign: TextAlign.center, style: TextStyle(color: Primary.white, fontSize: 19, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    30.height,
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Text("Se enviarán todos los registros al servidor. Este proceso puede tomar unos minutos, no salga ni cierre la aplicación.", textAlign: TextAlign.justify, style: Primary.body2),
                    ),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            //mFormBottomSheet2(context);
                          },
                          color: Primary.danger,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: BorderSide(
                                color: Primary.danger,
                              )),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Primary.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 15),
                        MaterialButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            //mFormBottomSheet2(context);
                            setState(() {
                              this.loading = true;
                            });

                            //await enviarDatosServidorVC();
                            //await traerDatos();

                            var respuesta = await enviarRegistrosReclutamientoServidor();


                            if(respuesta=="ok"){
                              toasty(this.context, "Registros guardados en el servidor.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);

                            }else if (respuesta=="sin_internet"){
                              toasty(this.context, "Sin internet", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);

                            }else{
                              toasty(this.context, "no se pudo enviar al servidor, inténtelo mas tarde!", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);

                            }

                            await Future.delayed(Duration(milliseconds: 6500));



                            setState(() {
                              this.loading = false;
                            });



                          },
                          color: Primary.naranja,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: BorderSide(
                                color: Primary.naranja,
                              )),
                          child: Text(
                            'Enviar',
                            style: TextStyle(color: Primary.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    16.height,
                  ],
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 250),
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {return SizedBox(); },
    );
  }

  void _buildAlertDialog2(BuildContext context) {
    showGeneralDialog(
      context: context,
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              backgroundColor: Primary.white.withOpacity(0),
              content: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(7),
                        bottomLeft: Radius.circular(7)
                    ),
                    color: Primary.white
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(height: 100, decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(50),
                            ),
                            color: Primary.naranja
                        )),
                        Column(
                          children: [
                            Icon(Icons.warning, color: white, size: 32),
                            8.height,
                            Text('¡Alerta!', textAlign: TextAlign.center, style: TextStyle(color: Primary.white, fontSize: 19, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    30.height,
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Text("Se restaurarán los registros del día 21/04/2022 al estado 'Sin Enviar'.", textAlign: TextAlign.justify, style: Primary.body2),
                    ),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            //mFormBottomSheet2(context);
                          },
                          color: Primary.danger,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: BorderSide(
                                color: Primary.danger,
                              )),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Primary.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 15),
                        MaterialButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            //mFormBottomSheet2(context);

                            //await restaurarDatosEnviadosVC();
                            //await traerDatos();
                            await Future.delayed(Duration(milliseconds: 2500));


                            toasty(this.context, "Registros restaurados.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);


                          },
                          color: Primary.naranja,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: BorderSide(
                                color: Primary.naranja,
                              )),
                          child: Text(
                            'Restaurar',
                            style: TextStyle(color: Primary.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    16.height,
                  ],
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 250),
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {return SizedBox(); },
    );
  }
}

Future mFormBottomSheet(BuildContext aContext, int id_vc_) async {
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
                SelectSync(id_vc_),
              ],
            ),
          )
      );
    },
  );
}

class SelectSync extends StatefulWidget {
  const SelectSync(this.id_reg);

  final int id_reg;

  @override
  _SelectSyncState createState() => _SelectSyncState();
}

class _SelectSyncState extends State<SelectSync> {

  late List<Foto> fotos = [];

  @override
  void initState() {
    super.initState();
    obtenerFotos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future obtenerFotos() async {
    var fotitos = await AgrovisionDataBase.bd.obtenerFotos(widget.id_reg);
    setState(() {
      this.fotos = fotitos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: SingleChildScrollView(
            child: ListView(shrinkWrap: true, children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Total de Fotos: " + this.fotos.length.toString(),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.010),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: GridView.count(
                  crossAxisCount: 1,
                  scrollDirection: Axis.vertical,
                  children: List.generate(this.fotos.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          color: Primary.white,
                          image: DecorationImage(
                            image: Image.file(File(this.fotos[index].file), fit: BoxFit.cover).image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(16.0)),
                            splashColor: Primary.white.withOpacity(0.4),
                            child: SizedBox(),
                          ),
                        ),
                      ),
                    );

                  }),
                ),
              )
            ]),
          ),
        ));
  }
}
