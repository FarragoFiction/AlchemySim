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


  List<GameEntity> get activatedNPCS {
    //UserTag previousTag = createDebugTag("ActivatingNPCs");

    grabActivatedBigBads();
    grabActivatedCarapaces();
    grabSpecialCases();
    //logger.info(" I think tick is $numTicks and activated npcs is $_activatedNPCS");
    //previousTag.makeCurrent();
    return new List.from(_activatedNPCS); //don't let ppl have access to original list they might mod it
  }

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


  void grabSpecialCases() {
    //no matter what you are, denizen, consort, ghost, ANYTHING
    //if you have the scepter and it's time for a reckoning, you have  role to play
    //logger.info("All Entities is: ${npcHandler.allEntities}");
    if(canReckoning) {
      for (GameEntity g in npcHandler.allEntities) {
        if (canReckoning && g.scepter != null) {
          //logger.info("I think that $g just activated as a special case.");
          g.active = true;
          _activatedNPCS.add(g);
          g.activateTasks();
        }
      }
    }

  }

  void grabActivatedCarapaces() {
    for(Moon m in moons) {
      List<GameEntity> toRemove = new List<GameEntity>();
      if(m != null) {
        for(GameEntity g in m.associatedEntities) {

          if(g.active) {
            // logger.info("I think that $g just activated as a carapace.");
            g.heal();
            _activatedNPCS.add(g);
            g.processCardFor();
            toRemove.add(g);
            g.activateTasks();
            numActiveCarapaces ++;

          }
        }
        for(GameEntity g in toRemove) {
          m.associatedEntities.remove(g);
        }
      }
    }
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
    globalInit();
    stats.isComboedInto = isCombo;
    logger = Logger.get("Session: $session_id", false);
    this.rand = new Random(session_id);
    PotentialSprite.initializeAShitTonOfPotentialSprites(this);
    npcHandler = new NPCHandler(this);
    //npcHandler.setupNpcs(); reinit will handle this
    mutator = new SessionMutator();
    stats.initialGameEntityId = GameEntity.getIDCopy();
    mutator.syncToSession(this);
    logger.info("Session made with ${sessionHealth} health.");
    resetAvailableClasspects();
    //reinit first, to match scratches and yards and shit, make players with fresh seed essentially
    reinit("new session");
    getPlayersReady();
  }

  SkaiaQuestChainFeature randomBattlefieldQuestChain() {
    //TODO quests that delay reckoning seem like they'd be boring. but could have specific quests with other effects
    //like increasing the time the reckoning lasts for (rocks fall ending)
    List<Quest> possibleActivities = new List<Quest>()
      ..add(new Quest("The ${Quest.PLAYER1} fights the Dersite army, desparately trying to stave off the Reckoning.   "))
      ..add(new Quest("The ${Quest.PLAYER1} explores Skaian Castles. Huh, there sure are a lot of books!"))
      ..add(new Quest("The ${Quest.PLAYER1} reroutes Dersite equipment to resupply Prospitian soliders."))
      ..add(new Quest("The ${Quest.PLAYER1} mentally prepares for the upcoming Final Battle."))
      ..add(new Quest("The ${Quest.PLAYER1} enters a Dersite battleship, punches the shit out of the captain, locks the door to the control room, reroutes the autopilot to crash into another battleship, then flies out through a window.  The ships crash and explode, and ${Quest.PLAYER1} walks away in slow-motion without looking backwards."))
      ..add(new Quest("The ${Quest.PLAYER1} gives speeches to Prospit army, convincing them that their cause is worth fighting for, despite its futility."))
      ..add(new Quest("The ${Quest.PLAYER1} spares a Derse company in exchange for them leaving the conflict. They decide to join the war for a better world instead."))
      ..add(new Quest("The ${Quest.PLAYER1} hijacks a massive Dersite drilling machine, creating a hole for the frog to enter Skaia more easily."));
    List<Quest> chosen = new List<Quest>();
    int times = rand.nextInt(2) + 3;
    for(int i = 0; i<times; i++) {
      chosen.add(rand.pickFrom(possibleActivities));
    }
    return new SkaiaQuestChainFeature(true, "Wander The Battlefield", chosen, new BattlefieldReward(), QuestChainFeature.defaultOption);
  }


  MoonQuestChainFeature randomProspitQuestChain() {
    List<Quest> possibleActivities = new List<Quest>()
      ..add(new Quest("The ${Quest.PLAYER1} bets 50 boonies on the red frog.   After a nerve wracking set of hops, it comes in first!  "))
      ..add(new Quest("The VAST CROAK will redeem us all.  The VAST CROAK is the purity of creation, untainted by the old universe.  The ${Quest.PLAYER1} isn’t sure they believe in the Church of the Frog’s message, but the sermon itself is very soothing."))
      ..add(new Quest("Two parts flour. One part good sweet butter.  A bowl of egg whites to brush onto the surface.  Sugar to taste. Plenty of elbow grease. The ${Quest.PLAYER1} is learning to master the secret art of the HOLY PASTRIES."))
      ..add(new Quest("The ${Quest.PLAYER1} talks to several Prospitians, learning about their daily lives and how happy they are under the WHITE QUEEN’s rule."))
      ..add(new Quest("The ${Quest.PLAYER1} flutters about aimlessly, simply enjoying the feeling of flying."))
      ..add(new Quest("The ${Quest.PLAYER1} attends a glorious dance party, complete with masquerades, tea parties and friendship.  The Prospitians admire the ${Quest.PLAYER1}’s cheerful demeanor and willingness to invent new dance steps."))
      ..add(new Quest("The ${Quest.PLAYER1} stares into the clouds on Skaia. Visions swim in their head. Is this game….more terrible than they thought?"));
    List<Quest> chosen = new List<Quest>();
    int times = rand.nextInt(2) + 3;
    for(int i = 0; i<times; i++) {
      chosen.add(rand.pickFrom(possibleActivities));
    }
    return new MoonQuestChainFeature(true, "Do Prospit Bullshit", chosen, new DreamReward(), QuestChainFeature.hasDreamSelf);
  }

  MoonQuestChainFeature randomDerseQuestChain() {
    List<Quest> possibleActivities = new List<Quest>()
      ..add(new Quest("The ${Quest.PLAYER1} attends a glorious dance party, complete with masquerades, backstabbing and intrigue.  The Dersites admire the ${Quest.PLAYER1}’s deftness at avoiding stabs in time to music. "))
      ..add(new Quest("The ${Quest.PLAYER1} is taking part in a high stakes poker game. Everybody is cheating, and that’s what makes it interesting.  The ${Quest.PLAYER1}  thinks they can convince everyone that all decks of cards come with five aces."))
      ..add(new Quest("The ${Quest.PLAYER1} is keeping tabs on the lifeblood of Derse. The Inquiring Carapacian is a VERY disreputable newspaper, which is what makes it so great for hearing the juicy gossip the Queen doesn’t WANT you to hear."))
      ..add(new Quest("The BLACK QUEEN is just three Salamanders in a robe.  The BLACK KING likes reading fanfiction. The ${Quest.PLAYER1} is keeping their LYING ATTRIBUTE sharp."))
      ..add(new Quest("The ${Quest.PLAYER1} does their best to ignore the unsettling...whispering that seems to be omnipresent on Derse. "))
      ..add(new Quest("The ${Quest.PLAYER1} is learning the steps to the Derse Waltz. There is no reason one can’t look classy as fuck while also being a lying, cheating, manipulative bastard, that’s what their dance teacher always says."))
      ..add(new Quest("SLICE!  The ${Quest.PLAYER1} slices open a watermelon while a local Dersite looks on in disgust.  ANYBODY can slice with a knife, it takes real commitment to stab.  The ${Quest.PLAYER1} has a lot to learn."))
      ..add(new Quest("The ${Quest.PLAYER1} is relaxing in a dimly lit jazz club.  The band is pretty good, but a nearby Dersite assures the ${Quest.PLAYER1}  that they got nothing on some outfit called ‘The Midnight Crew’. Shame they aren’t around right now."));
    List<Quest> chosen = new List<Quest>();
    int times = rand.nextInt(2) + 3;
    for(int i = 0; i<times; i++) {
      chosen.add(rand.pickFrom(possibleActivities));
    }
    return new MoonQuestChainFeature(true, "Do Derse Bullshit", chosen, new DreamReward(), QuestChainFeature.hasDreamSelf);
  }

  MoonQuestChainFeature randomHorrorTerrorQuestChain() {
    List<Quest> possibleActivities = new List<Quest>()
      ..add(new Quest("The ${Quest.PLAYER1} writhes in terror and pain. Why do players without dreamselves dream in the Furthest Ring with the Horror Terrors? "))
      ..add(new Quest("The ${Quest.PLAYER1} vows to never sleep again.  Why do players without dreamselves dream in the Furthest Ring with the Horror Terrors? "))
      ..add(new Quest("The ${Quest.PLAYER1} is reliving embarassing childhood memories for the amusement of the Horror Terrors.  Why do players without dreamselves dream in the Furthest Ring with the Horror Terrors?"));
    List<Quest> chosen = new List<Quest>();
    int times = rand.nextInt(2) + 3;
    for(int i = 0; i<times; i++) {
      chosen.add(rand.pickFrom(possibleActivities));
    }
    return new MoonQuestChainFeature(true, "Writhe In Pain", chosen, new DreamReward(), QuestChainFeature.hasNoDreamSelfNoBubbles);
  }

  MoonQuestChainFeature randomBubbleQuestChain() {
    List<Quest> possibleActivities = new List<Quest>()
      ..add(new Quest("The ${Quest.PLAYER1} has a relatively sedate time of reliving past memories and chatting up inconsequential ghosts. Good thing the dream bubbles were set up, huh?"))
      ..add(new Quest("The ${Quest.PLAYER1} enjoys a relaxing memory of their home planet while dreaming in the bubbles. "))
      ..add(new Quest("The ${Quest.PLAYER1}  tries not to give into existential horror as they realize just how MANY versions of their dead friends exist."));
    List<Quest> chosen = new List<Quest>();
    int times = rand.nextInt(2) + 3;
    for(int i = 0; i<times; i++) {
      chosen.add(rand.pickFrom(possibleActivities));
    }
    return new MoonQuestChainFeature(true, "Do Dream Bubble Bullshit", chosen, new DreamReward(), QuestChainFeature.hasNoDreamSelfBubbles);
  }

  void setupBattleField() {
    Map<Theme,double> battleFieldThemes = new Map<Theme, double>();
    Theme battleFieldTheme = new Theme(<String>["Battlefield"])
      ..addFeature(FeatureFactory.SMOKESMELL, Feature.HIGH)
      ..addFeature(FeatureFactory.BLOODSMELL, Feature.MEDIUM)
      ..addFeature(FeatureFactory.SCREAMSSOUND, Feature.LOW)
      ..addFeature(FeatureFactory.DANGEROUSFEELING, Feature.MEDIUM)
      ..addFeature(FeatureFactory.GUNPOWDERSMELL, Feature.MEDIUM)
      ..addFeature(FeatureFactory.PROSPITIANCARAPACE, Feature.HIGH)
      ..addFeature(FeatureFactory.DERSECARAPACE, Feature.HIGH)
    //TODO in npc update, have meeting WV be a quest here.
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW)
      ..addFeature(randomBattlefieldQuestChain(), Feature.LOW);


    battleFieldThemes[battleFieldTheme] = Theme.HIGH;
    //;
    battlefield = new Battlefield.fromWeightedThemes("BattleField", battleFieldThemes, this, Aspects.LIGHT);
    battlefield.spawnKings();
  }


  void setupMoons(String reason) {
    //;
    logger.info("DEBUG CUSTOM SESSION: setting up moons because $reason");

    prospitRing = new Ring.withoutOptionalParams("WHITE QUEEN'S RING OF ORBS ${convertPlayerNumberToWords()}FOLD",[ ItemTraitFactory.QUEENLY] );
    Fraymotif f = new Fraymotif("Mini Red Miles", 3);
    f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
    f.desc = " You cannot escape them, unless you get far enough away. ";
    prospitRing.fraymotifs.add(f);

    derseRing = new Ring.withoutOptionalParams("BLACK QUEEN'S RING OF ORBS ${convertPlayerNumberToWords()}FOLD",[ ItemTraitFactory.QUEENLY] );
    f = new Fraymotif("Mini Red Miles", 3);
    f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
    f.desc = " You cannot escape them, unless you get far enough away. ";
    derseRing.fraymotifs.add(f);

    prospitScepter = new Scepter.withoutOptionalParams("WHITE KING'S SCEPTER",[ ItemTraitFactory.KINGLY] );
    f = new Fraymotif("Mini Reckoning Meteors", 3); //TODO eventually check for this fraymotif (just lik you do troll psionics) to decide if you can start recknoing.;
    f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
    f.desc = " The very meteors from the Reckoning rain down. But small. ";
    prospitScepter.fraymotifs.add(f);

    derseScepter = new Scepter.withoutOptionalParams("BLACK KING'S SCEPTER",[ ItemTraitFactory.KINGLY] );
    f = new Fraymotif("Mini Reckoning Meteors", 3); //TODO eventually check for this fraymotif (just lik you do troll psionics) to decide if you can start recknoing.;
    f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
    f.desc = " The very meteors from the Reckoning rain down. But small.";
    derseScepter.fraymotifs.add(f);


    //no more than one of each.
    Map<Theme,double> prospitThemes = new Map<Theme, double>();
    Theme prospitTheme = new Theme(<String>["Prospit"])
      ..addFeature(FeatureFactory.DISCOSOUND, Feature.MEDIUM)
      ..addFeature(FeatureFactory.MUSICSOUND, Feature.LOW)
      ..addFeature(FeatureFactory.STUDIOUSFEELING, Feature.MEDIUM)
      ..addFeature(FeatureFactory.CALMFEELING, Feature.MEDIUM)
      ..addFeature(FeatureFactory.SWEETSMELL, Feature.LOW)
      ..addFeature(FeatureFactory.PROSPITIANCARAPACE, Feature.HIGH)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomProspitQuestChain(), Feature.WAY_LOW)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH);



    Map<Theme,double> derseThemes = new Map<Theme, double>();
    Theme derseTheme = new Theme(<String>["Prospit"])
      ..addFeature(FeatureFactory.JAZZSOUND, Feature.MEDIUM)
      ..addFeature(FeatureFactory.WHISPERSOUND, Feature.MEDIUM)
      ..addFeature(FeatureFactory.MUSICSOUND, Feature.LOW)
      ..addFeature(FeatureFactory.DANGEROUSFEELING, Feature.MEDIUM)
      ..addFeature(FeatureFactory.CREEPYFEELING, Feature.LOW)
      ..addFeature(FeatureFactory.DECEITSMELL, Feature.MEDIUM)
      ..addFeature(FeatureFactory.DERSECARAPACE, Feature.HIGH)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomDerseQuestChain(), Feature.LOW)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(new MoonQuestChainFeature(true, "Be a Legitimate Business Player", [
        new Quest("The ${Quest.PLAYER1} learns of a lucrative business opportunity. The BLACK QUEEN has all sorts of contraband laws. Everything from frogs to ice cream is so totally illegal. But that doesn't stop the right sort of Dersite from getting cravings, if you understand me. The ${Quest.PLAYER1} looks like they can be discreet. "),
        new Quest("The ${Quest.PLAYER1} runs afoul of the Authority Regulators. Through a frankly preposterous amount of running, parkour and misdirection, they finally escape, only to remember that they could have just flown away.  Dream selves sure are dumb!  "),
        new Quest("The ${Quest.PLAYER1} has decided to retire from a life of...legitimate business, highly lucrative though it was.  They use their earnings to set up a simple and refined Suit Shop, catering to only the most exclusive clientel. "),
      ], new DreamReward(), QuestChainFeature.hasDreamSelf), Feature.LOW);


    Map<Theme,double> furthestRingThemes = new Map<Theme, double>();
    Theme furthestRingTheme = new Theme(<String>["Prospit"])
      ..addFeature(FeatureFactory.SCREAMSSOUND, Feature.MEDIUM)
      ..addFeature(FeatureFactory.WHISPERSOUND, Feature.MEDIUM)
      ..addFeature(FeatureFactory.DANGEROUSFEELING, Feature.MEDIUM)
      ..addFeature(FeatureFactory.CREEPYFEELING, Feature.LOW)
      ..addFeature(FeatureFactory.HORRORTERROR, Feature.HIGH)
      ..addFeature(FeatureFactory.DECEITSMELL, Feature.MEDIUM)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomHorrorTerrorQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(randomBubbleQuestChain(), Feature.WAY_HIGH)
      ..addFeature(new MoonQuestChainFeature(true, "Be a Legitimate Business Player", [
        new Quest("The ${Quest.PLAYER1} learns of a lucrative business opportunity. The BLACK QUEEN has all sorts of contraband laws. Everything from frogs to ice cream is so totally illegal. But that doesn't stop the right sort of Dersite from getting cravings, if you understand me. The ${Quest.PLAYER1} looks like they can be discreet. "),
        new Quest("The ${Quest.PLAYER1} runs afoul of the Authority Regulators. Through a frankly preposterous amount of running, parkour and misdirection, they finally escape, only to remember that they could have just flown away.  Dream selves sure are dumb!  "),
        new Quest("The ${Quest.PLAYER1} has decided to retire from a life of...legitimate business, highly lucrative though it was.  They use their earnings to set up a simple and refined Suit Shop, catering to only the most exclusive clientel. "),
      ], new DreamReward(), QuestChainFeature.hasDreamSelf), Feature.LOW);


    prospitThemes[prospitTheme] = Theme.HIGH;
    derseThemes[derseTheme] = Theme.HIGH;
    furthestRingThemes[furthestRingTheme] = Theme.HIGH;

    prospit = new Moon.fromWeightedThemes(prospitRing, prospitScepter, "Prospit", prospitThemes, this, Aspects.LIGHT, session_id, ReferenceColours.PROSPIT_PALETTE);
    //;

    prospit.associatedEntities.addAll(npcHandler.getProspitians());
    derse = new Moon.fromWeightedThemes(derseRing, derseScepter, "Derse", derseThemes, this, Aspects.VOID, session_id +1, ReferenceColours.DERSE_PALETTE);
    // ;

    derse.associatedEntities.addAll(npcHandler.getDersites());
    //;

    furthestRing = new Moon.fromWeightedThemes(null,null,"Furthest Ring", furthestRingThemes, this, Aspects.SAUCE, session_id, ReferenceColours.DERSE_PALETTE);

    for(Player p in players) {
      p.syncToSessionMoon();
    }
    setupBattleField();
    prospit.spawnQueen();
    derse.spawnQueen();


    prospit.initRelationships(derse);
    derse.initRelationships(prospit);
  }

  //yes this should have been a get, but it's too annoying to fix now, used in too many places and refactoring menu doesn't know how to convert from method to get.
  List<Player> getReadOnlyAvailablePlayers() {
    List<Player> ret = new List<Player>();
    for(Player p in players){
      if(p.available) ret.add(p);
    }
    return ret;
  }


  void resetAvailableClasspects() {
    //make sure canon state is SET before we actually use it dunkass
    changeCanonState(this,getParameterByName("canonState",null));
    if(canonLevel == CanonLevel.CANON_ONLY) {
      this.available_classes_players = new List<SBURBClass>.from(SBURBClassManager.canon);
      this.available_classes_guardians = new List<SBURBClass>.from(SBURBClassManager.canon);
      this.available_aspects = new List<Aspect>.from(Aspects.canon);
    }else if(canonLevel == CanonLevel.FANON_ONLY) {
      this.available_classes_players = new List<SBURBClass>.from(SBURBClassManager.fanon);
      this.available_classes_guardians = new List<SBURBClass>.from(SBURBClassManager.fanon);
      this.available_aspects = new List<Aspect>.from(Aspects.fanon);
    }else {
      print("anything fucking goes");
      this.available_classes_players = new List<SBURBClass>.from(SBURBClassManager.all);
      this.available_classes_guardians = new List<SBURBClass>.from(SBURBClassManager.all);
      this.available_aspects = new List<Aspect>.from(Aspects.all);
    }
    this.required_aspects = <Aspect>[Aspects.TIME, Aspects.SPACE];
  }


  Future<Null> callNextIntro(int player_index) async{

    if (player_index >= this.players.length) {
      await tick(); //NOW start ticking
      return;
    }
    IntroNew s = new IntroNew(this);
    Player p = this.players[player_index];
    //

    //var playersInMedium = curSessionGlobalVar.players.slice(0, player_index+1); //anybody past me isn't in the medium, yet.
    List<Player> playersInMedium = this.players.sublist(0, player_index + 1);
    s.trigger(playersInMedium, p);
    s.renderContent(this.newScene(s.runtimeType.toString()), player_index); //new scenes take care of displaying on their own.
    this.processScenes(playersInMedium);
    //player_index += 1;
    //new Timer(new Duration(milliseconds: 10), () => callNextIntro(player_index)); //sweet sweet async
    SimController.instance.gatherStats(this);
    await window.requestAnimationFrame((num t) => callNextIntro(player_index + 1));
  }



  Future<Null> intro() async {
    //

    SimController.instance.initGatherStats();

    //advertisePatreon(SimController.instance.storyElement);
    //
    List<String> playerTitlesWithTag = new List<String>();
    for(Player p in this.players) {
      p.handleSubAspects();
      playerTitlesWithTag.add(p.htmlTitleWithTip());
    }

    List<String> npcsWithTag = new List<String>();
    for(GameEntity g in this.activatedNPCS) {
      npcsWithTag.add(g.htmlTitleWithTip());
    }


    appendHtml(SimController.instance.storyElement, "<Br><br>Game ${session_id} of  SBURB has been initiated. All prepare for the arrival of ${turnArrayIntoHumanSentence(playerTitlesWithTag)}. The ${turnArrayIntoHumanSentence(npcsWithTag)} seem to be especially anticipating them.<br><br>");
    processBigBadIntros();
    await callNextIntro(0);
  }

  void processBigBadIntros() {
    checkBigBadTriggers();
    if(ultimateShowdown) {
      DivElement fucked = new DivElement()
        ..setInnerHtml("The PLAYERS are fucked beyond all belief, hailing from a session where any and everyone worth their salt is locked in a neverending struggle for dominance. Good guys, bad guys and explosions, as far as the eye can see.<br><Br>");
      SimController.instance.storyElement.append(fucked);
    }
    //only check activated big bads for combo purposes, the non activated ones will happen in checkBigBadTriggers
    List<GameEntity> possibleTargets = new List<GameEntity>.from(activatedBigBads);
    //if you are not a big bad, dead or inactive, remove.
    possibleTargets.removeWhere((GameEntity item) => !(item is BigBad) || item.dead || !item.active);
    for(BigBad bb in possibleTargets) {
      if(bb.prologueText != null && bb.prologueText.isNotEmpty) {
        DivElement div = new DivElement()..setInnerHtml("${bb.prologueText}<Br><Br>");
        SimController.instance.storyElement.append(div);
      }
    }
  }

  Future<Null> processCombinedSession() async {
    //logger.info("TEST COMPLETE: processing combo session.");
    if(this.mutator.spaceField) {
      return; //you will do combo a different route.
    }
    Session tmpcurSessionGlobalVar = this.initializeCombinedSession();
    if (tmpcurSessionGlobalVar != null) {
      await doComboSession(tmpcurSessionGlobalVar);
    } else {
      //scratch fuckers.
      this.stats.makeCombinedSession = false; //can't make a combo session, and skiaia is a frog so no scratch.
      simulationComplete("Was eligible for a combo but it didn't have room.");
      renderAfterlifeURL(this);
      //renderScratchButton(this);
    }
  }

  Future<Null> doComboSession(Session tmpcurSessionGlobalVar) async {
    // logger.info("TEST COMPLETE: doing combo session.");

    int id = this.session_id;
    if(tmpcurSessionGlobalVar == null) tmpcurSessionGlobalVar = this.initializeCombinedSession();  //if space field this ALWAYS returns something. this should only be called on null with space field
    //maybe ther ARE no corpses...but they are sure as shit bringing the dead dream selves.
    List<Player> living = findLiving(tmpcurSessionGlobalVar.aliensClonedOnArrival);
    if(living.isEmpty) {
      appendHtml(SimController.instance.storyElement, "<br><Br>You feel a nauseating wave of space go over you. What happened? Wait. Fuck. That's right. The Space Player made it so that they could enter their own child Session. But. Fuck. Everybody is dead. This...god. Maybe...maybe the other Players can revive them? ");
    }else {
      appendHtml(SimController.instance.storyElement, "<br><Br> But things aren't over, yet. The survivors manage to contact the players in the universe they created. Their sick frog may have screwed them over, but the connection it provides to their child universe will equally prove to be their salvation. Time has no meaning between universes, and they are given ample time to plan an escape from their own Game Over. They will travel to the new universe, and register as players there for session <a href = 'index2.html?seed=${tmpcurSessionGlobalVar.session_id}'>${tmpcurSessionGlobalVar.session_id}</a>. You are a little scared to ask them why they are bringing the corpses with them. Something about...shipping??? That can't be right.");
    }
    checkSGRUB();
    if(this.mutator.spaceField) {
      window.scrollTo(0, 0);
      //querySelector("#charSheets").setInnerHtml(""); //don't do query selector shit anymore for speed reasons.
      //querySelector("#charSheets").setInnerHtml(""); //don't do query selector shit anymore for speed reasons.
      SimController.instance.storyElement.setInnerHtml("You feel a nauseating wave of space go over you. What happened? Huh. Is that.... a new session? How did the Players get here? Are they joining it? Will...it...even FIT having ${this.players.length} fucking players inside it? ");
    }

    //TODO test that this works.
    if(id == 4037) {
      window.alert("Who is Shogun???");
      this.session_id = 13;
    }
    if(id ==612) this.session_id = 413;

    //wastes effect you, too
    tmpcurSessionGlobalVar.mutator = mutator;
    await tmpcurSessionGlobalVar.startSession();
    //load(curSessionGlobalVar.players, <Player>[], ""); //in loading.js
    simulationComplete("Combo Session Returned");
  }



  Future<Null> reckoning() async {

    // this could be called, in theory, by an npc scene AND by the timer going off
    if(!didReckoning) {
      didReckoning = true;
      this.reckoningStarted = true;
      //this happens iff the reckoning doens't happen via two scepters
      if(!plzStartReckoning) {
        stats.timeoutReckoning = true;
        Scene s = new Reckoning(this);
        s.trigger(this.players);
        s.renderContent(this.newScene(s.runtimeType.toString(),));
      }
      if (!this.stats.doomedTimeline) {
        await reckoningTick();
      } else {
        simulationComplete("the reckoning doomed the timeline");
        renderAfterlifeURL(this);
      }
    }
  }

  Future<Null> restartSessionScratch() async {
    setHtml(SimController.instance.storyElement, '<canvas id="loading" width="1000" height="354"> ');
    window.scrollTo(0, 0);
    //await checkEasterEgg(this); start sessionw ill do this now, otherwise yellow yards don't work with eggs
    startSession();
  }

  Future<Null> reckoningTick([num time]) async {
    ////
    if (this.timeTillReckoning > -10) {
      this.timeTillReckoning += -1;
      this.processReckoning(this.players);
      SimController.instance.gatherStats(this);
      await window.requestAnimationFrame(reckoningTick);
      //new Timer(new Duration(milliseconds: 10), () => reckoningTick()); //sweet sweet async
    } else {
      Scene s = new Aftermath(this);
      s.trigger(this.players);
      s.renderContent(this.newScene(s.runtimeType.toString(), true));
      if (this.stats.makeCombinedSession == true) {
        await processCombinedSession(); //make sure everything is done rendering first
      } else {
        renderAfterlifeURL(this);
      }
      SimController.instance.gatherStats(this);
    }
  }





  void makeSurePlayersNotInSessionArentAvailable(List<Player> playerList) {
    for(Player p in players) {
      if(!playerList.contains(p)) {
        p.active = false;
        p.available = false;
      }
    }
  }

  //  //makes copy of player list (no shallow copies!!!!)
  List<Player> setAvailablePlayers(List<Player> playerList) {
    List<Player> ret = <Player>[];
    for (num i = 0; i < playerList.length; i++) {
      //dead players are always unavailable.
      if (!playerList[i].dead && playerList[i].active) {
        playerList[i].available = true;
        ret.add(playerList[i]);
      }else {
        playerList[i].available = false;
      }
    }
    return ret;
  }

  void resetNPCAvailability() {
    for(GameEntity g in activatedNPCS) {

      if(!g.dead) {
        //;
        g.available = true;
      }else {
        g.available = false;
      }
    }
  }



  //used to live in scene controller but fuck that noise (also used to be named processScenes2)
  void processScenes(List<Player> playersInSession) {
    //UserTag previousTag = createDebugTag("Processing Scenes");

    List<Player> avail = setAvailablePlayers(playersInSession);
    makeSurePlayersNotInSessionArentAvailable(playersInSession);
    resetNPCAvailability();
    //players used to go here but now i want them to go last
    List<GameEntity> cachedActivated = new List.from(activatedNPCS);
    //(since an npc can be activated during these scenes)
    for(GameEntity g in cachedActivated) {
      if(g.active && g.available && !g.dead) g.processScenes();
    }

    //keep it from being a concurrent mod if i activate (and thus get removed from list
    //print("processing scenes");
    checkBigBadTriggers();
    //logger.info("done processing big bads showing up");
    for(Player p in avail) {
      //;
      if(p.scenes.isEmpty) Scene.createScenesForPlayer(this, p);
      if(p.active && p.available && !p.dead) {
        //querySelector("#story").appendHtml("$p is both active and available and this is going through session.");
        p.processScenes();
      }else {
        p.handleAddingNewScenes();
      }
    }

    for (num i = 0; i < this.deathScenes.length; i++) {
      Scene s = this.deathScenes[i];
      if (s.trigger(playersInSession)) {
        //	session.scenesTriggered.add(s);
        s.renderContent(this.newScene(s.runtimeType.toString()));
      }
    }
    //previousTag.makeCurrent();
  }

  void checkBigBadTriggers() {
    //keep it from being a concurrent mod if i activate (and thus get removed from list
    List<GameEntity> bb = bigBadsReadOnly;
    //print("checking big bad trigger for $bb");
    for(GameEntity g in bb) {
      if(g is BigBad && !activatedBigBads.contains(g)) {
        //handles activation and rendering
        g.summonTriggered();
      }
      // logger.info("done processing $g showing up, big bads is $bigBads");
    }
  }

  void processReckoning(List<Player> playerList) {
    for (num i = 0; i < this.reckoningScenes.length; i++) {
      Scene s = this.reckoningScenes[i];
      if (s.trigger(playerList)) {
        //session.scenesTriggered.add(s);
        s.renderContent(this.newScene(s.runtimeType.toString()));
      }
    }

    for (num i = 0; i < this.deathScenes.length; i++) {
      Scene s = this.deathScenes[i];
      if (s.trigger(playerList)) {
        //	session.scenesTriggered.add(s);
        s.renderContent(this.newScene(s.runtimeType.toString()));
      }
    }
  }


  Player findBestSpace() {
    List<Player> spaces = findAllAspectPlayers(this.players, Aspects.SPACE);
    if (spaces.isEmpty) return null;
    Player ret = spaces[0];
    for (num i = 0; i < spaces.length; i++) {
      //the best space player either has the most quests done, OR has a land when the current best does not
      if (spaces[i].landLevel > ret.landLevel) {
        ret = spaces[i];
      }
    }

    //do a second loop to find the best space player with a land, if i can't find one, still return the one without a land
    if(ret.land == null || ret.land.dead) {
      for (num i = 0; i < spaces.length; i++) {
        //the best space player either has the most quests done, OR has a land when the current best does not
        if (spaces[i].landLevel > ret.landLevel || spaces[i].land != null) {
          //not enough to be better, need to also not be null
          if(spaces[i].land != null && !spaces[i].land.dead) ret = spaces[i];
        }
      }
    }
    return ret;
  }

  Player findMostCorruptedSpace() {
    List<Player> spaces = findAllAspectPlayers(this.players, Aspects.SPACE);
    if (spaces.isEmpty) return null;
    Player ret = spaces[0];
    for (num i = 0; i < spaces.length; i++) {
      if (spaces[i].landLevel < ret.landLevel) ret = spaces[i];
    }
    return ret; //lowest space player.
  }


  ///frog status is part actual tadpole, part grist
  bool sickFrogCheck(Player spacePlayer) {
    if(spacePlayer == null) return false; //it's actually NO frog, not sick
    //there is  a frog but it's not good enough
    bool frogSick = spacePlayer.landLevel < goodFrogLevel;
    bool frog = !noFrogCheck(spacePlayer);
    bool grist = enoughGristForFull();
    bool hasPlanet = spacePlayer.land != null;

    //frog is sick if it was bred wrong, or if it was nutured wrong
    return (frog && hasPlanet && (frogSick || !grist));

  }

  bool enoughGristForFull() {
    return getTotalGrist(players) > expectedGristContributionPerPlayer * players.length;
  }

  bool enoughGristForAny() {
    return getTotalGrist(players) > minimumGristPerPlayer * players.length;
  }

  int gristPercent() {
    return (100*(getTotalGrist(players)/(minimumGristPerPlayer * players.length))).floor();
  }



  bool fullFrogCheck(Player spacePlayer) {
    if(spacePlayer == null) return false;
    //there is  a frog but it's not good enough
    bool frogSick = spacePlayer.landLevel < goodFrogLevel;
    bool frog = !noFrogCheck(spacePlayer);
    bool grist = enoughGristForFull();
    bool rings = playersHaveRings();
    bool hasPlanet = spacePlayer.land != null;
    //frog is full if it was bred AND nurtured right.
    return (frog && rings && hasPlanet && (!frogSick &&  grist));
  }

  //don't care about grist, this is already p rare. maybe it eats grim dark and not grist???
  bool purpleFrogCheck(Player spacePlayer) {
    if(spacePlayer == null) return false;
    bool frog = spacePlayer.landLevel <= (this.minFrogLevel * -1);
    bool grist = enoughGristForAny();
    return (frog && grist);
  }

  //will this return false if either moon is destroyed??? that's weird
  bool playersHaveRings() {
    //if a ring is destroyed, it counts as being in the forge, even if it was destroyed through dumb shit like alchemy
    //the forge is just a game mechanic
    //all the session needs is the energy from teh ring
    GameEntity bqowner = derseRing == null  ?  null:derseRing.owner;
    GameEntity wqowner =  prospitRing == null  ?  null:prospitRing.owner;
    if(bqowner == null && wqowner == null) {
      //print("returning true because no one has the rings");
      return true;
    }
    if(bqowner == null && wqowner.alliedToPlayers) {
      //print("returning true because the black ring is destroyed adn the white ring belongs to the players");
      return true;
    }
    if(wqowner == null && bqowner.alliedToPlayers) {
      //print("returning true because the white ring is destroyed adn the black ring belongs to the players");
      return true;
    }
    //if we got here, either NEITHER are null, or ONE IS NULL and the OTHER IS AN ENEMY
    if(bqowner == null || wqowner == null) return false;
    return bqowner.alliedToPlayers && wqowner.alliedToPlayers;
  }


  //don't care about grist, if there's no frog to deploy at all. eventually check for rings
  bool noFrogCheck(Player spacePlayer) {
    if(spacePlayer == null) return false;
    bool frog =  spacePlayer.landLevel <= this.minFrogLevel;
    bool grist = !enoughGristForAny();
    bool rings  = !playersHaveRings();
    bool hasNoPlanet = spacePlayer.land == null || spacePlayer.land.dead;

    return (frog || grist || rings || hasNoPlanet);
  }

/*
    UserTag createDebugTag(String named) {
        var customTag = new UserTag(named);
        return customTag.makeCurrent();
    }*/

  void createScenesForPlayers() {
    //;
    for(Player p in players) {
      Scene.createScenesForPlayer(this, p);
    }
  }


  void checkSGRUB() {
    bool sgrub = true;
    for (num i = 0; i < players.length; i++) {
      if (players[i].isTroll == false) {
        sgrub = false;
      }
    }
    //can only get here if all are trolls.
    if (sgrub) {
      document.title = "SGRUBSim ${document.title}";
    }

    if (getParameterByName("nepeta", null) == ":33") {
      document.title = "NepetaQuest by jadedResearcher";
    }
    if (session_id == 33) {
      document.title = "NepetaQuest by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&nepeta=:33'>The furryocious huntress makes sure to bat at this link to learn a secret!</a>", treeSanitizer: NodeTreeSanitizer.trusted);
    } else if (session_id == 420) {
      document.title = "FridgeQuest by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&honk=:o)'>wHoA. lIkE. wHaT If yOu jUsT...ReAcHeD OuT AnD ToUcHeD ThIs? HoNk!</a>", treeSanitizer: NodeTreeSanitizer.trusted);
    } else if (session_id == 88888888) {
      document.title = "SpiderQuuuuuuuuest!!!!!!!! by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&luck=AAAAAAAALL'>Only the BEST Observers click here!!!!!!!!</a>", treeSanitizer: NodeTreeSanitizer.trusted);
    } else if (session_id == 0) {
      document.title = "0_0 by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&temporal=shenanigans'>Y0ur inevitabile clicking here will briefly masquerade as free will, and I'm 0kay with it.</a>");
    } else if (session_id == 413) { //why the hell is this one not triggering?
      "Homestuck Simulator by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&home=stuck'>A young man stands next to a link. Though it was 13 years ago he was given life, it is only today he will click it.</a>");
    } else if (session_id == 111111) { //why the hell is this one not triggering?
      document.title = "Homestuck Simulator by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&home=stuck'>A young lady stands next to a link. Though it was 16 years ago she was given life, it is only today she will click it.</a>");
    } else if (session_id == 613) {
      document.title = "OpenBound Simulator by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&open=bound'>Rebubble this link?.</a>", treeSanitizer: NodeTreeSanitizer.trusted);
    } else if (session_id == 612) {
      document.title = "HiveBent Simulator by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&hive=bent'>A young troll stands next to a click horizon. Though it was six solar sweeps ago that he was given life, it is only today that he will click it.</a>");
    } else if (session_id == 1025) {
      document.title = "Fruity Rumpus Asshole Simulator by jadedResearcher";
      SimController.instance.storyElement.appendHtml(" <a href = 'index2.html?seed=${getRandomSeed()}&rumpus=fruity'>I will have order in this RumpusBlock!!!</a>", treeSanitizer: NodeTreeSanitizer.trusted);
    }
  }

  //players should be created before i start
  Future<Session> startSession() async {

    logger.info("session is starting");
    await checkEasterEgg(this);
    //UserTag previousTag = createDebugTag("Session$session_id");
    SimController.instance.currentSessionForErrors = this;
    globalInit(); // initialise classes and aspects if necessary
    logger.info("session has ${players.length} players");
    /*
        //we await this because of the fan ocs being loaded from file like assholes.
        checkEasterEgg(this);
        //print(npcHandler.debugNPCs());
        await SimController.instance.easterEggCallBack(this);
        */
    print("about to start, seed is ${rand.spawn().nextInt()}");
    if(tableGuardianMode) {
      //no one is entering, no one needs loaded , just go
      tick();
    }else if (doNotRender == true) {
      intro();
    } else {
      load(this,players, getGuardiansForPlayers(players), "");
    }
    //previousTag.makeCurrent();

    return completer.future;
  }

  void getPlayersReady() {
    this.makePlayers();
    this.randomizeEntryOrder();
    this.makeGuardians(); //after entry order established
  }

  void simulationComplete(String ending) {
    if(completer == null) {
      // logger.error("TEST COMPLETION: Uh. Tried to complete something that hadn't been created yet. What???");
      return;
    }
    //logger.info("TEST COMPLETION: before session complete from $ending, with players ${players} with ticks: ${numTicks} with won: ${stats.won}, frog status ${frogStatus()} and scratch status of ${stats.scratched} and scratch available of ${stats.scratchAvailable}");
    //allow you to call this multiple times (reiniting will ALWAYS complete before making a new completer)
    try {
      this.completer.complete(this);
    }catch(e) {
      // logger.info("completing from  $ending had an error $e, probably cuz i tried to do it twice");
    }
    //logger.info("after session complete from $ending, with won: ${stats.won}, frog status:  ${frogStatus()}");

  }

  Future<Null> tick([num time]) async{
    //UserTag previousTag = createDebugTag("Ticking");

    this.numTicks ++;
    if(tableGuardianMode) players.clear();
    //
    ////
    //don't start  a reckoning until at least one person has been to the battlefield.
    //if everyone is dead, you can end. no more infinite jack sessions

    /*

        TODO:
            two things can start the reckoning: enough time passing (shenanigans launch the meteors)
            or someone having both scepters.
         */
    if(plzStartReckoning || numTicks > SimController.instance.maxTicks || (currentSceneNum > SimController.instance.maxScenes && tableGuardianMode) ||  (findLiving(players).isEmpty && !tableGuardianMode)) {
      if(numTicks > SimController.instance.maxTicks) stats.timeoutReckoning = true;
      this.logger.info("reckoning at ${this.timeTillReckoning} and can reckoning is ${this.canReckoning}");
      this.timeTillReckoning = 0; //might have gotten negative while we wait.
      await reckoning();
    }else if (!this.stats.doomedTimeline) {
      this.timeTillReckoning += -1;
      this.processScenes(this.players);
      SimController.instance.gatherStats(this);
      await window.requestAnimationFrame(tick);
    }
    //if we are doomed, we crashed, so don't do anything.
    //previousTag.makeCurrent();
  }

  void activateAllCarapaces() {
    for(GameEntity g in derse.associatedEntities) {
      g.active = true;
    }

    for(GameEntity g in prospit.associatedEntities) {
      g.active = true;
    }
  }

  void makePlayers() {
    logger.info("making players from seed ${rand.spawn().nextInt()}");
    this.players = <Player>[];
    if(tableGuardianMode) {
      activateAllCarapaces();
    }else{
      resetAvailableClasspects();
      print("after reseting classpects, got $canonLevel");
      int numPlayers = this.rand.nextIntRange(
          2, 12); //rand.nextIntRange(2,12);
      double special = rand.nextDouble();

      List<Player> replayer = getReplayers(this);
      if (replayer.isEmpty) {
        this.players.add(randomSpacePlayer(this));
        this.players.add(randomTimePlayer(this));
        for (int i = 2; i < numPlayers; i++) {
          this.players.add(randomPlayer(this));
        }

        //random chance of Lord/Muse for two player sessions
        if (numPlayers <= 2) {
          ;
          if (special > .6) {
            players[0].class_name = SBURBClassManager.LORD;
            players[1].class_name = SBURBClassManager.MUSE;
            players[0].initializeDerivedStuff();
            players[1].initializeDerivedStuff();

          } else if (special < .3) {
            players[0].class_name = SBURBClassManager.MUSE;
            players[1].class_name = SBURBClassManager.LORD;
            players[0].initializeDerivedStuff();
            players[1].initializeDerivedStuff();
          }
        }
      } else {
        players = new List.from(replayer);
      }

      logger.info("players is $players");
      playerInitialization();
    }
  }

  //called immediately after making players, whether replayers or natives
  void playerInitialization() {
    for (num j = 0; j < this.players.length; j++) {
      Player p = this.players[j];
      p.generateRelationships(this.players);
      if(p.aspect != Aspects.TIME) {
        p.active = false;
      }else {
        p.active = true;
      }
    }

    Relationship.decideInitialQuadrants(rand, this.players);

    //this.hardStrength = 500 + 20 * this.players.length;
    Sprite weakest = Stats.POWER.min(this.players.map((Player p) => p.sprite));
    double weakpower = weakest.getStat(Stats.POWER) / Stats.POWER.coefficient;
    this.hardStrength = (4000 + this.players.length * (85 + weakpower)) * Stats.POWER.coefficient;

    createScenesForPlayers();
    logger.info("TEST DATASTRING: done initializing players");
  }

  String convertPlayerNumberToWords() {
    //alien players don't count
    List<Player> ps = findPlayersFromSessionWithId(this.players, this.session_id);
    if (ps.isEmpty) {
      ps = this.players;
    }
    int length = ps.length;
    if (length == 2) {
      return "TWO";
    } else if (length == 3) {
      return "THREE";
    } else if (length == 4) {
      return "FOUR";
    } else if (length == 5) {
      return "FIVE";
    } else if (length == 6) {
      return "SIX";
    } else if (length == 7) {
      return "SEVEN";
    } else if (length == 8) {
      return "EIGHT";
    } else if (length == 9) {
      return "NINE";
    } else if (length == 10) {
      return "TEN";
    } else if (length == 11) {
      return "ELEVEN";
    } else if (length == 12) {
      return "TWELVE";
    } else {
      return "???";
    }
  }

  void makeGuardians() {
    ////;
    resetAvailableClasspects();
    //guardians have to pick from existing classes.
    available_classes_guardians = SBURBClassManager.playersToClasses(players);

    List<Player> guardians = <Player>[];
    for (num i = 0; i < this.players.length; i++) {
      Player player = this.players[i];
      player.makeGuardian();
      guardians.add(player.guardian);
    }

    for (num j = 0; j < this.players.length; j++) {
      Player g = this.players[j].guardian;
      g.generateRelationships(guardians);
    }
    Relationship.decideInitialQuadrants(rand, guardians);
  }

  void randomizeEntryOrder() {
    this.players = shuffle(this.rand, this.players);
    if(this.players.isNotEmpty)this.players[0].leader = true;
  }

  String getSessionType() {
    if(sessionType < 0 ) sessionType = rand.nextDouble();
    // logger.info("session type is $sessionType");
    if (this.sessionType > .6) {
      return "Human";
    } else if (this.sessionType > .3) {
      return "Troll";
    }
    return "Mixed";
  }



  @override
  String toString() {
    return session_id.toString();
  }

  Element newScene(String callingScene, [overRideVoid =false]) {
    numScenes ++;
    this.currentSceneNum ++;
    Element ret = new DivElement();
    ret.id = 'scene${this.currentSceneNum}';
    ret.classes.add("scene");
    String lightBS = "";
    String innerHTML = "";
    bool debugMode = getParameterByName("debug") == "fuckYes";
    if(debugMode || mutator.lightField) lightBS = "Session ID: $session_id Scene ID: ${this.currentSceneNum} Tick Num: $numTicks, Name: ${callingScene}  Session Health: ${sessionHealth}, Power coefficent: ${Stats.POWER.coefficient},  TimeTillReckoning: ${timeTillReckoning} Last Rand: ${rand.spawn().nextInt()}, Mutator: ${mutator}";
    if (this.sbahj) {
      ret.classes.add("sbahj");
      int reallyRand = getRandomIntNoSeed(1, 10);
      for (int i = 0; i < reallyRand; i++) {
        int indexOfTerribleCSS = getRandomIntNoSeed(0, terribleCSSOptions.length - 1);
        List<String> tin = terribleCSSOptions[indexOfTerribleCSS];
        if (tin[1] == "????") {
          tin[1] = "${getRandomIntNoSeed(1, 100)}%";
        }
        ret.style.setProperty(tin[0], tin[1]);
        //;
      }
    }
    if (ouija == true) {
      int trueRandom = getRandomIntNoSeed(1, 4);
      innerHTML = "<img class = 'pen15' src = 'images/pen15_bg$trueRandom.png'> $lightBS";
    }else {
      innerHTML = "$lightBS";
    }

    //instead of appending you're replacing. Void4 is SERIOUS about you not getting to see.
    if(mutator.voidField && !overRideVoid) {
      if(SimController.instance.voidStory == null) {
        doNotRender = true;
        numScenes = 0; //since we're lying to AB anyway, use this to keep track of how many scenes we skipped due to void
        doNotFetchXml = true;
        SimController.instance.voidStory = new DivElement();
        SimController.instance.voidStory.id = "voidStory";
        SimController.instance.storyElement.append(SimController.instance.voidStory);
      }
      SimController.instance.voidStory.setInnerHtml("${"<br>"*numScenes}");//one br for each skipped scene
      return ret;
    }else if(overRideVoid) {
      logger.info("am i setting do not render to false?");
      //doNotRender = false; //this fucks AB up. don't do it. but at least they'll see the text.
    }

    ret.setInnerHtml(innerHTML);
    SimController.instance.storyElement.append(ret);
    return ret;
  }

}