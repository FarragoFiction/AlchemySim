import 'SBURBSim.dart';

abstract class Aspects {
  static Aspect SPACE;
  static Aspect TIME;
  static Aspect BREATH;
  static Aspect DOOM;
  static Aspect BLOOD;
  static Aspect HEART;
  static Aspect MIND;
  static Aspect LIGHT;
  static Aspect VOID;
  static Aspect RAGE;
  static Aspect HOPE;
  static Aspect LIFE;
  static Aspect DREAM;
  static Aspect LAW;
  static Aspect SAUCE; //just shogun
  static Aspect JUICE; //everyone but sb

  static Aspect NULL;

  static void init() {
    SPACE = new Space(0);
    TIME = new Time(1);
    BREATH = new Breath(2);
    DOOM = new Doom(3);
    BLOOD = new Blood(4);
    HEART = new Heart(5);
    MIND = new Mind(6);
    LIGHT = new Light(7);
    VOID = new Void(8);
    RAGE = new Rage(9);
    HOPE = new Hope(10);
    LIFE = new Life(11);
    DREAM = new Dream(12);
    LAW = new Law(14);
    SAUCE = new Sauce(13);
    JUICE = new Juice(15); //sudden terror, did i make sure extension bytes work with aspects?

    NULL = new Aspect(255, "Null", isInternal:true);
  }

  // ##################################################################################################

  static Map<int, Aspect> _aspects = <int, Aspect>{};



  static void register(Aspect aspect) {
    if (_aspects.containsKey(aspect.id)) {
      throw "Duplicate aspect id for $aspect: ${aspect.id} is already registered for ${_aspects[aspect.id]}.";
    }
    _aspects[aspect.id] = aspect;
  }

  static Aspect get(int id) {
    if (_aspects.isEmpty) init();
    if (_aspects.containsKey(id)) {
      return _aspects[id];
    }
    return NULL; // return the NULL aspect instead of null
  }

  static Aspect getByName(String name) {
    if (_aspects.isEmpty) init();
    for (Aspect aspect in _aspects.values) {
      if (aspect.name == name) {
        return aspect;
      }
    }
    return NULL;
  }

  static Iterable<Aspect> get all => _aspects.values.where((Aspect a) => !a.isInternal);



  static Iterable<Aspect> get canon => _aspects.values.where((Aspect a) => a.isCanon);

  static Iterable<Aspect> get fanon => _aspects.values.where((Aspect a) => !a.isCanon);

  static Iterable<int> get ids => _aspects.keys;

  static Iterable<String> get names => _aspects.values.map((Aspect a) => a.name);

  static Aspect stringToAspect(String id) {
    List<Aspect> values = new List<Aspect>.from(_aspects.values);
    for (Aspect a in values) {
      if (a.name == id) return a;
    }
    return NULL;
  }
}

// ####################################################################################################################################

class Aspect {
  /// Used for OCData save/load.
  final int id;
  /// Used for string representations of the aspect.
  String name;
  String savedName;  //for AB restoring an aspects name after a hope player fucks it up

  /// Only canon aspects will appear in random sessions.
  final bool isCanon;
  final bool isInternal; //don't let null show up in lists.

  List<AssociatedStat> stats = <AssociatedStat>[];

  /// Perma-buffs for modifying stat growth and distribution - page growth curve etc.
  //starting items, quest rewards, etc.
  WeightedList<Item> items = new WeightedList<Item>();
  List<String> associatedScenes = <String>[];
  // ##################################################################################################
  // Constructor

  Aspect(int this.id, String this.name, {this.isCanon = false, this.isInternal = false}) {
    initializeItems();
    Aspects.register(this);
  }

  void processCard() {

  }


  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Perfectly Generic Object",<ItemTrait>[],shogunDesc: "I Think Is The Starbound Item For Debugging Unused Item IDs"));
  }

  @override
  String toString() => this.name;
}

class Blood extends Aspect {
  Blood(int id) :super(id, "Blood", isCanon: true);

  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Mystical Vial of Blood",<ItemTrait>[ItemTraitFactory.GLASS,ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.HEALING],shogunDesc: "Vial of Not-ABs Oil"))
    //shitty fanfic, you'll always be in my blood pusher.
      ..add(new Item("Bananaphone",<ItemTrait>[ItemTraitFactory.EDIBLE,ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.FUNNY], abDesc: "Really? Yet another in-joke nobody will ever get? Good work, 'oh mighty creator'. ",shogunDesc: "Yellow Respect Device"))

      ..add(new Item("Friendship Bracelet",<ItemTrait>[ItemTraitFactory.CLOTH,ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.HEALING, ItemTraitFactory.CHAIN],shogunDesc: "Soul Binding Wrist Shackle"))
      ..add(new Item("Bonding Manacles",<ItemTrait>[ItemTraitFactory.METAL,ItemTraitFactory.RESTRAINING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.HEALING,ItemTraitFactory.CHAIN, ItemTraitFactory.UNCOMFORTABLE],shogunDesc: "Handcuff with one cuff full of cigarettes"))
      ..add(new Item("Friendship Stairs",<ItemTrait>[ItemTraitFactory.WOOD,ItemTraitFactory.IRONICFAKECOOL, ItemTraitFactory.CALMING, ItemTraitFactory.HEALING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.LEGENDARY],shogunDesc: "Bloodstained Stairs",abDesc:"You push your friends down these, dunkass.")); //john wanted to push karkat down these.
  }

}

class Breath extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Pan's Pipe",<ItemTrait>[ItemTraitFactory.MUSICAL, ItemTraitFactory.WOOD, ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL],shogunDesc: "Smonkin Weeds Pipe"))
      ..add(new Item("Skeleton Key",<ItemTrait>[ItemTraitFactory.BONE, ItemTraitFactory.ASPECTAL],shogunDesc: "THE BONE SHAPED HOLE BREAKER",abDesc:"You are never gonna be imprisoned again.")) //escape any prison
      ..add(new Item("Inspector's Fan",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.METAL, ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL],shogunDesc: "Fondly Regarded Fan",abDesc:"Probably a refrance."))
      ..add(new Item("Jet Pack",<ItemTrait>[ItemTraitFactory.ONFIRE, ItemTraitFactory.METAL, ItemTraitFactory.LOUD,ItemTraitFactory.ASPECTAL, ItemTraitFactory.LEGENDARY],shogunDesc: "Rocket Powered Pants",abDesc:"Don't skip gates, asshole."));
  }

  Breath(int id) :super(id, "Breath", isCanon: true);
}

class Doom extends Aspect {
  Doom(int id) :super(id, "Doom", isCanon: true);

  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("~ATH - A Handbook for the Imminently Deceased ",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.ZAP, ItemTraitFactory.PAPER, ItemTraitFactory.DOOMED, ItemTraitFactory.ASPECTAL, ItemTraitFactory.LEGENDARY],shogunDesc: "A Huge Ass Black Book on Coding or Something",abDesc:"Don't use this to end two universes, asshole."))
      ..add(new Item("Egg Timer",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.DOOMED],shogunDesc: "Egg That Counts Down to Your Death"))
      ..add(new Item("Skull Timer",<ItemTrait>[ItemTraitFactory.BONE,ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.DOOMED],shogunDesc: "Skull That Counts Down to Your Dinner Being Ready",abDesc:"Everyone is mortal. Besides robots."))
      ..add(new Item("Poison Flask",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.ASPECTAL, ItemTraitFactory.POISON],shogunDesc: "Glass of Bone Hurting Juice"))
      ..add(new Item("Ice Gorgon Head",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.ASPECTAL, ItemTraitFactory.COLD,ItemTraitFactory.DOOMED,ItemTraitFactory.RESTRAINING,ItemTraitFactory.UGLY,ItemTraitFactory.SCARY],shogunDesc: "Oddly Attractive Decapitated Head"))
      ..add(new Item("Obituary",<ItemTrait>[ ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.SCARY, ItemTraitFactory.DOOMED, ItemTraitFactory.PAPER, ItemTraitFactory.ASPECTAL],shogunDesc: "Omae Wa Mou Shindeiru in Paper Form",abDesc:"I wonder whose it is? Yours?"));
  }
}

class Heart extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Doll",<ItemTrait>[ItemTraitFactory.PORCELAIN,ItemTraitFactory.PRETTY,ItemTraitFactory.SENTIENT, ItemTraitFactory.ASPECTAL],shogunDesc: "Possessed Doll (Probably)", abDesc: "It's like a robot, but useless."))
      ..add(new Item("Soul Puppet",<ItemTrait>[ItemTraitFactory.WOOD,ItemTraitFactory.SENTIENT, ItemTraitFactory.ASPECTAL, ItemTraitFactory.LEGENDARY,ItemTraitFactory.SCARY],shogunDesc: "Baby Muppet Snuff Survivor",abDesc:"Don't touch this shit."))
      ..add(new Item("Mirror",<ItemTrait>[ItemTraitFactory.MIRROR, ItemTraitFactory.ASPECTAL],shogunDesc: "Mirror That Shows A Reflection Of The World But A Horrible Beast Mimics Your Every Move"))
      ..add(new Item("Shipping Grid",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.ASPECTAL, ItemTraitFactory.ROMANTIC],shogunDesc: "A Grid of Pure Taint",abDesc:"No. No cat troll shit."))
      ..add(new Item("Shades",<ItemTrait>[ItemTraitFactory.COOLK1D,ItemTraitFactory.GLASS,ItemTraitFactory.ASPECTAL],shogunDesc: "Glasses For Try Hard Nerds", abDesc: "You can put a p great robot in these. I advise it."));
  }

  Heart(int id) :super(id, "Heart", isCanon: true);
}

class Hope extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Wand",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.ASPECTAL,ItemTraitFactory.MAGICAL, ItemTraitFactory.REAL],abDesc:"It's probably science powered.",shogunDesc: "Shitty Wizard Pencil"))
      ..add(new Item("Angel Feather",<ItemTrait>[ItemTraitFactory.REAL,ItemTraitFactory.FEATHER, ItemTraitFactory.ASPECTAL,ItemTraitFactory.GLOWING,ItemTraitFactory.MUSICAL, ItemTraitFactory.LEGENDARY, ItemTraitFactory.MAGICAL],shogunDesc: "Shitty Wizard Pencil",abDesc:"Angels are, like, these terrible feathery monsters. Don't fuck with them."))
      ..add(new Item("Never Ending Story DVD",<ItemTrait>[ItemTraitFactory.SHITTY, ItemTraitFactory.IRONICFAKECOOL, ItemTraitFactory.ASPECTAL, ItemTraitFactory.MAGICAL, ItemTraitFactory.FUNNY, ItemTraitFactory.REAL],shogunDesc: "White Dragon Kidnaps Kid The Movie"))
      ..add(new Item("Candle",<ItemTrait>[ItemTraitFactory.REAL,ItemTraitFactory.GLOWING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.ONFIRE],shogunDesc: "Dying Light Stick"))
      ..add(new Item("Fairy Figurine",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.GLOWING, ItemTraitFactory.ASPECTAL, ItemTraitFactory.REAL],shogunDesc: "Tiny Petrified Tinkerbell"));
  }

  Hope(int id) :super(id, "Hope", isCanon: true);

}

class Law extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("LAW Gavel",<ItemTrait>[ItemTraitFactory.ASPECTAL,ItemTraitFactory.WOOD, ItemTraitFactory.HAMMER],shogunDesc: "Tiny Whacky Smacky Skull Cracky of Justice",abDesc:"Organics seem to respect this. Use it to your advantage."))
      ..add(new Item("LAW Caution Tape",<ItemTrait>[ItemTraitFactory.ASPECTAL,ItemTraitFactory.PLASTIC, ItemTraitFactory.RESTRAINING],shogunDesc: "Impassible Barrier",abDesc:"For when you want to tell inferior organics to keep out."))
      ..add(new Item("STOP SIGN",<ItemTrait>[ItemTraitFactory.ASPECTAL,ItemTraitFactory.STAFF,ItemTraitFactory.METAL, ItemTraitFactory.RESTRAINING],abDesc:"This isn't a weapon, dunkass."));
  }
  Law(int id) :super(id, "Law", isCanon: false);
}

class Life extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Creeping Vine",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.ASPECTAL,ItemTraitFactory.PLANT,ItemTraitFactory.SENTIENT],shogunDesc: "Sentient Plant Tentacles"))
      ..add(new Item("Lollipop",<ItemTrait>[ItemTraitFactory.CANDY, ItemTraitFactory.ASPECTAL,ItemTraitFactory.HEALING],shogunDesc: "Sentient Plant Tentacles"))
      ..add(new Item("Golem",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.STONE, ItemTraitFactory.ASPECTAL,ItemTraitFactory.SENTIENT],shogunDesc: "Living Rock Man", abDesc: "I guess. It's LIKE a robot. Sort of. Just not a super computer."))
      ..add(new Item("Ectoplasm",<ItemTrait>[ItemTraitFactory.GHOSTLY, ItemTraitFactory.ASPECTAL,ItemTraitFactory.HEALING],shogunDesc: "Ghost [Censored]")) //thanks nana sprite
      ..add(new Item("Aqua Vitae",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.ASPECTAL,ItemTraitFactory.HEALING, ItemTraitFactory.LEGENDARY, ItemTraitFactory.MAGICAL],shogunDesc: "Tears of JR"))
      ..add(new Item("Homunculus",<ItemTrait>[ItemTraitFactory.FLESH, ItemTraitFactory.ASPECTAL,ItemTraitFactory.SENTIENT],shogunDesc: "False Man", abDesc: "Ugh. It's like a robot, but made of flesh. WHY WOULD YOU DO THIS."));
  }

  Life(int id) :super(id, "Life", isCanon: true);
}

class Light extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("FAQ",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.ASPECTAL,ItemTraitFactory.SMART,ItemTraitFactory.LUCKY],shogunDesc: "Questions to Ping JR About",abDesc:"Probably found it on a server in the Furthest Ring."))
      ..add(new Item("Flashlight",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.ASPECTAL,ItemTraitFactory.GLOWING,ItemTraitFactory.ZAP,ItemTraitFactory.LUCKY],shogunDesc: "Tube of Localised Sun"))
      ..add(new Item("Octet",<ItemTrait>[ItemTraitFactory.ASPECTAL,ItemTraitFactory.GLOWING,ItemTraitFactory.LUCKY,ItemTraitFactory.LEGENDARY,ItemTraitFactory.CRYSTAL],shogunDesc: "D13"))
      ..add(new Item("Horseshoe",<ItemTrait>[ItemTraitFactory.HORSESHOE, ItemTraitFactory.ASPECTAL, ItemTraitFactory.BLUNT],shogunDesc: "Horse Sneaker"))
      ..add(new Item("Rabbits Foot",<ItemTrait>[ItemTraitFactory.RABBITSFOOT, ItemTraitFactory.ASPECTAL],shogunDesc: "Rabbit Remains"))
      ..add(new Item("4 Leaf Clover",<ItemTrait>[ItemTraitFactory.PLANT, ItemTraitFactory.ASPECTAL,ItemTraitFactory.GLOWING,ItemTraitFactory.LUCKY],shogunDesc: "Plant of Luck +4"))
      ..add(new Item("8-Ball",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.ASPECTAL,ItemTraitFactory.SENTIENT],shogunDesc: "Worst Characters Only Quality",abDesc:"It seems this is never right. Ask again later or some shit."));

  }

  Light(int id) :super(id, "Light", isCanon: true);
}

class Mind extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Puzzle Box",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.ASPECTAL, ItemTraitFactory.MAGICAL],shogunDesc: "13x13 Rubix Cube", abDesc: "Don't let Mind players fool you. It's not about smarts."))
      ..add(new Item("Tesla Coil",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.ASPECTAL,ItemTraitFactory.METAL],shogunDesc: "Lightning Weiner",abDesc:  "Mind is electric shit. I guess."))
      ..add(new Item("Coin",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ASPECTAL],shogunDesc: "Official Minted Shogun Coin Circa. 1764",abDesc:  "Luck doesn't even matter, so neither does this coin. Mind players are such hams."))
      ..add(new Item("Electronic Door",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ASPECTAL,ItemTraitFactory.ZAP, ItemTraitFactory.SMART],shogunDesc: "Star Wars Force Activated Door",abDesc:"I guess it has buttons and shit? I bet it leads somewhere weird."))
      ..add(new Item("Janus Bust",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.BUST, ItemTraitFactory.STONE,ItemTraitFactory.CLASSY,ItemTraitFactory.ASPECTAL,ItemTraitFactory.LEGENDARY, ItemTraitFactory.ZAP],shogunDesc: "Bust of A Giant Phallic Asshole",abDesc:"So is the joke that Mind Players are two faced?"));
  }

  Mind(int id) :super(id, "Mind", isCanon: true);
}

class Rage extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Curtain",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.ASPECTAL, ItemTraitFactory.FAKE],shogunDesc: "Show Ender"))
      ..add(new Item("Cursed Sword",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.SWORD,ItemTraitFactory.POINTY,  ItemTraitFactory.ASPECTAL, ItemTraitFactory.EDGED, ItemTraitFactory.SCARY, ItemTraitFactory.FAKE, ItemTraitFactory.CORRUPT, ItemTraitFactory.DOOMED],abDesc:"You probably are gonna kill an army if you don't keep it safely tucked away in your sylladex."))

      ..add(new Item("Omegaphone",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.LOUD,ItemTraitFactory.ZAP,  ItemTraitFactory.ASPECTAL, ItemTraitFactory.FAKE],shogunDesc: "Voice Embiggener",abDesc:"Rage players are such loud assholes."))
      ..add(new Item("Trike Horn",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.METAL, ItemTraitFactory.LOUD, ItemTraitFactory.ENRAGING,ItemTraitFactory.RUBBER,ItemTraitFactory.ASPECTAL, ItemTraitFactory.FAKE],shogunDesc: "Two-wheel device mounted Juggalo voicebox"))
      ..add(new Item("Bacchus Wine",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.ENRAGING,ItemTraitFactory.CLASSY, ItemTraitFactory.ASPECTAL, ItemTraitFactory.LEGENDARY, ItemTraitFactory.FAKE ],shogunDesc: "Aged Grape Gore",abDesc:"I guess it makes you go beserk or some shit. Sucks being biological."))
      ..add(new Item("Nightmare Fuel",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.ASPECTAL,ItemTraitFactory.SCARY,ItemTraitFactory.ONFIRE,ItemTraitFactory.EXPLODEY, ItemTraitFactory.FAKE],shogunDesc: "Image of Adam Sandler in a Troll Face Shirt",abDesc:"It's clowns isn't it. It's always fucking clowns."));
  }

  Rage(int id) :super(id, "Rage", isCanon: true);

}

class Space extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Frog Statue",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.STONE, ItemTraitFactory.ASPECTAL],shogunDesc: "Croaking Lizard Monument",abDesc:"Frogs."))
      ..add(new Item("Frog Costume",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.ASPECTAL],shogunDesc: "Croaking Lizard Cosplay",abDesc:"You won't be able to stop the ribbits."))
      ..add(new Item("Nuclear Reactor",<ItemTrait>[ItemTraitFactory.NUCLEAR,ItemTraitFactory.SMART,ItemTraitFactory.ZAP, ItemTraitFactory.ASPECTAL],shogunDesc: "A Representation of My Hatred for Everything"))
      ..add(new Item("Telescope",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.GLASS,ItemTraitFactory.SMART,ItemTraitFactory.ASPECTAL],shogunDesc: "Mono-Sighted Long Ranged Perversion Apparatus"))
      ..add(new Item("Green Sun Poster",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.ASPECTAL, ItemTraitFactory.GREENSUN, ItemTraitFactory.LEGENDARY],shogunDesc: "Sauce Sun Poster",abDesc:"Huh."));
  }

  Space(int id) :super(id, "Space", isCanon: true);

}

class Time extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Grandfather Clock",<ItemTrait>[ItemTraitFactory.WOOD,ItemTraitFactory.CLASSY, ItemTraitFactory.VALUABLE, ItemTraitFactory.ASPECTAL],shogunDesc: "Ticking Tower of Time"))
      ..add(new Item("Drum",<ItemTrait>[ItemTraitFactory.LEATHER, ItemTraitFactory.ASPECTAL,ItemTraitFactory.MUSICAL],shogunDesc: "Ba Dum Tss but without the Tss Part"))
      ..add(new Item("Dead Doppelganger",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.FLESH, ItemTraitFactory.ASPECTAL,ItemTraitFactory.BONE, ItemTraitFactory.SCARY, ItemTraitFactory.DOOMED],shogunDesc: "The Inferior You",abDesc:"Time is truly the worst aspect."))
      ..add(new Item("Music Box",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ASPECTAL,ItemTraitFactory.MUSICAL,ItemTraitFactory.CLASSY],shogunDesc: "Cube of Noise"))
      ..add(new Item("Sick Turn Tables",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ASPECTAL,ItemTraitFactory.MUSICAL,ItemTraitFactory.LEGENDARY, ItemTraitFactory.COOLK1D],shogunDesc: "Spinning Noise Discs on a Noise Machine",abDesc:"Do they come with ironic raps?"))
      ..add(new Item("Metronome",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ASPECTAL,ItemTraitFactory.MUSICAL],shogunDesc: "Never Ending Ticking Device"));
  }

  Time(int id) :super(id, "Time", isCanon: true);

}

class Void extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Cardboard Box",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING],shogunDesc: "Shoguns Old Home",abDesc:"It's the highest level void item. Except not. It's a box. Asshole."))
      ..add(new Item("Hole Punch",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING],shogunDesc: "Paper Impaler"))
      ..add(new Item("Smoke Bombs",<ItemTrait>[ItemTraitFactory.EXPLODEY, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING,ItemTraitFactory.GRENADE],shogunDesc: "Vape Grenades"))
      ..add(new Item("Tribal Mask",<ItemTrait>[ItemTraitFactory.BONE, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING, ItemTraitFactory.SCARY, ItemTraitFactory.UGLY],shogunDesc: "Ancient Face"))
      ..add(new Item("Opera Mask",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.ASPECTAL,ItemTraitFactory.OBSCURING, ItemTraitFactory.CLASSY],shogunDesc: "Phantom of the Opera Mask"))
      ..add(new Item("Black Hole in a Bottle.",<ItemTrait>[ItemTraitFactory.ASPECTAL,ItemTraitFactory.LEGENDARY, ItemTraitFactory.GREENSUN,ItemTraitFactory.OBSCURING, ItemTraitFactory.GLASS],shogunDesc: "Eternal Suffering in a Jar",abDesc:"Jegus fuck, don't break this."));
  }

  Void(int id) :super(id, "Void", isCanon: true);
}

class Dream extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Dream Diary",<ItemTrait>[ItemTraitFactory.PAPER,ItemTraitFactory.BOOK, ItemTraitFactory.ASPECTAL],shogunDesc: "Tomb of the Writer’s Insecurities and Weaknesses"))
      ..add(new Item("Interlocking Brick",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.CALMING, ItemTraitFactory.BLUNT, ItemTraitFactory.ASPECTAL,ItemTraitFactory.LEGENDARY],shogunDesc: "A Fucking Lego But Legally JR’s Too Much Of A Coward To Say It",abDesc:"Lame. JR didn't want to use a brand name all of a sudden?"))
      ..add(new Item("Art Supplies",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.CALMING, ItemTraitFactory.ASPECTAL],shogunDesc: "The Tools For Smithing Pieces of Art That I Stole From KR"));
  }

  Dream(int id) :super(id, "Dream", isCanon: false);
}

class Sauce extends Aspect {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Uno Reverse Card",<ItemTrait>[ItemTraitFactory.CARD, ItemTraitFactory.ASPECTAL, ItemTraitFactory.FAKE,ItemTraitFactory.SAUCEY]))
      ..add(new Item("JR Body Pillow",<ItemTrait>[ItemTraitFactory.PILLOW, ItemTraitFactory.COMFORTABLE, ItemTraitFactory.ASPECTAL,ItemTraitFactory.SAUCEY]));

  }

  Sauce(int id) :super(id, "Sauce", isInternal: true);
}

class Juice extends Aspect {
  Juice(int id) :super(id, "Juice", isInternal: true); //secret

  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Apple Juice Bottle",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.ASPECTAL,ItemTraitFactory.MAGICAL, ItemTraitFactory.REAL],abDesc:"It's probably science powered.",shogunDesc: "Shitty Wizard Pencil"));
  }
}
