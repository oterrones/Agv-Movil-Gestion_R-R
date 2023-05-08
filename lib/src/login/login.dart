import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:proyectoryr/db/database.dart';
import 'package:proyectoryr/modelos/centro_poblado.dart';
import 'package:proyectoryr/modelos/distrito.dart';
import 'package:proyectoryr/modelos/evaluadores.dart';
import 'package:proyectoryr/modelos/lider_zona.dart';
import 'package:proyectoryr/modelos/paradero.dart';
import 'package:proyectoryr/modelos/trabajadores.dart';
import 'package:proyectoryr/src/providers/login_form_provider.dart';
import 'package:proyectoryr/src/tema/primary.dart';
import 'package:proyectoryr/src//var/var.dart';
import '../../modelos/provincia.dart';
import '../../modelos/region.dart';
import '../../modelos/trabajadores_pistoleado.dart';
import 'login_form.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKeyLog = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKeyLog,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: size.height * 1,
              child: FittedBox(
                child: Image.asset('static/images/login/fondo2.png'),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              height: size.height * 1,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.08),
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "static/images/logo_b_g.png",
                          color: Primary.white,
                          height: size.height * 0.1,
                        ),
                        SizedBox(height: 4),
                        Text('Versión 1.0.2',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Primary.white,
                                fontSize: size.height * 0.013))
                      ],
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Container(
                    margin: EdgeInsets.all(size.height * 0.015),
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(size.height * 0.015),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Primary.background.withOpacity(0.85),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                          ),
                          child: ChangeNotifierProvider(
                            create: (_) => LoginFormProvider(),
                            child: LoginForm(),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(size.height * 0.015),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Primary.black.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(child: SizedBox()),
                                        Icon(Icons.phone_forwarded_rounded,
                                            color: Primary.white),
                                        SizedBox(width: 5),
                                        Text(
                                          "Contacto",
                                          style:
                                          TextStyle(color: Primary.white),
                                        ),
                                        Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  child: Text("|",
                                      style: TextStyle(color: Primary.white))),
                              Expanded(
                                child: GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(child: SizedBox()),
                                        Icon(Icons.restart_alt_rounded,
                                            color: Primary.white),
                                        SizedBox(width: 5),
                                        Text("Sincronizar",
                                            style: TextStyle(
                                                color: Primary.white)),
                                        Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    mFormBottomSheet2(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

mFormBottomSheet2(BuildContext aContext) {
  showModalBottomSheet(
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
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.031),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SelectSync(),
          ],
        ),
      );
    },
  );
}

class SelectSync extends StatefulWidget {
  @override
  _SelectSyncState createState() => _SelectSyncState();
}

class _SelectSyncState extends State<SelectSync> {
  List<String> fundos = ['Agrovision C5', 'C6', 'A9', 'Arena Verde'];
  String? hola = 'Agrovision C5';
  var linkServer = "http://35.175.69.142/backend";

  //late List<Evaluador> evaluador;
  late List<Evaluador> evaluador;
  late List<Trabajador> trabajador;
  late Trabajador_model eva;
  late TrabajadorPistoleado_model objtrabajadorPistoleado;
  // late List<CategoriaCultivo> cate_cul;
  // late List<Area> area;
  // late List<LocalLog> localhost;
  late List<LiderZona> liderZona;
  late List<Region> region;
  late List<Provincia> provincia;
  late List<Distrito> distrito;

  String umbrles = "";
  String evaluadores = "";
  String categoria_cultivo_ = "";
  String evaluador_ = "";
  String trabajador_ = "";
  String area_ = "";
  String error = "";
  bool isLoading = false;
  bool isError = false;
  bool isSuccess = false;
  String dni = "";
  String lideres_zona_ = "";
  String region_ = "";
  String provincia_ = "";
  String distrito_ = "";

  late List<CentroPoblado> listCentroPoblado;
  String strCentroPoblado = "";

  late List<Paradero> listParadero;
  String strParadero = "";

  @override
  void initState() {
    super.initState();
    //datosSeleccion();
  }

  @override
  void dispose() {
    //AgrovisionDataBase.bd.close();
    super.dispose();
  }

  Future datosSeleccion() async {
    setState(() => isLoading = true);

    this.evaluador = await AgrovisionDataBase.bd.obtenerEvaluadores();
    if (this.evaluador.isEmpty) {
      this.error = "vacío";
      await obtenerEvaluadoresApi();

      this.evaluador = await AgrovisionDataBase.bd.obtenerEvaluadores();
      // this.cate_cul = await AgrovisionDataBase.bd.obtenerCategoriaCultivo();
    }

    //await Future.delayed(Duration(milliseconds: 1000));

    if (!this.isError) {
      setState(() {
        isLoading = false;
        isSuccess = true;
      });

      await Future.delayed(Duration(milliseconds: 1200));
      finish(context);
    } else {
      await Future.delayed(Duration(milliseconds: 4000));
      finish(context);
    }
  }

  obtenerEvaluadoresApi() async {
    var uro = Uri.parse("$linkServer/evaluadores/");

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      print(value.statusCode);
      if (value.statusCode == 200) {
        evaluador_ = utf8.decode(value.bodyBytes);
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      final eva = evaluadorFromJson(evaluador_);
      await AgrovisionDataBase.bd.crearEvaluador(eva);
      // await obtenerCategoriaCultivoApi();
    }
  }

  obtenerTrabajadoresApi() async {
    var uro = Uri.parse('http://64.150.187.45:8081/bi/controller/gmo.php?accion=getTrabajadoresSAP&idtrabajador=T&idestadotrab=ACTIVO');

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        eva = Trabajador_model.fromJson(jsonDecode(value.body));
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      await AgrovisionDataBase.bd.crearTrabajador(eva.trabajador);
      // await obtenerCategoriaCultivoApi();
    }
  }

  obtenerLideresZonaApi() async {
    var uro = Uri.parse("$linkServer/reclutamiento/lideres/zona/");
    print(uro);


    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {

      print(value.statusCode);

      if (value.statusCode == 200) {
        lideres_zona_ = utf8.decode(value.bodyBytes);
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      final lideresZona = liderZonaFromJson(lideres_zona_);
      await AgrovisionDataBase.bd.crearLiderZona(lideresZona);
    }
  }
  obtenerRegion() async {
    var uro = Uri.parse("$linkServer/reclutamiento/region/");

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        region_ = utf8.decode(value.bodyBytes);
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      final fromRegion = regionFromJson(region_);
      await AgrovisionDataBase.bd.crearRegion(fromRegion);
    }
  }
  obtenerProvincia() async {
    var uro = Uri.parse("$linkServer/reclutamiento/provincia/");

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        provincia_ = utf8.decode(value.bodyBytes);
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      final fromProvincia = provinciaFromJson(provincia_);
      await AgrovisionDataBase.bd.crearProvincia(fromProvincia);
    }
  }
  obtenerDistrito() async {
    var uro = Uri.parse("$linkServer/reclutamiento/distrito/");

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        distrito_ = utf8.decode(value.bodyBytes);
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      final fromDistrito = distritoFromJson(distrito_);
      await AgrovisionDataBase.bd.crearDistrito(fromDistrito);
    }
  }
  obtenerCentroPoblado() async {
    var uro = Uri.parse("$linkServer/reclutamiento/centro/poblado/list/");

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        strCentroPoblado = utf8.decode(value.bodyBytes);
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      final fromCentroPoblado = centroPobladoFromJson(strCentroPoblado);
      await AgrovisionDataBase.bd.crearCentroPoblado(fromCentroPoblado);
    }
  }
  obtenerParadero() async {
    var uro = Uri.parse("$linkServer/reclutamiento/paradero/list/");

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        strParadero = utf8.decode(value.bodyBytes);
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      final fromParadero = paraderoFromJson(strParadero);
      await AgrovisionDataBase.bd.crearParadero(fromParadero);
    }
  }

  obtenerTrabajadoresPistoleadosApi() async {
    var uro = Uri.parse('https://www.agvperu.com/backend/reclutamiento/personal/tareo/traer/semana/agv/');

    await http.get(uro, headers: {
      'Content-type': 'application/json; charset=utf-8',
    }).then((value) {
      if (value.statusCode == 200) {
        objtrabajadorPistoleado = TrabajadorPistoleado_model.fromJson(jsonDecode(value.body));
      } else if (value.statusCode == 500 || value.statusCode == 404) {
        setState(() {
          isError = true;
          this.error = "sin codigo";
        });
      }
    }).catchError((error, stackTrace) {
      setState(() => {
        isLoading = false,
        isError = true,
        this.error = '$error',
      });
    });

    if (!isError) {
      await AgrovisionDataBase.bd.crearTrabajadorTareoPistoleo(objtrabajadorPistoleado.trabajador_pistoleado);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: isSuccess
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.height * 0.025),
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.check, color: Primary.azul, size: 40),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                          Text("Sincronización completada.",
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
                          semanticsLabel: "Obteniendo datos...",
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025),
                        Text("Obteniendo y sincronizando datos...",
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
                  : SingleChildScrollView(
                      child: ListView(shrinkWrap: true, children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Sincronizar",
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.010),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
                          disabledColor: Primary.azul,
                          elevation: 0,
                          color: Primary.azul,
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            child: Text("Sincronizar",
                                style: TextStyle(
                                    color: Primary.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17)),
                          ),
                          onPressed: () async {
                            setState(() => isLoading = true);

                            await obtenerEvaluadoresApi();
                            await obtenerTrabajadoresApi();
                            await obtenerTrabajadoresPistoleadosApi();
                            await obtenerLideresZonaApi();
                            await obtenerRegion();
                            await obtenerProvincia();
                            await obtenerDistrito();
                            await obtenerCentroPoblado();
                            await obtenerParadero();
                            print('Ok');

                            if (!this.isError) {
                              setState(() {
                                this.isSuccess = true;
                              });
                              await Future.delayed(Duration(milliseconds: 2200));
                            }else{
                              await Future.delayed(Duration(milliseconds: 4000));
                            }

                            finish(context);
                          },
                        )
                      ]),
                    ),
        ));
  }
}
