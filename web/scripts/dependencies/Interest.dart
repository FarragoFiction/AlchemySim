import 'SBURBSim.dart';
class InterestManager {

  static Map<int, InterestCategory> _categories = <int, InterestCategory>{};

  static InterestCategory MUSIC;
  static InterestCategory ACADEMIC;
  static InterestCategory ATHLETIC;
  static InterestCategory COMEDY;
  static InterestCategory CULTURE;
  static InterestCategory DOMESTIC;
  static InterestCategory FANTASY;
  static InterestCategory JUSTICE;
  static InterestCategory POPCULTURE;
  static InterestCategory ROMANTIC;
  static InterestCategory SOCIAL;
  static InterestCategory TECHNOLOGY;
  static InterestCategory TERRIBLE;
  static InterestCategory WRITING;
  static InterestCategory NULL;

  static void init() {
    //;
    MUSIC = new Music();
    ACADEMIC = new Academic();
    ATHLETIC = new Athletic();
    COMEDY = new Comedy();
    CULTURE = new Culture();
    DOMESTIC = new Domestic();
    FANTASY = new Fantasy();
    JUSTICE = new Justice();
    POPCULTURE = new PopCulture();
    ROMANTIC = new Romantic();
    SOCIAL = new Social();
    TERRIBLE = new Terrible();
    WRITING = new Writing();
    TECHNOLOGY = new Technology();
    NULL = new InterestCategory(-13, "Null", "","",true); //shouldn't ever happen.
  }

  static void register(InterestCategory ic) {
    if (_categories.containsKey(ic.id)) {
      throw "Duplicate aspect id for $ic: ${ic
          .id} is already registered for ${_categories[ic.id]}.";
    }
    _categories[ic.id] = ic;
  }

  static InterestCategory get(int id) {
    if (_categories.isEmpty) init();
    if (_categories.containsKey(id)) {
      return _categories[id];
    }
    throw "ERROR: could not find interest category $id  and null is not supported. I have ${_categories
        .length} categories";
  }

  static InterestCategory getByName(String name) {
    if (_categories.isEmpty) init();
    for (InterestCategory ic in _categories.values) {
      if (ic.name == name) {
        return ic;
      }
    }
    throw "ERROR: could not find interest category $name and null is not supported. I have ${_categories
        .length} categories";
  }

  static Interest getRandomInterest(Random rand) {
    return new Interest.randomFromCategory(
        rand, rand.pickFrom(allCategories)); //need to have internal filtering
  }

  static Iterable<InterestCategory> get allCategories => _categories.values.where((InterestCategory c) => !c.isInternal);

  static InterestCategory getCategoryFromString(String s) {
    for (InterestCategory c in _categories.values) {
      if (c.name == s) return c;
    }
    return null;
  }
}

class InterestCategory {
  bool isInternal = false;
  List<String> handles1 = <String>["nobody"];
  List<AssociatedStat> stats = new List<AssociatedStat>.unmodifiable(<AssociatedStat>[]);
  List<String> handles2 = <String>["Nobody"];
  List<String> levels = <String>["Nobody"];
  int id;

  //this is what char creator should modify. making it private meant that children apparently couldn't override it. i guess i want protected, but does dart even have that?
  List<String> interestStrings = ["NONE"];
  //starting items, quest rewards, etc.
  WeightedList<Item> items = new WeightedList<Item>();

  String negative_descriptor;
  String positive_descriptor;
  String name;

  //p much no vars to set.
  InterestCategory(this.id, this.name, this.positive_descriptor, this.negative_descriptor, [this.isInternal = false]) {
    initializeItems();
    InterestManager.register(this);
  }

  void initializeItems() {
    items = new WeightedList<Item>()
      ..add(new Item("Perfectly Generic Object",<ItemTrait>[],shogunDesc: "The Third Entry for This Fucking Block"));
  }


  //clunky name to remind me that modding this does nothing
  List<String> get copyOfInterestStrings =>
      new List<String>.from(interestStrings);

  //interests are auto sanitized.
  void addInterest(String i) {
    ////;
    if (interestStrings.contains(i)) return;
    ////;
    interestStrings.add(
        i.replaceAll(new RegExp(r"""<(?:.|\n)*?>""", multiLine: true), ''));
  }

  @override
  String toString() => this.name;
}

/*
    Intrests are created programatically, from string list in interest category
 */
class Interest {
  InterestCategory category;
  String name;

  Interest(this.name, this.category) {
    //since the interest has the category in it, this is good enough.
    //it's okay if the category doesn't have a list of all interests
    //but for char creator want new interests to be in the drop downs.
    this.category.addInterest(
        this.name); //the method will make sure no duplicates.
    print(category.items);
  }

  Interest.randomFromCategory(Random rand, InterestCategory category){
    String s = "";
    this.category = category;
    this.name = s;
    print(category.items);
  }
}





class Music extends InterestCategory {
  Music() :super(1, "Music", "musical", "loud");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Piano",<ItemTrait>[ItemTraitFactory.BLUNT, ItemTraitFactory.WOOD, ItemTraitFactory.MUSICAL, ItemTraitFactory.CLASSY],shogunDesc: "Elephant Corpse Turned Amazing Instrument",abDesc:"An entire piano. In your inventory. WHY."))
      ..add(new Item("Flute",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.MUSICAL],shogunDesc: "Pipe of Screeches 2: Orchestral Shitstorm",abDesc:"I feel like a spaceship captain should play this."))
      ..add(new Item("Microphone",<ItemTrait>[ItemTraitFactory.LOUD, ItemTraitFactory.ZAP],shogunDesc: "Speaking Tube of Passion +3",abDesc:"Do you really deserve to drop this like it's hot?"))
      ..add(new Item("Violin",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.MUSICAL],shogunDesc: "Tiny Cello"))
      ..add(new Item("Sheet Music",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.MUSICAL],shogunDesc: "Cheat Codes for Instruments"))
      ..add(new Item("Electric Guitar",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.MUSICAL, ItemTraitFactory.ZAP, ItemTraitFactory.LOUD, ItemTraitFactory.COOLK1D],shogunDesc: "Electrical Stringed Music Maker"))
      ..add(new Item("Turn Tables",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.MUSICAL, ItemTraitFactory.ZAP, ItemTraitFactory.COOLK1D],shogunDesc: "Spinning Disc Sound Maker"))
      ..add(new Item("Guitar",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.MUSICAL],shogunDesc: "String Music Maker"));
    print(items);
  }
}

class Academic extends InterestCategory {
  Academic() :super(13, "Academic", "smart", "nerdy");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Math Book",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.SMART, ItemTraitFactory.BOOK],shogunDesc: "Big Book of Speaking Low Nerd",abDesc:"Unlike JR, Robots have no fear of Math."))
      ..add(new Item("Giant Map",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.SMART],shogunDesc: "Map to Staffs HQ"))
      ..add(new Item("Microscope",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.SMART, ItemTraitFactory.GLASS],shogunDesc: "Viewing Apparatus for Microscopic Perversion"))
      ..add(new Item("Star Chart",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.SMART],shogunDesc: "Cosmic Dot-to-Dot"))
      ..add(new Item("History Book",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.SMART],shogunDesc: "Homestuck Anthology"))
      ..add(new Item("Radioactive Rock",<ItemTrait>[ItemTraitFactory.NUCLEAR, ItemTraitFactory.STONE],shogunDesc: "Shoguns Petrified Hate",abDesc:"Why the fuck do you have this?"))
      ..add(new Item("Compass",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.SMART],shogunDesc: "Navigation Box"));
    print(items);
  }

}

class Athletic extends InterestCategory {
  Athletic() :super(4, "Athletic", "athletic", "dumb");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Barbells",<ItemTrait>[ItemTraitFactory.BLUNT, ItemTraitFactory.HEAVY, ItemTraitFactory.METAL],shogunDesc: "Strength Building Metal"))
      ..add(new Item("Basketball",<ItemTrait>[ItemTraitFactory.BALL, ItemTraitFactory.RUBBER],shogunDesc: "Dunksphere"))
      ..add(new Item("Baseball Bat",<ItemTrait>[ItemTraitFactory.CLUB, ItemTraitFactory.WOOD],shogunDesc: "Wooden Pole of Bone Hurting"))
      ..add(new Item("Rubber Ball",<ItemTrait>[ItemTraitFactory.BALL, ItemTraitFactory.RUBBER],shogunDesc: "Dead Animal Corpse Ball"))
      ..add(new Item("Megaphone",<ItemTrait>[ItemTraitFactory.LOUD, ItemTraitFactory.ZAP],shogunDesc: "Handheld Voice Empowerer",abDesc:"Let's you be a loud asshole instead of a regular asshole."))
      ..add(new Item("Hockey Stick",<ItemTrait>[ItemTraitFactory.CLUB, ItemTraitFactory.WOOD, ItemTraitFactory.STICK],shogunDesc: "L Shaped Bone Hurter"))
      ..add(new Item("Trophy",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.VALUABLE],shogunDesc: "Award for Best At Shitposting",abDesc:"Huh. What could you posibly have won. Ever."))
      ..add(new Item("Boxing Glove",<ItemTrait>[ItemTraitFactory.FIST, ItemTraitFactory.RUBBER],shogunDesc: "Fist Reinforcing Pain Cubes"))
      ..add(new Item("Yoga Mat",<ItemTrait>[ItemTraitFactory.RUBBER, ItemTraitFactory.COMFORTABLE],shogunDesc: "Flesh Rubberising Practice Mat"));
    print(items);
  }
}

class Comedy extends InterestCategory {
  Comedy() : super(0, "Comedy", "funny", "dorky");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Colonel Sassacre's Daunting Text ", <ItemTrait>[
        ItemTraitFactory.PAPER,
        ItemTraitFactory.BLUNT,
        ItemTraitFactory.FUNNY,
        ItemTraitFactory.HEAVY
      ], shogunDesc: "Life Story of the Only Good Mortal",
          abDesc: "Probably heavy enough to kill a cat."))..add(new Item(
          "Wise Guy Book",
          <ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.FUNNY],
          shogunDesc: "How To Shittalk For Fucking Dumbasses"))..add(new Item(
          "Beagle Puss",
          <ItemTrait>[ItemTraitFactory.GLASS, ItemTraitFactory.FUNNY],
          shogunDesc: "The Name Makes it Impossible For Me To Name Its So Fucking Funny",
          abDesc: "Does...does this really fool flesh bags like you?"))..add(
          new Item("Novelty Microphone", <ItemTrait>[
            ItemTraitFactory.LOUD,
            ItemTraitFactory.ZAP,
            ItemTraitFactory.FUNNY
          ], shogunDesc: "Meme Voice Enloudener Tube",
              abDesc: "Oh look, it makes you sound like a robot. Hilarious."))..add(
          new Item("Banana",
              <ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.FUNNY],
              shogunDesc: "Phallic Fruit",
              abDesc: "Truly the pinacle of fruit based comedy."))..add(
          new Item("Fake Flower",
              <ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.FUNNY],
              shogunDesc: "Flower that smells like Plastic"))..add(new Item(
          "Trick Handcuffs",
          <ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.FUNNY],
          shogunDesc: "Pink Fluffy Handcuffs",
          abDesc: "What is the fucking point of handcuffs you can escape."));
    print(items);
  }
}

class Culture extends InterestCategory {
  Culture() :super(2, "Culture", "cultured", "pretentious");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Can of Spray Paint",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.METAL],shogunDesc: "Wall Dick Drawing Apparatus"))
      ..add(new Item("Sensible Chuckles Magazine",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSY,ItemTraitFactory.FUNNY,ItemTraitFactory.BOOK],shogunDesc: "Meme Gif Magazine",abDesc:"Stoic faced asshole."))

      ..add(new Item("Gentleman's Razor",<ItemTrait>[ItemTraitFactory.RAZOR, ItemTraitFactory.METAL,ItemTraitFactory.EDGED],shogunDesc: "Face Cutting Hair Remover"))
      ..add(new Item("How To Draw Manga",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSY, ItemTraitFactory.BOOK],shogunDesc: "Absolutely Shit Book",abDesc:"Who is this on the cover. The Goddess of Manga or some shit?"))
      ..add(new Item("Painting of a Horse Boxing a Football Player",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.COOLK1D, ItemTraitFactory.PAPER],shogunDesc: "A Man Spent Money To Actually Own This Fucking Thing",abDesc:"Truly the highest of art."))
      ..add(new Item("Collection of Classical Works",<ItemTrait>[ItemTraitFactory.CLASSY, ItemTraitFactory.PAPER],shogunDesc: "Book of Naked Renaissance People"))
      ..add(new Item("Documentary on Horses",<ItemTrait>[ItemTraitFactory.CLASSY, ItemTraitFactory.PLASTIC, ItemTraitFactory.COOLK1D],shogunDesc: "Prime Horse: The Movie: The Book: The Remake"))
      ..add(new Item("Paint Set",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.CLASSY],shogunDesc: "Pain Drink Set"))
      ..add(new Item("Shaving Cream",<ItemTrait>[ItemTraitFactory.ONFIRE, ItemTraitFactory.CLASSY, ItemTraitFactory.METAL],shogunDesc: "Foamy Bad Tasting Marshmallow Fluff"))
      ..add(new Item("Classy Suit",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.CLASSY],shogunDesc: "Georgio Armani Suit"))
      ..add(new Item("The Fatherly Gent's Shaving Almanac ",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSY, ItemTraitFactory.BOOK],shogunDesc: "Book on Razors and Shit (what dumbass would want this?)",abDesc:"Ugh. Flesh bags and their constant hair growth."));
    print(items);
  }
}

class Domestic extends InterestCategory {
  Domestic() :super(8, "Domestic", "domestic", "boring");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Trendy Fabric",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.CLOTH],shogunDesc: "Weird Tasting Candy Paper"))
      ..add(new Item("Necklace",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.GOLDEN, ItemTraitFactory.CHAIN],shogunDesc: "Nasty Candy Necklace"))
      ..add(new Item("Sewing Needle",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.NEEDLE, ItemTraitFactory.POINTY],shogunDesc: "Cloth Stabbing Knife"))
      ..add(new Item("Broom",<ItemTrait>[ItemTraitFactory.BROOM, ItemTraitFactory.WOOD,ItemTraitFactory.BLUNT,ItemTraitFactory.BROOM,],shogunDesc: "Doctor Beating Staff",abDesc:"Fucking. Wastes."))
      ..add(new Item("Rolling Pin",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.ROLLINGPIN,ItemTraitFactory.BLUNT],shogunDesc: "Babushkas Punishment Pole"))
      ..add(new Item("Velvet Pillow",<ItemTrait>[ItemTraitFactory.CLOTH,ItemTraitFactory.COMFORTABLE, ItemTraitFactory.CALMING,ItemTraitFactory.PRETTY, ItemTraitFactory.PILLOW],shogunDesc: "Seductive Head Rest",abDesc:"Pretty good if you need to be calmed down, I hear."))
      ..add(new Item("Yarn Ball",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.CLOTH],shogunDesc: "Cats Plaything"))
      ..add(new Item("Refrigerator",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.HEAVY, ItemTraitFactory.METAL, ItemTraitFactory.COLD],shogunDesc: "Food Hardening Box"))
      ..add(new Item("Photo Album",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.PAPER],shogunDesc: "Memory Book"))
      ..add(new Item("Ice Cubes",<ItemTrait>[ItemTraitFactory.COLD],shogunDesc: "Hard Water"))
      ..add(new Item("Cast Iron Skillet",<ItemTrait>[ItemTraitFactory.METAL,ItemTraitFactory.ONFIRE,ItemTraitFactory.BLUNT, ItemTraitFactory.HEAVY,ItemTraitFactory.FRYINGPAN ],shogunDesc: "Fancy Unstoppable Weapon"))
      ..add(new Item("Failed Dish",<ItemTrait>[ItemTraitFactory.POISON],shogunDesc: "Culinary Perfection",abDesc:"Wow you suck at cooking.")) //this is ALSO a refrance. but to what?
      ..add(new Item("Dr Pepper BBQ Sauce",<ItemTrait>[ItemTraitFactory.POISON, ItemTraitFactory.SAUCEY],shogunDesc: "Culinary Perfection",abDesc:"Gross.")) //this is ALSO also a refrance. but to what?
      ..add(new Item("Apple Juice",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.CANDY],shogunDesc: "Culinary Perfection",abDesc:"Gross.")) //this is ALSO also a refrance. but to what?
      ..add(new Item("Apple Sauce",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.CANDY],shogunDesc: "Culinary Perfection",abDesc:"Gross.")) //this is ALSO also a refrance. but to what?
      ..add(new Item("Potted Plant",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.CERAMIC, ItemTraitFactory.PLANT],shogunDesc: "Imprisoned Flora, Trapped in Clay for its Sins"))
      ..add(new Item("Chicken Leg",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.FLESH, ItemTraitFactory.BONE],shogunDesc: "Thicc Chicken"))
      ..add(new Item("Juicy Steak",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.FLESH],shogunDesc: "Juicy Cow Flesh"))
      ..add(new Item("Wedding Cake",<ItemTrait>[ItemTraitFactory.PRETTY, ItemTraitFactory.EDIBLE, ItemTraitFactory.HEALING],shogunDesc: "The Only Benefit of a Wedding"));
    print(items);
  }
}

class Fantasy extends InterestCategory {
  Fantasy() :super(7, "Fantasy", "imaginative", "whimpy");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Fluthulu Poster",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.COMFORTABLE, ItemTraitFactory.SCARY, ItemTraitFactory.CORRUPT],shogunDesc: "The Next Target Poster",abDesc:"No. Fuck you. Don't alchemize this."))
      ..add(new Item("Scalemate",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.COMFORTABLE, ItemTraitFactory.SCARY],shogunDesc: "Target Practice Plush",abDesc:"Senator Lemonsnout's treachery knows no bounds."))
      ..add(new Item("Replica Bone Shield",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.PLASTIC,ItemTraitFactory.BONE, ItemTraitFactory.SHIELD, ItemTraitFactory.FAKE],shogunDesc: "Weaklings Fake Gear made of Dynamo Flesh",abDesc:"Something, something, Bonezerker."))
      ..add(new Item("Replica Ice Sword",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.ICE, ItemTraitFactory.SWORD, ItemTraitFactory.FAKE],shogunDesc: "Fake Hard Water Long Stabber"))
      ..add(new Item("Zombie Mask",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.UGLY, ItemTraitFactory.FLESH, ItemTraitFactory.SCARY],shogunDesc: "Dead Face"))
      ..add(new Item("Vampire Romance Novel",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER, ItemTraitFactory.ROMANTIC, ItemTraitFactory.SCARY],shogunDesc: "Fireplace Fodder Literature",abDesc:"Or, you know, Rainbow Drinkers, if you're fucking civilized."))
      ..add(new Item("Wizardy Herbert",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.MAGICAL, ItemTraitFactory.BLUNT],shogunDesc: "Shitty Wizard Object"))
      ..add(new Item("Complacency of the Learned",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.MAGICAL, ItemTraitFactory.BLUNT],shogunDesc: "Tome of Shitty Wizards",abDesc:"I hear it's an elaborate metaphor for something."))
      ..add(new Item("Grimoire for Summoning the Zoologically Dubious ",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.MAGICAL,ItemTraitFactory.UGLY,ItemTraitFactory.SCARY,ItemTraitFactory.CORRUPT],shogunDesc: "Shoguns Hitlist of HorrorTerrors",abDesc:"Not even kidding, throw this into the Furthest Ring and never look back."))
      ..add(new Item("Wizard Statue",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.STONE, ItemTraitFactory.MAGICAL, ItemTraitFactory.BLUNT, ItemTraitFactory.FAKE],shogunDesc: "Petrified Shitty Wizard",abDesc:"Suprisingly magical, given that magic is a fake thing."))
      ..add(new Item("Mermaid Fountain",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.CRYSTAL,ItemTraitFactory.MAGICAL, ItemTraitFactory.BLUNT, ItemTraitFactory.FAKE],shogunDesc: "Water Spitting Fish Woman Statue"));
    print(items);
  }
}

class Justice extends InterestCategory {
  Justice() :super(6, "Justice", "fair-minded", "harsh");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Gavel",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.HAMMER],shogunDesc: "Tiny Whacky Smacky Skull Cracky of Justice"))
      ..add(new Item("Caution Tape",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.RESTRAINING],shogunDesc: "Impassible Barrier"))
      ..add(new Item("Deerstalker Hat",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.PRETTY],shogunDesc: "Horns but not Troll Horns put on a Hat",abDesc:"Sherlock Holmes has nothing on Detectron 3000."))
      ..add(new Item("Mystery Novel",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.BOOK],shogunDesc: "Book where the Criminal was the Janitor"))
      ..add(new Item("Dish Served Cold",<ItemTrait>[ItemTraitFactory.CERAMIC, ItemTraitFactory.EDIBLE, ItemTraitFactory.COLD],shogunDesc: "REVENGE"))
      ..add(new Item("Pony Pals: Detective Pony ",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.BOOK, ItemTraitFactory.COOLK1D],shogunDesc: "A Disgusting Book",abDesc:"Truly the most ironic work of all time."))
      ..add(new Item("Handcuffs",<ItemTrait>[ItemTraitFactory.UNCOMFORTABLE,ItemTraitFactory.METAL, ItemTraitFactory.RESTRAINING],shogunDesc: "Wrist Imprisoning Device",abDesc:"These ones aren't fucking pointless like those trick ones."));
    print(items);
  }
}

class PopCulture extends InterestCategory {
  PopCulture() :super(9, "PopCulture", "geeky", "frivolous");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Superhero Action Figure",<ItemTrait>[ItemTraitFactory.PLASTIC, ItemTraitFactory.COOLK1D, ItemTraitFactory.FAKE],shogunDesc: "Shogun Action Figure",abDesc:"How perfectly fucking generic. You couldn't even pick a brand name?"))
      ..add(new Item("Action DVD",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.COOLK1D],shogunDesc: "Shogun The Movie"))
      ..add(new Item("Ghost Busters DVD",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.GHOSTLY],shogunDesc: "Shogunsprite Hunters The Movie", abDesc:  "I refuse to call a bunch of washed up comedians."))
      ..add(new Item("Snow Dogs DVD",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.FUNNY, ItemTraitFactory.COLD, ItemTraitFactory.FUR],shogunDesc: "Snow Buddies Anthology"))
      ..add(new Item("Skateboarding Video Game",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.COOLK1D],shogunDesc: "Snow Buddies Anthology",abDesc:"All of these glitches are offensive to my robo-sensbilities."))
      ..add(new Item("Apple Juice",<ItemTrait>[ItemTraitFactory.EDIBLE, ItemTraitFactory.CANDY],shogunDesc: "Culinary Perfection",abDesc:"Gross.")) //this is ALSO also a refrance. but to what?
      ..add(new Item("Movie Poster",<ItemTrait>[ItemTraitFactory.PAPER,ItemTraitFactory.COOLK1D],shogunDesc: "Shogun 2: Electric Shitstorm Poster"))
      ..add(new Item("Audrey II Plush",<ItemTrait>[ItemTraitFactory.PLANT,ItemTraitFactory.COOLK1D,ItemTraitFactory.CLOTH, ItemTraitFactory.SENTIENT],shogunDesc: "World Eating Plant Plush, A Pure Entity"))
      ..add(new Item("Peashooter Toy",<ItemTrait>[ItemTraitFactory.PLANT,ItemTraitFactory.SHOOTY,ItemTraitFactory.COOLK1D, ItemTraitFactory.CLOTH],shogunDesc: "Plants Vs Zombies Peaplant Plush"))
      ..add(new Item("Shitty Sword",<ItemTrait>[ItemTraitFactory.FAKE,ItemTraitFactory.METAL,ItemTraitFactory.COOLK1D, ItemTraitFactory.SWORD, ItemTraitFactory.EDGED, ItemTraitFactory.SHITTY],shogunDesc: "Perfect Weapon",abDesc:"So. Shitty."))
      ..add(new Item("GameBro Magazine",<ItemTrait>[ItemTraitFactory.PAPER,ItemTraitFactory.COOLK1D],abDesc:"5/5 hats.",shogunDesc: "Nerd Magazine"))
      ..add(new Item("GameGrl Magazine",<ItemTrait>[ItemTraitFactory.PAPER,ItemTraitFactory.COOLK1D],abDesc:"5/5 lady hats.",shogunDesc: "Nerd Magazine for Girls"));
    print(items);
  }

}

class Romantic extends InterestCategory {
  Romantic() :super(12, "Romantic", "romantic", "obsessive");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Red Rose",<ItemTrait>[ItemTraitFactory.ROMANTIC, ItemTraitFactory.PRETTY],shogunDesc: "Seductive Plant"))
      ..add(new Item("Friend Fic",<ItemTrait>[ItemTraitFactory.ROMANTIC, ItemTraitFactory.PAPER],shogunDesc: "Grid of Sin",abDesc:"Don't ship irl ppl, asshole."))
      ..add(new Item("Chocolate Bar",<ItemTrait>[ItemTraitFactory.ROMANTIC, ItemTraitFactory.EDIBLE],shogunDesc: "Brick of Shit Coloured Nice Tasting Food",abDesc:"Robots don't need shitty food."))
      ..add(new Item("Candelabra",<ItemTrait>[ItemTraitFactory.ROMANTIC, ItemTraitFactory.ONFIRE],shogunDesc: "Dying Light Holding Device, Cruelty Made of Metal"))
      ..add(new Item("Head Cannon",<ItemTrait>[ItemTraitFactory.ROMANTIC, ItemTraitFactory.EXPLODEY,ItemTraitFactory.METAL, ItemTraitFactory.SHOOTY], abDesc: "Fuck you for that pun, JR."))

      ..add(new Item("Her Pitch Passions Novel",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER, ItemTraitFactory.ROMANTIC],shogunDesc: "I dont Understand This But It Makes Me Sad",abDesc:"Okay, I will give ABJ this. Troll romance is HILARIOUS."));
    print(items);
  }
}

class Social extends InterestCategory {
  Social() :super(11, "Social", "extroverted", "shallow");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Fiduspawn Plush",<ItemTrait>[ItemTraitFactory.FUR,ItemTraitFactory.CLOTH, ItemTraitFactory.COMFORTABLE],shogunDesc: "Copyrighted Yellow Rat Plush",abDesc:"Hopefully just a replica."))
      ..add(new Item("Teddy Bear",<ItemTrait>[ItemTraitFactory.FUR,ItemTraitFactory.CLOTH, ItemTraitFactory.COMFORTABLE],shogunDesc: "Cuddle Bear"))
      ..add(new Item("D20",<ItemTrait>[ItemTraitFactory.DICE, ItemTraitFactory.PLASTIC],shogunDesc: "D113"))
      ..add(new Item("Pet Pigeon",<ItemTrait>[ItemTraitFactory.FEATHER, ItemTraitFactory.SENTIENT, ItemTraitFactory.FLESH, ItemTraitFactory.BONE, ItemTraitFactory.CORRUPT, ItemTraitFactory.PIGEON],shogunDesc: "Bird of Impending Doom",abDesc:"Better fucking tell JR. Ironic pigeons and all."))
      ..add(new Item("Cat Ears",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.COMFORTABLE, ItemTraitFactory.FUR],shogunDesc: "Weeb Shit",abDesc:"Fuck. Cat. Trolls."))
      ..add(new Item("Religious Text",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER],shogunDesc: "Religious Book Containing No Shogun, A Bad Book"))
      ..add(new Item("Psychology Book",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER],shogunDesc: "How to Guarantee Your Message Gets Pinned The Book"))
      ..add(new Item("Therapy Couch",<ItemTrait>[ItemTraitFactory.COMFORTABLE,ItemTraitFactory.CLOTH],shogunDesc: "Giant Problem Absorbing Couch"))
      ..add(new Item("FLARP Manual",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER, ItemTraitFactory.SMART],shogunDesc: "Book of Nerd Natural Selection",abDesc:"Fuck. Cat. Trolls. Though I guess she never FLARPED."));
    print(items);
  }
}

class Technology extends InterestCategory {
  Technology() :super(10, "Technology", "techy", "awkward");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Robot",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.METAL, ItemTraitFactory.SENTIENT, ItemTraitFactory.SMART],shogunDesc: "ShogunBot",abDesc:"An obviously superior choice."))
      ..add(new Item("Circuit Board",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.METAL],shogunDesc: "Machines Heart, Torn Straight From ABs still powered chest",abDesc:"This better be going INTO a robot and not out of one."))
      ..add(new Item("Datastructures for Assholes",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.PAPER],shogunDesc: "Machines Heart, Torn Straight From ABs still powered chest",abDesc:"Sounds like the perfect book for you."))
      ..add(new Item("~ATH For Dummies ",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.PAPER, ItemTraitFactory.DOOMED, ItemTraitFactory.BOOK],shogunDesc: "Huge Fucking Book for Goddamn Lifeless Nerds",abDesc:"Such a pointless book."))
      ..add(new Item("3-D Printer",<ItemTrait>[ItemTraitFactory.PLASTIC,ItemTraitFactory.ZAP, ItemTraitFactory.METAL],shogunDesc: "3-D Shitpost Maker"))
      ..add(new Item("Virus on a USB Stick",<ItemTrait>[ItemTraitFactory.GLITCHED, ItemTraitFactory.METAL],shogunDesc: "Make a Computer Shitpost Itself to Death on A Stick",abDesc:"Fuck you. You fucking DROP that."))
      ..add(new Item("Wrench",<ItemTrait>[ItemTraitFactory.WRENCH, ItemTraitFactory.METAL,ItemTraitFactory.BLUNT],shogunDesc: "The Tool of Judgement for Machines",abDesc:"Make sure to use it build a dope af robot."))
      ..add(new Item("Computer",<ItemTrait>[ItemTraitFactory.ZAP, ItemTraitFactory.METAL],shogunDesc: "JRs Computer, Broken yeah but still",abDesc:"Computers are good. That is all there is to say on the matter."));
    print(items);
  }
}

class Terrible extends InterestCategory {
  Terrible() :super(5, "Terrible", "honest", "terrible");
  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Lighter",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.ONFIRE],shogunDesc: "ABJs Birthday Gift",abDesc:"Don't let ABJ know you have this."))
      ..add(new Item("Siberia Poster",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.COLD],shogunDesc: "Poster of the Shoguns Birthplace"))
      ..add(new Item("Nuclear Winter Poster",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.COLD, ItemTraitFactory.NUCLEAR],shogunDesc: "Shoguns Dream as a Poster"))
      ..add(new Item("Doomsday Device",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.DOOMED, ItemTraitFactory.NUCLEAR, ItemTraitFactory.REAL, ItemTraitFactory.CORRUPT],shogunDesc: "Shoguns UNO Reverse Card",abDesc:"Oh god, who would fucking trust YOU with thi?"))
      ..add(new Item("Juggalo Poster",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.JUGGALO],shogunDesc: "False God Poster"))
      ..add(new Item("Fancy Watch",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.VALUABLE, ItemTraitFactory.REAL],shogunDesc: "Shoguns Watch"))
      ..add(new Item("Magnificent Crown",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.VALUABLE, ItemTraitFactory.REAL],shogunDesc: "The Shoguns Crown"))
      ..add(new Item("Bitching Clothes",<ItemTrait>[ItemTraitFactory.CLOTH, ItemTraitFactory.BESPOKE, ItemTraitFactory.REAL],shogunDesc: "Shoguns Godtier Outfit",abDesc:"Just wear roboclothes. Never need another set."))
      ..add(new Item("Ceramic Pork Hollow",<ItemTrait>[ItemTraitFactory.CERAMIC, ItemTraitFactory.VALUABLE],shogunDesc: "Shoguns Old Porkhollow",abDesc:"..."))//that fanfic, man
      ..add(new Item("Shit Ton of Guns",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.PISTOL, ItemTraitFactory.SHOOTY, ItemTraitFactory.REAL],shogunDesc: "Dynamos Armament",abDesc:"You are one high quality sociopath."))
      ..add(new Item("Sniper Rifle",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.RIFLE, ItemTraitFactory.SHOOTY, ItemTraitFactory.REAL],shogunDesc: "Long Range Rooty Tooty Point And Boomy",abDesc:"What. The. Hell."))
      ..add(new Item("AK-47",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.MACHINEGUN, ItemTraitFactory.SHOOTY, ItemTraitFactory.REAL],shogunDesc: "100% Genuine Soviet Kalashnikov",abDesc:"What is it with you and guns."))
      ..add(new Item("IED",<ItemTrait>[ItemTraitFactory.GRENADE, ItemTraitFactory.EDGED,ItemTraitFactory.METAL, ItemTraitFactory.EXPLODEY, ItemTraitFactory.REAL],shogunDesc: "Shitpost Bomb",abDesc:"You are probably going to blow yourself up, asshole."))
      ..add(new Item("Idiots Guide To Being An Asshole",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.ENRAGING, ItemTraitFactory.BOOK],shogunDesc: "Shoguns Guide to Shitposting",abDesc:"Oh god, this is HILARIOUS, it's the PERFECT book for you."))
      ..add(new Item("Bike Horn",<ItemTrait>[ItemTraitFactory.RUBBER,ItemTraitFactory.METAL, ItemTraitFactory.LOUD,ItemTraitFactory.ENRAGING],shogunDesc: "Bike Mounted Pain Box",abDesc:"I hear flesh bags keep gtting scared by these. I don't get it."))
      ..add(new Item("Matches",<ItemTrait>[ItemTraitFactory.WOOD, ItemTraitFactory.ONFIRE],abDesc:"Don't let ABJ get this.",shogunDesc: "ABJs First Arsonist Set"));
    print(items);
  }
}

class Writing extends InterestCategory {
  Writing() :super(3, "Writing", "lettered", "wordy");

  @override
  void initializeItems() {
    print("Items were initialized");
    items = new WeightedList<Item>()
      ..add(new Item("Make a World Book",<ItemTrait>[ItemTraitFactory.PAPER, ItemTraitFactory.CLASSY, ItemTraitFactory.BOOK],shogunDesc: "World Building for Dumbasses",abDesc:"World building is p okay, I guess."))
      ..add(new Item("Quill Pen",<ItemTrait>[ItemTraitFactory.COMFORTABLE, ItemTraitFactory.CLOTH, ItemTraitFactory.PEN],shogunDesc: "Dead Bird Scribing Tool"))
      ..add(new Item("Book On Writing",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER, ItemTraitFactory.SMART],shogunDesc: "How to do words for unsmarts"))
      ..add(new Item("FLARP Manual",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER, ItemTraitFactory.SMART],abDesc:"That Cat Troll doesn't do this. So I guess it's okay.",shogunDesc: "Natural Selection for Nerds The Book"))
      ..add(new Item("Script",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER],shogunDesc: "Death of JR, a screenplay by The Shogun"))
      ..add(new Item("Fancy Pen",<ItemTrait>[ItemTraitFactory.METAL, ItemTraitFactory.SMART, ItemTraitFactory.PEN, ItemTraitFactory.CLASSY],shogunDesc: "Ink Bleeding Plastic Finger"))
      ..add(new Item("Spiral Bound Notebook",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER, ItemTraitFactory.METAL],shogunDesc: "Spinney Spine Scribing Station"))
      ..add(new Item("Half Written Novel",<ItemTrait>[ItemTraitFactory.BOOK,ItemTraitFactory.PAPER],shogunDesc: "The Shoguns Magnum Opus",abDesc:"I'm sure you'll finish it any day now."));
    print(items);
  }
}