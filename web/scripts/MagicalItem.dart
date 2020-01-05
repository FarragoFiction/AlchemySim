import "Item.dart";
import 'Trait.dart';
import 'dependencies/stat.dart';
import 'dependencies/statholder.dart';
import "dependencies/SBURBSim.dart";
import 'dependencies/GameEntity.dart';
import 'dependencies/fraymotif.dart';
import 'dependencies/FraymotifEffect.dart';

//rings and shit.
class MagicalItem extends Item with StatOwner {
  @override
  bool isCopy = false;
  //TODO: FIGURE OUT HOW MAGIC ITEMS EFFECT THEIR OWNERS
  //like, rings and scepters should only effect carapaces besides enabling the reckoning.

  //it's what makes them magical in addition to direct stat boosts.
  List<Fraymotif> fraymotifs = <Fraymotif>[];



  @override
  String get fullNameWithUpgrade {
    return "${fullName} ${fraymotifs.length} spells";
  }


  MagicalItem.withoutOptionalParams(String baseName,List<ItemTrait> traitsList):super.withoutOptionalParams(baseName, traitsList){
    initStatHolder();
  }


  @override
  StatHolder createHolder() {
    return new MagicalItemStatHolder<MagicalItem>(this);
  }
}

class Ring extends MagicalItem {
  Ring.withoutOptionalParams(String baseName,List<ItemTrait> traitsList):super.withoutOptionalParams(baseName, traitsList);

}


class Scepter extends MagicalItem {
  Scepter.withoutOptionalParams(String baseName,List<ItemTrait> traitsList):super.withoutOptionalParams(baseName, traitsList);

}