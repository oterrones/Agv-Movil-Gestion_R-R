import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyectoryr/src/tema/primary.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
/*
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rrhh/src/fotos/camara.dart';
import 'package:rrhh/src/home/home.dart';
import 'package:rrhh/src/home_star/home_star.dart';
*/

import 'home/home.dart';
import 'login/login.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Primary.white.withOpacity(0.3),
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.light
      ),
      child: MaterialApp(
          title: 'RRHH',
          debugShowCheckedModeBanner: false,
          home: Login(),
          theme: ThemeData(
            fontFamily: 'Quicksand',
            platform: TargetPlatform.android,
          ),
          initialRoute: 'login',
          routes: {
            'login' : ( _ ) => Login(),
            'home'  : ( _ ) => homeStar(),
            // 'registro'  : ( _ ) => historicoHome(),
            // 'camara'  : ( _ ) => homeCamara(),
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: [
            const Locale("es", "ES"),
            const Locale("en", "US")
          ],
          locale: Locale('es')
      ),
    );
  }
}