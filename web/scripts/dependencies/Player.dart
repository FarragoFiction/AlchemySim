import 'dart:async';
import 'dart:convert';
import "dart:html";
import "dart:math" as Math;
import "dart:typed_data";
import 'SBURBSim.dart';


class Player extends GameEntity{
  //TODO trollPlayer subclass of player??? (have subclass of relationship)
  Session session;
  SBURBClass class_name;
  Aspect aspect;
  //want to be able to see when it's set
  Interest interest1 = null;
  Interest interest2 = null;
  String chatHandle = null;
  bool isTroll = false; //later
  String bloodColor = "#ff0000"; //human red.


  Player([Session session, SBURBClass this.class_name, Aspect this.aspect]) : super("", session);
    @override
  String get name => "${title()}($chatHandle)";

  @override
  StatHolder createHolder() => new PlayerStatHolder();


  String htmlTitleBasicNoTip() {
    return "${this.titleBasic()}</font> (${chatHandle}</font>)";
  }

  //@override
  String titleBasic() {
    String ret = "";

    ret = "$ret${this.class_name} of ${this.aspect}";
    return ret;
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