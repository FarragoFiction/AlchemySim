import "dart:collection";
import "SBURBSim.dart";

/// Interface for objects with stats when you don't care about anything else.
/// Mostly for when you want to support [StatHolder] AND [StatOwner] in a method.
abstract class StatObject {
  StatHolder getStatHolder();
}

class StatHolder extends Object with IterableMixin<Stat> implements StatObject {
  final Map<Stat, double> _base = <Stat, double>{};

  @override
  StatHolder getStatHolder() => this;

  double getBase(Stat key) => _base.containsKey(key) ? _base[key] : 0.0;

  void setBase(Stat key, num val) {
    _base[key] = val.toDouble();
    /*if (_base[key].isNaN) {
            throw "$key was set to NaN in setBase (val: $val)";
        }*/
  }
  void addBase(Stat key, num val) {
    _base[key] = getBase(key) + val.toDouble();
    /*if (_base[key].isNaN) {
            throw "$key was set to NaN in addBase (val: $val)";
        }*/
  }

  void setMap(Map<Stat,num> map) {
    for (Stat stat in map.keys) {
      this.setBase(stat, map[stat]);
    }
  }

  @override
  Iterator<Stat> get iterator => this._base.keys.iterator;
  @override
  int get length => this._base.length;
}

abstract class StatOwner implements StatObject {
  StatHolder _stats;

  @override
  StatHolder getStatHolder() => this.stats;

  void initStatHolder() {
    this._stats = this.createHolder();
  }

  StatHolder get stats => _stats;
  void setStat(Stat stat, num val) => this.stats.setBase(stat, val.toDouble());
}

abstract class OwnedStatHolder<T extends StatOwner> extends StatHolder {
  T owner;

  OwnedStatHolder(T this.owner);
}




class MagicalItemStatHolder<T extends MagicalItem> extends OwnedStatHolder<T> {

  MagicalItemStatHolder(T owner):super(owner);

  @override
  void setBase(Stat key, num val) {
    /*if (owner.session != null) {
            owner.session.logger.error("SET $owner: $key = $val");
        }*/
    super.setBase(key, val);
  }
  @override
  void addBase(Stat key, num val) {
    /*if (owner.session != null) {
            owner.session.logger.error("ADD $owner: $key += $val");
        }*/
    super.addBase(key, val);
  }
}