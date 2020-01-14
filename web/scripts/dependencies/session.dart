import 'dart:developer';
import "dart:html";
import "dart:async";
import "SBURBSim.dart";
//okay, fine, yes, global variables are getting untenable.
class Session {

  static Session _defaultSession;


  int session_id; //initial seed
  //var sceneRenderingEngine = new SceneRenderingEngine(false); //default is homestuck  //comment this line out if need to run sim without it crashing
  List<Player> players = <Player>[];

  //if i have less than expected grist, then no frog, bucko
  Random rand;

  Session(int this.session_id, [bool isCombo= false]) {
    globalInit();
    this.rand = new Random(session_id);
    //npcHandler.setupNpcs(); reinit will handle this
    //reinit first, to match scratches and yards and shit, make players with fresh seed essentially
  }



}