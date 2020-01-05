import 'dart:math' as Math;
import 'statholder.dart';

abstract class Stats {

  //<String>[Stats.POWER, Stats.HEALTH, Stats.RELATIONSHIPS, Stats.MOBILITY, Stats.SANITY, Stats.FREE_WILL, Stats.MAX_LUCK, Stats.MIN_LUCK, Stats.ALCHEMY];

  static Stat EXPERIENCE;//todo remove
  static Stat GRIST;//todo remove

  static Stat POWER;
  static Stat HEALTH;
  static Stat CURRENT_HEALTH;//todo remove
  static Stat MOBILITY;//todo remove

  static Stat RELATIONSHIPS;//todo remove
  static Stat SANITY;//todo remove
  static Stat FREE_WILL;//todo remove

  static Stat MAX_LUCK;//todo remove
  static Stat MIN_LUCK;//todo remove

  static Stat ALCHEMY;
  static Stat SBURB_LORE;//todo remove

  static List<Stat> _list = <Stat>[];

  static Iterable<Stat> get all => _list;
  static Iterable<Stat> get summarise => _list.where((Stat stat) => stat.summarise);

  static Map<String, Stat> byName;
}

class Stat {
  final String name;

  final bool pickable;
  final bool summarise;
  final bool transient;

  double coefficient; //hope players can change
  final double associatedGrowth;

  double minBase = double.negativeInfinity;
  double maxBase = double.infinity;
  double minDerived = double.negativeInfinity;
  double maxDerived = double.infinity;

  Stat(String this.name,{double this.coefficient = 1.0, double this.associatedGrowth = 1.0, bool this.pickable = true, bool this.summarise = true, bool this.transient = false}) {
    Stats._list.add(this);
  }

  double derived(StatHolder stats, double base) { return base * coefficient; }

  @override
  String toString() => this.name;

  T min<T extends StatObject>(Iterable<T> from) {
    double n = double.infinity;
    T least = null;
    double s;
    for (T h in from) {
      s = h.getStatHolder()[this];
      if (s < n) {
        least = h;
        n = s;
      }
    }
    return least;
  }


  double average(Iterable<StatObject> from, [bool baseStats = false]) {
    if(from.isEmpty) return 0.0;
    return this.total(from, baseStats) / from.length;
  }

  double total(Iterable<StatObject> from, [bool baseStats = false]) {
    if (baseStats) {
      return from.map((StatObject o) => o.getStatHolder().getBase(this)).reduce((double a, double b) => a+b);
    }
    return from.map((StatObject o) => o.getStatHolder()[this]).reduce((double a, double b) => a+b);
  }

  int sorter(StatObject a, StatObject b) => a.getStatHolder()[this].compareTo(b.getStatHolder()[this]);

  List<T> sortedList<T extends StatObject>(Iterable<T> iterable, [bool reverse = false]) {
    List<T> unsorted = iterable.toList();
    if (reverse) {
      unsorted = unsorted.reversed.toList();
    }
    return unsorted..sort(this.sorter);
  }
}
