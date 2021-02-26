import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_de_requisicao/models/Item.dart';
import 'package:gerenciador_de_requisicao/models/ItemPedido.dart';
import 'package:gerenciador_de_requisicao/models/Pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequisicaoVisualizar extends StatefulWidget {

  String _idRequisicao, _descricaoRequisicao, _rca, _razaosocial, _pedido, _valor, _tipoRestricao, _item, _data, _limite, _idUsuario, _hora;

  RequisicaoVisualizar(this._idRequisicao, this._descricaoRequisicao, this._rca, this._razaosocial, this._pedido, this._valor, this._tipoRestricao, this._item, this._data, this._limite, this._idUsuario, this._hora);

  @override
  _RequisicaoVisualizarState createState() => _RequisicaoVisualizarState();
}

class _RequisicaoVisualizarState extends State<RequisicaoVisualizar> with SingleTickerProviderStateMixin {

  Pedido pedido;
  List<ItemPedido> itemPedido = List<ItemPedido>();
  Item item;

  @override
  void initState() {
    super.initState();
    recuperarRequisicoes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  recuperarRequisicoes() async{
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("pedido").where("id", isEqualTo: widget._pedido).getDocuments();
    for (DocumentSnapshot pedidos in querySnapshot.documents){
      pedido = Pedido(pedidos.data["id"], pedidos.data["total"], pedidos.data["data"], pedidos.data["cliente"]);
      QuerySnapshot querySnapshot2 = await db.collection("itempedido").where("pedido", isEqualTo: pedido.idPedido).getDocuments();
      for (DocumentSnapshot itemPedidos in querySnapshot2.documents){
        QuerySnapshot querySnapshot3 = await db.collection("item").where("id", isEqualTo: itemPedidos.data["item"]).getDocuments();
        for (DocumentSnapshot itens in querySnapshot3.documents){
          QuerySnapshot querySnapshot4 = await db.collection("tabeladepreco").document(itens.data["tabeladepreco"]).collection(itens.data["id"]).getDocuments();
          for (DocumentSnapshot tabelaPreco in querySnapshot4.documents){
            itemPedido.add(new ItemPedido(itemPedidos.data["id"], new Item(itens.data["id"], itens.data["descricao"], itens.data["valor"], tabelaPreco.data["minimo"], tabelaPreco.data["maximo"], itemPedidos.data["tabeladepreco"]) ,itemPedidos.data["pedido"] ,itemPedidos.data["quantidade"], ));
          }
        }
      }
    }
  }

  Widget buildClienteRestrito(){
    return FutureBuilder(
      future: recuperarRequisicoes(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                ),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              print("Falha ao carregar requisição");
            }
            else{
              return Scaffold(
                appBar: AppBar(
                  title: Text("Requisição"),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                          child: Text(
                            "Dados do pedido",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          child: Text(
                            "RAZÃO SOCIAL",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                          child: Text(
                            widget._razaosocial,
                            style: TextStyle(
                                fontSize: 14
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          child: Text(
                            "NOME DO VENDEDOR",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                          child: Text(
                            widget._rca,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
                          child: Text(
                            widget._data+" "+widget._hora,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
                              child: Text(
                                "LIMITE DE CRÉDITO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
                              child: Text(
                                "R\$ "+widget._limite,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "TÍTULOS VENCIDOS",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                widget._valor!="" || widget._valor==null ? "R\$ "+widget._valor : "R\$ 0",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "LIMITE DISPONÍVEL",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "R\$ "+limiteDisponivel().toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "VALOR TOTAL DO PEDIDO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "R\$ "+pedido.total,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              padding: EdgeInsets.fromLTRB(48, 8, 48, 8),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.green,
                              onPressed: (){
                                dispose();
                                Navigator.pop(context);
                                dispose();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        }
        return Center(
          child: Text("Falha ao carregar requisição"),
        );
      },
    );
  }

  Widget buildClienteLimiteCredito(){
    return FutureBuilder(
      future: recuperarRequisicoes(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                ),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              print("Falha ao carregar requisição");
            }
            else{
              return Scaffold(
                appBar: AppBar(
                  title: Text("Requisição"),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                          child: Text(
                            "Dados do pedido",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          child: Text(
                            "RAZÃO SOCIAL",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                          child: Text(
                            widget._razaosocial,
                            style: TextStyle(
                                fontSize: 14
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          child: Text(
                            "NOME DO VENDEDOR",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                          child: Text(
                            widget._rca,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
                          child: Text(
                            widget._data+" "+widget._hora,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
                              child: Text(
                                "LIMITE DE CRÉDITO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
                              child: Text(
                                "R\$ "+widget._limite,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "TÍTULOS VENCIDOS",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                widget._valor!="" || widget._valor==null ? "R\$ "+widget._valor : "R\$ 0",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "LIMITE ULTRAPASSADO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "R\$ "+diferencaLimiteUltrapassado().toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "VALOR TOTAL DO PEDIDO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "R\$ "+pedido.total,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              padding: EdgeInsets.fromLTRB(48, 8, 48, 8),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.green,
                              onPressed: (){
                                dispose();
                                Navigator.pop(context);
                                dispose();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        }
        return Center(
          child: Text("Falha ao carregar requisição"),
        );
      },
    );
  }

  Widget buildProdutoAbaixoValorMinimo(){
    return FutureBuilder(
      future: recuperarRequisicoes(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                ),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              print("Falha ao carregar requisição");
            }
            else{
              return Scaffold(
                appBar: AppBar(
                  title: Text("Requisição"),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                          child: Text(
                            "Dados do pedido",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          child: Text(
                            "RAZÃO SOCIAL",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                          child: Text(
                            widget._razaosocial,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          child: Text(
                            "NOME DO VENDEDOR",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                          child: Text(
                            widget._rca,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          child: Text(
                            widget._data+" "+widget._hora,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                              child: Text(
                                "LIMITE DE CRÉDITO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                              child: Text(
                                "R\$ "+widget._limite,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "TÍTULOS VENCIDOS",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                widget._valor!="" || widget._valor==null ? "R\$ "+widget._valor : "R\$ 0",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "LIMITE DISPONÍVEL",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "R\$ "+limiteDisponivel().toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "VALOR TOTAL DO PEDIDO",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              child: Text(
                                "R\$ "+pedido.total,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
                          child: Text(
                            "DESCRIÇÃO DO PRODUTO",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 4),
                          child: Text(
                            recuperarProdutoAbaixo(),
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 4, 32, 8),
                                      child: Text(
                                        "PREÇO DE VENDA",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                                      child: Text(
                                        "R\$ "+widget._valor,
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 4, 32, 8),
                                      child: Text(
                                        "QUANTIDADE",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                                      child: Text(
                                        recuperarQuantidadeAbaixo(),
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          ]
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                                      child: Text(
                                        "PREÇO DE TABELA",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                                      child: Text(
                                        recuperarValorMinimoAbaixo(),
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                                      child: Text(
                                        "DIFERENÇA",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(32, 0, 32, 8),
                                      child: Text(
                                        percentualDiferenca().toStringAsPrecision(2)+"%",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          ]
                      ),
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              padding: EdgeInsets.fromLTRB(48, 8, 48, 8),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.green,
                              onPressed: (){
                                dispose();
                                Navigator.pop(context);
                                dispose();
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                      ),
                    ],
                  ),
                ),
              );
            }
        }
        return Center(
          child: Text("Falha ao carregar requisição"),
        );
      },
    );
  }

  double percentualDiferenca() {
    double percentual = double.parse(widget._valor)*100/recuperarValorMinimoAbaixoDouble();
    String percentualCasas = percentual.toStringAsPrecision(4);
    return (100-double.parse(percentualCasas))/100;
  }

  double diferencaLimiteUltrapassado(){
    return (double.parse(widget._limite)-double.parse(pedido.total))*-1;
  }

  double limiteDisponivel(){
    return (double.parse(widget._limite)-double.parse(pedido.total));
  }

  String recuperarProdutoAbaixo(){
    for(int i=0;i<itemPedido.length;i++){
      if(itemPedido[i].item.idItem==widget._item) {
        return itemPedido[i].item.descricao;
      }
    }
    return "";
  }

  String recuperarQuantidadeAbaixo(){
    for(int i=0;i<itemPedido.length;i++){
      if(itemPedido[i].item.idItem==widget._item) {
        return itemPedido[i].quantidade;
      }
    }
    return "";
  }

  String recuperarValorMinimoAbaixo(){
    for(int i=0;i<itemPedido.length;i++){
      if(itemPedido[i].item.idItem==widget._item) {
        return "R\$ "+itemPedido[i].item.minimo;
      }
    }
    return "";
  }

  double recuperarValorMinimoAbaixoDouble(){
    for(int i=0;i<itemPedido.length;i++){
      if(itemPedido[i].item.idItem==widget._item) {
        return double.parse(itemPedido[i].item.minimo);
      }
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if(widget._tipoRestricao=="clienterestrito"){
      return buildClienteRestrito();
    }
    else
    if(widget._tipoRestricao=="creditoultrapassado"){
      return buildClienteLimiteCredito();
    }
    else{
      return buildProdutoAbaixoValorMinimo();
    }
  }
}