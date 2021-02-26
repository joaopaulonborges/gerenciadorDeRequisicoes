import 'dart:async';
import 'dart:convert';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gerenciador_de_requisicao/models/Usuario.dart';
import 'package:gerenciador_de_requisicao/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'package:xml2json/xml2json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum LoginState {IDLE, LOADING, SUCCESS, FAIL, FAIL_EMAIL, FAIL_SENHA, FAIL_INTERNET}

class LoginBloc extends BlocBase with LoginValidators {

  Usuario _usuario;
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();
  final String apiusuario1 = "http://jcomm.mysuite.com.br/webservices/ws_getusuarios.php?email=";
  final String apiusuario2 = "&sigla=jrv&servicekey=";
  final String apiempresa1 = "http://jcomm.mysuite.com.br/webservices/ws_getclientes.php?codempresa=";
  final String apiempresa2 = "&sigla=jrv&servicekey=";
  final String key = "eac1a3376bd6acd708085f8c87dc246c";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Stream<String> get outEmail => _emailController.stream;
  //Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream;
  //Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Stream<LoginState> get outState => _stateController.stream;
  Usuario get usuario => _usuario;

  Stream<bool> get outSubmitValid => Observable.combineLatest2(
      outEmail, outPassword, (a, b) => true
  );

  LoginBloc(){
    _stateController.add(LoginState.IDLE);
  }

  void submit() async{
    _stateController.add(LoginState.SUCCESS);
  }

  esperarVerificacaoLogin(){
    _stateController.add(LoginState.LOADING);
  }

  falhaVerificacaoLogin(){
    _stateController.add(LoginState.IDLE);
  }

  verificarLogado(String email, String senhamd5) async{
    _stateController.add(LoginState.LOADING);
    http.Response responseUsuario;
    try{
      responseUsuario = await http.get(apiusuario1 + email + apiusuario2 + key);
      if (responseUsuario.statusCode == 200) {
        Xml2Json xml2json = Xml2Json();
        xml2json.parse(responseUsuario.body);
        var jsondatausuario = xml2json.toParker();
        var datausuario = json.decode(jsondatausuario);
        if (senhamd5==datausuario["usuarios"]["usuario"]["senha"]){
          http.Response responseEmpresa;
          responseEmpresa = await http.get(apiempresa1 + datausuario["usuarios"]["usuario"]["codempresa"] + apiempresa2 + key);
          if (responseEmpresa.statusCode == 200) {
            Xml2Json xml2json = Xml2Json();
            xml2json.parse(responseEmpresa.body);
            var jsondataempresa = xml2json.toParker();
            var dataempresa = json.decode(jsondataempresa);
            String idCliente = datausuario["usuarios"]["usuario"]["codcliente"];
            String nome = datausuario["usuarios"]["usuario"]["nomecompleto"];
            String email = datausuario["usuarios"]["usuario"]["email1"];
            String senha = datausuario["usuarios"]["usuario"]["senha"];
            String idEmpresa = datausuario["usuarios"]["usuario"]["codempresa"];
            String empresa = dataempresa["usuarios"]["usuario"]["nomeempresa"];
            FirebaseUser user = await firebaseAuth.currentUser();
            user.updatePassword(datausuario["usuarios"]["usuario"]["senha"]);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("senha", senhamd5.toString());
            _usuario = Usuario(idCliente, nome, email, senha, idEmpresa, empresa);
            submit();
          }
          else {
            _stateController.add(LoginState.FAIL);
          }
        }
        else {
          final prefs = await SharedPreferences.getInstance();
          prefs.remove("senha");
          firebaseAuth.signOut();
          _stateController.add(LoginState.FAIL);
        }
      }
      else {
        _stateController.add(LoginState.FAIL);
      }
    }
    catch(e){
      _stateController.add(LoginState.FAIL_INTERNET);
    }
  }

  verificaLogin() async{
    _stateController.add(LoginState.LOADING);
    final email = _emailController.value;
    final senha = _passwordController.value;
    if (email == null || email == "") {
      _stateController.add(LoginState.FAIL_EMAIL);
    }
    else
      if (senha == null || senha == "") {
        _stateController.add(LoginState.FAIL_SENHA);
      }
    else {
      http.Response responseUsuario;
      try {
        responseUsuario = await http.get(apiusuario1 + email + apiusuario2 + key);
        if (responseUsuario.statusCode == 200) {
          Xml2Json xml2json = Xml2Json();
          xml2json.parse(responseUsuario.body);
          var jsondatausuario = xml2json.toParker();
          var datausuario = json.decode(jsondatausuario);
          var content = new Utf8Encoder().convert(senha);
          var md5 = crypto.md5;
          var senhamd5 = md5.convert(content);
          if (senhamd5.toString() ==
              datausuario["usuarios"]["usuario"]["senha"]) {
            http.Response responseEmpresa;
            responseEmpresa = await http.get(apiempresa1 +
                datausuario["usuarios"]["usuario"]["codempresa"] +
                apiempresa2 + key);
            if (responseUsuario.statusCode == 200) {
              Xml2Json xml2json = Xml2Json();
              xml2json.parse(responseEmpresa.body);
              var jsondataempresa = xml2json.toParker();
              var dataempresa = json.decode(jsondataempresa);
              String idCliente = datausuario["usuarios"]["usuario"]["codcliente"];
              String nome = datausuario["usuarios"]["usuario"]["nomecompleto"];
              String email1 = datausuario["usuarios"]["usuario"]["email1"];
              String senha1 = datausuario["usuarios"]["usuario"]["senha"];
              String idEmpresa = datausuario["usuarios"]["usuario"]["codempresa"];
              String empresa = dataempresa["usuarios"]["usuario"]["nomeempresa"];
              FirebaseUser user = await firebaseAuth.currentUser();
              firebaseAuth.createUserWithEmailAndPassword(
                  email: email1,
                  password: senha1
              ).catchError((erro) {
                user.updatePassword(
                    datausuario["usuarios"]["usuario"]["senha"]);
              });
              firebaseAuth.signInWithEmailAndPassword(
                  email: email1,
                  password: senha1
              );
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                  "senha", datausuario["usuarios"]["usuario"]["senha"]);
              _usuario = Usuario(
                  idCliente, nome, email1, senha1, idEmpresa, empresa);
              submit();
            }
            else {
              _stateController.add(LoginState.FAIL);
            }
          }
          else {
            _stateController.add(LoginState.FAIL);
          }
        }
        else {
          _stateController.add(LoginState.FAIL);
        }
      }
      catch (e) {
        if(e.toString().contains("jcomm.mysuite.com.br")){
          _stateController.add(LoginState.FAIL_INTERNET);
        }
        else{
          _stateController.add(LoginState.FAIL);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _stateController.close();
  }
}