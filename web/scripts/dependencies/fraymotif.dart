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
  bool usable = true; //when used in a fight, switches to false. IMPORTANT: fights should turn it back on when over.
  //flavor text acts as a template, with ENEMIES and CASTERS and ALLIES and ENEMY being replaced.
  //you don't call flavor text directly, instead expecting the use of the fraymotif to return something;
  //based on it.
  //make sure ENEMY is the same for all effects, dunkass.
  String desc; //will generate it procedurally if not set, otherwise things like sprites will have it hand made.
  List<FraymotifEffect> effects = <FraymotifEffect>[]; //each effect is a target, a revive, a statName
  Fraymotif() {
  }


}

