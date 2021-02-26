class Usuario {

  String _idUsuario;
  String _nome;
  String _email;
  String _senha;
  String _idEmpresa;
  String _empresa;

  Usuario(this._idUsuario, this._nome, this._email, this._senha, this._idEmpresa, this._empresa);

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get empresa => _empresa;

  set empresa (String value) {
    _empresa = value;
  }

  String get idEmpresa => _idEmpresa;

  set idEmpresa (String value) {
    _idEmpresa = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }
}