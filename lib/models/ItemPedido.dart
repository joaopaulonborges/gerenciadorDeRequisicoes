import 'Item.dart';

class ItemPedido {

  String _idItemPedido;
  Item _item;
  String _idPedido;
  String _quantidade;

  ItemPedido(this._idItemPedido, this._item, this._idPedido, this._quantidade);

  String get idItemPedido => _idItemPedido;

  set idItemPedido (String value) {
    _idItemPedido = value;
  }

  Item get item => _item;

  set item (Item value) {
    _item = value;
  }

  String get idPedido => _idPedido;

  set idPedido (String value) {
    _idPedido = value;
  }

  String get quantidade => _quantidade;

  set quantidade (String value) {
    _quantidade = value;
  }
}