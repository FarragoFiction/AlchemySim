import 'dart:developer';
import "dart:html";
import "../Lands/FeatureTypes/QuestChainFeature.dart";
import "../Lands/Quest.dart";
import "../Lands/Reward.dart";
import "dart:async";
import "SBURBSim.dart";
enum CanonLevel {
  CANON_ONLY,
  FANON_ONLY,
  EVERYTHING_FUCKING_GOES
}

//okay, fine, yes, global variables are getting untenable.
class Session {

  static Session _defaultSession;
  //this will be set by reinit
  Completer<Session> completer; // PL: this handles the internal callback for awaiting a session!

  //no players, carapaces only, final destination
  bool tableGuardianMode = false;
  bool ultimateShowdown = false;
  bool plzStartReckoning = false;
  bool didReckoning = false;
  int numberPlayersOnBattlefield = 0;

  bool get canReckoning {
    if(tableGuardianMode) return false;
    int difficulty = 2;//at least half of us are done
    if(stats.crownedCarapace)difficulty = players.length; // ANY of us are down (ala canon's early reckoning)
    return numberPlayersOnBattlefield > (players.length/difficulty).round();
  }//can't do the reckoning until this is set (usually when at least one player has made it to the battlefield)
  //TODO some of these should just live in session mutator
  Logger logger = null;
  //for the reckoning
  int numTicks = 0;
  Battlefield battlefield;
  Moon prospit;
  Moon derse;
  //needed for dreams now, null moons are possible
  Moon furthestRing;
  List<Moon> get moons => <Moon>[prospit, derse];

  int numActiveCarapaces = 0;

  //used to be stored on moon, which was good and sane....but then what happens when the moon blows up.
  //crashes, that's what. and or there not being any more rings.
  Ring prospitRing;
  Ring derseRing;
  Scepter prospitScepter;
  Scepter derseScepter;



  int session_id; //initial seed
  //var sceneRenderingEngine = new SceneRenderingEngine(false); //default is homestuck  //comment this line out if need to run sim without it crashing
  List<Player> players = <Player>[];

  //these are stable between combos and scratches

  List<GameEntity> get bigBadsReadOnly => new List<BigBad>.from(npcHandler.bigBads);
  //these are not

  //stores them.
  Set<GameEntity> _activatedNPCS = new Set<GameEntity>();
  //    //so ab can acurately report to shogun bot
  Set<BigBad> activatedBigBads = new Set<BigBad>();


  void deactivateNPC(GameEntity npc) {
    npc.active = false;
    _activatedNPCS.remove(npc);
  }

  void addActiveNPCSForCombo(List<GameEntity>npcs){
    for(GameEntity g in npcs) {
      //no guarantee you'll make it in
      if(g.dead == false && g.active && rand.nextBool()) {
        _activatedNPCS.add(g);
      }
    }
  }

  //for use in session customizer and easter eggs
  void activateBigBad(GameEntity bb) {
    bb.active = true;
    if(!_activatedNPCS.contains(bb)) {
      _activatedNPCS.add(bb);
      activatedBigBads.add(bb);
      //print("after adding $bb to activated big bads its ${activatedBigBads.length} long");
      bb.activateTasks();
    }
  }

  void grabActivatedBigBads() {
    for(GameEntity g in bigBadsReadOnly) {
      if(g.active) {
        logger.info("I think that $g just activated as a big bad");
        _activatedNPCS.add(g);
        activatedBigBads.add(g);
        //print("after adding $g to activated big bads its ${activatedBigBads.length} long");
        g.activateTasks();
        print("before removing $g, big bads is $bigBadsReadOnly");
        npcHandler.bigBads.remove(g);
        print("after removing $g, big bads is $bigBadsReadOnly");
      }
    }

  }



  //save a copy of the alien (in case of yellow yard)
  void addAliensToSession(List<Player> aliens) {
    logger.info("adding ${aliens.length} aliens to me.");
    for (num i = 0; i < aliens.length; i++) {
      Player survivor = aliens[i];
      survivor.land = null;
      survivor.moon = null;
      //note to future JR: you're gonna see this and think that they should lose their moons, too, but that just means they can't have horrorterror dreams. don't do it.
      survivor.dreamSelf = false;
      survivor.godDestiny = false;
      survivor.leader = false;
    }
    //save a copy of the alien players in case this session has time shenanigans happen

    for (num i = 0; i < aliens.length; i++) {
      Player survivor = aliens[i];
      // print("survivor dream palette is ${survivor.dreamPalette}");
      aliensClonedOnArrival.add(clonePlayer(survivor, this, false));
    }
    //don't want relationships to still be about original players
    for (num i = 0; i < aliensClonedOnArrival.length; i++) {
      Player clone = aliensClonedOnArrival[i];
      Relationship.transferFeelingsToClones(clone, aliensClonedOnArrival);
    }
    ////;
    //generate relationships AFTER saving a backup of hte player.
    //want clones to only know about other clones. not players.
    for (num i = 0; i < aliens.length; i++) {
      Player survivor = aliens[i];
      ////print(survivor.title() + " generating relationship with new players ")
      survivor.generateRelationships(players); //don't need to regenerate relationship with your old friends
    }


    for (int j = 0; j < players.length; j++) {
      Player player = players[j];
      player.generateRelationships(aliens);
    }

    for (num i = 0; i < aliens.length; i++) {
      for (int j = 0; j < players.length; j++) {
        Player player = players[j];
        Player survivor = aliens[i];
        //survivors have been talking to players for a very long time, because time has no meaning between univereses.
        Relationship r1 = survivor.getRelationshipWith(player);
        Relationship r2 = player.getRelationshipWith(survivor);
        r1.moreOfSame();
        r1.moreOfSame();
        //been longer from player perspective
        r2.moreOfSame();
        r2.moreOfSame();
        r2.moreOfSame();
        r2.moreOfSame();
      }
    }

    players.addAll(aliens);
    // ;

  }


  num sessionHealth = 500 * Stats.POWER.coefficient; //grimDark players work to lower it. at 0, it crashes.  maybe have it do other things at other levels, or effect other things.
  AfterLife afterLife = new AfterLife();

  //if i have less than expected grist, then no frog, bucko
  int expectedGristContributionPerPlayer; //set in mutator
  int minimumGristPerPlayer; //less than this, and no frog is possible.
  CanonLevel canonLevel = CanonLevel.CANON_ONLY; //regular sessions are canon only, but wastes and eggs can change that.
  num numScenes = 0;
  bool sbahj = false;
  num minTimeTillReckoning = 10;
  num maxTimeTillReckoning = 30;
  num hardStrength = null; //mutator sets
  num minFrogLevel = 13;
  num goodFrogLevel = 20;
  bool reckoningStarted = false;
  List<Player> aliensClonedOnArrival = <Player>[]; //if i'm gonna do time shenanigans, i need to know what the aliens were like when they got here.
  num timeTillReckoning = 0;
  num reckoningEndsAt = -15;
  num sessionType = -999;
  List<String> doomedTimelineReasons = <String>[]; //am I even still using this?
  num currentSceneNum = 0;
  List<Scene> reckoningScenes = <Scene>[];
  List<Scene> deathScenes = <Scene>[];
  //Session parentSession = null;
  //need to reverse the polarity
  Session childSession = null;
  //private, should only be accessed by methods so removing a player can be invalid for time/breath
  List<ImportantEvent> importantEvents = <ImportantEvent>[];
  YellowYardResultController yellowYardController = new YellowYardResultController(); //don't expect doomed time clones to follow them to any new sessions
  SessionStats stats = new SessionStats();
  NPCHandler npcHandler = null;
  // extra fields
  Random rand;
  List<SBURBClass> available_classes_players;
  List<SBURBClass> available_classes_guardians;
  List<Aspect> available_aspects;
  List<Aspect> required_aspects;
  SessionMutator mutator;

  Session(int this.session_id, [bool isCombo= false]) {

    stats.isComboedInto = isCombo;
    logger = Logger.get("Session: $session_id", false);
    this.rand = new Random(session_id);
    PotentialSprite.initializeAShitTonOfPotentialSprites(this);
    npcHandler = new NPCHandler(this);
    //npcHandler.setupNpcs(); reinit will handle this
    stats.initialGameEntityId = GameEntity.getIDCopy();
    mutator.syncToSession(this);
    logger.info("Session made with ${sessionHealth} health.");
    //reinit first, to match scratches and yards and shit, make players with fresh seed essentially
  }



}