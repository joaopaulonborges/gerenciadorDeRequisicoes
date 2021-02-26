import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerenciador_de_requisicao/blocs/RequisicaoBloc.dart';
import 'package:gerenciador_de_requisicao/screens/RequisicaoVisualizar.dart';

class Aceitas extends StatefulWidget {

  String _idCliente, _tipoRequisicao;
  RequisicaoBloc _lista;

  Aceitas(this._idCliente, this._tipoRequisicao, this._lista);

  @override
  _AceitasState createState() => _AceitasState();
}

class _AceitasState extends State<Aceitas> with SingleTickerProviderStateMixin {

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    CollectionReference reference = Firestore.instance.collection("requisicoes").document(widget._idCliente).collection(widget._tipoRequisicao);
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        setState(() {
          widget._lista.aceitas = recuperarRequsicoes(widget._idCliente, widget._tipoRequisicao);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future recuperarRequsicoes(String idUsuario, String tipoRequisicao) async{
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("requisicoes").document(idUsuario).collection(tipoRequisicao).getDocuments();
    return querySnapshot.documents;
  }

  verificaCor(String tipo){
    if(tipo=="clienterestrito"){
      return Colors.red;
    }
    else
    if(tipo=="creditoultrapassado"){
      return Colors.orange;
    }
    else{
      return Colors.yellow;
    }
  }

  verificaTipoRestricao(String tipo){
    if(tipo=="clienterestrito"){
      return "Pedido para cliente restrito";
    }
    else
    if(tipo=="creditoultrapassado"){
      return "Limite de crédito ultrapassado";
    }
    else{
      return "Preço abaixo do permitido";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: FutureBuilder(
            future: widget._lista.aceitas,
            builder: (context, snapshot){
              switch( snapshot.connectionState ){
                case ConnectionState.none :
                case ConnectionState.waiting :
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                  break;
                case ConnectionState.active :
                case ConnectionState.done :
                  if( snapshot.hasError ){
                    return Center(
                      child: Text(
                        "Falha ao carregar requisições",
                      ),
                    );
                  }
                  else
                    if(snapshot.data.length==0){
                      return Center(
                        child: Text(
                          "Nenhuma requisição encontrada",
                        ),
                      );
                    }
                  else {
                    return ListView.builder(
                        padding: EdgeInsets.all(4),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index){
                          return SingleChildScrollView(
                            padding: EdgeInsets.all(0),
                            child: Card(
                              elevation: 4,
                              child: ListTile(
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) =>
                                        RequisicaoVisualizar(snapshot.data[index].data["id"], snapshot.data[index].data["descricao"], snapshot.data[index].data["rca"], snapshot.data[index].data["razaosocial"], snapshot.data[index].data["pedido"], snapshot.data[index].data["valor"], snapshot.data[index].data["tiporestricao"], snapshot.data[index].data["item"], snapshot.data[index].data["data"], snapshot.data[index].data["limite"], widget._idCliente, snapshot.data[index].data["hora"])),
                                  );
                                },
                                title: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.all(0),
                                      width: 12,
                                      height: 80,
                                      color: verificaCor(snapshot.data[index].data["tiporestricao"]),
                                    ),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(24, 4, 0, 4),
                                            child: Text(
                                              snapshot.data[index].data["razaosocial"],
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(24, 4, 0, 4),
                                            child: Text(
                                              verificaTipoRestricao(snapshot.data[index].data["tiporestricao"]),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(4),
                                    ),
                                    Container(
                                      color: Color.fromRGBO(31, 45, 45, 1),
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                            snapshot.data[index].data["id"],
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white
                                            )
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                            snapshot.data[index].data["data"]+" "+snapshot.data[index].data["hora"],
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black
                                            )
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    );
                  }
                  break;
              }
              return Center(
                child: Text("Falha ao carregar requisições"),
              );
            },
          ),
        ),
      ],
    );
  }
}