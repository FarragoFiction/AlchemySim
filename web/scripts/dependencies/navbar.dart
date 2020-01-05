import "dart:async";
import 'dart:html';

String simulatedParamsGlobalVar = "";



String todayToSession() {
  DateTime now = new DateTime.now();
  if(now.month == 4 && now.day == 1) {
    querySelector('body').classes.add("voidbody");
  }
  int year = now.year;
  int month = now.month;
  int day = now.day;
  String y = year.toString();
  String m = month.toString();
  String d = day.toString();
  if (month < 10) m = "0$m";
  if (day < 10) d = "0$d";
  return "$y$m$d";
}


String getRawParameterByName(String name, String url) {
  print("url is $url");
  Uri uri = Uri.base;
  if (url != null) {
    uri = new Uri.file(url); //TODO is there no built in way to parse a string as a URI? need for virtual parameters like ocDataSTrings from selfInsertOC=true
  }
  print("uri is $uri parms are ${uri.queryParameters}");
  return uri.queryParameters[name];
}
