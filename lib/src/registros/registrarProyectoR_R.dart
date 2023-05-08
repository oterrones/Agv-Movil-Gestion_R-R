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
import 'package:proyectoryr/src/providers/input_decorations.dart';
import 'package:proyectoryr/src/tema/primary.dart';
import 'package:signature/signature.dart';

class registrarProyectoR_R extends StatefulWidget {
  registrarProyectoR_R(this.id_ed);

  int id_ed;

  @override
  State<registrarProyectoR_R> createState() => _registrarProyectoR_RState();
}

class _registrarProyectoR_RState extends State<registrarProyectoR_R> {
  String error = "hola";
  bool isCargando = true;
  bool isCargandoBtn = true;
  bool isError = false;
  bool isSuccess = false;
  bool isFirma = false;
  bool cargandoLL = false;
  String cosechaSem = "";
  String hora = "";
  String descripcion = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyH = GlobalKey<ScaffoldState>();

  /*
  late List<LocalLog> localhost;
  late List<CheckList> che_lis;
  */

  TextEditingController dateinput = TextEditingController();
  TextEditingController cultivo_area = TextEditingController();

  String hoy = "";
  TextEditingController nombre = TextEditingController();
  TextEditingController n_evaluador = TextEditingController();
  TextEditingController latitud = TextEditingController();
  TextEditingController longitud = TextEditingController();
  TextEditingController dni = TextEditingController();
  TextEditingController descripcion_c = TextEditingController();
  TextEditingController estado_c = TextEditingController();

  int id_eval = 0;
  int id_vc = 0;

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

  List<String> estados = ['Activo', 'Inactivo'];
  String? estadoSelected = 'Activo';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
    obtenerFecha();
    //validarCrearEditar(widget.id_ed);
    //traerCheckList();
    hola();
    dateinput.text = DateFormat("dd/MM/yyy").format(DateFormat("yyyy-MM-dd HH:mm:ss").parseUTC(DateTime.now().toString()).toUtc());;
  }

  @override
  void dispose() {
    super.dispose();

    //resetearInfoSE();
  }

  Future hola() async {
    setState(() => isCargando = true);
    this.dni.text = '';

    await Future.delayed(Duration(milliseconds: 600));
    var responsable =  await AgrovisionDataBase.bd.obtenerResponsable();

    this.nombre.text = responsable[0].nombres + " " + responsable[0].apellidos;
    this.id_eval = responsable[0].id;

    var nowTime = DateTime.now ();
    this.hora = DateFormat('HH:mm:ss').format(nowTime);
    //this.latitud.text  = "-6.7843" + Random().nextInt(999).toString();
    //this.longitud.text  = "-79.8424" + Random().nextInt(999).toString();

    setState(() => isCargando = false);
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

  Future obtenerTrabajador(String dni) async{
    setState(() => isCargandoBtn = true);

    var trabaja = await AgrovisionDataBase.bd.obtenerTrabajador(dni);

    if(trabaja.isNotEmpty){
      this.n_evaluador.text = trabaja[0].nombresall!;
    }else{
      this.n_evaluador.text = "";
      toasty(this.context, "DNI no encontrado.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
    }

    setState(() => isCargandoBtn = false);
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

  Future registraVisitaCampo() async {
    setState(() => isCargando = true);
    List<Foto> fotitos = [];

    for(var vaal in this.imagenes){
      fotitos.add(Foto(file: vaal.path, estado: '0'));
    }

    var fechita = dateinput.text.split('/')[2]+"-"+dateinput.text.split('/')[1]+"-"+dateinput.text.split('/')[0];

    final registro = Registro(fecha: fechita+ " " + this.hora, dniTrabajador: dni.text, nombreTrabajador: n_evaluador.text, observacion: descripcion_c.text, estadoE: estadoSelected!, latitud: latitud.text, longitud: longitud.text, estado: '0', idResponsable: this.id_eval, fotos_ryr: fotitos);

    await AgrovisionDataBase.bd.crearRegFot(registro);

    //await Future.delayed(Duration(milliseconds: 2800));

    this.dni.text = "";
    this.n_evaluador.text = "";
    this.descripcion_c.text = "";
    this.estado_c.text = "";
    this.total_fotos = 0;
    this.latitud.text = '';
    this.longitud.text = '';
    this.estadoSelected = 'Activo';
    this.imagenes = [];
    var nowTime = DateTime.now ();
    this.hora = DateFormat('HH:mm:ss').format(nowTime);

    setState(() => isCargando = false);
  }

  Future limpiarDatos() async {
    setState(() => isCargando = true);

    await Future.delayed(Duration(milliseconds: 1000));
    this.dni.text = "";
    this.n_evaluador.text = "";
    this.descripcion_c.text = "";
    this.estado_c.text = "";
    this.total_fotos = 0;
    this.imagenes = [];
    var nowTime = DateTime.now ();
    this.hora = DateFormat('HH:mm:ss').format(nowTime);

    setState(() => isCargando = false);
  }

  /*
  Future validarCrearEditar(int id_S) async{
    setState(() => isCargando = true);

    if(id_S == 0){
      await datosSeleccion();
    }

    setState(() => isCargando = false);
  }


  Future datosSeleccion() async {

    this.localhost = await AgrovisionDataBase.bd.obtenerLocal();
    this.nombre = this.localhost[0].nombre_evaluador!;
    this.id_eval = this.localhost[0].evaluador!;

  }


  Future registraVisitaCampo() async {
    setState(() => isCargando = true);

    final VisCa = VisitaCampo(
        empresa: this.empresaSelected!,
        fundo: this.fundoSelected!,
        etapa: this.etapaSelected!,
        campo_area: this.campoSelected!,
        cultivo_area: this.cultivoSelected!,
        zona_inspeccion: this.zona_inspeccionSelected!,
        fecha: DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(dateinput.text)),
        estado: '0',
        evaluador: this.id_eval);

    var IdVc = await AgrovisionDataBase.bd.crearVisitaCampo(VisCa);

    setState((){
      this.id_vc = IdVc;
      this.activar = false;
      isCargando = false;
    });
  }


  Future resetearInfoSE() async {
    await AgrovisionDataBase.bd.eliminarVisitaCampo(this.id_vc);
  }


  Future resetearInfo() async {
    setState(() => isCargando = true);

    await AgrovisionDataBase.bd.eliminarVisitaCampo(this.id_vc);

    setState((){
      this.id_vc = 0;
      this.activar = true;
      dateinput.text = "";
      isCargando = false;
    });
  }


  Future traerCheckList() async {
    var cl_es = await AgrovisionDataBase.bd.obtenerCheckList(id_vc);
    setState(() {
      this.che_lis = cl_es;
    });
  }


  Future guardarDatos() async {

    setState(() => isCargando = true);

    var spd = await AgrovisionDataBase.bd.obtenerTotalCLxVC(this.id_vc);

    if (spd[0]['total'] > 0 ){
      await Future.delayed(Duration(milliseconds: 1200));
      setState((){
        this.activar = true;
        dateinput.text = "";
        isFirma = true;
      });
    }else{
      toasty(this.context, "Debe registrar la inspección de al menos una categoría.", bgColor: Primary.danger, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
    }

    setState(() => isCargando = false);

  }


  Future guardarDatos2() async {
    setState(() => isCargando = true);

    final directory = await getApplicationDocumentsDirectory();
    var nowTime = DateTime.now ();
    var a = nowTime.millisecondsSinceEpoch;
    final name = basename('firma_$a.png');
    File('${directory.path}/$name').writeAsBytes(this.foto_firma!);

    print('${directory.path}/$name');

    await AgrovisionDataBase.bd.editarCheckListFirma(this.id_vc, '${directory.path}/$name');

    setState((){
      isCargando = false;
      isFirma = false;
      this.id_vc = 0;
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Primary.white.withOpacity(0),
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Primary.azul,
            systemNavigationBarIconBrightness: Brightness.light),
        child: Container(
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
                          : this.isFirma
                          ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
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
                                          height: MediaQuery.of(context).size.height * 0.3,
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

                                                      // await guardarDatos2();

                                                      await Future.delayed(const Duration(milliseconds: 3000));

                                                      toasty(context, "Datos registrados correctamente.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);


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
                          ],
                        ),
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
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text('RESPONSABLE DE INSPECCIÓN:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: nombre,
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
                                                      child: Text('DNI TRABAJADOR:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: dni,
                                                      autocorrect: false,
                                                      keyboardType: TextInputType.phone,
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

                                                        return regExp.hasMatch(value ?? '')
                                                            ? null
                                                            : 'DNI incorrecto';
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  await obtenerTrabajador(dni.text);
                                                },
                                                child: Icon(Icons.search),
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
                                                      child: Text('NOMBRE DEL TRABAJADOR:', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: n_evaluador,
                                                      decoration: const InputDecoration(
                                                        hintText: 'Trabajador',
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          this.descripcion = value;
                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Trabajador requerido';
                                                        }
                                                        return null;
                                                      },
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
                                                      child: Text('OBSERVACIÓN: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: descripcion_c,
                                                      decoration: const InputDecoration(
                                                        hintText: 'Observación',
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          this.descripcion = value;
                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Observación requerido';
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
                                                      child: Text('ESTADO: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    DropdownButton(
                                                      isExpanded: true,
                                                      value: estadoSelected,
                                                      icon: Icon(
                                                        Icons.keyboard_arrow_down,
                                                      ),
                                                      onChanged: activar ? (dynamic newValue) {
                                                        setState(() {
                                                          estadoSelected = newValue;
                                                        });
                                                      } : null,
                                                      items: estados.map((category) {
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
                                                      child: Text('LATITUD: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    TextFormField(
                                                      controller: latitud,
                                                      decoration: const InputDecoration(
                                                        hintText: 'Latitud',
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          this.descripcion = value;
                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Latitud requerido';
                                                        }
                                                        return null;
                                                      },
                                                      textInputAction: TextInputAction.next,
                                                      readOnly: true,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
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
                                                      decoration: const InputDecoration(
                                                        hintText: 'Longitud',
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {

                                                        });
                                                      },
                                                      validator: (String? value) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Longitud requerido';
                                                        }
                                                        return null;
                                                      },
                                                      textInputAction: TextInputAction.next,
                                                      readOnly: true,
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
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                            child: Container(
                                                              child: Text('FOTOS: ', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                                              alignment: Alignment.centerLeft,
                                                            ),
                                                        ),
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
                                                      ],
                                                    ),
                                                    SizedBox(height: 15,),
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
                                          ],
                                        ),
                                        SizedBox(height: 25),
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
                                                        Icon(Icons.cleaning_services_rounded, color: Primary.white),
                                                        SizedBox(width: 10),
                                                        Expanded(child:
                                                        Text("Limpiar",
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
                                                onPressed: this.imagenes.length==0 ? null : () async {
                                                  await limpiarDatos();
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
                                                        Icon(Icons.file_open_rounded, color: Primary.white),
                                                        Expanded(child:
                                                          Text("Registrar",
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
                                                onPressed: this.activar ? () async {
                                                  //Navigator.pushReplacementNamed(context, 'camara');
                                                  FocusScope.of(context).unfocus();
                                                  if(_formKey.currentState?.validate() ?? false){
                                                    if(this.imagenes.length>0){
                                                      await registraVisitaCampo();
                                                      toasty(context, "Datos registrados correctamente.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                                                    }else{
                                                      toasty(context, "Insertar al menos una foto.", bgColor: Primary.naranja, textColor: whiteColor, gravity: ToastGravity.BOTTOM);
                                                    }
                                                  }else{
                                                    return;
                                                  }
                                                } : null,
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