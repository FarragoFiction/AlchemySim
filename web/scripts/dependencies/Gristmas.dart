import "dart:html";
import "SBURBSim.dart";


class Gristmas{
  Player player;
  Gristmas() : super();

  //takes all items in inventory and rubs them on each other.
  List<AlchemyResult> doAlchemy() {
    List<AlchemyResult> ret = new List<AlchemyResult>();
    //WHY the fuck is this sometimes returning 0 without a dream field? oh, cuz only upgrading specibus
    //if(ret.length == 0) ;
    return ret;
  }

}