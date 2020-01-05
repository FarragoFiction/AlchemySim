import 'dart:async';
import 'dart:convert';
import "dart:html";
import "dart:math" as Math;
import "dart:typed_data";
import 'SBURBSim.dart';
import "bytebuilder.dart";
import 'PlayerSpriteHandler.dart';


class Player extends GameEntity{
  //TODO trollPlayer subclass of player??? (have subclass of relationship)
  num baby = null;

  //set when you set moon, so you know what your dream self looks like even if you don't have a moon.
  Palette dreamPalette;

  //if 0, not yet woken up.
  double moonChance = 0.0;
  Sprite sprite = null; //gets set to a blank sprite when character is created.
  bool deriveChatHandle = true;
  bool deriveSprite = true;
  bool deriveSpecibus = true;
  bool deriveLand = true;
  String flipOutReason = null; //if it's null, i'm not flipping my shit.
  bool trickster = false;
  bool sbahj = false;
  bool robot = false;
  num ectoBiologicalSource = null; //might not be created in their own session now.
  SBURBClass class_name;
  Player _guardian = null; //no longer the sessions job to keep track
  bool baby_stuck = false;
  String influenceSymbol = null; //multiple aspects can influence/mind control.
  Aspect aspect;
  Land land;
  //want to be able to see when it's set
  Moon _moon;
  Interest interest1 = null;
  Interest interest2 = null;
  String chatHandle = null;
  GameEntity object_to_prototype; //mostly will be potential sprites, but sometimes a player
  //List<Relationship> relationships = [];  //TODO keep a list of player relationships and npc relationships. MAYBE don't wax red for npcs? dunno though.
  List<String> mylevels = null;
  num level_index = -1; //will be ++ before i query
  bool godTier = false;
  String victimBlood = null; //used for murdermode players.
  num hair = null; //num hair = 16;
  String hairColor = null;
  bool dreamSelf = true;
  bool isTroll = false; //later
  String bloodColor = "#ff0000"; //human red.
  num leftHorn = null;
  num rightHorn = null;
  GameEntity myLusus = null;
  Quirk quirk = null;

  bool godDestiny = false;
  bool isDreamSelf = false; //players can be triggered for various things. higher their triggerLevle, greater chance of going murdermode or GrimDark.
  bool murderMode = false; //kill all players you don't like. odds of a just death skyrockets.
  bool leftMurderMode = false; //have scars, unless left via death.
  num gnosis = 0; //sburbLore causes you to increase a level of this.
  double landLevel = 0.0; //at 10, you can challenge denizen.  only space player can go over 100 (breed better universe.)
  Moon get moon => _moon;


  void set moon(Moon m) {
    if(m != null) ;
    _moon = m;
    if(m!=null) {
      dreamPalette = _moon.palette;
      syncToSessionMoon();
    }
  }




  @override
  String get name => "${title()}($chatHandle)";


  Player([Session session, SBURBClass this.class_name, Aspect this.aspect, GameEntity this.object_to_prototype, Moon m, bool this.godDestiny]) : super("", session) {
    //;
    moon = m; //set explicitly so triggers syncing.
    //testing something
  }



  //stop having references to fake as fuck moons yo.
  //make sure you refere to private moon so you don't get in infinite loop
  void syncToSessionMoon() {
    //;
    if(moon == null || session == null || session.prospit == null || session.derse == null) return;
    //;
    if (moon.name == session.prospit.name) {
      ;
      _moon = session.prospit;
    } else if (moon.name == session.derse.name) {
      ;
      _moon = session.derse;
    }
  }


  void copyFromOCDataString(String ocDataString) {
    String bs = "${window.location}?" + ocDataString; //need "?" so i can parse as url
    if(window.location.toString().contains("?")) bs = "${window.location}&" + ocDataString;
    String b = (getParameterByName("b", bs)); //this is pre-decoded, if you try to decode again breaks mages of heart which are "%"
    String s = getParameterByName("s", bs);
    String x = (getParameterByName("x", bs));
    List<Player> players = dataBytesAndStringsToPlayers(session,b, s, x); //technically an array of one players.;
    this.copyFromPlayer(players[0]);
  }


  @override
  List<Fraymotif> get fraymotifsForDisplay {
    List<Fraymotif> ret = new List.from(fraymotifs);
    //;
    for(Item item in sylladex) {
      //;

      if(item is MagicalItem && aspect.isThisMe(Aspects.SAUCE)) {
        MagicalItem m = item as MagicalItem;
        //only sauce players can use the ring
        ret.addAll(m.fraymotifs);
      }else if(Item is MagicalItem) {
        //MagicalItem m = item as MagicalItem;
        //if(!(m is Ring) && !(m is Scepter) ) ret.addAll(m.fraymotifs);
      }
    }
    return ret;
  }

  Player get guardian {
    if(_guardian == null) {
      makeGuardian();
    }
    return _guardian;
  }

  void set guardian(Player g) {
    _guardian = g;
  }



  @override
  String title() {
    String ret = "$extraTitle ";

    if (this.villain) ret = "${ret}Villainous ";


    if(this.crowned != null) {
      ret = "${ret}Crowned ";
    }

    if(this.leader) {
      //ret = "${ret}Leader ";
    }

    if (this.doomed) {
      ret = "${ret}Doomed ";
    }

    if (this.trickster) {
      ret = "${ret}Trickster ";
    }

    if (this.murderMode) {
      ret = "${ret}Murder Mode ";
    }

    if (this.grimDark > 3) {
      ret = "${ret}Severely Grim Dark ";
    } else if (this.grimDark > 1) {
      ret = "${ret}Mildly Grim Dark ";
    } else if (this.grimDark > 2) {
      ret = "${ret}Grim Dark ";
    }

    if (this.godTier) {
      ret = "${ret}God Tier ";
    } else if (this.isDreamSelf) {
      ret = "${ret}Dream ";
    }
    if (this.robot) {
      ret = "${ret}Robo";
    }

    if (this.gnosis == 4) {
      ret = "${ret}Wasted ";
    }
    //refrance to shogun's april fools artwork
    if(aspect == Aspects.SAUCE) {
      ret = "$ret${this.class_name.sauceTitle} of ${this.aspect}";
    }else {
      ret = "$ret${this.class_name} of ${this.aspect}";
    }
    if (this.dead) {
      ret = "$ret's Corpse";
    } else if (this.ghost) {
      ret = "$ret's Ghost";
    }else if(this.brainGhost) {
      ret = "$ret's Brain Ghost";

    }

    return ret;
  }

  String htmlTitleBasicNoTip() {
    return "${this.aspect.fontTag()}${this.titleBasic()}</font> (<font color = '${getChatFontColor()}'>${chatHandle}</font>)";
  }

  //@override
  String titleBasic() {
    String ret = "";

    ret = "$ret${this.class_name} of ${this.aspect}";
    return ret;
  }

  //what gets displayed when you hover over any htmlTitle (even HP)
  String getToolTip() {
    if (Drawing.checkSimMode() == true) {
      return "<span>";
    }
    String ret = "<span class = 'tooltip'><span class='tooltiptext'><table>";
    ret += "<tr><td class = 'toolTipSection'>$chatHandle<hr>";
    ret += "Class: ${class_name.name}<Br>";
    ret += "Aspect: ${aspect.name}<Br>";
    String landString = "DESTROYED.";
    if(land != null) landString = land.name;
    ret += "Land: ${landString}<Br>";
    String denizen = "NONE";
    if(land != null) denizen = land.denizenFeature.name;

    ret += "Denizen: $denizen<Br>";

    ret += "LandLevel: $landLevel<Br>";
    ret += "Gnosis: $gnosis<Br>";
    if(sprite != null) ret += "Sprite: ${sprite.name}";
    if(sprite != null && sprite.dead) ret += " (dead)";
    ret += "<br><Br>Prophecy Status: ${prophecy}";
    ret += "<br><br>Flipping out over: ${flipOutReason}";

    ret += "</td>";
    Iterable<Stat> as = Stats.summarise;
    ret += "<td class = 'toolTipSection'>Stats<hr>";
    for (Stat stat in as) {
      int baseValue = getStat(stat,true).round();
      int derivedValue = getStat(stat).round();
      ret += "$stat: ${baseValue} (+ ${derivedValue-baseValue})<br>";
    }
    ret += "Grist: $grist)<br>";


    ret += "</td>";
    ret += "<td class = 'toolTipSection'>Companions<hr>";
    for(GameEntity g in companionsCopy) {
      String species  = "";
      if(g is Leprechaun) species = "(Leprechaun)";
      if(g is Consort) species = "(Consort)";
      if(g is Carapace && (g as Carapace).type == Carapace.DERSE) species = "(Dersite)";
      if(g is Carapace && (g as Carapace).type == Carapace.PROSPIT) species = "(Prospitian)";

      ret += "${g.title()} $species<br>";
    }

    ret += "</td><td class = 'toolTipSection' rowspan='2'>Sylladex<hr>";
    ret += "Specibus: ${specibus.fullNameWithUpgrade}, Rank: ${specibus.rank}<br><br>";

    for(Item item in sylladex) {
      ret += "${item.fullNameWithUpgrade}<br>";
    }

    ret += "</td><td class = 'toolTipSection' rowspan='2'>AI<hr>";

    for (Scene s in scenes) {
      if(s is SerializableScene) {
        ret += "${s}<br>";
      }else {
        ret += "???<br>";
      }
    }


    ret += "</td><td class = 'toolTipSection' rowspan='2'>Buffs<hr>";



    for (Buff b in buffs) {
      ret += "$b<br>";
    }

    for (AssociatedStat s in associatedStats) {
      ret += "$s<br>";
    }

    ret += "</td></tr><tr><td class = 'toolTipSection'>Fraymotifs<hr>";
    for(Fraymotif f in fraymotifs) {
      ret += "${f.name}<br>";
    }
    if(aspect is AspectWithSubAspects) {
      AspectWithSubAspects sa = aspect as AspectWithSubAspects;
      for(Aspect a in sa.subAspects) {
        ret += "Aspectal ${a.name}<br>";
      }
    }

    ret += "</td><td class = 'toolTipSection'>Relationships<hr>";
    for(Relationship r in relationships) {
      ret += "$r<br>";
    }
    ret += "</td></tr></table></span>";
    return ret;
  }

  List<Fraymotif> psionicList() {
    List<Fraymotif> psionics = <Fraymotif>[];
    //telekenisis, mind control, mind reading, ghost communing, animal communing, laser blasts, vision xfold.
        {
      Fraymotif f = new Fraymotif("Telekinesis", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " Large objects begin pelting the ENEMY. ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Pyrokinesis", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " Who knew shaving cream was so flammable? ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Aquakinesis", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " A deluge begins damaging the ENEMY. ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Electrokinesis", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " An electric pulse begins damaging the ENEMY. ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Terakinesis", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " The very ground begins damaging the ENEMY. ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Vitaekinesis", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " The ENEMY's own body is turned against them as they begin punching their own face. ";
      psionics.add(f);
    }
    {
      Fraymotif f = new Fraymotif("Fungikinesis", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " A confusing array of mushrooms begins damaging the ENEMY. ";
      psionics.add(f);
    }


    {
      Fraymotif f = new Fraymotif("Mind Control", 1);
      f.effects.add(new FraymotifEffect(Stats.FREE_WILL, 3, true));
      f.effects.add(new FraymotifEffect(Stats.FREE_WILL, 3, false));
      f.desc = " All enemies start damaging themselves. It's kind of embarassing how easy this is.  ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Optic Blast", 1);
      f.effects.add(new FraymotifEffect(Stats.POWER, 2, true));
      f.desc = " Appropriately colored eye beams pierce the ENEMY. ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Ghost Communing", 1);
      f.effects.add(new FraymotifEffect(Stats.SANITY, 3, true));
      f.effects.add(new FraymotifEffect(Stats.SANITY, 3, false));
      f.desc = " The souls of the dead start hassling all enemies. ";
      psionics.add(f);
    }

    {
      Fraymotif f = new Fraymotif("Animal Communing", 1);
      f.effects.add(new FraymotifEffect(Stats.SANITY, 3, true));
      f.effects.add(new FraymotifEffect(Stats.SANITY, 3, false));
      f.desc = " Local animal equivalents start hassling all enemies. ";
      psionics.add(f);
    }

    return psionics;
  }

  void applyPossiblePsionics() {
    // //print("Checking to see how many fraymotifs I have: " + this.fraymotifs.length + " and if I am a troll: " + this.isTroll);
    if (!this.fraymotifs.isEmpty || !this.isTroll) return; //if i already have fraymotifs, then they were probably predefined.
    //highest land dwellers can have chucklevoodoos. Other than that, lower on hemospectrum = greater odds of having psionics.;
    //make sure psionic list is kept in global var, so that char creator eventually can access? Wait, no, just wrtap it in a function here. don't polute global name space.
    //trolls can clearly have more than one set of psionics. so. odds of psionics is inverse with hemospectrum position. didn't i do this math before? where?
    //oh! low blood vocabulary!!! that'd be in quirks, i think.
    ////print("My blood color is: " + this.bloodColor);
    num odds = 10 - bloodColors.indexOf(this.bloodColor); //want gamzee and above to have NO powers (will give highbloods chucklevoodoos separate)
    List<Fraymotif> powers = this.psionicList();
    for (num i = 0; i < powers.length; i++) {
      if (this.session.rand.nextDouble() * 40 < odds) { //even burgundy bloods have only a 25% shot of each power.
        this.fraymotifs.add(powers[i]);
      }
    }
    //special psionics for high bloods and lime bloods.  highblood: #631db4  lime: #658200
    if (this.bloodColor == "#631db4") {
      Fraymotif f = new Fraymotif("Chucklevoodoos", 1);
      f.effects.add(new FraymotifEffect(Stats.SANITY, 3, false));
      f.effects.add(new FraymotifEffect(Stats.SANITY, 3, true));
      f.desc = " Oh god oh no no no no no no no no. The enemies are no longer doing okay, psychologically speaking. ";
      this.fraymotifs.add(f);
    } else if (this.bloodColor == "#658200") {
      Fraymotif f = new Fraymotif("Limeade Refreshment", 1);
      f.effects.add(new FraymotifEffect(Stats.SANITY, 1, false));
      f.effects.add(new FraymotifEffect(Stats.SANITY, 1, true));
      f.desc = " All allies just settle their shit for a little while. Cool it. ";
      this.fraymotifs.add(f);
    } else if (this.bloodColor == "#ffc3df") {
      Fraymotif f = new Fraymotif("'<font color='pink'>${this.chatHandle} and the Power of Looove~~~~~<3<3<3</font>'", 1);
      f.effects.add(new FraymotifEffect(Stats.RELATIONSHIPS, 3, false));
      f.effects.add(new FraymotifEffect(Stats.RELATIONSHIPS, 3, true));
      f.desc = " You are pretty sure this is not a real type of Troll Psionic.  It heals everybody in a bullshit parade of sparkles, and heart effects despite your disbelief. Everybody is also SUPER MEGA ULTRA IN LOVE with each other now, but ESPECIALLY in love with ${this.htmlTitleHP()}. ";
      this.fraymotifs.add(f);
    }
  }


  bool isActive([double multiplier = 0.0]) {
    return class_name.isActive(multiplier);
  }

  void associatedStatsIncreasePower(num powerBoost) {
    //modifyAssociatedStat
    for (num i = 0; i < this.associatedStats.length; i++) {
      this.processStatPowerIncrease(powerBoost, this.associatedStats[i]);
    }
  }

  num modPowerBoostByClass(num powerBoost, AssociatedStat stat) {
    return this.class_name.modPowerBoostByClass(powerBoost, stat);
  }


  void processStatPowerIncrease(num powerBoost, AssociatedStat stat) {
    powerBoost = this.modPowerBoostByClass(powerBoost, stat);
    if (this.isActive(stat.multiplier)) { //modify me
      this.modifyAssociatedStat(powerBoost, stat);
    } else { //modify others.
      powerBoost = 1 * powerBoost; //to make up for passives being too nerfed. 1 for you
      this.modifyAssociatedStat(powerBoost * 0.5, stat); //half for me
      for (num i = 0; i < this.session.players.length; i++) {
        this.session.players[i].modifyAssociatedStat(powerBoost / this.session.players.length, stat);
      }
    }
  }

  @override
  String htmlTitle() {
    String light = "";
    if(session.mutator.lightField) light = " (Active: ${active}, Available: ${available})";
    return "${this.aspect.fontTag()}${this.title()}</font>$light";
  }

  @override
  String htmlTitleWithTip() {
    return "${getToolTip()}${this.aspect.fontTag()}${this.title()}</font></span>";
  }

  @override
  String htmlTitleHP() {
    return "${getToolTip()}${this.aspect.fontTag()}${this.title()} (${(this.getStat(Stats.CURRENT_HEALTH)).round()}hp, ${(this.getStat(Stats.POWER)).round()} power)</font></span>";
  }

  void generateRelationships(List<Player> friends) {
    //	//print(this.title() + " generating a relationship with: " + friends.length);
    for (num i = 0; i < friends.length; i++) {
      if (friends[i] != this) { //No, Karkat, you can't be your own Kismesis.
        //one time in a random sim two heirresses decided to kill each other and this was so amazing and canon compliant
        //that it needs to be a thing.
        Relationship r = Relationship.randomRelationship(this, friends[i]);
        if (this.isTroll && this.bloodColor == "#99004d" && friends[i].isTroll && friends[i].bloodColor == "#99004d") {
          r.value = -20; //biological imperitive to fight for throne.
          this.addStat(Stats.SANITY, -10);
          friends[i].addStat(Stats.SANITY, -10);
        }
        this.relationships.add(r);
      } else {
        ////print(this.title() + "Not generating a relationship with: " + friends[i].title());
      }
    }
  }



  @override
  Relationship getRelationshipWith(GameEntity player) {
    if(session.mutator.lightField && session.mutator.inSpotLight != null) player = session.mutator.inSpotLight; //check for null so i can make previous holder hate new one
    for (Relationship r in relationships) {
      if (r.target.id == player.id) {
        return r;
      }
    }
    //;
    //JR: this might be a VERY bad idea. let's find out together. (1/26/18)
    //you at least have to be a player for now, because of how relationships work.
    //might subclass it out later
    if(player is Player) {
      Relationship newR = new Relationship(this, 0, player);
      player.relationships.add(newR); //nice to meet you
      return newR;
    }
    return null;
  }

  String getChatFontColor() {
    if (this.isTroll) {
      return this.bloodColor;
    } else {
      return this.aspect.palette.text.toStyleString();
    }
  }


  GameEntity getBestFriend() {
    Relationship bestRelationshipSoFar = this.relationships[0];
    for (num i = 1; i < this.relationships.length; i++) {
      Relationship r = this.relationships[i];
      if (r != null && r.value > bestRelationshipSoFar.value) {
        bestRelationshipSoFar = r;
      }
    }
    return bestRelationshipSoFar.target;
  }


  void decideTroll() {
    //session.logger.info("Session of type: ${this.session.getSessionType()}");
    if (this.session.getSessionType() == "Human") {
      this.hairColor = session.rand.pickFrom(human_hair_colors);
      return;
    }

    if (this.session.getSessionType() == "Troll" || (this.session.getSessionType() == "Mixed" && rand.nextDouble() > 0.5)) {
      this.isTroll = true;
      this.hairColor = "#000000";
      this.decideHemoCaste();
      this.decideLusus();
      this.object_to_prototype = this.myLusus;
      this.object_to_prototype.session = session;
    } else {
      this.hairColor = session.rand.pickFrom(human_hair_colors);
    }
  }

  void decideHemoCaste() {
    if (this.aspect != Aspects.BLOOD) { //sorry karkat
      this.bloodColor = session.rand.pickFrom(bloodColors);
    }
    this.applyPossiblePsionics();
  }

  void decideLusus() {
    if (this.bloodColor == "#610061" || this.bloodColor == "#99004d" || this.bloodColor == "#631db4") {
      this.myLusus = session.rand.pickFrom(PotentialSprite.sea_lusus_objects);
      this.myLusus.session = session;
    } else {
      this.myLusus = session.rand.pickFrom(PotentialSprite.lusus_objects);
      this.myLusus.session = session;
    }
  }

  bool highInit() {
    return this.class_name.highHinit();
  }

  void initializeLuck() {
    this.setStat(Stats.MIN_LUCK, this.session.rand.nextIntRange(-10, 0)); //middle of the road.
    this.setStat(Stats.MAX_LUCK, this.session.rand.nextIntRange(1, 10)); //max needs to be more than min.
  }


  void initializeFreeWill() {
    this.setStat(Stats.FREE_WILL, this.session.rand.nextIntRange(-10, 10));
  }

  void initializeHP() {
    this.setStat(Stats.HEALTH, this.session.rand.nextIntRange(40, 60));
    this.setStat(Stats.CURRENT_HEALTH, this.getStat(Stats.HEALTH));

    if (this.isTroll && this.bloodColor != "#ff0000") {
      this.addStat(Stats.CURRENT_HEALTH, bloodColorToBoost(this.bloodColor));
      this.addStat(Stats.HEALTH, bloodColorToBoost(this.bloodColor));
    }
  }


  void clearSelf() {
    canvas.context2D.clearRect(0, 0, canvas.width, canvas.height);
  }

  void initializeMobility() {
    this.setStat(Stats.MOBILITY, this.session.rand.nextIntRange(-10, 10));
  }

  void initializeSanity() {
    this.setStat(Stats.SANITY, this.session.rand.nextIntRange(-10, 10));
  }

  void initializeRelationships() {
    if (this.trickster && !this.aspect.deadpan) {
      for (num k = 0; k < this.relationships.length; k++) {
        Relationship r = this.relationships[k];
        r.value = 11111111111; //EVERYTHIGN IS BETTER!!!!!!!!!!!
        r.saved_type = r.goodBig;
      }
    }

    if (this.isTroll && this.bloodColor == "#99004d") {
      for (num i = 0; i < this.relationships.length; i++) {
        //needs to be part of this in ADDITION to initialization because what about custom players now.
        Relationship r = this.relationships[i];
        if (this.isTroll && this.bloodColor == "#99004d" && (r.target  as Player).isTroll && (r.target  as Player).bloodColor == "#99004d") {
          r.value = -20; //biological imperitive to fight for throne.
          this.addStat(Stats.SANITY, -10);
          r.target.addStat(Stats.SANITY, -10);
        }
      }
    }
    if (this.robot || this.grimDark > 1) { //you can technically start grimDark
      for (num k = 0; k < this.relationships.length; k++) {
        Relationship r = this.relationships[k];
        r.value = 0; //robots are tin cans with no feelings
        r.saved_type = r.neutral;
        r.old_type = r.neutral;
      }
    }
  }


  void initializePower() {
    this.setStat(Stats.POWER, 10);

    if (this.robot) {
      this.addStat(Stats.POWER, 100); //robots are superior
    }

    if (this.isTroll && this.bloodColor != "#ff0000") {
      this.addStat(Stats.POWER, bloodColorToBoost(this.bloodColor));
    }
    //;
  }

  String toDataStrings(bool includeChatHandle) {
    String ch = "";
    if (includeChatHandle) ch = sanitizeString(this.chatHandle);
    String cod = this.causeOfDrain;
    if (cod == null) cod = "";
    String ret = "${sanitizeString(cod)},${sanitizeString(this.causeOfDeath)},${sanitizeString(this.interest1.name)},${sanitizeString(this.interest2.name)},${sanitizeString(ch)}";
    return ret;
  }

  String toOCDataString() {
    //for now, only extentsion sequence is for classpect. so....
    String tmpx = this.toDataBytesX(new ByteBuilder());
    if (tmpx == null) tmpx = ""; //DART is putting null here instead of a blank string, like an asshole.
    String x = "&x=$tmpx"; //ALWAYS have it. worst case scenario is 1 bit.

    return "b=${this.toDataBytes()}&s=${this.toDataStrings(true)}$x";
  }

  //take in a builder so when you do a group of players then can use same builder and no padding.
  String toDataBytesX(ByteBuilder builder) {
    Map<String, dynamic> j = this.toJSONBrief();
    if (j["class_name"] <= 15 && j["aspect"] <= 15) { //if NEITHER have need of extension, just return size zero;
      builder.appendExpGolomb(0); //for length
      return base64Url.encode(builder.toBuffer().asUint8List());
    }
    builder.appendExpGolomb(2); //for length
    builder.appendByte(j["class_name"]);
    builder.appendByte(j["aspect"]);
    //String data = utf8.decode(builder.toBuffer().asUint8List());
    return base64Url.encode(builder.toBuffer().asUint8List());
    //return Uri.encodeComponent(data).replaceAll(new RegExp(r"""#""", multiLine:true), '%23').replaceAll(new RegExp(r"""&""", multiLine:true), '%26');
  }

  JSONObject toJSON() {
    JSONObject json = super.toJSON();
    json["ocDataString"] = toOCDataString();
    //TODO eventually shove quirk and relationships into here
    return json;
  }

  void copyFromJSON(String jsonString) {
    super.copyFromJSON(jsonString);
    JSONObject json = new JSONObject.fromJSONString(jsonString);
    copyFromOCDataString(json["ocDataString"]);
  }

  String toDataBytes() {
    Map<String, dynamic> json = this.toJSONBrief(); //<-- gets me data in pre-compressed format.
    //var buffer = new ByteBuffer(11);
    StringBuffer ret = new StringBuffer(); //gonna return as a string of chars.;
    Uint8List uint8View = new Uint8List(11);
    uint8View[0] = json["hairColor"] >> 16; //hair color is 12 bits. chop off 4 on right side, they will be in buffer[1];
    uint8View[1] = json["hairColor"] >> 8;
    uint8View[2] = json["hairColor"] >> 0;
    uint8View[3] = (json["class_name"] << 4) + json["aspect"]; //when I do fanon classes + aspect, use this same scheme, but have binary for "is fanon", so I know 1 isn't page, but waste (or whatever);
    uint8View[4] = (json["victimBlood"] << 4) + json["bloodColor"];
    uint8View[5] = (json["interest1Category"] << 4) + json["interest2Category"];
    uint8View[6] = (json["grimDark"] << 5) + (json["isTroll"] << 4) + (json["isDreamSelf"] << 3) + (json["godTier"] << 2) + (json["murderMode"] << 1) + (json["leftMurderMode"]); //shit load of single bit variables.;
    uint8View[7] = (json["robot"] << 7) + (json["moon"] << 6) + (json["dead"] << 5) + (json["godDestiny"] << 4) + (json["favoriteNumber"]);
    uint8View[8] = json["leftHorn"];
    uint8View[9] = json["rightHorn"];
    uint8View[10] = json["hair"];
    ////print(uint8View);
    for (num i = 0; i < uint8View.length; i++) {
      ret.writeCharCode(uint8View[i]); // += String.fromCharCode(uint8View[i]);
    }
    return Uri.encodeComponent(ret.toString()).replaceAll("#", '%23').replaceAll("&", '%26');
  }

  Map<String, dynamic> toJSONBrief() {
    num moonNum = 0;
    String cod = this.causeOfDrain;
    if (cod == null) cod = "";
    if (this.moon == session.prospit) moonNum = 1;
    Map<String, dynamic> json = <String, dynamic>{"aspect": this.aspect.id, "class_name": classNameToInt(this.class_name), "favoriteNumber": this.quirk.favoriteNumber, "hair": this.hair, "hairColor": hexColorToInt(this.hairColor), "isTroll": this.isTroll ? 1 : 0, "bloodColor": bloodColorToInt(this.bloodColor), "leftHorn": this.leftHorn, "rightHorn": this.rightHorn, "interest1Category": this.interest1.category.id, "interest2Category": this.interest2.category.id, "interest1": this.interest1.name, "interest2": this.interest2.name, "robot": this.robot ? 1 : 0, "moon": moonNum, "causeOfDrain": cod, "victimBlood": bloodColorToInt(this.victimBlood), "godTier": this.godTier ? 1 : 0, "isDreamSelf": this.isDreamSelf ? 1 : 0, "murderMode": this.murderMode ? 1 : 0, "leftMurderMode": this.leftMurderMode ? 1 : 0, "grimDark": this.grimDark, "causeOfDeath": this.causeOfDeath, "dead": this.dead ? 1 : 0, "godDestiny": this.godDestiny ? 1 : 0};
    return json;
  }

  @override
  String toString() {
    return title(); //no spaces.
  }

  void copyFromPlayer(Player replayPlayer) {
    ////print("copying from player who has a favorite number of: " + replayPlayer.quirk.favoriteNumber);
    ////;
    ////print(replayPlayer);
    session.logger.info("copying ${replayPlayer} to ${this}");
    this.aspect = replayPlayer.aspect;
    this.class_name = replayPlayer.class_name;
    this.hair = replayPlayer.hair;
    this.hairColor = replayPlayer.hairColor;
    this.isTroll = replayPlayer.isTroll;
    this.bloodColor = replayPlayer.bloodColor;
    this.leftHorn = replayPlayer.leftHorn;
    this.specibus = replayPlayer.specibus.copy();
    print("specibus is $specibus with traits ${specibus.traits}, required trait is ${specibus.requiredTrait}, the replay player has ${replayPlayer.specibus} with traits ${replayPlayer.specibus.traits} required trait is ${replayPlayer.specibus.requiredTrait}");
    this.rightHorn = replayPlayer.rightHorn;
    this.interest1 = replayPlayer.interest1;
    this.interest2 = replayPlayer.interest2;

    this.causeOfDrain = replayPlayer.causeOfDrain;
    this.causeOfDeath = replayPlayer.causeOfDeath;
    //print("TEST CUSTOM: replay player's chat handle is ${replayPlayer.chatHandle}");
    if (replayPlayer.chatHandle != "") {
      this.chatHandle = replayPlayer.chatHandle;
      this.deriveChatHandle = false;
    }
    this.isDreamSelf = replayPlayer.isDreamSelf;
    this.godTier = replayPlayer.godTier;
    this.godDestiny = replayPlayer.godDestiny;
    this.murderMode = replayPlayer.murderMode;
    this.leftMurderMode = replayPlayer.leftMurderMode;
    this.grimDark = replayPlayer.grimDark;

    this.moon = replayPlayer.moon;
    this.dead = replayPlayer.dead;
    this.victimBlood = replayPlayer.victimBlood;
    this.robot = replayPlayer.robot;
    this.fraymotifs.clear(); //whoever you were before, you don't have those psionics anymore
    this.applyPossiblePsionics(); //now you have new psionics
    this.quirk.favoriteNumber = replayPlayer.quirk.favoriteNumber; //will get overridden, has to be after initialization, too, but if i don't do it here, char creartor will look wrong.
    this.makeGuardian();
    this.guardian.applyPossiblePsionics(); //now you have new psionics
  }

  void initialize() {
    handleSubAspects();
    this.initializeStats();
    this.initializeSprite();
    if(deriveSpecibus) this.specibus = SpecibusFactory.getRandomSpecibus(session.rand);
    this.initializeDerivedStuff();
  }

  void handleSubAspects() {
    if(aspect is AspectWithSubAspects) {
      AspectWithSubAspects subAspectedAspect = aspect as AspectWithSubAspects;
      print ("handling sub aspects for ${title()} with subaspects ${subAspectedAspect.subAspects}");

      if(subAspectedAspect.subAspects == null) {
        (aspect as AspectWithSubAspects).setSubAspectsFromPlayer(this);
      }
    }
  }


  void initializeDerivedStuff() {
    populateInventory();
    populateAi();

    if(deriveLand) land = spawnLand();

    if (this.deriveChatHandle) this.chatHandle = getRandomChatHandle(this.session.rand, this.class_name, this.aspect, this.interest1, this.interest2);
    this.mylevels = getLevelArray(this); //make them ahead of time for echeladder graphic

    if (this.isTroll) {
      if (this.quirk == null) this.quirk = randomTrollSim(this.session.rand, this); //if i already have a quirk it was defined already. don't override it.;
      this.addStat(Stats.SANITY, -10); //trolls are slightly less stable

    } else {
      if (this.quirk == null) this.quirk = randomHumanSim(this.session.rand, this);
    }
    moonChance += session.rand.nextDouble() * -33; //different amount of time pre-game start to get in. (can still wake up before entry)
    if(aspect.isThisMe(Aspects.SPACE)) moonChance += 33.0; //huge chance for space players.
    if(aspect.isThisMe( Aspects.DOOM)) prophecy = ProphecyState.ACTIVE; //sorry doom players
    specibus.modMaxUpgrades(this);
  }

  void populateAi() {
    //as long as i add them before the first scene, they should show up
    //ANYTHING you alerady know should be cleared (hopefully this doesn't fuck over the session creator)
    scenesToAdd.clear();
    serializableSceneStrings.clear();
    for(Scene scene in scenes) {
      if(scene is SerializableScene) {
        scenesToRemove.add(scene);
      }
    }
    handleRemovingScenes();
    //not every player gets their classpect fully realized
    //(otherwise theres too much ai per player and older scenes don't trigger.
    if(session.rand.nextBool()) {
      return;
    }
    for(String s in class_name.associatedScenes) {
      serializableSceneStrings.add(s);
    }

    for(String s in aspect.associatedScenes) {
      serializableSceneStrings.add(s);
    }

  }

  void populateInventory() {
    sylladex.clear();
    sylladex.add(session.rand.pickFrom(interest1.category.items));
    sylladex.add(session.rand.pickFrom(interest2.category.items));
    //testing something
    // sylladex.add(new Item("Dr Pepper BBQ Sauce",<ItemTrait>[ItemTraitFactory.POISON],shogunDesc: "Culinary Perfection",abDesc:"Gross."));

  }

  //I mark the source of the themes here, where i'm using them, rather than on creation
  //need the source for QuestChains (want first quest to be interest related, second aspect, third class) <-- important
  Land spawnLand([Map<Theme, double> extraThemes]) {
    Map<Theme, double> themes = new Map<Theme, double>();
    if(extraThemes != null) themes = new Map<Theme, double>.from(extraThemes);
    Theme classTheme = session.rand.pickFrom(class_name.themes.keys);
    classTheme.source = Theme.CLASSSOURCE;
    Theme aspectTheme = session.rand.pickFrom(aspect.themes.keys);
    aspectTheme.source = Theme.ASPECTSOURCE;
    Theme interest1Theme = session.rand.pickFrom(interest1.category.themes.keys);
    interest1Theme.source = Theme.INTERESTSOURCE;
    Theme interest2Theme = session.rand.pickFrom(interest2.category.themes.keys);
    interest2Theme.source = Theme.INTERESTSOURCE;

    //the weight is the same weight it had in it's source
    themes[classTheme] = class_name.themes[classTheme];
    themes[aspectTheme] = aspect.themes[aspectTheme];
    themes[interest1Theme] = interest1.category.themes[interest1Theme];
    themes[interest2Theme] = interest2.category.themes[interest2Theme];
    Land l =  new Land.fromWeightedThemes(themes, session, aspect,class_name);
    l.associatedEntities.add(this);
    return l;

  }

  void initializeSprite() {
    if(object_to_prototype == null) {
      object_to_prototype =  session.rand.pickFrom(PotentialSprite.prototyping_objects);
    }
    this.sprite = new Sprite("sprite", session); //unprototyped.
    //minLuck, maxLuck, hp, mobility, triggerLevel, freeWill, power, abscondable, canAbscond, framotifs, grist
    this.sprite.stats.setMap(<Stat, num>{Stats.HEALTH: 10, Stats.CURRENT_HEALTH: 10}); //same as denizen minion, but empty power
    this.sprite.doomed = true;
  }


  @override
  void modifyAssociatedStat(num modValue, AssociatedStat stat) {
    if (stat == null) return;
    //modValue * stat.multiplier.
    if (stat.stat == Stats.RELATIONSHIPS) {
      for (num i = 0; i < this.relationships.length; i++) {
        this.relationships[i].value += (modValue / this.relationships.length) * stat.multiplier * stat.stat.associatedGrowth; //stop having relationship values on the scale of 100000
      }
    } else {
      //don't lower health below 1. if i can't do it in stats itself for now, do it here.
      if(stat.stat != Stats.HEALTH || (stat.stat == Stats.HEALTH && getStat(Stats.HEALTH) >1)) {
        this.addStat(stat.stat, modValue * stat.multiplier * stat.stat.associatedGrowth);
      }
    }
  }

  //oh my fuck, how was this ever allowed in javascript, it was trying to add stats to the LIST OF STATS.
  void initializeInterestStats() {
    //getInterestAssociatedStats
    List<AssociatedStat> interest1Stats = this.interest1.category.stats;
    List<AssociatedStat> interest2Stats = this.interest2.category.stats;
    for (AssociatedStat stat in interest1Stats) {
      this.modifyAssociatedStat(10, stat);
    }

    for (AssociatedStat stat in interest2Stats) {
      this.modifyAssociatedStat(10, stat);
    }
  }

  void initializeStats() {
    //initStatHolder();
    if (this.trickster && this.aspect.ultimateDeadpan) this.trickster == false; //doom players break rules
    if(trickster) {
      this.addBuff(new BuffTricksterMode(), name:"trickster", source:this);
      landLevel = 11111111111.0;
      grist = 11111111111;
    }
    this.associatedStats = <AssociatedStat>[]; //this might be called multiple times, wipe yourself out.
    this.aspect.initAssociatedStats(this);
    this.class_name.initAssociatedStats(this);
    this.setStat(Stats.SBURB_LORE,0); //all start ignorant.
    this.initializeLuck();
    this.initializeFreeWill();
    this.initializeHP();
    this.initializeMobility();
    this.initializeRelationships();
    this.initializePower();
    this.initializeSanity();

    this.initializeAssociatedStats();
    this.initializeInterestStats(); //takes the place of old random intial stats.
    //reroll goddestiny and sprite as well. luck might have changed.
    num luck = this.rollForLuck();
    if (this.class_name == SBURBClassManager.WITCH || luck < -9) {
      if(deriveSprite) this.object_to_prototype = this.session.rand.pickFrom(PotentialSprite.disastor_objects);
      this.object_to_prototype.session = session;
      ////;
    } else if (luck > 25) {
      if(deriveSprite) this.object_to_prototype = this.session.rand.pickFrom(PotentialSprite.fortune_objects);
      this.object_to_prototype.session = session;
      ////;
    }
    if (luck > 5) {
      this.godDestiny = true;
    }
    this.setStat(Stats.CURRENT_HEALTH, getStat(Stats.HEALTH)); //could have been altered by associated stats

    if (this.class_name == SBURBClassManager.WASTE) {
      Fraymotif f = new Fraymotif("Rocks Fall, Everyone Dies", 1); //what better fraymotif for an Author to start with. Too bad it sucks.  If ONLY there were some way to hax0r SBURB???;
      f.effects.add(new FraymotifEffect(Stats.POWER, 3, true));
      f.desc = "Disappointingly sized meteors rain down from above.  Man, for such a cool name, this fraymotif kind of sucks. ";
      this.fraymotifs.add(f);
    } else if (this.class_name == SBURBClassManager.NULL) {
      {
        Fraymotif f = new Fraymotif("What class???", 1);
        f.effects.add(new FraymotifEffect(Stats.POWER, 1, true));
        f.desc = " I am certain there is not a class here and it is laughable to imply otherwise. ";
        this.fraymotifs.add(f);
      }

      {
        Fraymotif f = new Fraymotif("Nulzilla", 2);
        f.effects.add(new FraymotifEffect(Stats.POWER, 1, true));
        f.desc = " If you get this reference, you may reward yourself 15 Good Taste In Media Points (tm).  ";
        this.fraymotifs.add(f);
      }
    }
    //;
  }

}