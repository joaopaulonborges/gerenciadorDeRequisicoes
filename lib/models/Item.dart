class Item {

  String _idItem;
  String _descricao;
  String _valor;
  String _minimo;
  String _maximo;
  String _tabelaDePreco;

  Item(this._idItem, this._descricao, this._valor, this._minimo, this._maximo, this._tabelaDePreco);

  String get idItem => _idItem;

  set idItem (String value) {
    _idItem = value;
  }

  String get descricao => _descricao;

  set descricao (String value) {
    _descricao = value;
  }

  String get valor => _valor;

  set valor (String value) {
    _valor = value;
  }

  String get minimo => _minimo;

  set minimo (String value) {
    _minimo = value;
  }

  String get maxmimo => _maximo;

  set maximo (String value) {
    _maximo = value;
  }

  String get tabelaDePreco => _tabelaDePreco;

  set tabelaDePreco (String value) {
    _tabelaDePreco = value;
  }
}