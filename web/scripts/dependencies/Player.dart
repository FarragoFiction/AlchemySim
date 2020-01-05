import 'dart:async';
import 'dart:convert';
import "dart:html";
import "dart:math" as Math;
import "dart:typed_data";
import 'SBURBSim.dart';


class Player extends GameEntity{
  //TODO trollPlayer subclass of player??? (have subclass of relationship)
  num baby = null;
  Session session;
  //if 0, not yet woken up.
  double moonChance = 0.0;
  bool deriveChatHandle = true;
  bool deriveSprite = true;
  bool deriveSpecibus = true;
  bool deriveLand = true;
  String flipOutReason = null; //if it's null, i'm not flipping my shit.
  bool trickster = false;
  bool sbahj = false;
  bool robot = false;
  num ectoBiologicalSource = null; //might not be created in their own session now.
  SBURBClass class_name;
  Player _guardian = null; //no longer the sessions job to keep track
  bool baby_stuck = false;
  String influenceSymbol = null; //multiple aspects can influence/mind control.
  Aspect aspect;
  //want to be able to see when it's set
  Moon _moon;
  Interest interest1 = null;
  Interest interest2 = null;
  String chatHandle = null;
  GameEntity object_to_prototype; //mostly will be potential sprites, but sometimes a player
  //List<Relationship> relationships = [];  //TODO keep a list of player relationships and npc relationships. MAYBE don't wax red for npcs? dunno though.
  List<String> mylevels = null;
  num level_index = -1; //will be ++ before i query
  bool godTier = false;
  String victimBlood = null; //used for murdermode players.
  num hair = null; //num hair = 16;
  String hairColor = null;
  bool dreamSelf = true;
  bool isTroll = false; //later
  String bloodColor = "#ff0000"; //human red.
  num leftHorn = null;
  num rightHorn = null;
  GameEntity myLusus = null;

  bool godDestiny = false;
  bool isDreamSelf = false; //players can be triggered for various things. higher their triggerLevle, greater chance of going murdermode or GrimDark.
  bool murderMode = false; //kill all players you don't like. odds of a just death skyrockets.
  bool leftMurderMode = false; //have scars, unless left via death.
  num gnosis = 0; //sburbLore causes you to increase a level of this.
  double landLevel = 0.0; //at 10, you can challenge denizen.  only space player can go over 100 (breed better universe.)





  @override
  String get name => "${title()}($chatHandle)";


  void set guardian(Player g) {
    _guardian = g;
  }


  String htmlTitleBasicNoTip() {
    return "${this.aspect.fontTag()}${this.titleBasic()}</font> (<font color = '${getChatFontColor()}'>${chatHandle}</font>)";
  }

  //@override
  String titleBasic() {
    String ret = "";

    ret = "$ret${this.class_name} of ${this.aspect}";
    return ret;
  }

  bool isActive([double multiplier = 0.0]) {
    return class_name.isActive(multiplier);
  }

  num modPowerBoostByClass(num powerBoost, AssociatedStat stat) {
    return this.class_name.modPowerBoostByClass(powerBoost, stat);
  }


  String getChatFontColor() {
    if (this.isTroll) {
      return this.bloodColor;
    } else {
      return this.aspect.palette.text.toStyleString();
    }
  }

  bool highInit() {
    return this.class_name.highHinit();
  }

  void initializeLuck() {
    this.setStat(Stats.MIN_LUCK, this.session.rand.nextIntRange(-10, 0)); //middle of the road.
    this.setStat(Stats.MAX_LUCK, this.session.rand.nextIntRange(1, 10)); //max needs to be more than min.
  }


  void initializeFreeWill() {
    this.setStat(Stats.FREE_WILL, this.session.rand.nextIntRange(-10, 10));
  }


  void clearSelf() {
    canvas.context2D.clearRect(0, 0, canvas.width, canvas.height);
  }

  void initializeMobility() {
    this.setStat(Stats.MOBILITY, this.session.rand.nextIntRange(-10, 10));
  }

  void initializeSanity() {
    this.setStat(Stats.SANITY, this.session.rand.nextIntRange(-10, 10));
  }

  @override
  String toString() {
    return title(); //no spaces.
  }




  void populateInventory() {
    sylladex.clear();
    sylladex.add(session.rand.pickFrom(interest1.category.items));
    sylladex.add(session.rand.pickFrom(interest2.category.items));
    //testing something
    // sylladex.add(new Item("Dr Pepper BBQ Sauce",<ItemTrait>[ItemTraitFactory.POISON],shogunDesc: "Culinary Perfection",abDesc:"Gross."));

  }

}