import 'SBURBSim.dart';

class Aspect {
  WeightedList<Item> items = new WeightedList<Item>();

  Aspect() {
    initializeItems();
  }

  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Perfectly Generic Object",<ItemTrait>[],shogunDesc: "I Think Is The Starbound Item For Debugging Unused Item IDs"));
  }


}