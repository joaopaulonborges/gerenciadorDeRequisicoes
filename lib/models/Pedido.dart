class Pedido {

  String _idPedido;
  String _data;
  String _total;
  String _idCliente;

  Pedido(this._idPedido, this._total, this._data, this._idCliente);

  String get idPedido => _idPedido;

  set idPedido (String value) {
    _idPedido = value;
  }

  String get total => _total;

  set total (String value) {
    _total = value;
  }

  String get data => _data;

  set data (String value) {
    _data = value;
  }

  String get idCliente => _idCliente;

  set idCliente (String value) {
    _idCliente = value;
  }
}