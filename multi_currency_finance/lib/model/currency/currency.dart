class Currency {
  late final String _id;
  late String _name;
  late String _abbreviation;
  late String _symbol;

  String get id => this._id;

  String get name => this._name;
  set name(String value) => this._name = value;

  String get abbreviation => this._abbreviation;
  set abbreviation(String value) => this._abbreviation = value;

  String get symbol => this._symbol;
  set symbol(String value) => this._symbol = value; 

  Currency(this._id, this._name, this._abbreviation, this._symbol);
}
