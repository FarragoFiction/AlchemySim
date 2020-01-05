import "dart:html";
import "SBURBSim.dart";


class Gristmas extends Scene {
  int expectedInitialAverageAlchemyValue = 6;
  int expectedMiddleAverageAlchemyValue = 10;
  int expectedEndAverageAlchemyValue = 30;
  Player player;
  int playerSkill;
  Gristmas(Session session) : super(session);



  bool playerCanMakeRobot(Player p) {
    bool first = getAlchemySkillNormalized(p) >=2 && p.companionsCopy.isEmpty;
    if(first) return first;
    //one last shot, you like tech?
    if(InterestManager.TECHNOLOGY.playerLikes(p) && getAlchemySkillNormalized(p) >=1 && p.companionsCopy.isEmpty ) return true;
    return false;
  }

  //takes all items in inventory and rubs them on each other.
  List<AlchemyResult> doAlchemy() {
    List<AlchemyResult> ret = new List<AlchemyResult>();
    //REMEMBER: item1 OR item2 is a DIFFERENT THING than the reverse. so you aren't wasting time by doing each item pair twice.
    for(Item item1 in player.sylladex) {
      for(Item item2 in player.sylladex) {
        if(item1 != item2){
          //;
          if ((item1.canUpgrade(playerSkill == 3) || session.mutator.dreamField)){
            //;

            ret.addAll(AlchemyResult.planAlchemy(<Item>[item1, item2],session,playerSkill));
          }
        }else {
          //;
        }
      }
    }
    //WHY the fuck is this sometimes returning 0 without a dream field? oh, cuz only upgrading specibus
    //if(ret.length == 0) ;
    return ret;
  }

  //takes all items in inventory and rubs them on each other.
  List<AlchemyResult> upgradeSpecibus() {
    List<AlchemyResult> ret = new List<AlchemyResult>();
    //REMEMBER: item1 OR item2 is a DIFFERENT THING than the reverse. so you aren't wasting time by doing each item pair twice.
    for(Item item1 in player.sylladex) {
      ret.addAll(AlchemyResult.planAlchemy(<Item>[player.specibus, item1], session,playerSkill));
    }
    return ret;
  }


  int getAlchemySkillNormalized(Player p) {
    double ratio = 1.0;
    if (p.land != null && !p.land.firstCompleted) ratio = p.getStat(Stats.ALCHEMY) / expectedInitialAverageAlchemyValue;
    if (p.land != null && p.land.firstCompleted && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY) / expectedMiddleAverageAlchemyValue;
    if (p.land != null && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY) / expectedEndAverageAlchemyValue;
    if (ratio < 1) {
      //session.logger.info("${p} alchemy skill 1, raw value ${ p.getStat(Stats.ALCHEMY)}");
      return 0;
    } else if (ratio < 2) {
      //session.logger.info("${p} alchemy skill 2,raw value ${ p.getStat(Stats.ALCHEMY)}");
      return 1;
    } else {
      //session.logger.info("${p} alchemy skill 3,raw value ${ p.getStat(Stats.ALCHEMY)}");
      return 2;
    }
  }



  //the better you are at alchemy, the higher your standards are.
  bool meetsStandards(Player p, Item i) {
    return true; //<--being picky actually bites players good at alchemy in the ass.
    double ratio = 1.0;
    //depending on how far along you are in your quest, your standards should get higher.
    if(p.land != null && !p.land.firstCompleted) ratio = p.getStat(Stats.ALCHEMY)/expectedInitialAverageAlchemyValue;
    if(p.land != null && p.land.firstCompleted && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY)/expectedMiddleAverageAlchemyValue;
    if(p.land != null && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY)/expectedEndAverageAlchemyValue;

    //basically, if you'er higher than average, your standards will be higher
    //and if you'er lower than average, your standards will be lower.
    //specibus = 1.0, item = .9 works for somebody with lower skill
    //does not work for somebody with higher.
    //BUT don't be so snobby you don't alchemize things before the final battle.
    return ((i.rank) > p.specibus.rank*ratio) || session.timeTillReckoning < 10;
  }
}