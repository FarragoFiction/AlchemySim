import 'dart:convert';
import 'dart:developer';
import "dart:html";
import "dart:math" as Math;
import "SBURBSim.dart";

//fully replacing old GameEntity that was also an unholy combo of strife engine
//not abstract, COULD spawn just a generic game entity.
class GameEntity extends Object with StatOwner   {
  bool everCrowned = false;
  //big bads and etc can set this
  String extraTitle = "";
  Session session;

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
  //TODO figure out how i want tier 2 sprites to work. prototyping with a carapace and then a  player and then god tiering should result in a god tier Player that can use the Royalty's Items.

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
  void set grist(num value) {
    setStat(Stats.GRIST, value);
  }

  bool dead = false;
  String causeOfDrain = null; //if it's ever not null they will be sideways
  bool corrupted = false; //players are corrupted at level 4. will be easier than always checking grimDark level
  List<Fraymotif> fraymotifs = <Fraymotif>[];
  bool usedFraymotifThisTurn = false;
  num renderingType = 0; //0 means default for this sim.
  List<AssociatedStat> associatedStats = <AssociatedStat>[]; //most players will have a 2x, a 1x and a -1x stat.
  //String spriteCanvasID = null; //part of new rendering engine. deprecated 1/24/18 in favor of using a canvas directly
  CanvasElement canvas;

  num id;
  bool doomed = false; //if you are doomed, no matter what you are, you are likely to die.
  String causeOfDeath = ""; //fill in every time you die. only matters if you're dead at end

  //npc traits: violent, lucky, charming, cunning


  //just returns first, hoarding them does nothing.
  MagicalItem get crowned {
    for(Item item in sylladex) {
      if(item is Ring || item is Scepter) {
        return item;
      }
    }
  }

  @override
  StatHolder createHolder() =>new StatHolder();

  List<GameEntity> get companionsCopy {
    //don't want there to be a way to get companions directly
    //cuz then i might add and remove without going through methods.
    return new List<GameEntity>.from(_companions);
  }

  @override
  String toString() {
    return this.title();
  }



  String htmlTitleBasicNoTip() {
    String ret = "";
    if (this.crowned != null) ret = "${ret}Crowned ";
    return "$ret $name";
  }


  static int generateID() {
    GameEntity._nextID += 1;
    return GameEntity._nextID;
  }

  static int getIDCopy() {
    return GameEntity._nextID;
  }

  String title() {
    return name; //players will override this
  }
}


//need to know if you're from aspect, 'cause only aspect associatedStats will be used for fraymotifs.
//except for heart, which can use ALL associated stats. (cause none will be from aspect.)
class AssociatedStat {
  Stat stat;
  double multiplier;
}


