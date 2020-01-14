import 'SBURBSim.dart';

class SBURBClassManager {
  static SBURBClass KNIGHT;
  static SBURBClass SEER;
  static SBURBClass BARD;
  static SBURBClass HEIR;
  static SBURBClass MAID;
  static SBURBClass ROGUE;
  static SBURBClass PAGE;
  static SBURBClass THIEF;
  static SBURBClass SYLPH;
  static SBURBClass PRINCE;
  static SBURBClass WITCH;
  static SBURBClass MAGE;
  static SBURBClass WASTE;
  static SBURBClass SCOUT;
  static SBURBClass SAGE;
  static SBURBClass SCRIBE;
  static SBURBClass GUIDE;
  static SBURBClass GRACE;
  static SBURBClass NULL;
  static SBURBClass MUSE;
  static SBURBClass LORD;
  static SBURBClass SMITH;

  //did you know that static attributes are lazy loaded, and so you can't access them until
  //you interact with the class? Yes, this IS bullshit, thanks for asking!
  static void init() {
    KNIGHT = new Knight();
    SEER = new Seer();
    BARD = new Bard();
    HEIR = new Heir();
    MAID = new Maid();
    ROGUE = new Rogue();
    PAGE = new Page();
    THIEF = new Thief();
    SYLPH = new Sylph();
    PRINCE = new Prince();
    WITCH = new Witch();
    MAGE = new Mage();
    WASTE = new Waste();
    SCOUT = new Scout();
    SCRIBE = new Scribe();
    SAGE = new Sage();
    GUIDE = new Guide();
    GRACE = new Grace();
    MUSE = new Muse();
    LORD = new Lord();
    SMITH = new Smith();

    NULL = new SBURBClass("Null", 255, false, isInternal:true);
  }


  static Map<int, SBURBClass> _classes = <int, SBURBClass>{}; // gets filled by class constrcutor


  static void addClass(SBURBClass c) {
    if (_classes.containsKey(c.id)) {
      throw "Duplicate class id for $c: ${c.id} is already registered for ${_classes[c.id]}.";
    }
    _classes[c.id] = c;
  }

  static Iterable<SBURBClass> get all => _classes.values.where((SBURBClass c) => !c.isInternal);

  static SBURBClass findClassWithID(num id) {
    if (_classes.isEmpty) init();
    if (_classes.containsKey(id)) {
      return _classes[id];
    }
    return NULL; // return the NULL aspect instead of null
  }

  static SBURBClass stringToSBURBClass(String id) {
    if (_classes.isEmpty) init();
    for (SBURBClass c in _classes.values) {
      if (c.name == id) return c;
    }
    return NULL;
  }

  static List<SBURBClass> playersToClasses(List<Player> players) {
    return new List<SBURBClass>.from(players.map((Player p) => p.class_name));
  }

}

//instantiatable for Null classes.
class SBURBClass {

  String name = "Null";
  int id = 256; //for classNameToInt
  bool isCanon = false; //you gotta earn canon, baby.
  bool isInternal = false; //if you're an internal aspect or class you shouldn't show up in lists.

  //for quests and shit, assume canon classes pick ONE of these and fanon can pick two


  //starting items, quest rewards, etc.
  WeightedList<Item> items = new WeightedList<Item>();


  SBURBClass(this.name, this.id, this.isCanon,{ this.isInternal = false}) {
    //;
    initializeItems();
    SBURBClassManager.addClass(this);
  }

  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Perfectly Generic Object",<ItemTrait>[],shogunDesc: "Green Version of Those Sweet Yellow Candies I Loved"));
  }

  @override
  String toString() => this.name;
}

class Bard extends SBURBClass {
  Bard() : super("Bard", 9, true);
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
    //things that let you destroy yourself.
      ..add(new Item("Cod Piece",<ItemTrait>[ItemTraitFactory.CLOTH,ItemTraitFactory.LEGENDARY,ItemTraitFactory.FAKE, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.WOOD],abDesc:"God damn it, MI. "))
      ..add(new Item("Poisoned Candy",<ItemTrait>[ItemTraitFactory.CANDY, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.POISON],shogunDesc: "Not So Sweet Treat",abDesc:"I guess CodTier is okay."))
      ..add(new Item("Cursed Lyre",<ItemTrait>[ItemTraitFactory.DOOMED,ItemTraitFactory.WOOD,ItemTraitFactory.CALMING, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.MUSICAL],shogunDesc: "I Don’t Know What This Is Normally",abDesc:"I guess CodTier is okay. Sort of."))
      ..add(new Item("Snare Trap",<ItemTrait>[ItemTraitFactory.CLOTH,ItemTraitFactory.DOOMED, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.RESTRAINING],shogunDesc: "The Perfect Trap",abDesc:"I guess CodTier is okay. But still. The actual codpiece. You fleshy meatbags and your weird shit."));
  }
}

class Grace extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
    //things that take only a nudge to ruin everything.
      ..add(new Item("How to Teach Your Friends to Hack SBURB",<ItemTrait>[ItemTraitFactory.BOOK, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.PAPER, ItemTraitFactory.LEGENDARY, ItemTraitFactory.SMARTPHONE],abDesc:"Oh sure, it's bad enough that WASTES fuck around in my shit, but at least they somewhat know what they are doing. SURE, let's have GRACES teach the WHOLE FUCKING PARTY to do it."))
      ..add(new Item("Unstable Domino",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.DOOMED],shogunDesc: "Broken Knocker Over Maths Thing",abDesc:"Fucking Graces can't leave well enough alone."))
      ..add(new Item("Exposed Thread",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.DOOMED],shogunDesc: "Indecent String",abDesc:"Fucking Graces can't leave well enough alone."))
      ..add(new Item("Teetering Plate",<ItemTrait>[ItemTraitFactory.PORCELAIN, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.DOOMED],shogunDesc: "Impending Drop Dish",abDesc:"Fucking Graces can't leave well enough alone."));
  }
  Grace() : super("Grace", 17, false);

}

class Guide extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Sherpa Parka",<ItemTrait>[ItemTraitFactory.COLD, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.FUR],abDesc:"Clearly the best class uses this."))
      ..add(new Item("Guide Book",<ItemTrait>[ItemTraitFactory.LEGENDARY, ItemTraitFactory.COLD,ItemTraitFactory.BOOK, ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.SMART],shogunDesc: "Dummies Guide to Shitposting",abDesc:"Clearly the best class uses this."))
      ..add(new Item("Whistle",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.LOUD],shogunDesc: "Loud screeching pipe",abDesc:"Clearly the best class uses this.")) //keep together people we have a lot of attractions to visit
      ..add(new Item("Announcement System",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.ZAP, ItemTraitFactory.SMART],shogunDesc: "Voice Empowering Speaking System",abDesc:"Clearly the best class uses this."));
  }

  Guide() : super("Guide", 16, false);

}

class Heir extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
    //mostly just shitty legal puns on inheritance.
      ..add(new Item("Family Ashes",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.ONFIRE, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.DOOMED, ItemTraitFactory.GHOSTLY],shogunDesc: "Whats Left of Staff",abDesc:"Probably an inheritance or some shit."))
      ..add(new Item("Last Will and Testament",<ItemTrait>[ItemTraitFactory.LEGENDARY,ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.DOOMED, ItemTraitFactory.LEGAL],shogunDesc: "Legal Rights to SBURBSim",abDesc:"Probably an inheritance or some shit."))
      ..add(new Item("Grooming Guide",<ItemTrait>[ItemTraitFactory.BOOK, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.CLASSY],shogunDesc: "I Hope This Is About Animals",abDesc:"Probably an inheritance or some shit."))
      ..add(new Item("Powered Attorney",<ItemTrait>[ItemTraitFactory.COLOSSUS, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.AI, ItemTraitFactory.LEGAL],shogunDesc: "Phoenix Wright 2.0",abDesc:"Believe me, you don't want to be sued by a RoboLawyer."))
      ..add(new Item("Executer's Ax",<ItemTrait>[ItemTraitFactory.AXE, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.EDGED, ItemTraitFactory.LEGAL],shogunDesc: "Handheld Guillotine",abDesc:"Probably an inheritance or some shit."));
  }
  Heir() : super("Heir", 8, true);

}

class Knight extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Shining Armor",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.PLATINUM, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.SHIELD],shogunDesc: "Kyoto Overcoat",abDesc:"Knight Shit"))
      ..add(new Item("Excalibur",<ItemTrait>[ItemTraitFactory.LEGENDARY,ItemTraitFactory.PLATINUM, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.POINTY, ItemTraitFactory.EDGED, ItemTraitFactory.SWORD],shogunDesc: "Masamune",abDesc:"Knight Shit"))
      ..add(new Item("Noble Steed",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.FLESH, ItemTraitFactory.SENTIENT],shogunDesc: "Horse Prime, Envoy of the Ultimate End",abDesc:"Knight Shit"))
      ..add(new Item("Hero's Shield",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.SHIELD, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.PLATINUM],shogunDesc: "A Weaklings Way Out, Shame Upon You",abDesc:"Knight Shit"));
  }
  Knight() : super("Knight", 3, true);

}

class Mage extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Alternate Costume",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.MAGICAL, ItemTraitFactory.LEGENDARY, ItemTraitFactory.OBSCURING],abDesc:"Apparently some people don't like the regular mage outfit? Whatever."))
      ..add(new Item("Mage's Cape",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.MAGICAL],shogunDesc: "Shitty Wizard Cape",abDesc:"Mage Shit"))
      ..add(new Item("Mage's Staff",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BLUNT, ItemTraitFactory.MAGICAL, ItemTraitFactory.STICK],shogunDesc: "Shitty Wizard Stick of Power",abDesc:"Mage Shit"))
      ..add(new Item("Walking Broom",<ItemTrait>[ItemTraitFactory.BROOM,ItemTraitFactory.WOOD, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.SENTIENT,ItemTraitFactory.MAGICAL, ItemTraitFactory.STICK],shogunDesc: "Support Stick of Cleaning",abDesc:"Normally I'd blame Wastes, but walking brooms is more of a Mage thing."));
  }
  Mage() : super("Mage", 2, true);

}

class Maid extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
    //disney princess, house maid, shield maid.
      ..add(new Item("Maiden's Breath",<ItemTrait>[ItemTraitFactory.PLANT, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.PRETTY]))
      ..add(new Item("Feather Duster",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.STICK, ItemTraitFactory.FEATHER],shogunDesc: "Maids Weapon of Choice",abDesc:"Housemaid shit."))
      ..add(new Item("Valkyrie Shield",<ItemTrait>[ItemTraitFactory.PRETTY,ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.LEGENDARY, ItemTraitFactory.SHIELD,ItemTraitFactory.ADAMANTIUM],shogunDesc: "Another Weakling Piece of Metal But For Some Kind of Angel Woman I Guess?",abDesc:"Shieldmaid shit"))
      ..add(new Item("Maiden's Songbook",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.MUSICAL,ItemTraitFactory.BOOK],shogunDesc: "Smash Mouth Lyrics",abDesc:"Longing maiden shit."));

  }
  Maid() : super("Maid", 0, true);

}

class Page extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Shorts",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BESPOKE,ItemTraitFactory.LEGENDARY],shogunDesc: "Crotch Hugging Thigh Exposers. Absolutely Indecent.",abDesc:"Don't skip leg day."))
      ..add(new Item("Sidekick Figurine",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.COOLK1D],shogunDesc: "Small Statue of a White Headed Cat in a Green Suit",abDesc:"Robin is way cooler than Batman."))
      ..add(new Item("Steroids",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.MAGICAL],shogunDesc: "My Morning Medication",abDesc:"Shit son, calm down with all the screaming and the powering up."));
  }
  Page() : super("Page", 1, true);
}

class Prince extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Feather'd Cap",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BESPOKE],shogunDesc: "Pupa Pan Hat",abDesc:"So fucking pretentious."))
      ..add(new Item("Crown",<ItemTrait>[ItemTraitFactory.LEGENDARY,ItemTraitFactory.GOLDEN, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BESPOKE],shogunDesc: "A False Symbol of Power",abDesc:"Prince shit. Man. The tiara dealy."))
      ..add(new Item("Gunpowder",<ItemTrait>[ItemTraitFactory.EXPLODEY, ItemTraitFactory.CLASSRELATED],shogunDesc: "The Best Thing since The Shogun",abDesc:"Huh. I guess cause princes are destructive."));
  }

  Prince() : super("Prince", 10, true);
}

class Rogue extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Domino Mask",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BESPOKE],shogunDesc: "This Scares Me On A Primal Level",abDesc:"Not satisfied with the god tier shit I guess."))
      ..add(new Item("Archery Set",<ItemTrait>[ItemTraitFactory.BOW, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BESPOKE, ItemTraitFactory.ARROW],shogunDesc: "This Is Number 69 On The List I Dont Need To Make An Equius Joke",abDesc:"Like robin hood and shit."))
      ..add(new Item("Gristtorrent Server",<ItemTrait>[ItemTraitFactory.LEGENDARY,ItemTraitFactory.PLASTIC,ItemTraitFactory.ZAP, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.SMART, ItemTraitFactory.OBSCURING],shogunDesc: "Shogun Coin Printer. Illegal Item.",abDesc:"Steal from the rich, give to the poor."));
  }

  Rogue() : super("Rogue", 4, true);

}

class Sage extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Sage's Robe",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.COMFORTABLE,ItemTraitFactory.SMART, ItemTraitFactory.MAGICAL, ItemTraitFactory.LEGENDARY],shogunDesc: "Pompous Asshole Robes",abDesc:"So sagey. Needs a beard or some shit, though."))
      ..add(new Item("Peer Reviewed Journal",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BOOK, ItemTraitFactory.SMART],shogunDesc: "Book Containing More Corrections Than Actual Content",abDesc:"I guess this is p well reviewed."))
      ..add(new Item("Guru Pillow",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.PILLOW, ItemTraitFactory.SMART],shogunDesc: "Headrest For Smart People",abDesc:"Huh. What. Was JR thinking. When they made this item?")); //JR: I have no fucking clue.
  }
  Sage() : super("Sage", 14, false);
}

class Scout extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Walking Stick",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.STICK],shogunDesc: "Support Stick of Old And Injured",abDesc:"I guess it helps scouts walk for long periods of time? And not let anybody catch up."))
      ..add(new Item("Adorable Girlscout Beret",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.FASHIONABLE, ItemTraitFactory.SMART, ItemTraitFactory.LEGENDARY],shogunDesc: "ABJs Hat",abDesc:"Okay, legit, ABJ's hat is amazing."))
      ..add(new Item("Map",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.SMART],shogunDesc: "Kyoto Overcoats Spacemap",abDesc:"I guess Scouts update this on their own? Untread ground and all."))
      ..add(new Item("Magical Compass",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.SMART, ItemTraitFactory.MAGICAL],shogunDesc: "Shoguns Navigation Box",abDesc:"Magnets man, how do they work."));
  }
  Scout() : super("Scout", 13, false);

}

class Scribe extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Scroll",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.SMART],shogunDesc: "Rolled Up Picture of JR",abDesc:"Scribe Shit"))
      ..add(new Item("Ink Pot",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.OBSCURING, ItemTraitFactory.SMART],shogunDesc: "Black Liquid That Tastes Awful",abDesc:"You could probably censor shit with this."))
      ..add(new Item("Blank Book",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BOOK, ItemTraitFactory.SMART, ItemTraitFactory.OBSCURING,ItemTraitFactory.LEGENDARY],shogunDesc: "Dick Drawing Practice Apparatus",abDesc:"Fill it in yourself I guess."));
  }
  Scribe() : super("Scribe", 15, false);
}

class Seer extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Cueball",<ItemTrait>[ItemTraitFactory.CUEBALL, ItemTraitFactory.CLASSRELATED],shogunDesc: "A Worthless White Ball",abDesc:"Don't listen to this asshole."))
      ..add(new Item("Crystal Ball",<ItemTrait>[ItemTraitFactory.BALL,ItemTraitFactory.CRYSTALBALL, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.GLOWING],shogunDesc: "A Worthless Clear Ball",abDesc:"Seer shit."))
      ..add(new Item("Binoculars",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.METAL],shogunDesc: "Long Distance Perversion Apparatus",abDesc:"Seer shit."))
      ..add(new Item("Blindfold",<ItemTrait>[ItemTraitFactory.BLINDFOLDED, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.COMFORTABLE],shogunDesc: "Long Distance Perversion Apparatus",abDesc:"May as well skip the whole 'going blind' part of the deal."));
  }
  Seer() : super("Seer", 6, true);

}

class Sylph extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Meddler's Guide",<ItemTrait>[ItemTraitFactory.BOOK, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.PAPER, ItemTraitFactory.ENRAGING,ItemTraitFactory.LEGENDARY,ItemTraitFactory.HEALING],abDesc:"Meddling meddlers gotta meddle. "))
      ..add(new Item("First Aid Kit",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.HEALING],shogunDesc: "Anti-Pain Box",abDesc:"Heals here."))
      ..add(new Item("Cloud in a Bottle",<ItemTrait>[ItemTraitFactory.CLASSRELATED, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.CALMING],shogunDesc: "Fart In a Jar",abDesc:"Fucking sylphs man. How do they work?"))
      ..add(new Item("Fairy Wings",<ItemTrait>[ItemTraitFactory.MAGICAL, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.GLOWING, ItemTraitFactory.PRETTY, ItemTraitFactory.PAPER],shogunDesc: "Wings Cut Straight From a God Tier Troll", abDesc: "I GUESS Sylphs in myths are kinda fairy shit, right?"));
  }
  Sylph() : super("Sylph", 5, true);

}

class Smith extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Meddler's Guide",<ItemTrait>[ItemTraitFactory.BOOK, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.PAPER, ItemTraitFactory.ENRAGING,ItemTraitFactory.LEGENDARY,ItemTraitFactory.HEALING],abDesc:"Meddling meddlers gotta meddle. "))
      ..add(new Item("First Aid Kit",<ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.HEALING],shogunDesc: "Anti-Pain Box",abDesc:"Heals here."))
      ..add(new Item("Cloud in a Bottle",<ItemTrait>[ItemTraitFactory.CLASSRELATED, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.CALMING],shogunDesc: "Fart In a Jar",abDesc:"Fucking sylphs man. How do they work?"))
      ..add(new Item("Fairy Wings",<ItemTrait>[ItemTraitFactory.MAGICAL, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.GLOWING, ItemTraitFactory.PRETTY, ItemTraitFactory.PAPER],shogunDesc: "Wings Cut Straight From a God Tier Troll", abDesc: "I GUESS Sylphs in myths are kinda fairy shit, right?"));
  }

  Smith() : super("Smith", 20, false);

}

class Thief extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Lockpick",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.OBSCURING, ItemTraitFactory.POINTY,ItemTraitFactory.LEGENDARY],shogunDesc: "Anti-Lock Dagger",abDesc:"No matter what, you'll always have at least one.")) //like katia.
      ..add(new Item("Sneaking Suit",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.OBSCURING],shogunDesc: "Full Body Latex Suit",abDesc:"God. Why is Snake's outfit really called this. So dumb.")) //snake knows what it's about
      ..add(new Item("Thief's Dagger",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.POINTY, ItemTraitFactory.EDGED, ItemTraitFactory.DAGGER],shogunDesc: "Stabbing Contraption",abDesc:"For when you wanna show 'em your stabs, I guess."));
  }

  Thief() : super("Thief", 7, true);

}

class Waste extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Yardstick",<ItemTrait>[ItemTraitFactory.STICK, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.PLYWOOD, ItemTraitFactory.LEGENDARY],abDesc:"Wait. Did you beat LORAS?"))
      ..add(new Item("SBURBSim Hacking Guide",<ItemTrait>[ItemTraitFactory.BOOK, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.SMARTPHONE,ItemTraitFactory.PAPER],shogunDesc: "The Shoguns Guide to Winning",abDesc:"Hell no, you leave your grubby fucking mitts outta the code."))
      ..add(new Item("Body Pillow of JR",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.PILLOW, ItemTraitFactory.IRONICSHITTYFUNNY, ItemTraitFactory.COMFORTABLE,ItemTraitFactory.SAUCEY],shogunDesc: "The Shoguns Vessel",abDesc:"...I would ask why, but I already calculated all possible responses at a million times the speed I could get an answer."))
      ..add(new Item("Nanobots",<ItemTrait>[ItemTraitFactory.ROBOTIC2, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.AI],shogunDesc: "NANOMACHINES SON, THEY HARDEN IN RESPONSE TO PHYSICAL TRAUMA",abDesc:"Oh look, a NON hacking way to fuck everything up, forever."));
  }
  Waste() : super("Waste", 12, false);

}

class Witch extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Cauldron",<ItemTrait>[ItemTraitFactory.LEAD, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.MAGICAL],shogunDesc: "Bell But For Liquids",abDesc:"Surprisingly literal."))
      ..add(new Item("Flying Broom",<ItemTrait>[ItemTraitFactory.BROOM,ItemTraitFactory.STICK, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.WOOD,ItemTraitFactory.MAGICAL],shogunDesc: "Bell But For Liquids",abDesc:"WHY ARE THERE SO MANY FUCKING BROOMS IN THIS GAME."))
      ..add(new Item("Warped Mirror",<ItemTrait>[ItemTraitFactory.MIRROR, ItemTraitFactory.CLASSRELATED,ItemTraitFactory.MAGICAL, ItemTraitFactory.OBSCURING, ItemTraitFactory.LEGENDARY],shogunDesc: "Mirror from The Shoguns Dresser",abDesc:"I guess Witches warp shit and stuff."));
  }
  Witch() : super("Witch", 11, true);

}

class Muse extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Feather Pen",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.CLASSY, ItemTraitFactory.FEATHER],shogunDesc: "Feather Object to be Dipped in Black Liquid",abDesc:"Oh my god, did JR really not know how to spell 'Quill'?"))
      ..add(new Item("Half Finished Bust of Snoop Dog",<ItemTrait>[ItemTraitFactory.MARBLE, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.BUST, ItemTraitFactory.BLUNT, ItemTraitFactory.LEGENDARY],shogunDesc: "The Gods Refused to Let This Object Finish Completion",abDesc:"Meme Shit"))
      ..add(new Item("Book of Poetry",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.CLASSY, ItemTraitFactory.BOOK],shogunDesc: "Ocean Man Lyrics 50,000 Times: The Book",abDesc:"Hope it inspires you."));
  }
  Muse() : super("Muse", 18, false);
}

class Lord extends SBURBClass {
  @override
  void initializeItems() {
    items = new WeightedList<Item>()

      ..add(new Item("Deck of Uno Cards",<ItemTrait>[ItemTraitFactory.CARD, ItemTraitFactory.PLYWOOD, ItemTraitFactory.CLASSY],shogunDesc: "Shoguns Card",abDesc:"Some kind of memey bullshit."))
      ..add(new Item("Lord's Cape",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.CLASSY],shogunDesc: "Shoguns Cape",abDesc:"Lord Shit"))
      ..add(new Item("Drawing Tablet",<ItemTrait>[ItemTraitFactory.SMARTPHONE, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.CLASSY],shogunDesc: "Shitpost Etching Table",abDesc:"Have fun drawing grids."))
      ..add(new Item("How to Make Friends And Influence People",<ItemTrait>[ItemTraitFactory.LEGENDARY,ItemTraitFactory.PAPER, ItemTraitFactory.CLASSRELATED, ItemTraitFactory.ENRAGING, ItemTraitFactory.BOOK],shogunDesc: "Book for Nerds",abDesc:"Good luck with that. You'll need it, asshole."));
  }
  Lord() : super("Lord", 19, false);

}