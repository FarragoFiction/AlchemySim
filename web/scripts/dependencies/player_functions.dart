import 'SBURBSim.dart';

Player randomPlayerWithClaspect(Session session, SBURBClass c, Aspect a) {
  bool gd = false;

  Player p = new Player(session, c, a);
  p.interest1 = InterestManager.getRandomInterest(session.rand);
  p.interest2 = InterestManager.getRandomInterest(session.rand);
  return p;
}


Player randomPlayer(Session session) {
  //remove class AND aspect from available
  SBURBClass c = session.rand.pickFrom(SBURBClass.all);
  Aspect a = session.rand.pickFrom(Aspects.all);
  return randomPlayerWithClaspect(session, c, a);
}