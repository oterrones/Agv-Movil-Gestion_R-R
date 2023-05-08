import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:proyectoryr/src/registros/listRegistrosReclutamientoPersonal.dart';
import 'package:proyectoryr/src/registros/registrarProyectoR_R.dart';
import 'package:proyectoryr/src/registros/listRegistrosProyectoR_R.dart';
import 'package:proyectoryr/src/registros/registrarReclutamientoPersonal.dart';
import 'package:proyectoryr/src/tema/primary.dart';


class reclutamientoPersonal extends StatefulWidget {
  @override
  State<reclutamientoPersonal> createState() => _reclutamientoPersonalState();
}

class _reclutamientoPersonalState extends State<reclutamientoPersonal> with TickerProviderStateMixin {

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  );
  final GlobalKey<ScaffoldState> _scaffoldKeyHS = GlobalKey<ScaffoldState>();

  String hoy = "";
  //late List<LocalLog> localhost;

  @override
  void initState() {
    super.initState();
    obtenerFecha();
    //obtenerEvaluadores();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /*
  Future obtenerEvaluadores() async{
    this.localhost = await AgrovisionDataBase.bd.obtenerLocal();
    print(this.localhost[0].nombre_evaluador);
  }
  */

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
    Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: Interval((1 / 3) * 1, 1.0,
                curve: Curves.fastOutSlowIn
            )
        )
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Primary.white.withOpacity(0),
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Primary.azul,
            systemNavigationBarIconBrightness: Brightness.light),
        child: Container(
          color: Primary.background,
          child: Scaffold(
            key: _scaffoldKeyHS,
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[
                getAppBarUI(),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 0, bottom: 18),
                  child: Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                          topRight: Radius.circular(70.0)),
                      image: DecorationImage(
                        image: AssetImage('static/images/inspeccion3.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Primary.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0
                        ),
                      ],
                    ),
                    /*
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 10,),
                              Image.asset(
                                "static/images/logo_b_g.png",
                                color: Primary.azulb,
                                width: 70,
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    */
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(child:
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 12, top: 0, bottom: 18),
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Primary.verde,
                            Primary.verdeb,
                            Primary.verdec,
                            Primary.verded,
                            Primary.verdee,
                          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60.0),
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0),
                              topRight: Radius.circular(15.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Primary.grey.withOpacity(0.2),
                                offset: Offset(1.1, 1.1),
                                blurRadius: 10.0
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60.0),
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                                topRight: Radius.circular(15.0)),
                            splashColor: Primary.verdef,
                            onTap: () {
                              // Navigator.pushReplacementNamed(context, 'registro');
                              Navigator.push(context, MaterialPageRoute(builder: (context) => registrarReclutamientoPersonal(0)));
                            },
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 28,
                                ),
                                Icon(
                                  Icons.edit_rounded,
                                  color: Primary.white,
                                  size: 35,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Insertar', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Primary.white)),
                                Text('Registro', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Primary.white))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ),
                    Expanded(child:
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12, right: 24, top: 0, bottom: 18),
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Primary.azul,
                            Primary.azulb,
                            Primary.azulc,
                            Primary.azuld,
                            Primary.azule,
                          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(70.0),
                              topRight: Radius.circular(15.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Primary.grey.withOpacity(0.2),
                                offset: Offset(1.1, 1.1),
                                blurRadius: 10.0
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(70.0),
                                topRight: Radius.circular(15.0)),
                            splashColor: Primary.azulf,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => listRegistrosReclutamientoPersonal()));
                            },
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 28,
                                ),
                                Icon(
                                  Icons.list_rounded,
                                  color: Primary.white,
                                  size: 35,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text('Ver', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Primary.white)),
                                Text('Registros', textAlign: TextAlign.justify,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Primary.white))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    )
                  ],
                ),

                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        ));
  }

  Widget getAppBarUI() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.14,
      decoration: BoxDecoration(
        color: Primary.azul.withOpacity(0),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tareo diario',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: Primary.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
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
                    borderRadius: const BorderRadius.all(
                        Radius.circular(32.0)),
                    onTap: () {},
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
                    borderRadius: const BorderRadius.all(
                        Radius.circular(32.0)),
                    onTap: () {
                      //Navigator.pushReplacementNamed(context, 'camara');
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
}
