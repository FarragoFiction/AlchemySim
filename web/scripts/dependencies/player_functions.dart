import 'SBURBSim.dart';

/*
oh my fucking god 234908u2alsk;d
javascript, you shitty shitty langugage
why the fuck does trying to decode a URI that is null, return the string "null";
why would ANYONE EVER WANT THAT!?????????
javascript is "WAT"ing me
because of COURSE "null" == null is fucking false, so my code is like "oh, i must have some players" and then try to fucking parse!!!!!!!!!!!!!!*/
List<Player> getReplayers(Session session) {
  //replayers are only for the originating session
  if(session.stats.isComboedInto) return new List<Player>();
  print("session $session was comboed into? ${session.stats.isComboedInto}");
  //needed or i can't parse moon data
  if(session.prospit == null) session.setupMoons("getting replayers");
//	var b = LZString.decompressFromEncodedURIComponent(getRawParameterByName("b"));
  //var available_classes_guardians = classes.sublist(0); //if there are replayers, then i need to reset guardian classes
  String raw = getRawParameterByName("b", null);
  if (raw == null) return <Player>[]; //don't even try getting the rest.
  String b = Uri.decodeComponent(LZString.decompressFromEncodedURIComponent(getRawParameterByName("b", null)));
  String s = LZString.decompressFromEncodedURIComponent(getRawParameterByName("s", null));
  String x = (getRawParameterByName("x", null));
  //;
  if (b == null || s == null) return <Player>[];
  if (b == "null" || s == "null") return <Player>[]; //why was this necesassry????????????????
  ////;
  ////print(b);
  ////;
  ////print(s);
  List<Player> ret =  dataBytesAndStringsToPlayers(session,b, s, x);
  //can't let them keep their null session reference.
  //session.logger.info("replayers are $ret before moon syncing");

  for(Player p in ret) {
    p.session = session;
    p.syncToSessionMoon();
    p.initialize();
  }
  //session.logger.info("replayers are $ret");
  return ret;
}


Player randomPlayerWithClaspect(Session session, SBURBClass c, Aspect a, [Moon m = null]) {
  ////;
  // //;
  GameEntity k = session.rand.pickFrom(PotentialSprite.prototyping_objects);
  k.session = session;

  bool gd = false;

  if(m == null) {
    m = session.rand.pickFrom(session.moons);
    //;
  }else {
    // ;
  }
  Player p = new Player(session, c, a, k, m, gd);
  p.decideTroll();
  p.interest1 = InterestManager.getRandomInterest(session.rand);
  p.interest2 = InterestManager.getRandomInterest(session.rand);
  p.initialize();

  //no longer any randomness directly in player class. don't want to eat seeds if i don't have to.
  p.baby = session.rand.nextIntRange(1, 3);

  p.hair = session.rand.nextIntRange(1, Player.maxHairNumber); //hair color in decide troll
  p.leftHorn = session.rand.nextIntRange(1, 46);
  p.rightHorn = p.leftHorn;
  if (session.rand.nextDouble() > .7) { //preference for symmetry
    p.rightHorn = session.rand.nextIntRange(1, 46);
  }

  return p;
}


Player randomPlayer(Session session) {
  //remove class AND aspect from available
  SBURBClass c = session.rand.pickFrom(session.available_classes_players);
  removeFromArray(c, session.available_classes_players);
  Aspect a = session.rand.pickFrom(session.available_aspects);
  removeFromArray(a, session.available_aspects);
  return randomPlayerWithClaspect(session, c, a);
}


Player randomSpacePlayer(Session session) {
  //remove class from available
  SBURBClass c = session.rand.pickFrom(session.available_classes_players);
  removeFromArray(c, session.available_classes_players);
  Aspect a = Aspects.SPACE;
  removeFromArray(a, session.available_aspects);
  return randomPlayerWithClaspect(session, c, a);
}


Player randomTimePlayer(Session session) {
  //remove class from available
  SBURBClass c = session.rand.pickFrom(session.available_classes_players);
  removeFromArray(c, session.available_classes_players);
  Aspect a = Aspects.TIME;
  removeFromArray(a, session.available_aspects);
  return randomPlayerWithClaspect(session, c, a);
}


List<Player> findAllAspectPlayers(List<GameEntity> playerList, Aspect aspect) {
  if(playerList.isEmpty) return <Player>[];
  Session session = playerList.first.session;

  if(session.mutator.lightField && session.mutator.inSpotLight != null) return [session.mutator.inSpotLight];
  List<Player> ret = <Player>[];
  for (int i = 0; i < playerList.length; i++) {
    GameEntity g = playerList[i]; //could be a sprite, only work for player
    if (g is Player) {
      Player p = playerList[i];
      if (p.aspect.isThisMe(aspect)) {
        ////;
        ret.add(p);
      }
    }
  }
  return ret;
}


List<T> findDeadPlayers<T extends GameEntity>(List<T> playerList) {
  List<T> ret = <T>[];
  for (int i = 0; i < playerList.length; i++) {
    T p = playerList[i];
    if (p.dead || (playerList[i].session.mutator.doomField && !p.dead)) {
      ret.add(p);
    }
  }
  return ret;
}

//TODO shove this somewhere mroe useful, rename so not just players
//take in a generic type as long as it extends generic and return a generic type, you get mix of sprites and players, returns that way.i hope
List<T> findLiving<T extends GameEntity> (List<T> playerList){
  List<T> ret = new List<T>();
  for (int i = 0; i < playerList.length; i++) {
    if (!playerList[i].dead || (playerList[i].session.mutator.doomField && playerList[i].dead )) { //the dead are alive.
      ret.add(playerList[i]);
    }
  }
  return ret;
}



String getPlayersTitlesBasic(List<GameEntity> playerList) {
  if (playerList.isEmpty) {
    return "";
  }
  String ret = playerList[0].htmlTitleBasic();
  for (int i = 1; i < playerList.length; i++) {
    ret = "$ret and ${playerList[i].htmlTitleBasic()}";
  }
  return ret;
}



//don't override existing source
void setEctobiologicalSource(List<Player> playerList, num source) {
  for (int i = 0; i < playerList.length; i++) {
    Player p = playerList[i];
    Player g = p.guardian; //not doing this caused a bug in session 149309 and probably many, many others.
    if (p.ectoBiologicalSource == null) {
      p.ectoBiologicalSource = source;
      if(g != null) g.ectoBiologicalSource = source;
    }
  }
}

//deeper than a snapshot, for yellowyard aliens
//have to treat properties that are objects differently. luckily i think those are only player and relationships.
Player clonePlayer(Player player, Session session, bool isGuardian) {
  if(player == null) return null;
  Player clone = player.clone();
  if (!isGuardian && clone.guardian != null) {  //tier4 gnosis can make some weird shit happen
    Player g = clonePlayer(player.guardian, session, true);
    clone.guardian = g;
    g.guardian = clone;
  }
  //;
  return clone;
}


List<Player> findPlayersFromSessionWithId(List<Player> playerList, num source) {
  List<Player> ret = <Player>[];
  for (int i = 0; i < playerList.length; i++) {
    Player p = playerList[i];
    //if it' snull, you could be from here, but not yet ectoborn
    if (p.ectoBiologicalSource == source || p.ectoBiologicalSource == null) {
      ret.add(p);
    }
  }
  return ret;
}


List<Player> getGuardiansForPlayers(List<Player> playerList) {
  List<Player> tmp = <Player>[];
  for (int i = 0; i < playerList.length; i++) {
    Player g = playerList[i].guardian;
    if(i == 0) g.leader = true;
    tmp.add(g);
  }
  return tmp;
}

num getTotalGrist(List<GameEntity> players) {
  if (players.isEmpty) return 0;
  num ret = 0;
  for (int i = 0; i < players.length; i++) {
    ret += players[i].grist;
  }
  return ret;
}