import 'package:flutter/material.dart';
import 'package:gerenciador_de_requisicao/blocs/LoginBloc.dart';
import 'package:gerenciador_de_requisicao/screens/Home.dart';
import 'package:gerenciador_de_requisicao/widgets/input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _loginBloc = LoginBloc();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loginBloc.esperarVerificacaoLogin();
    verificarLogin();
    _loginBloc.outState.listen((state){
      switch(state){
        case LoginState.SUCCESS:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=>Home(_loginBloc.usuario))
          );
          break;
        case LoginState.FAIL:
          showDialog(
              context: context,
              builder: (context) =>
                AlertDialog(
                  title: Text("Erro"),
                  content: Text("Usuário ou senha inválidos"),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(
                        "OK",
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
          );
          _loginBloc.falhaVerificacaoLogin();
          break;
        case LoginState.FAIL_EMAIL:
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text("Erro"),
                    content: Text("Digite um e-mail"),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "OK",
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
          );
          _loginBloc.falhaVerificacaoLogin();
          break;
        case LoginState.FAIL_SENHA:
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text("Erro"),
                    content: Text("Digite uma senha"),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "OK",
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
          );
          _loginBloc.falhaVerificacaoLogin();
          break;
        case LoginState.FAIL_INTERNET:
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text("Erro"),
                    content: Text("Não foi possível conectar a internet"),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "OK",
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
          );
          _loginBloc.falhaVerificacaoLogin();
          break;
        case LoginState.LOADING:
        case LoginState.IDLE:
      }
    });
  }

  verificarLogin() async{
    FirebaseUser user = await firebaseAuth.currentUser();
    final prefs = await SharedPreferences.getInstance();
    if(user!=null && prefs.getString("senha")!=null){
      _loginBloc.verificarLogado(user.email, prefs.getString("senha"));
    }
    else{
      _loginBloc.falhaVerificacaoLogin();
    }
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciador de Requisições"),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<LoginState>(
          stream: _loginBloc.outState,
          initialData: LoginState.LOADING,
          builder: (context, snapshot) {
            switch(snapshot.data){
              case LoginState.LOADING:
                return Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.indigoAccent),),
                );
              case LoginState.FAIL:
              case LoginState.SUCCESS:
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.indigoAccent),),
                );
              case LoginState.IDLE:
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(),
                    SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Image.asset(
                                "imagens/logo.png",
                                fit: BoxFit.scaleDown,
                              ),
                              Center(
                                child: Text(
                                  "Entre com sua conta da Jcom",
                                ),
                              ),
                              InputField(
                                icon: Icons.person_outline,
                                hint: "Usuário",
                                obscure: false,
                                stream: _loginBloc.outEmail,
                                onChanged: _loginBloc.changeEmail,
                              ),
                              InputField(
                                icon: Icons.lock_outline,
                                hint: "Senha",
                                obscure: true,
                                stream: _loginBloc.outPassword,
                                onChanged: _loginBloc.changePassword,
                              ),
                              SizedBox(height: 32),
                              StreamBuilder<bool>(
                                stream: _loginBloc.outSubmitValid,
                                builder: (context, snapshot) {
                                  return Container(
                                    height: 50,
                                    child: RaisedButton(
                                      color: Colors.indigo,
                                      child: Text("Entrar"),
                                      onPressed: (){
                                         _loginBloc.verificaLogin();
                                      },
                                      textColor: Colors.white,
                                    ),
                                  );
                                }
                              )
                            ],
                          ),
                        ),
                    ),
                  ],
                );
              default: return Column();
            }
          }
      ),
    );
  }
}