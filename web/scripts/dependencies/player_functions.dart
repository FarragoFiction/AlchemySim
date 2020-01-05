import 'SBURBSim.dart';

Player randomPlayerWithClaspect(Session session) {
  ////;
  // //;


  bool gd = false;


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
