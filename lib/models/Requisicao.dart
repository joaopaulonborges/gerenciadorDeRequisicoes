import 'Pedido.dart';
import 'ItemPedido.dart';

class Requisicao {

  String _idRequisicao;
  String _razaosocial;
  String _rca;
  String _descricao;
  String _valor;
  String _tipoRestricao;
  String _data;
  String _hora;
  Pedido _pedido;
  String _limite;
  List<ItemPedido> _itemPedido;

  Requisicao(this._idRequisicao, this._razaosocial, this._rca, this._tipoRestricao, this._descricao, this._valor, this._data, this._pedido, this._itemPedido, this._hora, this._limite);

  String get idRequisicao => _idRequisicao;

  set idRequisicao(String value) {
    _idRequisicao = value;
  }

  String get razaosocial => _razaosocial;

  set razaosocial (String value) {
    _razaosocial = value;
  }

  String get rca => _rca;

  set rca (String value) {
    _rca = value;
  }

  String get tipoRestricao => _tipoRestricao;

  set tipoRestricao(String value) {
    _tipoRestricao = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get valor => _valor;

  set valor(String value) {
    _valor = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get hora => _hora;

  set hora(String value) {
    _hora = value;
  }

  String get limite => _limite;

  set limite(String value) {
    _limite = value;
  }

  Pedido get pedido => _pedido;

  set pedido(Pedido value) {
    _pedido = value;
  }

  List<ItemPedido> get itemPedido => _itemPedido;

  set itemPedido(List<ItemPedido> value) {
    _itemPedido = value;
  }
}