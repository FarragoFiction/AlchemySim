import "SBURBSim.dart";

//carapaces are the only things that can be crowned and have it give anything but fraymotifs.
class Carapace {

  int sideLoyalty = 1;


  static String PROSPIT = "prospit";
  static String DERSE = "derse";

  bool royalty = false;

  List<String> firstNames;
  List<String> lastNames;
  List<String> ringFirstNames;
  List<String> ringLastNames;
  String type;



  void pickName() {
    if(crowned != null) {
      name = "${session.rand.pickFrom(ringFirstNames)} ${session.rand.pickFrom(ringLastNames)}";
    }else {
      name = "${session.rand.pickFrom(firstNames)} ${session.rand.pickFrom(lastNames)}";
    }
  }

}



