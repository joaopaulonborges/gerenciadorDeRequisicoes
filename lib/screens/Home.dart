import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gerenciador_de_requisicao/blocs/RequisicaoBloc.dart';
import 'package:gerenciador_de_requisicao/models/Usuario.dart';
import 'package:gerenciador_de_requisicao/screens/Aceitas.dart';
import 'package:gerenciador_de_requisicao/screens/Pendentes.dart';
import 'package:gerenciador_de_requisicao/screens/Negadas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {

  Usuario _usuario;

  Home(this._usuario);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  TabController _tabController;
  Usuario u;
  Firestore db = Firestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final RequisicaoBloc _requisicaoBloc = RequisicaoBloc();
  Icon actionIcon = new Icon(Icons.search, color: Colors.black87);
  Widget appBarTitle = new Text("Requisições");
  Widget appBarAction = new Column();
  TextEditingController busca = TextEditingController();
  Color color = Colors.red;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    u = widget._usuario;
    _requisicaoBloc.iniciaListas(u.idUsuario);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        showNotification(message['notification']);
      },
      onResume: (Map<String, dynamic> message) async {
        onSelectNotification("");
      },
      onLaunch: (Map<String, dynamic> message) async {
      },
    );
    _tabController = TabController(
        length: 3,
        vsync: this
    );
    busca.addListener((){
      if(_tabController.index==0){
        if(!busca.text.isEmpty){
          setState(() {
            _requisicaoBloc.pendentes = _requisicaoBloc.recuperarRequsicoesPorRazaoSocial(widget._usuario.idUsuario, "pendentes", busca.text);
          });
        }
        else{
          setState(() {
            _requisicaoBloc.pendentes = _requisicaoBloc.recuperarRequsicoes(widget._usuario.idUsuario, "pendentes");
          });
        }
      }
      else
        if(_tabController.index==1){
          if(!busca.text.isEmpty){
            setState(() {
              _requisicaoBloc.aceitas = _requisicaoBloc.recuperarRequsicoesPorRazaoSocial(widget._usuario.idUsuario, "aceitas", busca.text);
            });
          }
          else{
            setState(() {
              _requisicaoBloc.aceitas = _requisicaoBloc.recuperarRequsicoes(widget._usuario.idUsuario, "aceitas");
            });
          }
        }
      else{
        if(!busca.text.isEmpty){
          setState(() {
            _requisicaoBloc.negadas = _requisicaoBloc.recuperarRequsicoesPorRazaoSocial(widget._usuario.idUsuario, "negadas", busca.text);
          });
        }
        else{
          setState(() {
            _requisicaoBloc.negadas = _requisicaoBloc.recuperarRequsicoes(widget._usuario.idUsuario, "negadas");
          });
        }
      }
    });
    _tabController.addListener((){
      setState(() {
        appBarAction = retornaAppBarAction(_tabController.index);
        appBarTitle = new Text("Requisições");
        this.actionIcon = new Icon(Icons.search, color: Colors.black87);
        busca.text = "";
        if(_tabController.index==0){
          configLocalNotification();
          saveDeviceToken();
          color = Colors.red;
        }
        else
          if(_tabController.index==1){
            color = Colors.orange;
          }
        else{
          color = Colors.yellow;
        }
      });
    });
    configLocalNotification();
    saveDeviceToken();
  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.jcom.gerenciador_de_requisicao' : 'com.jcom.gerenciador_de_requisicao',
      'Jcom requisições',
      'Jcom',
      playSound: true,
      enableVibration: false,
      importance: Importance.Max,
      priority: Priority.High,

    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message['title'].toString(),
      message['body'].toString(),
      platformChannelSpecifics,
      payload: json.encode(message),
    );
  }

  Future onSelectNotification(String route) async {
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Home(widget._usuario)),
    );
    dispose();
  }

  saveDeviceToken() async{
    String id = widget._usuario.idUsuario;
    FirebaseUser user = await firebaseAuth.currentUser();
    String token = await _firebaseMessaging.getToken();
    if(token!=null && token!=''){
      Firestore db = Firestore.instance;
      var tokenRef = db.collection("token").document(id);
      await tokenRef.setData({
        'token' : token,
        'idCliente' : id,
        'uid' : user.uid
      });
    }
    else{
    }
  }

  logout() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("senha");
    firebaseAuth.signOut();
  }

  Future<Null> selecionarData(BuildContext context) async{
    final DateTime dataSelecionada = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2000),
        lastDate: new DateTime.now(),
    );
    if(_tabController.index==0){
      String dia;
      String mes;
      if(int.parse(dataSelecionada.day.toString())<10){
        dia = "0"+dataSelecionada.day.toString();
      }
      else{
        dia = dataSelecionada.day.toString();
      }
      if(int.parse(dataSelecionada.month.toString())<10){
        mes = "0"+dataSelecionada.month.toString();
      }
      else{
        mes = dataSelecionada.month.toString();
      }
      String data = dia+"/"+mes+"/"+dataSelecionada.year.toString();
      setState(() {
        _requisicaoBloc.pendentes = _requisicaoBloc.recuperarRequsicoesPorData(widget._usuario.idUsuario, "pendentes", data);
      });
    }
      else if(_tabController.index==1){
        String dia;
        String mes;
        if(int.parse(dataSelecionada.day.toString())<10){
          dia = "0"+dataSelecionada.day.toString();
        }
        else{
          dia = dataSelecionada.day.toString();
        }
        if(int.parse(dataSelecionada.month.toString())<10){
          mes = "0"+dataSelecionada.month.toString();
        }
        else{
          mes = dataSelecionada.month.toString();
        }
        String data = dia+"/"+mes+"/"+dataSelecionada.year.toString();
        setState(() {
          _requisicaoBloc.aceitas = _requisicaoBloc.recuperarRequsicoesPorData(widget._usuario.idUsuario, "aceitas", data);
        });
      }
    else{
      String dia;
      String mes;
      if(int.parse(dataSelecionada.day.toString())<10){
        dia = "0"+dataSelecionada.day.toString();
      }
      else{
        dia = dataSelecionada.day.toString();
      }
      if(int.parse(dataSelecionada.month.toString())<10){
        mes = "0"+dataSelecionada.month.toString();
      }
      else{
        mes = dataSelecionada.month.toString();
      }
      String data = dia+"/"+mes+"/"+dataSelecionada.year.toString();
      setState(() {
        _requisicaoBloc.negadas = _requisicaoBloc.recuperarRequsicoesPorData(widget._usuario.idUsuario, "negadas", data);
      });
    }
  }

  atualizarElementos(){
    if(_tabController.index==0){
      setState(() {
        _requisicaoBloc.pendentes = _requisicaoBloc.recuperarRequsicoes(widget._usuario.idUsuario, "pendentes");
      });
    }
    else if(_tabController.index==1){
      setState(() {
        _requisicaoBloc.aceitas = _requisicaoBloc.recuperarRequsicoes(widget._usuario.idUsuario, "aceitas");
      });
    }
    else{
      setState(() {
        _requisicaoBloc.negadas = _requisicaoBloc.recuperarRequsicoes(widget._usuario.idUsuario, "negadas");
      });
    }
  }

  retornaAppBarAction(int index){
    if(index!=0){
      return new Row(
        children: <Widget>[
          SizedBox(
            height: 50,
            width: 45,
            child: RaisedButton(
              padding: EdgeInsets.all(0),
              elevation: 0,
              color: Color.fromRGBO(245, 245, 245, 1),
              onPressed: (){
                atualizarElementos();
              },
              child: Icon(
                Icons.refresh,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 45,
            child: RaisedButton(
              padding: EdgeInsets.all(0),
              elevation: 0,
              color: Color.fromRGBO(245, 245, 245, 1),
              onPressed: (){
                setState(() {
                  if (this.actionIcon.icon == Icons.search){
                    this.actionIcon = new Icon(Icons.close, color: Colors.black87);
                    appBarAction = retornaAppBarAction(_tabController.index);
                    this.appBarTitle = new TextField(
                      controller: busca,
                      autofocus: true,
                      style: new TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                      ),
                      decoration: new InputDecoration(
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.indigoAccent),
                        ) ,
                        hintText: "Pesquisar...",
                        hintStyle: new TextStyle(color: Colors.black38),
                      ),
                    );
                  }
                  else{
                    this.actionIcon = new Icon(Icons.search, color: Colors.black87);
                    appBarAction = retornaAppBarAction(_tabController.index);
                    this.appBarTitle = new Text("Requisições");
                    atualizarElementos();
                    this.busca.text = "";
                  }
                });
              },
              child: actionIcon,
            ),
          ),
          SizedBox(
            height: 50,
            width: 45,
            child: RaisedButton(
              padding: EdgeInsets.all(0),
              elevation: 0,
              color: Color.fromRGBO(245, 245, 245, 1),
              onPressed: (){
                selecionarData(context);
              },
              child: Icon(
                Icons.date_range,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      );
    }
    else{
      return new Row();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        actions: <Widget>[
          appBarAction,
        ],
        bottom: TabBar(
          indicatorColor: color,
          labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: "Pendentes",),
            Tab(text: "Aceitas",),
            Tab(text: "Negadas",),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Pendentes(u.idUsuario, "pendentes", _requisicaoBloc),
          Aceitas(u.idUsuario, "aceitas", _requisicaoBloc),
          Negadas(u.idUsuario, "negadas", _requisicaoBloc),
        ],
      ),
      drawer: Drawer(
        elevation: 4,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(235, 235, 235, 1),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 40,
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          u.nome,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          u.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                  Icons.exit_to_app
              ),
              title: Text(
                'Sair',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                logout();
                dispose();
              },
            ),
            Divider(
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}