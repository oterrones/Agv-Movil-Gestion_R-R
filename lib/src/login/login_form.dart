
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*
import 'package:nb_utils/nb_utils.dart';
import 'package:rrhh/db/database.dart';
import 'package:rrhh/modelos/evaluadores.dart';
import 'package:rrhh/src/providers/input_decorations.dart';
import 'package:rrhh/src/providers/login_form_provider.dart';
import 'package:rrhh/src/tema/primary.dart';
*/

import 'package:nb_utils/nb_utils.dart';
import 'package:proyectoryr/db/database.dart';
import 'package:proyectoryr/modelos/evaluadores.dart';
import 'package:proyectoryr/modelos/lider_zona.dart';
import 'package:proyectoryr/src/providers/input_decorations.dart';
import 'package:proyectoryr/src/providers/login_form_provider.dart';
import 'package:proyectoryr/src/tema/primary.dart';
import 'login.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  late List<Evaluador> evaluadores;
  late List<LiderZona> lidesZ;
  bool cargando = false;
  bool logeado = false;
  bool sevaluadores = false;
  String dni = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future obtenerEvaluadores(String dni) async{
    this.evaluadores = await AgrovisionDataBase.bd.obtenerEvaluadores();
    if(this.evaluadores.isNotEmpty){
      setState(() => sevaluadores = false );
      final siHayEval = await AgrovisionDataBase.bd.obtenerEvaluador(dni);
      if(siHayEval){
        setState(() => logeado = true);
      }
    }else{
      setState(() => sevaluadores = true);
    }
  }

  Future obtenerLiderZona(String dni) async{
    this.lidesZ = await AgrovisionDataBase.bd.obtenerLideresZona();
    if(this.lidesZ.isNotEmpty){
      setState(() => sevaluadores = false );
      final siHayEval = await AgrovisionDataBase.bd.obtenerLiderZona(dni);
      if(siHayEval){
        setState(() => logeado = true);
      }
    }else{
      setState(() => sevaluadores = true);
    }
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.003),
          Container(
            child: Text('Iniciar Sesión', style: TextStyle(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Primary.black)),
          ),
          SizedBox(height: size.height * 0.007),
          Form(
            key: loginForm.formkey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Row(
              children: [
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.people_alt_rounded, color: Primary.azul,),
                      SizedBox(width: size.height * 0.01),
                      Text("DNI: ", style: TextStyle(fontSize: size.height * 0.0175, fontWeight: FontWeight.bold, color: Primary.black)),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                    child: Container(
                      child: TextFormField(
                        autocorrect: false,
                        keyboardType: TextInputType.phone,
                        maxLength: 8,
                        cursorColor: Primary.azul,
                        textInputAction: TextInputAction.send,
                        textAlign: TextAlign.center,
                        decoration: InputDecorations.loginInputDecoration(hintText: "DNI", labelText: "DNI"),
                        onChanged: (value) => loginForm.dni = value,
                        style: TextStyle(color: Primary.azul, fontWeight: FontWeight.bold, fontSize: 17),
                        textAlignVertical: TextAlignVertical.bottom,
                        validator: (value) {
                          String pattern = r'^\d{8}$';
                          RegExp regExp  = new RegExp(pattern);

                          return regExp.hasMatch(value ?? '')
                              ? null
                              : 'DNI INCORRECTO.';
                        },
                      ),
                    )
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  /*
                  child: ElevatedButton(
                      onPressed: loginForm.isLoading ? null : () async {
                        Navigator.pushReplacementNamed(context, 'home');
                      },
                      child: loginForm.isLoading
                          ? SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                          : Icon(Icons.login_sharp),
                      style: ElevatedButton.styleFrom(
                          primary: Primary.azul, onPrimary: Primary.white, fixedSize: Size(30, 20)
                      )
                  ),
                  */

                  child: ElevatedButton(
                      onPressed: loginForm.isLoading ? null : () async {
                        FocusScope.of(context).unfocus();
                        if(!loginForm.isValidForm()) return;
                        loginForm.isLoading = true;
                        //await obtenerEvaluadores(loginForm.dni);
                        await obtenerLiderZona(loginForm.dni);
                        // await Future.delayed(const Duration(milliseconds: 1500));
                        loginForm.isLoading = false;
                        // setState(() => logeado = true);

                        if (!this.sevaluadores){
                          if (this.logeado){
                            Navigator.pushReplacementNamed(context, 'home');
                          }else{
                            toasty(context, "Usuario incorrecto.", bgColor: Primary.verde, textColor: whiteColor, gravity: ToastGravity.SNACKBAR);
                          }
                        }else{
                          _buildAlertDialog(context);
                        }
                      },
                      child: loginForm.isLoading
                          ? SizedBox(child: CircularProgressIndicator(color: Primary.white, strokeWidth: 2), width: 15, height: 15)
                          : Icon(Icons.login_sharp),
                      style: ElevatedButton.styleFrom(
                          primary: Primary.azul, onPrimary: Primary.white, fixedSize: Size(30, 20)
                      )
                  ),

                )
              ],
            ),
          ),
        ],
      ),
    );
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
                decoration: const BoxDecoration(
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
                        Container(height: 100, decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(50),
                            ),
                            color: Primary.verdec
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
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text("No se encuentraron datos de sesión disponibles, por favor sincronice la aplicación e intente nuevamente.", textAlign: TextAlign.justify, style: Primary.body2),
                    ),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            mFormBottomSheet2(context);
                          },
                          color: Primary.verdec,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: const BorderSide(
                                color: Primary.verdec,
                              )),
                          child: const Text(
                            'Sincronizar',
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