import 'dart:html';
import 'SBURBSim.dart';

//effects are frozen at creation, basically.  if this fraymotif is created by a Bard of Breath in a session with a Prince of Time,
//who then dies, and then a combo session results in an Heir of Time being able to use it with the Bard of Breath, then it'll still have the prince effect.
class FraymotifEffect {
  Stat statName; //hp heals current hp AND revives the player.
  num target; //self, allies or enemy or enemies, 0, 1, 2, 3
  bool damageInsteadOfBuff = false; // statName can either be applied towards damaging someone or buffing someone.  (damaging self or allies is "healing", buffing enemies is applied in the negative direction.)
  num s = 0; //convineience methods cause i don't think js has enums but am too lazy to confirm.
  num a = 1;
  num e = 2;
  num e2 = 3;

  /// target 0  = self, 1 = allies, 2 = enemy 3 = enemies.
  FraymotifEffect(Stat this.statName, num this.target, bool this.damageInsteadOfBuff) {}

  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json["stat"] = statName.name;
    json["target"] = "$target";
    json["damageInsteadOfBuff"] = damageInsteadOfBuff.toString();
    return json;
  }

  void copyFromJSON(JSONObject json) {
    // print("copying fraymotif effect from json $json");
    statName = Stats.byName[json["stat"]];
    target = int.parse(json["target"]);
    if(json["damageInsteadOfBuff"] == "true") {
      damageInsteadOfBuff = true;
    }else {
      damageInsteadOfBuff = false;
    }
  }

  @override
  String toString() {
    String ret = "";
    if (this.damageInsteadOfBuff && this.target < 2) {
      ret += " heals";
    } else if (this.damageInsteadOfBuff && this.target >= 2) {
      ret += " damages";
    } else if (!this.damageInsteadOfBuff && this.target < 2) {
      ret += " buffs";
    } else if (!this.damageInsteadOfBuff && this.target >= 2) {
      ret += " debuffs";
    }

    if (this.target == 0) {
      ret += " self";
    } else if (this.target == 1) {
      ret += " allies";
    } else if (this.target == 2) {
      ret += " an enemy";
    } else if (this.target == 3) {
      ret += " all enemies";
    }
    String stat = "STAT";
    ret += " based on how " + stat + " the casters are compared to their enemy";
    return ret;
  }

}
