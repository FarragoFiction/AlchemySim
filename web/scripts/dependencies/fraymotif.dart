import 'dart:convert';
import "dart:html";
import 'SBURBSim.dart';



/*
stat effects from a fraymotif are temporary. wear off after battle.
so, players, player snapshots AND gameEntities will have to have an array of applied fraymotifs.
and their getPower, getHP etc stats must use these.
at start AND end of battle (can't be too careful), wipe applied fraymotifs
*/
class Fraymotif {

  String get labelPattern => ":___ ";


  List<Aspect> aspects; //expect to be an array
  String name;
  int tier;
  bool usable = true; //when used in a fight, switches to false. IMPORTANT: fights should turn it back on when over.
  //flavor text acts as a template, with ENEMIES and CASTERS and ALLIES and ENEMY being replaced.
  //you don't call flavor text directly, instead expecting the use of the fraymotif to return something;
  //based on it.
  //make sure ENEMY is the same for all effects, dunkass.
  String desc; //will generate it procedurally if not set, otherwise things like sprites will have it hand made.
  List<FraymotifEffect> effects = <FraymotifEffect>[]; //each effect is a target, a revive, a statName


  Fraymotif(String this.name, int this.tier, {List<Aspect> this.aspects = null, String this.desc = ""}) {
    if (this.aspects == null) {
      this.aspects = <Aspect>[];
    }
  }

  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json["name"] = name;
    json["tier"] = "$tier";
    json["desc"] = desc;
    List<JSONObject> effectArray = new List<JSONObject>();

    for(FraymotifEffect s in effects) {
      effectArray.add(s.toJSON());
    }
    json["effects"] = effectArray.toString();

    return json;
  }


  void copyFromDataString(String data) {
    //print("copying from data: $data, looking for labelpattern: $labelPattern");
    String dataWithoutName = data.split("$labelPattern")[1];
    //print("data without name is $dataWithoutName");

    String rawJSON = LZString.decompressFromEncodedURIComponent(dataWithoutName);
    //print("raw json is $rawJSON");
    JSONObject json = new JSONObject.fromJSONString(rawJSON);
    copyFromJSON(json);
  }

  void copyFromJSON(JSONObject json) {
    //print("copying from json $json");
    name = json["name"];
    tier = int.parse(json["tier"]);
    desc = json["desc"];
    String traitsString = json["effects"];
    loadEffects(traitsString);
  }

  void loadEffects(String weirdString) {
    if(weirdString == null) return;
    List<dynamic> what = jsonDecode(weirdString);
    for(dynamic d in what) {
      FraymotifEffect ss = new FraymotifEffect(null, 0, false);
      JSONObject j = new JSONObject();
      j.json = d;
      ss.copyFromJSON(j);
      effects.add(ss);
    }
  }

  @override
  String toString() => this.name;



}

