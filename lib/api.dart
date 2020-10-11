//modal Class for the JSON data
class API {
  Map _rates = {};
  String _base = '';
  String _date = '';

  Map get rates => _rates;

  set rates(Map value) {
    _rates = value;
  }

  String get base => _base;

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  set base(String value) {
    _base = value;
  }
}