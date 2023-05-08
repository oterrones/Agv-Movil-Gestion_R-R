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
import 'package:proyectoryr/modelos/registro_foto.dart';
import 'package:proyectoryr/src/tema/primary.dart';
import 'package:proyectoryr/src/var/var.dart';
import 'package:signature/signature.dart';

import 'dart:io';
import 'dart:async';

class listRegistrosProyectoR_R extends StatefulWidget {
  @override
  State<listRegistrosProyectoR_R> createState() => _listRegistrosProyectoR_RState();
}

class _listRegistrosProyectoR_RState extends State<listRegistrosProyectoR_R> with TickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKeyRe = GlobalKey<ScaffoldState>();

  String hoy = "";
  String error = "";
  // late List<VisitaCampo2> _visitaCampo = [];
  bool loading = false;
  bool loading2 = false;
  bool isError = false;
  late List<Map<String, dynamic>> registrosT = [];

  late List<Map<String, dynamic>> reg = [];
  late List<Map<String, dynamic>> fotos = [];

  late List<Registro> registrosSinEnviar = [];

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
    this.registrosT = await AgrovisionDataBase.bd.obtenerRegFot();
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

    setState(() => this.loading2 = false);
  }

  Future enviarRegistrosServidor() async{
    this.registrosSinEnviar = await AgrovisionDataBase.bd.obtenerRegistros();
    this.registrosSinEnviar.forEach((element) async {
      if(element.idBd == null){
        var uro = Uri.parse("$link/registrosryr/crear/");

        var headers = {
          'Content-Type': 'application/json'
        };

        var request = http.Request('POST', uro);

        request.body = jsonEncode({
          "fecha": element.fecha,
          "dni_trabajador": element.dniTrabajador,
          "nombre_trabajador": element.nombreTrabajador,
          "observacion": element.observacion,
          "estado_e": element.estadoE,
          "latitud": element.latitud,
          "longitud": element.longitud,
          "estado": element.estado,
          "con_evaluador": element.idResponsable,
        });

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 201) {
          this.stringVCDevueta = json.decode(await response.stream.bytesToString());
          await AgrovisionDataBase.bd.actualizarReg(element.id!, this.stringVCDevueta['id']);
          await registrarFotos(element.fotos_ryr, this.stringVCDevueta['id']);

        }
        else {
          print(response.reasonPhrase);
        }
      }
    });
    await this.traerDatos();
  }

  Future registrarFotos(List<Foto> fotos, int idRegistro) async{
    fotos.forEach((fotitos) async {
      if(fotitos.idBd == null){
        var uro = Uri.parse("$link/fotosryr/crear/");

        var request = http.MultipartRequest('POST', uro)
          ..files.add(await http.MultipartFile.fromPath('file', fotitos.file))
          ..fields['ryr_registros'] = idRegistro.toString();

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 201) {
          this.stringCLDevueta = json.decode(await response.stream.bytesToString());
          print(this.stringCLDevueta);
          await AgrovisionDataBase.bd.actualizarFot(fotitos.id!, this.stringCLDevueta['id']);
        }
        else {
          print(response.statusCode);
          print(response.reasonPhrase);
        }

      }
    });
  }

/*
  Future enviarDatosServidorVC() async{
    print("VC");
    this.visitaCampoSinEnviar = await AgrovisionDataBase.bd.obtenerVisitaCampoSE();

    if (this.visitaCampoSinEnviar.isNotEmpty){
      for(var valuess in this.visitaCampoSinEnviar){
        var uro = Uri.parse("$link/visitascampo/crear/");
        await http.post (
          uro,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: json.encode(valuess),
        ).then((value) => {
          if(value.statusCode == 201){

            this.stringVCDevueta = jsonDecode(utf8.decode(value.bodyBytes)),

          }else if(value.statusCode == 500 || value.statusCode == 404){
            setState(() {
              isError = true;
              this.error = "sin codigo";
            })
          }
        }).catchError((error, stackTrace) {
          print(error);
        });

        if (!this.isError) {
          final eva = this.stringVCDevueta;
          await AgrovisionDataBase.bd.editarVisitaCampo(valuess.id!);
          await enviarDatosServidorCL(eva['id'], valuess.id!);
        }

      }
    }
  }

  Future restaurarDatosEnviadosVC() async{
    await AgrovisionDataBase.bd.editarEstadoVC();
  }

  Future enviarDatosServidorCL(int idVC, int idVCL) async{
    print("CL");
    this.checkListSinEnviar = await AgrovisionDataBase.bd.obtenerCheckListSE(idVCL);
    if (this.visitaCampoSinEnviar.isNotEmpty){

      for(var valuesc in this.checkListSinEnviar){
        var uro = Uri.parse("$link/checklist/crear/");

        var request = http.MultipartRequest('POST', uro)
          ..fields['categoria'] = valuesc.categoria
          ..fields['respuesta'] = valuesc.respuesta
          ..fields['hora_visita'] = valuesc.hora_visita
          ..fields['descripcion'] = (valuesc.descripcion == null ? '' : valuesc.descripcion)!
          ..fields['responsable'] = valuesc.responsable
          ..fields['area'] = valuesc.area
          ..fields['accion_correctiva'] = (valuesc.accion_correctiva == null ? '' : valuesc.accion_correctiva)!
          ..fields['plazo_dias_lo'] = (valuesc.plazo_dias_lo == null ? '' : valuesc.plazo_dias_lo)!.toString()
          ..fields['fecha_lo'] = (valuesc.fecha_lo == null ? '' : valuesc.fecha_lo)!
          ..fields['estado'] = valuesc.estado
          ..fields['visita_campo'] = idVC.toString()
          ..files.add(await http.MultipartFile.fromPath('firma_responsable', valuesc.firma_responsable!));

        var response = await request.send();

        var respuesta = await http.Response.fromStream(response);

        if (response.statusCode == 201) {
          this.stringCLDevueta = jsonDecode(utf8.decode(respuesta.bodyBytes));
        }else if(response.statusCode == 500 || response.statusCode == 404){
          setState(() {
            isError = true;
            this.error = "Error en check list";
          });
        }

        if (!this.isError) {
          final eva = this.stringCLDevueta;
          await AgrovisionDataBase.bd.editarCheckList(valuesc.id!);
          await enviarDatosServidorFotosCL(eva['id'], valuesc.id!);
        }

      }
    }
  }

  Future enviarDatosServidorFotosCL(int idCL, int idCLL) async{
    print("FCL");
    this.fotosCLSinEnviar = await AgrovisionDataBase.bd.obtenerFotosCLSE(idCLL);
    if (this.fotosCLSinEnviar.isNotEmpty){
      for(var valuesfc in this.fotosCLSinEnviar){
        var uro = Uri.parse("$link/fotoschecklist/crear/");

        var request2 = http.MultipartRequest('POST', uro)
          ..fields['descripcion'] = (valuesfc.descripcion == null ? '' : valuesfc.descripcion)!
          ..fields['estado'] = valuesfc.estado
          ..fields['check_list'] = idCL.toString()
          ..files.add(await http.MultipartFile.fromPath('file', valuesfc.file));

        var response2 = await request2.send();

        var respuesta2 = await http.Response.fromStream(response2);

        if (response2.statusCode == 201) {
          // print(jsonDecode(utf8.decode(respuesta2.bodyBytes)));
        }else if(response2.statusCode == 500 || response2.statusCode == 404){
          setState(() {
            isError = true;
            this.error = "Error en fotos de check list";
          });
        }

        if (!this.isError) {
          await AgrovisionDataBase.bd.editarFotosCheckList(valuesfc.id!);
        }

      }
    }
  }
  */

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
                Container(
                  height: MediaQuery.of(context).size.height -
                      (MediaQuery.of(this.context).size.height * 0.13 + MediaQuery.of(context).padding.bottom),
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
                      : ListView.builder(
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
                                              Text('Evaluador: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['nombres'] + " " + this.reg[index]['apellidos'], textAlign: TextAlign.justify))
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
                                              Expanded(child: Text('${DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(this.reg[index]['fecha']))}', textAlign: TextAlign.justify))
                                            ],
                                          )
                                      ),
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('Hora: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text('${DateFormat('hh:mm:ss').format(DateFormat('yyyy-MM-dd hh:mm:ss').parse(this.reg[index]['fecha']))}', textAlign: TextAlign.justify))
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
                                              Text('Trabajador: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['nombre_trabajador'], textAlign: TextAlign.justify))
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
                                              Text('Observación: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Expanded(child: Text(this.reg[index]['observacion'], textAlign: TextAlign.justify))
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
                                              Text('Estado: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text(this.reg[index]['estado_e'], textAlign: TextAlign.justify),
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
                    _buildAlertDialog(context);
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
                    padding: const EdgeInsets.all(8.0),
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

                            await enviarRegistrosServidor();
                            await traerDatos();
                            await Future.delayed(Duration(milliseconds: 6500));

                            setState(() {
                              this.loading = false;
                            });

                            toasty(this.context, "Registros guardados en el servidor.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);

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
