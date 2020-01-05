import 'dart:convert';
import 'dart:developer';
import "dart:html";
import "dart:math" as Math;
import "SBURBSim.dart";



enum ProphecyState {
  NONE,
  ACTIVE,
  FULLFILLED
}

//fully replacing old GameEntity that was also an unholy combo of strife engine
//not abstract, COULD spawn just a generic game entity.
class GameEntity extends Object with StatOwner   {
  //for players it effects god tier revive, for others it works like life gnosis
  //used to judge heroic deaths
  bool unconditionallyImmortal = false;
  //only a few big bads can't even be fought in the first place
  bool canStrife = true;

  List<String> bannedScenes =<String>[];

  int playerKillCount = 0;
  bool addedSerializableScenes = false;
  int npcKillCount = 0;
  int landKillCount  = 0;
  bool everCrowned = false;
  String labelPattern = ":___ ";
  //big bads and etc can set this
  String extraTitle = "";

  //mostly for big bads, but other things can have them, too
  List<StopScene> playerReactions = new List<StopScene>();

  //availibility set to false by scenes
  bool available = true;
  //scenes are no longer singletons owned by the session. except for the reckoning and aftermath
  List<Scene> scenes = new List<Scene>();
  List<Scene> scenesToAdd = new List<Scene>();
  //just for the action effects that remove shit that might be called on self.
  List<SerializableScene> scenesToRemove = new List<SerializableScene>();

  List<String> serializableSceneStrings = new List<String>();

  //AW wrote up a bunch of these for carapaces
  String description = "";

  //why are they pestering Jack?
  List<String> bureaucraticBullshit = new List<String>();

  //if you have been flagged as a big bad, the players will try to stop you
  bool villain = false;
  //players activate when they enter session, npcs activate when they encounter a player.
  bool active  = false;

  //if you become a companion, they are your party leader.
  GameEntity partyLeader;
  static int _nextID = 0;
  Specibus specibus;
  Sylladex sylladex = null;
  //1/16/18 let's fucking do this. npc update go. mostly npcs but can be brain ghosts and robots, too.
  List<GameEntity> _companions = new List<GameEntity>();

  ProphecyState prophecy = ProphecyState.NONE; //doom players can give this which nerfs their stats but ALSO gives them a huge boost when they die
  //TODO figure out how i want tier 2 sprites to work. prototyping with a carapace and then a  player and then god tiering should result in a god tier Player that can use the Royalty's Items.

  /// can NEVER be null, but I expect this to be replaced.
  Session session = PotentialSprite.defaultSession; //don't make a new one just use default, don't care what it is gonna override it if it's important.

  //TODO replace 'minLuck' with 'destiny'
  String name = "";
  //TODO the next few stats are for sprites but since ANY living thing can become a sprite...

  String helpPhrase = "provides the requisite amount of gigglesnort hideytalk to be juuuust barely helpful. ";
  num helpfulness = 0;
  bool armless = false;
  bool disaster = false;
  bool lusus = false; //HAVE to be vars or can't inherit through prototyping.
  bool player = false;
  bool illegal = false; //maybe AR won't help players with ILLEGAL sprites?
  //
  String fontColor = "#000000";
  bool ghost = false; //if you are ghost, you are rendered spoopy style
  bool brainGhost = false;

  //depreciated, use pls stat system finally on 10/2/18 says jr
  //num grist = 100; //everything has it.

  num get grist => getStat(Stats.GRIST);

  void set grist(num value) {
    setStat(Stats.GRIST, value);
  }

  bool dead = false;
  String causeOfDrain = null; //if it's ever not null they will be sideways
  List<GhostPact> ghostPacts = <GhostPact>[]; //list of two element array [Ghost, enablingAspect]
  bool corrupted = false; //players are corrupted at level 4. will be easier than always checking grimDark level
  List<Fraymotif> fraymotifs = <Fraymotif>[];
  bool usedFraymotifThisTurn = false;
  List<Relationship> relationships = <Relationship>[]; //not to be confused with the RELATIONSHIPS stat which is the value of all relationships.
  //Map<String, num> permaBuffs = <String, num>{ "MANGRIT": 0}; //is an object so it looks like a player with stats.  for things like manGrit which are permanent buffs to power (because modding power directly is confusing since it's also 'level')
  num renderingType = 0; //0 means default for this sim.
  List<AssociatedStat> associatedStats = <AssociatedStat>[]; //most players will have a 2x, a 1x and a -1x stat.
  //String spriteCanvasID = null; //part of new rendering engine. deprecated 1/24/18 in favor of using a canvas directly
  CanvasElement canvas;

  num id;
  bool doomed = false; //if you are doomed, no matter what you are, you are likely to die.
  String causeOfDeath = ""; //fill in every time you die. only matters if you're dead at end

  //npc traits: violent, lucky, charming, cunning

  String get initials {
    RegExp exp = new RegExp(r"""\b(\w)|[A-Z]""", multiLine: true);
    String ret =  joinMatches(exp.allMatches(name)).toUpperCase();
    if(ret == "JN") return "SS"; //fuck you, that's why. Nah. I'm sorry. It's because Jack Noir needs to have the same initails as his Crowned or Exiled self.
    return ret;
  }

  //just returns first, hoarding them does nothing.
  MagicalItem get crowned {
    for(Item item in sylladex) {
      if(item is Ring || item is Scepter) {
        return item;
      }
    }
  }

  //otherwise i risk modifying a concurrent array
  void handleRemovingScenes() {
    for(SerializableScene scene in scenesToRemove) {
      //both places to mimic previous content
      scenes.remove(scene);
      scenesToAdd.remove(scene);
    }
  }


  List<GameEntity> get companionsCopy {
    //don't want there to be a way to get companions directly
    //cuz then i might add and remove without going through methods.
    return new List<GameEntity>.from(_companions);
  }


  GameEntity(this.name, this.session) {
    this.initStatHolder();
    id = GameEntity.generateID();
    sylladex = new Sylladex(this);
    //;
    //default non player thingy.
    //if i don't copy this it eventually loses it's required trait and i don't know why
    this.specibus = SpecibusFactory.CLAWS.copy();
    this.addBuff(new BuffSpecibus(this)); //programatic
    this.addBuff(new BuffLord(this)); //will only apply if you are a lord, but all have potential
    //crashes if(getStat(Stats.CURRENT_HEALTH) <= 0) setStat(Stats.CURRENT_HEALTH, 10);
    if(!(this is PotentialSprite) && session != null) session.npcHandler.allEntities.add(this);
    //players don't start with grist and also null players will crash here cuz apparently no aspect = no stats
    if(!(this is Player) && grist <= 0) {
      // print("trying to set grist for $name");
      grist = 113;
    }
  }


  @override
  String toString() {
    return this.title();
  }


  @override
  StatHolder createHolder() {
    return new ProphecyStatHolder<GameEntity>(this);
  }


  void copyStatsTo(GameEntity clonege) {
    clonege.stats = this; // copies the stats via StatOwner's stats setter! (also buffs)
    clonege.fontColor = fontColor;
    clonege.ghost = ghost; //if you are ghost, you are rendered spoopy style
    clonege.dead = dead;
    clonege.ghostPacts = ghostPacts; //list of two element array [Ghost, enablingAspect]
    clonege.corrupted = corrupted; //players are corrupted at level 4. will be easier than always checking grimDark level
    clonege.fraymotifs = fraymotifs; //TODO should these be cloned, too?
    clonege.usedFraymotifThisTurn = usedFraymotifThisTurn;
    clonege.relationships = Relationship.cloneRelationshipsStopgap(relationships);
    clonege.renderingType = renderingType; //0 means default for this sim.
    clonege.extraTitle = extraTitle;
    clonege.associatedStats = associatedStats; //most players will have a 2x, a 1x and a -1x stat.
    clonege.doomed = doomed; //if you are doomed, no matter what you are, you are likely to die.
    clonege.causeOfDeath = causeOfDeath; //fill in every time you die. only matters if you're dead at end
    clonege.sylladex = new Sylladex(sylladex.owner, sylladex.inventory);
  }


  void modifyAssociatedStat(num modValue, AssociatedStat stat) {
    //modValue * stat.multiplier.
    //////session.logger.info("Modify associated stat $stat on $this by $modValue");
    if (stat.stat == Stats.RELATIONSHIPS) {
      for (num i = 0; i < this.relationships.length; i++) {
        this.relationships[i].value += modValue * stat.multiplier;
      }
    } else {
      this.addStat(stat.stat, modValue * stat.multiplier); // I hope this isn't doing something totally wonky -PL
    }
  }

  //sets current hp to max hp. mostly called after strifes assuming you'll use healing items
  void heal() {
    //have at least one hp
    this.setStat(Stats.CURRENT_HEALTH, Math.max(this.getStat(Stats.HEALTH),1));
  }

  String htmlTitleWithTip() {
    String ret = "$extraTitle ";
    if (this.crowned != null) ret = "${ret}Crowned ";
    String pname = this.name;
    if (pname == "Yaldabaoth") {
      List<String> misNames = <String>[ 'Yaldobob', 'Yolobroth', 'Yodelbooger', "Yaldabruh", 'Yogertboner', 'Yodelboth'];
      ////session.logger.info("Yaldobooger!!! ${this.session.session_id}");
      pname = this.session.rand.pickFrom(misNames);
    }
    if (this.corrupted) pname = Zalgo.generate(this.name); //will i let denizens and royalty get corrupted???
    return "${getToolTip()}$ret$pname</span>"; //TODO denizens are aspect colored.  also, that extra span there is to close out the tooltip
  }

  //will be diff for carapaces
  List<Fraymotif> get fraymotifsForDisplay {
    List<Fraymotif> ret = new List<Fraymotif>.from(fraymotifs);
    if(this is Carapace) {
      for (Item item in sylladex) {
        if (item is MagicalItem) {
          MagicalItem m = item as MagicalItem;
          if (!(m is Ring) && !(m is Scepter)) ret.addAll(
              m.fraymotifs);
        }
      }
    }
    // ;
    return ret;
  }

  //what gets displayed when you hover over any htmlTitle (even HP)
  String getToolTip() {
    if (Drawing.checkSimMode() == true) {
      return "<span>";
    }
    String ret = "<span class = 'tooltip'><span class='tooltiptext'><table>";
    ret += "<tr><td class = 'toolTipSection'>$name<hr>";

    ret += "</td>";
    Iterable<Stat> as = Stats.summarise;
    ret += "<td class = 'toolTipSection'>Stats<hr>";
    for (Stat stat in as) {
      int baseValue = getStat(stat,true).round(); //113 lets say
      int derivedValue = getStat(stat).round(); //120 lets say
      ret += "$stat: ${baseValue} (+ ${derivedValue-baseValue})<br>";
    }
    ret += "Grist: $grist)<br>";

    ret += "</td>";

    ret += "<td class = 'toolTipSection'>Companions<hr>";
    for(GameEntity g in companionsCopy) {
      String species  = "";
      if(g is Leprechaun) species = "(Leprechaun)";
      if(g is Consort) species = "(Consort)";
      if(g is Carapace && (g as Carapace).type == Carapace.DERSE) species = "(Dersite)";
      if(g is Carapace && (g as Carapace).type == Carapace.PROSPIT) species = "(Prospitian)";

      ret += "${g.title()} $species<br>";
    }


    ret += "</td><td class = 'toolTipSection' rowspan='2'>Sylladex<hr>";
    ret += "Specibus: ${specibus.fullNameWithUpgrade}, Rank: ${specibus.rank}<br><br>";



    for(Item item in sylladex) {
      ret += "${item.fullNameWithUpgrade}<br>";
    }

    ret += "</td><td class = 'toolTipSection' rowspan='2'>AI<hr>";

    for (Scene s in scenes) {
      if(s is SerializableScene) {
        ret += "${s}<br>";
      }else {
        ret += "???<br>";
      }
    }

    ret += "</td><td class = 'toolTipSection' rowspan='2'>Buffs<hr>";



    for (Buff b in buffs) {
      ret += "$b<br>";
    }

    ret += "</td></tr><tr><td class = 'toolTipSection'>Fraymotifs<hr>";
    List<Fraymotif> confusion = fraymotifsForDisplay;
    //;
    for(Fraymotif f in confusion) {
      ret += "${f.name}<br>";
    }

    ret += "</td><td class = 'toolTipSection'>Relationships<hr>";
    for(Relationship r in relationships) {
      ret += "$r<br>";
    }
    ret += "</td></tr></table></span>";
    return ret;
  }

  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json["name"] = name;
    json["description"] = description;
    json["canStrife"] = canStrife.toString();
    json["unconditionallyImmortal"] = unconditionallyImmortal.toString();
    json["serializableSceneStrings"] = serializableSceneStrings.join(",");

    List<JSONObject> sceneArray = new List<JSONObject>();
    for(Scene s in scenes) {
      if(s is SerializableScene) sceneArray.add(s.toJSON());
    }
    json["scenes"] = sceneArray.toString();

    json["specibus"] = specibus.toJSON().toString();
    List<JSONObject> sylladexArray = new List<JSONObject>();
    for(Item s in sylladex.inventory) {
      sylladexArray.add(s.toJSON());
    }
    json["sylladex"] = sylladexArray.toString();

    List<JSONObject> fraymotifArray = new List<JSONObject>();
    for(Fraymotif s in fraymotifs) {
      fraymotifArray.add(s.toJSON());
    }
    json["fraymotifs"] = fraymotifArray.toString();

    List<JSONObject> statArray = new List<JSONObject>();
    Iterable<Stat> as = Stats.summarise;
    for(Stat s in as) {
      //i'm not sure how to get a stats value from inside itself so....*shrug*
      JSONObject j = new JSONObject();
      j["name"] = s.name;
      j["value"] = "${getStatHolder().getBase(s)}";
      statArray.add(j);
    }
    json["stats"] = statArray.toString();
    return json;
  }

  void copyFromJSON(String jsonString) {
    //print("trying to copy from json $jsonString");
    JSONObject json = new JSONObject.fromJSONString(jsonString);
    name = json["name"];
    description = json["description"];
    canStrife = json["canStrife"] == "true"? true : false ;
    unconditionallyImmortal = json["unconditionallyImmortal"] == "true" ? true : false ;

    if(json["serializableSceneStrings"] != null) {
      String tmp = json["serializableSceneStrings"];
      tmp = tmp.replaceAll("[", "");
      tmp = tmp.replaceAll("]", ""); //just in case it's using the old fucking shit
      serializableSceneStrings = tmp.split(",");
    }

    String statString = json["stats"];
    loadStats(statString);
    //print("loaded stats");

    String fraymotifString = json["fraymotifs"];
    loadFraymotifs(fraymotifString);
    // print("loaded fraymotifs");

    if(json["specibus"] != null) specibus.copyFromJSON(new JSONObject.fromJSONString(json["specibus"]));
    //print("loaded specibus");

    String sylladexString = json["sylladex"];
    loadSylladex(sylladexString);
    //print("loaded sylladex");


    String scenesString = json["scenes"];
    //print("scenes string is $scenesString");
    loadScenes(scenesString);
    //print("done loading scenes");

    String stopScenesString = json["stopMechanisms"];

    if(stopScenesString != null) loadStopMechanisms(stopScenesString);

    if(grist <130) {
      grist = getStat(Stats.EXPERIENCE)*100+100;
    }

  }

  void loadScenes(String weirdString) {
    if(weirdString == null) return;
    List<dynamic> what = jsonDecode(weirdString);
    for(dynamic d in what) {
      //print("dynamic json thing for action scene is is  $d");
      JSONObject j = new JSONObject();
      j.json = d;
      SerializableScene ss = new SerializableScene(session);
      ss.gameEntity = this;
      ss.copyFromJSON(j);
      scenes.add(ss);
    }
  }



  void loadStopMechanisms(String weirdString) {
    //print("weird string is $weirdString");
    List<dynamic> what = jsonDecode(weirdString);
    for(dynamic d in what) {
      //print("dynamic json thing is  $d");
      JSONObject j = new JSONObject();
      j.json = d;
      StopScene ss = new StopScene(session);
      ss.originalOwner = this;
      ss.copyFromJSON(j);
      playerReactions.add(ss);
    }
    //print ("loaded stop mechanisms $playerReactions");
  }

  //players call this on intro, everything else in the grabActivatedX loops. not sure if dead session players will call this? i want them to
  void activateTasks() {
    heal();
    applyStopMechanisms();
  }

  void applyStopMechanisms() {
    // print("looking for stop mechanisms to apply, found $playerReactions");
    if(playerReactions.isEmpty) return;
    for(Player p in session.players) {
      //please don't try to defeat yourself.
      if(p!=this) {
        for(StopScene ss in playerReactions) {
          // print("giving player $p the stop reaction $ss");
          ss.gameEntity = p;
          p.scenesToAdd.add(ss);
        }
      }
    }
    //only happens once.
    playerReactions.clear();
  }

  void loadStats(String weirdString) {
    //print("trying to decode weirdString $weirdString");
    if(weirdString == null) return;
    List<dynamic> what = jsonDecode(weirdString);
    for(dynamic d in what){
      JSONObject j = new JSONObject();
      j.json = d;
      Stat stat = Stats.byName[j["name"]];
      setStat(stat, num.parse(j["value"]));
    }
    if(grist <= 113) grist = getStat(Stats.EXPERIENCE,true);
    heal();
  }

  void loadFraymotifs(String weirdString) {
    fraymotifs.clear();
    if(weirdString == null) return;
    List<dynamic> what = jsonDecode(weirdString);
    for(dynamic d in what) {
      //print("d is $d");
      JSONObject j = new JSONObject();
      j.json = d;
      Fraymotif ss = new Fraymotif("",0);
      ss.copyFromJSON(j);
      fraymotifs.add(ss);
    }
  }

  void loadSylladex(String weirdString) {
    //print ("weird string is $weirdString");
    sylladex.inventory.clear();
    if(weirdString == null) return;
    List<dynamic> what = jsonDecode(weirdString);
    for(dynamic d in what) {
      //print("sylladex d is $d");
      Item ss = new Item("",<ItemTrait>[]);
      JSONObject j = new JSONObject();
      j.json = d;
      ss.copyFromJSON(j);
      sylladex.add(ss);
    }
  }


  String htmlTitleHP() {
    String ret = "<font color ='$fontColor'>";
    if (this.crowned != null) ret = "${ret}Crowned ";
    String pname = this.name;
    if (this.corrupted) pname = Zalgo.generate(this.name); //will i let denizens and royalty get corrupted???
    return "${getToolTip()}$ret$pname (${(this.getStat(Stats.CURRENT_HEALTH)).round()} hp, ${(this.getStat(Stats.POWER)).round()} power)</font></span>"; //TODO denizens are aspect colored. also, that extra span there is to close out the tooltip
  }

  String htmlTitleBasicNoTip() {
    String ret = "";
    if (this.crowned != null) ret = "${ret}Crowned ";
    return "$ret $name";
  }


  Relationship getRelationshipWith(GameEntity target) {
    //stub for boss fights where an asshole absconds.
    for (Relationship r in relationships) {
      if (r.target.id == target.id) {
        return r;
      }
    }
    return null;
  }

  //takes in a stat name we want to use. for example, use only min luck to avoid bad events.
  double rollForLuck([Stat stat]) {
    if (stat == null) {
      return this.session.rand.nextDoubleRange(this.getStat(Stats.MIN_LUCK), this.getStat(Stats.MAX_LUCK));
    } else {
      //don't care if it's min or max, just compare it to zero.
      return this.session.rand.nextDouble(this.getStat(stat));
    }
  }


  static int generateID() {
    GameEntity._nextID += 1;
    return GameEntity._nextID;
  }

  static int getIDCopy() {
    return GameEntity._nextID;
  }

  Random get rand => this.session.rand;

  String title() {
    return name; //players will override this
  }
}


//need to know if you're from aspect, 'cause only aspect associatedStats will be used for fraymotifs.
//except for heart, which can use ALL associated stats. (cause none will be from aspect.)
class AssociatedStat {
  Stat stat;
  double multiplier;
  bool isFromAspect;


  @override
  String toString() => "[$stat x $multiplier${this.isFromAspect ? " (from Aspect)" : ""}]";
}


