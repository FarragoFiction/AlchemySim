import 'dart:developer';
import "dart:html";
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
  //for the reckoning
  int numTicks = 0;
  //needed for dreams now, null moons are possible

  int numActiveCarapaces = 0;


  int session_id; //initial seed
  //var sceneRenderingEngine = new SceneRenderingEngine(false); //default is homestuck  //comment this line out if need to run sim without it crashing
  List<Player> players = <Player>[];

  //if i have less than expected grist, then no frog, bucko
  SessionStats stats = new SessionStats();
  Random rand;
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