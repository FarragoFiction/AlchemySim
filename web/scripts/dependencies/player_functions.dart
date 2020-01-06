import 'SBURBSim.dart';

Player randomPlayerWithClaspect(Session session) {
  bool gd = false;
  Player p = new Player();
  p.interest1 = InterestManager.getRandomInterest(session.rand);
  p.interest2 = InterestManager.getRandomInterest(session.rand);
  return p;
}


Player randomPlayer(Session session) {
  return randomPlayerWithClaspect(session);
}
