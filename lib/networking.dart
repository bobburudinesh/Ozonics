import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper(this.url);
  final String url;
  Future getData() async {
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      String climate = response.body;

      var decodedat = jsonDecode(climate);
      return decodedat;
    } else {
      print(response.statusCode);
    }
  }
}