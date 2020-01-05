/*
    should be a wrapper for a map.
    new JsonObject.fromJsonString(json); should be implemented.
 */
import 'dart:collection';
import 'dart:convert';

class JSONObject extends Object with MapMixin<String,String>{
  Map<String, dynamic> json = new Map<String,dynamic>();
  JSONObject();

  JSONObject.fromJSONString(String j){
    //;
    //okay. that's not working. what if i do it opposite to see what a encoded object looks like
    //JSONObject test = new JSONObject();
    //test["HELLO"] = "WORLD ";
    //test["GOODBYE"] = "WORLD BUT A SECOND TIME ";
    //;
    //;

    json = jsonDecode(j);
  }


  @override
  String toString() {
    return jsonEncode(json);
  }

  @override
  String operator [](Object key) {
    return json[key];
  }

  @override
  void operator []=(String key, String value) {
    json[key] = value;
  }

  @override
  void clear() {
    json.clear();
  }

  @override
  Iterable<String> get keys => json.keys;

  @override
  String remove(Object key) {
    json.remove(key);
  }
}