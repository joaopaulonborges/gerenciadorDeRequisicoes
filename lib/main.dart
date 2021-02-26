import 'package:flutter/material.dart';
import 'package:gerenciador_de_requisicao/screens/Login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ThemeData temaPadrao = ThemeData(
    primaryColor: Color.fromRGBO(245, 245, 245, 1),
    accentColor: Colors.indigoAccent,
);

void main(){
  runApp(
      MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('pt', 'BR')],
        home: Login(),
        theme: temaPadrao,
        debugShowCheckedModeBanner: false,
  ));
}