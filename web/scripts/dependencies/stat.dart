import 'dart:math' as Math;

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

  static void init() {
    if (_initialised) {return;}
    _initialised = true;

    EXPERIENCE = new Stat("Experience", "learned", "naïve", pickable: false)..minBase=0.0; //wastes can get 0
    GRIST = new Stat("Grist Level", "rich", "poor", pickable: false, summarise:false);

    POWER = new XPScaledStat("Power", "strong", "weak", 0.03, coefficient: 10.0, associatedGrowth: 0.5)..minBase=2.5..minDerived=1.0;
    HEALTH = new XPScaledStat("Health", "sturdy", "fragile", 0.04, coefficient: 10.0)..minBase=2.5;
    CURRENT_HEALTH = new Stat("Current Health", "healthy", "infirm", pickable: false, transient:true);
    MOBILITY = new Stat("Mobility", "fast", "slow");

    //RELATIONSHIPS = new RelationshipStat("Relationships", "friendly", "aggressive", pickable: false); // should be a special one to deal with players
    SANITY = new Stat("Sanity", "calm", "crazy");
    FREE_WILL = new Stat("Free Will", "willful", "gullible");

    MAX_LUCK = new Stat("Maximum Luck", "lucky", "unlucky");
    MIN_LUCK = new Stat("Minimum Luck", "lucky", "unlucky");

    ALCHEMY = new Stat("Alchemy", "creative", "boring");
    SBURB_LORE = new Stat("SBURB Lore", "woke", "clueless", pickable: false);

    byName = new Map<String,Stat>.unmodifiable(new Map<String,Stat>.fromIterable(all, key: (dynamic s) => s.name, value: (dynamic s) => s));
  }
  static bool _initialised = false;

  static List<Stat> _list = <Stat>[];

  static Iterable<Stat> get all => _list;
  static Iterable<Stat> get pickable => _list.where((Stat stat) => stat.pickable);
  static Iterable<Stat> get summarise => _list.where((Stat stat) => stat.summarise);

  static Map<String, Stat> byName;
}

class Stat {
  final String name;
  final String emphaticPositive;
  final String emphaticNegative;

  final bool pickable;
  final bool summarise;
  final bool transient;

  double coefficient; //hope players can change
  final double associatedGrowth;

  double minBase = double.negativeInfinity;
  double maxBase = double.infinity;
  double minDerived = double.negativeInfinity;
  double maxDerived = double.infinity;

  Stat(String this.name, String this.emphaticPositive, String this.emphaticNegative, {double this.coefficient = 1.0, double this.associatedGrowth = 1.0, bool this.pickable = true, bool this.summarise = true, bool this.transient = false}) {
    Stats._list.add(this);
  }

  double derived(StatHolder stats, double base) { return base * coefficient; }

  @override
  String toString() => this.name;

  T max<T extends StatObject>(Iterable<T> from) {
    double n = double.negativeInfinity;
    T most = null;
    double s;
    for (T h in from) {
      s = h.getStatHolder()[this];
      if (s > n) {
        most = h;
        n = s;
      }
    }
    return most;
  }

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

  String emphaticDescriptor(StatObject o) {
    if (o.getStatHolder()[this] > 0) {
      return this.emphaticPositive;
    }
    return this.emphaticNegative;
  }

  double get rangeMinimum => Math.max(this.minBase * this.coefficient, this.minDerived);
  double get rangeMaximum => Math.min(this.maxBase * this.coefficient, this.maxDerived);
}

class XPScaledStat extends Stat {
  final double expCoefficient;

  XPScaledStat(String name, String emphaticPositive, String emphaticNegative, double this.expCoefficient, {double coefficient = 1.0, double associatedGrowth = 1.0, bool pickable = true, bool summarise = true, bool transient = false}):super(name, emphaticPositive, emphaticNegative, coefficient:coefficient, associatedGrowth:associatedGrowth, pickable:pickable, summarise:summarise, transient:transient);

  @override
  double derived(StatHolder stats, double base) {
    double xp = stats[Stats.EXPERIENCE];
    return super.derived(stats, base) * (1.0 + expCoefficient * xp);
  }
}