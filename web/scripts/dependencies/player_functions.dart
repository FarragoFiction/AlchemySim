import 'SBURBSim.dart';

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