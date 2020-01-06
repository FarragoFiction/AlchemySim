import 'SBURBSim.dart';

class SBURBClass {

  //starting items, quest rewards, etc.
  WeightedList<Item> items = new WeightedList<Item>();

  SBURBClass() {
    initializeItems();
  }

  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Perfectly Generic Object",<ItemTrait>[],shogunDesc: "Green Version of Those Sweet Yellow Candies I Loved"));
  }

}