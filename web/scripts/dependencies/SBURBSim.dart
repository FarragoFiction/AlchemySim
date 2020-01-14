import 'colour.dart';
import 'fraymotif.dart';
import 'FraymotifEffect.dart';
import 'GameEntity.dart';
import 'Gristmas.dart';
import 'handle_sprites.dart';
import 'JSONObject.dart';
import 'lz-string.dart';
import 'navbar.dart';
import 'NPCS.dart';
import 'Player.dart';
import 'player_functions.dart';
import 'random.dart';
import 'random_tables.dart';
import 'session.dart';
import 'stat.dart';
import 'statholder.dart';
import '../../AlchemyController.dart';
import '../AlchemyResult.dart';
import '../Item.dart';
import '../MagicalItem.dart';
import '../Specibus.dart';
import '../Trait.dart';
import 'Interest.dart';
import 'Aspect.dart';
import 'weighted_lists.dart';
import 'SBURBClass.dart';

export 'colour.dart';
export 'fraymotif.dart';
export 'FraymotifEffect.dart';
export 'GameEntity.dart';
export 'Gristmas.dart';
export 'handle_sprites.dart';
export 'JSONObject.dart';
export 'lz-string.dart';
export 'navbar.dart';
export 'NPCS.dart';
export 'Player.dart';
export 'player_functions.dart';
export 'random.dart';
export 'random_tables.dart';
export 'session.dart';
export 'stat.dart';
export 'statholder.dart';
export '../../AlchemyController.dart';
export '../AlchemyResult.dart';
export '../Item.dart';
export '../MagicalItem.dart';
export '../Specibus.dart';
export '../Trait.dart';
export 'weighted_lists.dart';
export 'SBURBClass.dart';
export 'Interest.dart';
export 'Aspect.dart';


bool doneGlobalInit = false;
Future<Null> globalInit() async {
  if (doneGlobalInit) { return; }
  doneGlobalInit = true;
  //Stats.init();
  ItemTraitFactory.init();
  SpecibusFactory.init();
  //FeatureFactory.init(); //do BEFORE classes or aspects or you're gonna have a bad time (null features) PL figured this out
  //SBURBClassManager.init();
  //Aspects.init(); //todo fix
  InterestManager.init();

  //Loader.init();
  //await NPCHandler.loadBigBads();

}