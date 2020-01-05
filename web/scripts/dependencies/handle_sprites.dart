import "dart:async";
import "dart:html";
import "dart:math" as Math;

import "SBURBSim.dart";

bool cool_kid = false;
bool easter_egg = false;
bool bardQuest = false;
bool ouija = false;
bool faceOff = false;
//~~~~~~~~~~~IMPORTANT~~~~~~~~~~LET NOTHING HERE BE RANDOM
//OR PREDICTIONS AND TIME LOOPS AND AI SEARCHES WILL BE WRONG
//except nepepta, cuz that cat troll be crazy, yo

typedef void PaletteSwapCallback(CanvasElement canvas, Player player);

ImageElement imageSelector(String path) {
  return querySelector("#${escapeId(path)}");
}

abstract class ReferenceColours {
  static Colour WHITE = new Colour.fromHex(0xFFFFFF);
  static Colour BLACK = new Colour.fromHex(0x000000);
  static Colour RED = new Colour.fromHex(0xFF0000);
  static Colour LIME = new Colour.fromHex(0x00FF00);

  static Colour LIME_CORRECTION = new Colour.fromHex(0x00FF2A);

  static Colour GRIM = new Colour.fromHex(0x424242);
  static Colour GREYSKIN = new Colour.fromHex(0xC4C4C4);
  static Colour GRUB = new Colour.fromHex(0x585858);
  static Colour ROBOT = new Colour.fromHex(0xB6B6B6);
  static Colour ECHELADDER = new Colour.fromHex(0x4A92F7);
  static Colour BLOOD_PUDDLE = new Colour.fromHex(0xFFFC00);
  static Colour BLOODY_FACE = new Colour.fromHex(0x440A7F);

  static Colour HAIR = new Colour.fromHex(0x313131);
  static Colour HAIR_ACCESSORY = new Colour.fromHex(0x202020);

  static AspectPalette SPRITE_PALETTE = new AspectPalette()
    ..aspect_light = '#FEFD49'
    ..aspect_dark = '#FEC910'
    ..shoe_light = '#10E0FF'
    ..shoe_dark = '#00A4BB'
    ..cloak_light = '#FA4900'
    ..cloak_mid = '#E94200'
    ..cloak_dark = '#C33700'
    ..shirt_light = '#FF8800'
    ..shirt_dark = '#D66E04'
    ..pants_light = '#E76700'
    ..pants_dark = '#CA5B00';

  static AspectPalette PROSPIT_PALETTE = new AspectPalette()
    ..aspect_light = "#FFFF00"
    ..aspect_dark = "#FFC935"
  // no shoe colours here on purpose
    ..cloak_light = "#FFCC00"
    ..cloak_mid = "#FF9B00"
    ..cloak_dark = "#C66900"
    ..shirt_light = "#FFD91C"
    ..shirt_dark = "#FFE993"
    ..pants_light = "#FFB71C"
    ..pants_dark = "#C67D00";

  static AspectPalette DERSE_PALETTE = new AspectPalette()
    ..aspect_light = "#F092FF"
    ..aspect_dark = "#D456EA"
  // no shoe colours here on purpose
    ..cloak_light = "#C87CFF"
    ..cloak_mid = "#AA00FF"
    ..cloak_dark = "#6900AF"
    ..shirt_light = "#DE00FF"
    ..shirt_dark = "#E760FF"
    ..pants_light = "#B400CC"
    ..pants_dark = "#770E87";

  static AspectPalette ROBOT_PALETTE = new AspectPalette()
    ..aspect_light = "#0000FF"
    ..aspect_dark = "#0022cf"
    ..shoe_light = "#B6B6B6"
    ..shoe_dark = "#A6A6A6"
    ..cloak_light = "#484848"
    ..cloak_mid = "#595959"
    ..cloak_dark = "#313131"
    ..shirt_light = "#B6B6B6"
    ..shirt_dark = "#797979"
    ..pants_light = "#494949"
    ..pants_dark = "#393939";
}

abstract class Drawing {
  //sharpens the image so later pixel swapping doesn't work quite right.
  //https://www.html5rocks.com/en/tutorials/canvas/imagefilters/
  static void sbahjifier(CanvasElement canvas) {
    bool opaque = false;
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    ctx.rotate(getRandomIntNoSeed(0, 10) * Math.pi / 180);
    ImageData pixels = ctx.getImageData(0, 0, canvas.width, canvas.height);
    List<int> weights = <int>[ -1, -1, -1, -1, 9, -1, -1, -1, -1];
    int side = (Math.sqrt(weights.length)).round();
    int halfSide = (side ~/ 2);
    List<int> src = pixels.data;
    int sw = pixels.width;
    int sh = pixels.height;
    // pad output by the convolution matrix
    int w = sw;
    int h = sh;
    ImageData output = ctx.getImageData(0, 0, canvas.width, canvas.height);
    List<int> dst = output.data;
    // go through the destination image pixels
    int alphaFac = opaque ? 1 : 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int sy = y;
        int sx = x;
        int dstOff = (y * w + x) * 4;
        // calculate the weighed sum of the source image pixels that
        // fall under the convolution matrix
        int r = 0,
            g = 0,
            b = 0,
            a = 0;
        for (int cy = 0; cy < side; cy++) {
          for (int cx = 0; cx < side; cx++) {
            int scy = sy + cy - halfSide;
            int scx = sx + cx - halfSide;
            if (scy >= 0 && scy < sh && scx >= 0 && scx < sw) {
              int srcOff = (scy * sw + scx) * 4;
              int wt = weights[cy * side + cx];
              r += src[srcOff] * wt;
              g += src[srcOff + 1] * wt;
              b += src[srcOff + 2] * wt;
              a += src[srcOff + 3] * wt;
            }
          }
        }
        dst[dstOff] = r;
        dst[dstOff + 1] = g;
        dst[dstOff + 2] = b;
        dst[dstOff + 3] = a + alphaFac * (255 - a);
      }
    }
    //sligtly offset each time
    ctx.putImageData(output, getRandomIntNoSeed(0, 10), getRandomIntNoSeed(0, 10));
  }


  //work once again gives me inspiration for this sim. thanks, bob!!!
  static void rainbowSwap(CanvasElement canvas) {
    if (checkSimMode() == true) {
      return;
    }
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    ImageData img_data = ctx.getImageData(0, 0, canvas.width, canvas.height);
    String imageString = "rainbow.png";
    ImageElement img = imageSelector(imageString);
    int width = img.width;
    int height = img.height;

    CanvasElement rainbow_canvas = getBufferCanvas(SimController.rainbowTemplateWidth, SimController.rainbowTemplateHeight);
    CanvasRenderingContext2D rctx = rainbow_canvas.context2D;
    rctx.drawImage(img, 0, 0);
    ImageData img_data_rainbow = rctx.getImageData(0, 0, width, height);

    int i;
    for (int x = 0; x < img_data.width; x++) {
      for (int y = 0; y < img_data.height; y++) {
        i = (y * img_data.width + x) * 4;

        if (img_data.data[i + 3] >= 128) {
          int rainbow = (y % img_data_rainbow.height) * 4;

          img_data.data[i] = img_data_rainbow.data[rainbow];
          img_data.data[i + 1] = img_data_rainbow.data[rainbow + 1];
          img_data.data[i + 2] = img_data_rainbow.data[rainbow + 2];
          img_data.data[i + 3] = getRandomIntNoSeed(100, 255); //make it look speckled.

        }
      }
    }
    ctx.putImageData(img_data, 0, 0);
    //ctx.putImageData(img_data_rainbow, 0, 0);
  }


  //how translucent are we talking, here?  number between 0 and 1
  static void voidSwap(CanvasElement canvas, double alphaPercent) {
    if (checkSimMode() == true) {
      return;
    }
    // //print("replacing: " + oldc  + " with " + newc);
    CanvasRenderingContext2D ctx = canvas.context2D;
    ImageData img_data = ctx.getImageData(0, 0, canvas.width, canvas.height);
    //4 byte color array
    for (int i = 0; i < img_data.data.length; i += 4) {
      if (img_data.data[i + 3] > 50) {
        img_data.data[i + 3] = (img_data.data[i + 3] * alphaPercent).floor(); //keeps wings at relative transparency
      }
    }
    ctx.putImageData(img_data, 0, 0);
  }


  //work once again gives me inspiration for this sim. thanks, bob!!!
  static void drainedGhostSwap(CanvasElement canvas) {
    if (checkSimMode() == true) {
      return;
    }
    CanvasRenderingContext2D ctx = canvas.context2D;
    ImageData img_data = ctx.getImageData(0, 0, canvas.width, canvas.height);
    String imageString = "ghostGradient.png";
    ImageElement img = imageSelector(imageString);
    int width = img.width;
    int height = img.height;

    CanvasElement rainbow_canvas = getBufferCanvas(SimController.rainbowTemplateWidth, SimController.rainbowTemplateHeight);
    CanvasRenderingContext2D rctx = rainbow_canvas.context2D;
    rctx.drawImage(img, 0, 0);
    ImageData img_data_rainbow = rctx.getImageData(0, 0, width, height);
    //4 *Math.floor(i/(4000)) is because 1/(width*4) get me the row number (*4 'cause there are 4 elements per pixel). then, when i have the row number, *4 again because first row is 0,1,2,3 and second is 4,5,6,7 and third is 8,9,10,11
    for (int i = 0; i < img_data.data.length; i += 4) {
      if (img_data.data[i + 3] >= 128) {
        img_data.data[i + 3] = img_data_rainbow.data[4 * (i ~/ (4000)) + 3] ~/ 2; //only mimic transparency. even fainter.;

      }
    }
    ctx.putImageData(img_data, 0, 0);
    //ctx.putImageData(img_data_rainbow, 0, 0);
  }


  //work once again gives me inspiration for this sim. thanks, bob!!!
  static void ghostSwap(CanvasElement canvas) {
    if (checkSimMode() == true) {
      return;
    }
    CanvasRenderingContext2D ctx = canvas.context2D;
    ImageData img_data = ctx.getImageData(0, 0, canvas.width, canvas.height);
    String imageString = "ghostGradient.png";
    ImageElement img = imageSelector(imageString);
    int width = img.width;
    int height = img.height;

    CanvasElement rainbow_canvas = getBufferCanvas(SimController.rainbowTemplateWidth, SimController.rainbowTemplateHeight);
    CanvasRenderingContext2D rctx = rainbow_canvas.context2D;
    rctx.drawImage(img, 0, 0);
    ImageData img_data_rainbow = rctx.getImageData(0, 0, width, height);
    //4 *Math.floor(i/(4000)) is because 1/(width*4) get me the row number (*4 'cause there are 4 elements per pixel). then, when i have the row number, *4 again because first row is 0,1,2,3 and second is 4,5,6,7 and third is 8,9,10,11
    for (int i = 0; i < img_data.data.length; i += 4) {
      if (img_data.data[i + 3] >= 128) {
        img_data.data[i + 3] = img_data_rainbow.data[4 * (i ~/ (4000)) + 3] * 2; //only mimic transparency.;

      }
    }
    ctx.putImageData(img_data, 0, 0);
    //ctx.putImageData(img_data_rainbow, 0, 0);
  }


  //if speed becomes an issue, take in array of color pairs to swap out
  //rather than call this method once for each color
  //swaps one hex color with another.
  //wait no, would be same amount of things. just would have nested for loops instead of
  //multiple calls
  static void swapColors(CanvasElement canvas, Colour oldc, Colour newc, [int alpha = 255]) {
    if (checkSimMode() == true) {
      return;
    }
    // //print("replacing: " + oldc  + " with " + newc);
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    ImageData img_data = ctx.getImageData(0, 0, canvas.width, canvas.height);
    //4 byte color array
    for (int i = 0; i < img_data.data.length; i += 4) {
      if (img_data.data[i] == oldc[0] && img_data.data[i + 1] == oldc[1] && img_data.data[i + 2] == oldc[2] && img_data.data[i + 3] == 255) {
        img_data.data[i] = newc[0];
        img_data.data[i + 1] = newc[1];
        img_data.data[i + 2] = newc[2];
        img_data.data[i + 3] = alpha;
      }
    }
    ctx.putImageData(img_data, 0, 0);
  }

  static void swapPalette(CanvasElement canvas, Palette source, Palette replacement) {
    if (checkSimMode() == true) {
      return;
    }
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    ImageData img_data = ctx.getImageData(0, 0, canvas.width, canvas.height);

    for (int i = 0; i < img_data.data.length; i += 4) {
      Colour sourceColour = new Colour(img_data.data[i], img_data.data[i + 1], img_data.data[i + 2]);
      for (String name in source.names) {
        if (source[name] == sourceColour) {
          Colour replacementColour = replacement[name];
          img_data.data[i] = replacementColour.red;
          img_data.data[i + 1] = replacementColour.green;
          img_data.data[i + 2] = replacementColour.blue;
          break;
        }
      }
    }
    ctx.putImageData(img_data, 0, 0);
  }

  static void grimDarkSkin(CanvasElement canvas) {
    swapColors(canvas, ReferenceColours.WHITE, ReferenceColours.GRIM);
  }

  static void peachSkin(CanvasElement canvas, Player player) {
    int index = player.hair % tricksterColors.length;
    swapColors(canvas, ReferenceColours.WHITE, tricksterColors[index]);
  }

  static void greySkin(CanvasElement canvas) {
    swapColors(canvas, ReferenceColours.WHITE, ReferenceColours.GREYSKIN);
  }

  static void roboSkin(CanvasElement canvas) {
    swapColors(canvas, ReferenceColours.WHITE, ReferenceColours.ROBOT);
  }

  static void wings(CanvasElement canvas, Player player) {
    //blood players have no wings, all other players have wings matching
    //favorite color
    if (!player.aspect.trollWings) {
      //return;  //karkat and kankri don't have wings, but is that standard? or are they just hiding them?
    }

    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    int num = player.quirk.favoriteNumber;
    //int num = 5;
    String imageString = "Wings/wing$num.png";
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0); //,width,height);

    Colour blood = new Colour.fromStyleString(player.bloodColor);
    swapColors(canvas, ReferenceColours.RED, blood);
    swapColors(canvas, ReferenceColours.LIME_CORRECTION, blood, 128);
    swapColors(canvas, ReferenceColours.LIME, blood, 128); //I have NO idea why some browsers render the lime parts of the wing as 00ff00 but whatever.

  }

  static void grimDarkHalo(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = "grimdark.png";
    if (player.trickster) {
      imageString = "squiddles_chaos.png";
    }
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
  }

  //TODO, eventually render fin1, then hair, then fin2
  static void fin1(CanvasElement canvas, Player player) {
    if (player.bloodColor == "#610061" || player.bloodColor == "#99004d") {
      CanvasRenderingContext2D ctx = canvas.getContext('2d');
      String imageString = "fin1.png";
      addImageTag(imageString);
      ImageElement img = imageSelector(imageString);
      ctx.drawImage(img, 0, 0);
    }
  }

  static void fin2(CanvasElement canvas, Player player) {
    if (player.bloodColor == "#610061" || player.bloodColor == "#99004d") {
      CanvasRenderingContext2D ctx = canvas.getContext('2d');
      String imageString = "fin2.png";
      addImageTag(imageString);
      ImageElement img = imageSelector(imageString);
      ctx.drawImage(img, 0, 0);
    }
  }

  static void horns(CanvasElement canvas, Player player) {
    leftHorn(canvas, player);
    rightHorn(canvas, player);
  }


  //horns are no longer a sprite sheet. tracy and kristi and brandon gave me advice.
  //position horns on an image as big as the canvas. put the horns directly on the
  //place where the head of every sprite would be.
  //same for wings eventually.
  static void leftHorn(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = "Horns/left${player.leftHorn}.png";
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    ////print("Random number is: " + randNum);
  }

  //parse horns sprite sheet. render a random right horn.
  //right horn should be at: 120,40
  static void rightHorn(CanvasElement canvas, Player player) {
    // //;
    CanvasRenderingContext2D ctx = canvas.getContext('2d');

    String imageString = "Horns/right${player.rightHorn}.png";
    addImageTag(imageString);

    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
  }

  static void addImageTag(String url) {
    ////print(url);
    //only do it if image hasn't already been added.
    if (imageSelector(url) == null) {
      String tag = '<img id="${escapeId(url)}" src = "images/$url" class="loadedimg">';
      querySelector("#image_staging").appendHtml(tag, treeSanitizer: NodeTreeSanitizer.trusted);
    }
  }


  /* code that implies a different way i could load images. with an async callback to img.onload
    Hrrrm. Problem is that async would mean that things would be rendered in the wrong order.
    could have something that knows when ALL things in a single sprite have been rendered?
    function start_loading_images(ctx, canvas, view);
    {
        ImageElement img = new Image();
        img.onload = () {
            ////print(this);

            x = canvas.width/2 - this.width/2;
            y = canvas.height/2 - this.height/2;
            ctx.drawImage(this, x,y);
            debug_image = this;

            load_more_images(ctx, canvas, view, img.width, img.height);
        }
        img.src = url_for_image(view)+"&center";
    }
    //this one is slighlty more useful. instead of async, just asks if image is loaded or not.
    http://stackoverflow.com/questions/1977871/check-if-an-image-is-loaded-no-errors-in-javascript
    for now i'm okay with just waiting a half second, though.
    function imgLoaded(imgElement) {
      return imgElement.complete && imgElement.naturalHeight !== 0;
    }

    */


  //true random position
  static void drawWhateverTerezi(CanvasElement canvas, String imageString) {
    if (checkSimMode() == true) {
      return;
    }
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    //	//  //all true random
    int x = getRandomIntNoSeed(0, 50);
    int y = getRandomIntNoSeed(0, 50);
    if (random() > .5) x = x * -1;
    if (random() > .5) y = y * -1;
    ctx.drawImage(img, x, y);
  }


  static void drawWhateverTurnways(CanvasElement canvas, String imageString) {
    if (checkSimMode() == true) {
      return;
    }
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    ctx.imageSmoothingEnabled = false; //should get rid of orange halo in certain browsers.
    ctx.translate(canvas.width, 0);
    ctx.scale(-1, 1);
    drawWhatever(canvas, imageString);
  }


  static void drawWhateverWithPalleteSwapCallback(CanvasElement canvas, String str, Player player, PaletteSwapCallback palleteSwapCallBack) {
    CanvasElement temp = getBufferCanvas(canvas.width, canvas.height);

    drawWhatever(temp, str);
    ////;
    palleteSwapCallBack(temp, player); //regular, trickster, robo, whatever.
    canvas.context2D.drawImage(temp, 0,0);
  }

  //have i really been too lazy to make this until now
  static void drawWhatever(CanvasElement canvas, String imageString) {
    if (checkSimMode() == true) {
      return;
    }
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    if (img == null) {
      //;
      //;
    }
    ctx.drawImage(img, 0, 0);
  }


  static bool checkSimMode() {
    //return true; // debugging, is loading the problem, or is this method?
    if (doNotRender == true) {
      //looking for rare sessions, or getting moon prophecies.
      //  //;
      return true;
    }
    return false;
  }

  static void bloodPuddle(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = "blood_puddle.png";
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    swapColors(canvas, ReferenceColours.BLOOD_PUDDLE, new Colour.fromStyleString(player.bloodColor));
  }


  static void drawSpriteFromScratch(CanvasElement canvas, Player player, [CanvasRenderingContext2D ctx = null, bool baby = false]) async {

    if (checkSimMode() == true) {
      return;
    }
    canvas.context2D.save();
    player = Player.makeRenderingSnapshot(player,true);
    //could be turnways or baby
    if (ctx == null) {
      ctx = canvas.context2D;
    }

    ctx.imageSmoothingEnabled = false; //should get rid of orange halo in certain browsers.
    if (!baby && (player.dead)) { //only rotate once
      ctx.translate(canvas.width, 0);
      ctx.rotate(90 * Math.pi / 180);
    }

    //they are not dead, only sleeping
    if (!baby && ((player.causeOfDrain != null && !player.causeOfDrain.isEmpty))) { //only rotate once
      ctx.translate(0, 6 * canvas.height / 5);
      ctx.rotate(270 * Math.pi / 180);
    }

    if (!baby && player.grimDark > 3) {
      grimDarkHalo(canvas, player);
    }

    //spotlight
    if (player.session.mutator.hasSpotLight(player)) drawWhatever(canvas, player.aspect.bigSymbolImgLocation);

    if (!baby && player.isTroll && player.godTier) { //wings before sprite
      wings(canvas, player);
    }

    if (!baby && player.dead) {
      bloodPuddle(canvas, player);
    }
    hairBack(canvas, player);
    if (player.isTroll) { //wings before sprite
      fin2(canvas, player);
    }

    if (!baby && !player.baby_stuck) {
      playerToSprite(canvas, player);
      bloody_face(canvas, player); //not just for murder mode, because you can kill another player if THEY are murder mode.
      if (player.murderMode == true) {
        scratch_face(canvas, player);
      }
      if (player.leftMurderMode == true) {
        scar_face(canvas, player);
      }
      if (player.robot == true) {
        robo_face(canvas, player);
      }
    } else {
      await babySprite(canvas, player);
      if (player.baby_stuck && !baby) {
        bloody_face(canvas, player); //not just for murder mode, because you can kill another player if THEY are murder mode.
        if (player.murderMode == true) {
          scratch_face(canvas, player);
        }
        if (player.leftMurderMode == true) {
          scar_face(canvas, player);
        }
        if (player.robot == true) {
          robo_face(canvas, player);
        }
      }
    }


    if (ouija) {
      drawWhatever(canvas, "/Bodies/pen15.png");
    }

    if (faceOff) {
      if (random() > .9) {
        drawWhatever(canvas, "/Bodies/face4.png");

        ///spooky wolf easter egg.
      } else {
        drawWhatever(canvas, "/Bodies/face${player.baby}.png");
      }
    }
    hair(canvas, player);
    if (player.isTroll) { //wings before sprite
      fin1(canvas, player);
    }
    if (!baby && player.godTier) {
      PaletteSwapCallback callback = aspectPalletSwap;
      if (player.trickster) callback = candyPalletSwap;
      if (player.robot) callback = robotPalletSwap;
      drawWhateverWithPalleteSwapCallback(canvas, playerToCowl(player), player, callback);
    }

    if (player.robot == true) {
      roboSkin(canvas); //, player);
    } else if (player.trickster == true) {
      peachSkin(canvas, player);
    } else if (!baby && player.grimDark > 3) {
      grimDarkSkin(canvas); //, player);
    } else if (player.isTroll) {
      greySkin(canvas); //,player);
    }
    if (player.isTroll) {
      horns(canvas, player);
    }

    if (!baby && player.dead && player.causeOfDeath == "after being shown too many stabs from Jack") {
      stabs(canvas, player);
    } else if (!baby && player.dead && player.causeOfDeath == "fighting the Black King") {
      kingDeath(canvas, player);
    }


    if (!baby && player.ghost) {
      //wasteOfMindSymbol(canvas, player);
      //halo(canvas, player.influenceSymbol);
      if (player.causeOfDrain != null) {
        drainedGhostSwap(canvas);
      } else {
        ghostSwap(canvas);
      }
    }

    if (player.brainGhost){
      ;
      ghostSwap(canvas);
    }

    if (!baby && player.aspect == Aspects.VOID) {
      voidSwap(canvas, 1 - player.getStat(Stats.POWER) / (2000 * Stats.POWER.coefficient)); //a void player at 2000 power is fully invisible.
    }else if(player.session.mutator.lightField && !player.session.mutator.hasSpotLight(player)) {
      voidSwap(canvas, 0.2); //compared to the light player, you are irrelevant.
    }

    canvas.context2D.restore();

  }


  static void playerToSprite(CanvasElement canvas, Player player) {
    //CanvasRenderingContext2D ctx = canvas.getContext('2d');
    if (player.robot == true) {
      robotSprite(canvas, player);
    } else if (player.trickster) {
      tricksterSprite(canvas, player);
    } else if (player.godTier) {
      godTierSprite(canvas, player);
    } else if (player.isDreamSelf) {
      dreamSprite(canvas, player);
    } else {
      regularSprite(canvas, player);
    }
  }


  static void robo_face(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = "robo_face.png";
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
  }


  static void scar_face(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = "calm_scratch_face.png";
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
  }


  static void scratch_face(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = "scratch_face.png";
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    swapColors(canvas, ReferenceColours.BLOOD_PUDDLE, new Colour.fromStyleString(player.bloodColor)); //it's their own blood
  }


  //not just murder mode, you could have killed a murder mode player.
  static void bloody_face(CanvasElement canvas, Player player) {
    if (player.victimBlood != null) {
      CanvasRenderingContext2D ctx = canvas.getContext('2d');
      String imageString = "bloody_face.png";
      addImageTag(imageString);
      ImageElement img = imageSelector(imageString);
      ctx.drawImage(img, 0, 0);
      swapColors(canvas, ReferenceColours.BLOODY_FACE, new Colour.fromStyleString(player.victimBlood)); //it's not their own blood
    }
  }



  static void hair(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = "Hair/hair${player.hair}.png";
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    if (player.sbahj) {
      sbahjifier(canvas);
    }
    if (player.isTroll) {
      swapColors(canvas, ReferenceColours.HAIR, new Colour.fromStyleString(player.hairColor));
      swapColors(canvas, ReferenceColours.HAIR_ACCESSORY, new Colour.fromStyleString(player.bloodColor));
    } else {
      swapColors(canvas, ReferenceColours.HAIR, new Colour.fromStyleString(player.hairColor));
      swapColors(canvas, ReferenceColours.HAIR_ACCESSORY, player.aspect.palette.accent);
    }
  }



  static String playerToRegularBody(Player player) {
    if (easter_egg) return playerToEggBody(player);
    return "Bodies/reg${(classNameToInt(player.class_name)+1)}.png";
  }

  static String playerToCowl(Player player) {
    if (easter_egg) return playerToEggBody(player); //no cowl, just double up on egg.
    return "Bodies/cowl${(classNameToInt(player.class_name)+1)}.png";
  }


  static String playerToDreamBody(Player player) {
    if (easter_egg) return playerToEggBody(player);
    return "Bodies/dream${(classNameToInt(player.class_name)+1)}.png";
  }


  static String playerToEggBody(Player player) {
    return "Bodies/egg${(classNameToInt(player.class_name)+1)}.png";
  }


  static void robotSprite(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString;
    if (!player.godTier) {
      imageString = playerToRegularBody(player);
    } else {
      imageString = playerToGodBody(player);
    }
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    robotPalletSwap(canvas, player);
    //eeeeeh...could figure out how to color swap symbol, but lazy.
  }


  static void tricksterSprite(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString;
    if (!player.godTier) {
      imageString = playerToRegularBody(player);
    } else {
      imageString = playerToGodBody(player);
    }
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    candyPalletSwap(canvas, player);
    //aspectSymbol(canvas, player);
  }


  static void regularSprite(CanvasElement canvas, Player player) {
    String imageString = playerToRegularBody(player);
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    if (player.sbahj) {
      sbahjifier(canvas);
    }
    aspectPalletSwap(canvas, player);
    //aspectSymbol(canvas, player);
  }


  static void dreamSprite(CanvasElement canvas, Player player) {
    String imageString = playerToDreamBody(player);
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    CanvasRenderingContext2D ctx = canvas.getContext("2d");
    ctx.drawImage(img, 0, 0);
    dreamPalletSwap(canvas, player);
  }


  static String playerToGodBody(Player player) {
    if (easter_egg) return playerToEggBody(player);
    return "Bodies/god${(classNameToInt(player.class_name)+1)}.png";
  }


  static void godTierSprite(CanvasElement canvas, Player player) {
    //draw class, then color like aspect, then draw chest icon
    //ctx.drawImage(img,canvas.width/2,canvas.height/2,width,height);
    CanvasRenderingContext2D ctx = canvas.getContext("2d");
    String imageString = playerToGodBody(player);
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
    if (bardQuest && player.class_name == SBURBClassManager.BARD) {
      drawWhatever(canvas, "/Bodies/cod.png");
    }
    aspectPalletSwap(canvas, player);
    if (player.sbahj) {
      sbahjifier(canvas);
    }
    aspectSymbol(canvas, player);
  }


  static Future<void> babySprite(CanvasElement canvas, Player player) async {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    if(player.baby == null) {
      player.baby = 1;
    }
    String imageString = "images/Bodies/baby${player.baby}.png";
    if (player.isTroll) {
      imageString = "images/Bodies/grub${player.baby}.png";
    }
    ImageElement img = new ImageElement(src: imageString);
    Completer<void> completer = new Completer<void>();
    img.onLoad.listen((Event e) {
      ctx.drawImage(img, 0, 0);
      if (player.sbahj) {
        sbahjifier(canvas);
      }
      if (player.isTroll) {
        swapColors(canvas, ReferenceColours.GRUB, new Colour.fromStyleString(player.bloodColor));
      } else {
        swapColors(canvas, ReferenceColours.SPRITE_PALETTE.pants_light, player.aspect.palette.shirt_light);
        swapColors(canvas, ReferenceColours.SPRITE_PALETTE.pants_dark, player.aspect.palette.shirt_dark);
      }

      completer.complete();
    });
    return completer.future;
  }


  static void aspectSymbol(CanvasElement canvas, Player player) {
    CanvasRenderingContext2D ctx = canvas.getContext('2d');
    String imageString = player.aspect.symbolImgLocation;
    addImageTag(imageString);
    ImageElement img = imageSelector(imageString);
    ctx.drawImage(img, 0, 0);
  }

  static void robotPalletSwap(CanvasElement canvas, Player player) {
    swapPalette(canvas, ReferenceColours.SPRITE_PALETTE, ReferenceColours.ROBOT_PALETTE);
  }


  static void dreamPalletSwap(CanvasElement canvas, Player player) {
    Palette shoes = new AspectPalette()
      ..shoe_light = player.aspect.palette.shirt_light
      ..shoe_dark = player.aspect.palette.shirt_dark;

    Palette dream = player.dreamPalette;
    Palette p = new Palette.combined(<Palette>[dream, shoes]);

    swapPalette(canvas, ReferenceColours.SPRITE_PALETTE, p);
  }


  static void candyPalletSwap(CanvasElement canvas, Player player) {
    //not all browsers do png gama info correctly. Chrome does, firefox does not, mostly.
    //remove it entirely with this command
    //pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB infile.png outfile.png
    //pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB reg001.png reg001copy.png
    //./pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB stab.png stab_copy.png

    AspectPalette candy = new AspectPalette();

    //I am the GREETEST. Figured out how to make spreadsheet auto gen code: ="new_color"&ROW()&"='#" &B23 &"';"
    if (player.aspect == Aspects.LIGHT) {
      candy
        ..aspect_light = tricksterColors[0]
        ..aspect_dark = tricksterColors[1]
        ..shoe_light = tricksterColors[2]
        ..shoe_dark = tricksterColors[3]
        ..cloak_light = tricksterColors[4]
        ..cloak_mid = tricksterColors[5]
        ..cloak_dark = tricksterColors[6]
        ..shirt_light = tricksterColors[7]
        ..shirt_dark = tricksterColors[8]
        ..pants_light = tricksterColors[9]
        ..pants_dark = tricksterColors[10];
    } else if (player.aspect == Aspects.BREATH) {
      candy
        ..aspect_light = tricksterColors[11]
        ..aspect_dark = tricksterColors[12]
        ..shoe_light = tricksterColors[13]
        ..shoe_dark = tricksterColors[14]
        ..cloak_light = tricksterColors[15]
        ..cloak_mid = tricksterColors[16]
        ..cloak_dark = tricksterColors[17]
        ..shirt_light = tricksterColors[18]
        ..shirt_dark = tricksterColors[0]
        ..pants_light = tricksterColors[1]
        ..pants_dark = tricksterColors[2];
    } else if (player.aspect == Aspects.TIME) {
      candy
        ..aspect_light = tricksterColors[3]
        ..aspect_dark = tricksterColors[4]
        ..shoe_light = tricksterColors[5]
        ..shoe_dark = tricksterColors[6]
        ..cloak_light = tricksterColors[7]
        ..cloak_mid = tricksterColors[8]
        ..cloak_dark = tricksterColors[9]
        ..shirt_light = tricksterColors[10]
        ..shirt_dark = tricksterColors[11]
        ..pants_light = tricksterColors[12]
        ..pants_dark = tricksterColors[13];
    } else if (player.aspect == Aspects.SPACE) {
      candy
        ..aspect_light = tricksterColors[14]
        ..aspect_dark = tricksterColors[15]
        ..shoe_light = tricksterColors[16]
        ..shoe_dark = tricksterColors[17]
        ..cloak_light = tricksterColors[18]
        ..cloak_mid = tricksterColors[0]
        ..cloak_dark = tricksterColors[1]
        ..shirt_light = tricksterColors[2]
        ..shirt_dark = tricksterColors[3]
        ..pants_light = tricksterColors[4]
        ..pants_dark = tricksterColors[5];
    } else if (player.aspect == Aspects.HEART) {
      candy
        ..aspect_light = tricksterColors[6]
        ..aspect_dark = tricksterColors[7]
        ..shoe_light = tricksterColors[8]
        ..shoe_dark = tricksterColors[9]
        ..cloak_light = tricksterColors[10]
        ..cloak_mid = tricksterColors[11]
        ..cloak_dark = tricksterColors[12]
        ..shirt_light = tricksterColors[13]
        ..shirt_dark = tricksterColors[14]
        ..pants_light = tricksterColors[15]
        ..pants_dark = tricksterColors[16];
    } else if (player.aspect == Aspects.MIND) {
      candy
        ..aspect_light = tricksterColors[17]
        ..aspect_dark = tricksterColors[18]
        ..shoe_light = tricksterColors[17]
        ..shoe_dark = tricksterColors[16]
        ..cloak_light = tricksterColors[15]
        ..cloak_mid = tricksterColors[14]
        ..cloak_dark = tricksterColors[13]
        ..shirt_light = tricksterColors[12]
        ..shirt_dark = tricksterColors[11]
        ..pants_light = tricksterColors[10]
        ..pants_dark = tricksterColors[9];
    } else if (player.aspect == Aspects.LIFE) {
      candy
        ..aspect_light = tricksterColors[8]
        ..aspect_dark = tricksterColors[7]
        ..shoe_light = tricksterColors[6]
        ..shoe_dark = tricksterColors[5]
        ..cloak_light = tricksterColors[4]
        ..cloak_mid = tricksterColors[3]
        ..cloak_dark = tricksterColors[2]
        ..shirt_light = tricksterColors[1]
        ..shirt_dark = tricksterColors[0]
        ..pants_light = tricksterColors[1]
        ..pants_dark = tricksterColors[2];
    } else if (player.aspect == Aspects.VOID) {
      candy
        ..aspect_light = tricksterColors[3]
        ..aspect_dark = tricksterColors[5]
        ..shoe_light = tricksterColors[8]
        ..shoe_dark = tricksterColors[0]
        ..cloak_light = tricksterColors[10]
        ..cloak_mid = tricksterColors[11]
        ..cloak_dark = tricksterColors[3]
        ..shirt_light = tricksterColors[4]
        ..shirt_dark = tricksterColors[8]
        ..pants_light = tricksterColors[7]
        ..pants_dark = tricksterColors[6];
    } else if (player.aspect == Aspects.HOPE) {
      candy
        ..aspect_light = tricksterColors[10]
        ..aspect_dark = tricksterColors[9]
        ..shoe_light = tricksterColors[8]
        ..shoe_dark = tricksterColors[7]
        ..cloak_light = tricksterColors[6]
        ..cloak_mid = tricksterColors[5]
        ..cloak_dark = tricksterColors[4]
        ..shirt_light = tricksterColors[3]
        ..shirt_dark = tricksterColors[2]
        ..pants_light = tricksterColors[1]
        ..pants_dark = tricksterColors[0];
    }
    else if (player.aspect == Aspects.DOOM) {
      candy
        ..aspect_light = tricksterColors[18]
        ..aspect_dark = tricksterColors[17]
        ..shoe_light = tricksterColors[16]
        ..shoe_dark = tricksterColors[0]
        ..cloak_light = tricksterColors[15]
        ..cloak_mid = tricksterColors[14]
        ..cloak_dark = tricksterColors[13]
        ..shirt_light = tricksterColors[12]
        ..shirt_dark = tricksterColors[10]
        ..pants_light = tricksterColors[9]
        ..pants_dark = tricksterColors[10];
    } else if (player.aspect == Aspects.RAGE) {
      candy
        ..aspect_light = tricksterColors[4]
        ..aspect_dark = tricksterColors[1]
        ..shoe_light = tricksterColors[3]
        ..shoe_dark = tricksterColors[6]
        ..cloak_light = tricksterColors[1]
        ..cloak_mid = tricksterColors[2]
        ..cloak_dark = tricksterColors[1]
        ..shirt_light = tricksterColors[0]
        ..shirt_dark = tricksterColors[2]
        ..pants_light = tricksterColors[5]
        ..pants_dark = tricksterColors[7];
    } else if (player.aspect == Aspects.BLOOD) {
      candy
        ..aspect_light = tricksterColors[1]
        ..aspect_dark = tricksterColors[2]
        ..shoe_light = tricksterColors[3]
        ..shoe_dark = tricksterColors[4]
        ..cloak_light = tricksterColors[5]
        ..cloak_mid = tricksterColors[10]
        ..cloak_dark = tricksterColors[18]
        ..shirt_light = tricksterColors[15]
        ..shirt_dark = tricksterColors[14]
        ..pants_light = tricksterColors[13]
        ..pants_dark = tricksterColors[0];
    }


    swapPalette(canvas, ReferenceColours.SPRITE_PALETTE, candy);
  }


  static void aspectPalletSwap(CanvasElement canvas, Player player) {
    //not all browsers do png gama info correctly. Chrome does, firefox does not, mostly.
    //remove it entirely with this command
    //pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB infile.png outfile.png
    //pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB reg001.png reg001copy.png
    //./pngcrush -rem gAMA -rem cHRM -rem iCCP -rem sRGB stab.png stab_copy.png

    //I am the GREETEST. Figured out how to make spreadsheet auto gen code: ="new_color"&ROW()&"='#" &B23 &"';"
    /*if (player.aspect == "Light") {
            new_color1 = '#FEFD49';
            new_color2 = '#FEC910';
            new_color3 = '#10E0FF';
            new_color4 = '#00A4BB';
            new_color5 = '#FA4900';
            new_color6 = '#E94200';
            new_color7 = '#C33700';
            new_color8 = '#FF8800';
            new_color9 = '#D66E04';
            new_color10 = '#E76700';
            new_color11 = '#CA5B00';
        } else if (player.aspect == "Breath") {
            new_color1 = '#10E0FF';
            new_color2 = '#00A4BB';
            new_color3 = '#FEFD49';
            new_color4 = '#D6D601';
            new_color5 = '#0052F3';
            new_color6 = '#0046D1';
            new_color7 = '#003396';
            new_color8 = '#0087EB';
            new_color9 = '#0070ED';
            new_color10 = '#006BE1';
            new_color11 = '#0054B0';
        } else if (player.aspect == "Time") {
            new_color1 = '#FF2106';
            new_color2 = '#AD1604';
            new_color3 = '#030303';
            new_color4 = '#242424';
            new_color5 = '#510606';
            new_color6 = '#3C0404';
            new_color7 = '#1F0000';
            new_color8 = '#B70D0E';
            new_color9 = '#970203';
            new_color10 = '#8E1516';
            new_color11 = '#640707';
        } else if (player.aspect == "Space") {
            new_color1 = '#EFEFEF';
            new_color2 = '#DEDEDE';
            new_color3 = '#FF2106';
            new_color4 = '#B01200';
            new_color5 = '#2F2F30';
            new_color6 = '#1D1D1D';
            new_color7 = '#080808';
            new_color8 = '#030303';
            new_color9 = '#242424';
            new_color10 = '#333333';
            new_color11 = '#141414';
        } else if (player.aspect == "Heart") {
            new_color1 = '#BD1864';
            new_color2 = '#780F3F';
            new_color3 = '#1D572E';
            new_color4 = '#11371D';
            new_color5 = '#4C1026';
            new_color6 = '#3C0D1F';
            new_color7 = '#260914';
            new_color8 = '#6B0829';
            new_color9 = '#4A0818';
            new_color10 = '#55142A';
            new_color11 = '#3D0E1E';
        } else if (player.aspect == "Mind") {
            new_color1 = '#06FFC9';
            new_color2 = '#04A885';
            new_color3 = '#6E0E2E';
            new_color4 = '#4A0818';
            new_color5 = '#1D572E';
            new_color6 = '#164524';
            new_color7 = '#11371D';
            new_color8 = '#3DA35A';
            new_color9 = '#2E7A43';
            new_color10 = '#3B7E4F';
            new_color11 = '#265133';
        } else if (player.aspect == "Life") {
            new_color1 = '#76C34E';
            new_color2 = '#4F8234';
            new_color3 = '#00164F';
            new_color4 = '#00071A';
            new_color5 = '#605542';
            new_color6 = '#494132';
            new_color7 = '#2D271E';
            new_color8 = '#CCC4B5';
            new_color9 = '#A89F8D';
            new_color10 = '#A29989';
            new_color11 = '#918673';
        } else if (player.aspect == "Void") {
            new_color1 = '#0B1030';
            new_color2 = '#04091A';
            new_color3 = '#CCC4B5';
            new_color4 = '#A89F8D';
            new_color5 = '#00164F';
            new_color6 = '#00103C';
            new_color7 = '#00071A';
            new_color8 = '#033476';
            new_color9 = '#02285B';
            new_color10 = '#004CB2';
            new_color11 = '#003E91';
        } else if (player.aspect == "Hope") {
            new_color1 = '#FDF9EC';
            new_color2 = '#D6C794';
            new_color3 = '#164524';
            new_color4 = '#06280C';
            new_color5 = '#FFC331';
            new_color6 = '#F7BB2C';
            new_color7 = '#DBA523';
            new_color8 = '#FFE094';
            new_color9 = '#E8C15E';
            new_color10 = '#F6C54A';
            new_color11 = '#EDAF0C';
        }
        else if (player.aspect == "Doom") {
            new_color1 = '#0F0F0F';
            new_color2 = '#010101';
            new_color3 = '#E8C15E';
            new_color4 = '#C7A140';
            new_color5 = '#1E211E';
            new_color6 = '#141614';
            new_color7 = '#0B0D0B';
            new_color8 = '#204020';
            new_color9 = '#11200F';
            new_color10 = '#192C16';
            new_color11 = '#121F10';
        } else if (player.aspect == "Rage") {
            new_color1 = '#974AA7';
            new_color2 = '#6B347D';
            new_color3 = '#3D190A';
            new_color4 = '#2C1207';
            new_color5 = '#7C3FBA';
            new_color6 = '#6D34A6';
            new_color7 = '#592D86';
            new_color8 = '#381B76';
            new_color9 = '#1E0C47';
            new_color10 = '#281D36';
            new_color11 = '#1D1526';
        } else if (player.aspect == "Blood") {
            new_color1 = '#BA1016';
            new_color2 = '#820B0F';
            new_color3 = '#381B76';
            new_color4 = '#1E0C47';
            new_color5 = '#290704';
            new_color6 = '#230200';
            new_color7 = '#110000';
            new_color8 = '#3D190A';
            new_color9 = '#2C1207';
            new_color10 = '#5C2913';
            new_color11 = '#4C1F0D';
        } else {
            new_color1 = '#FF9B00';
            new_color2 = '#FF8700';
            new_color3 = '#7F7F7F';
            new_color4 = '#727272';
            new_color5 = '#A3A3A3';
            new_color6 = '#999999';
            new_color7 = '#898989';
            new_color8 = '#EFEFEF';
            new_color9 = '#DBDBDB';
            new_color10 = '#C6C6C6';
            new_color11 = '#ADADAD';
        }
        */

    swapPalette(canvas, ReferenceColours.SPRITE_PALETTE, player.aspect.palette);
  }


  static CanvasElement getBufferCanvas(int width, int height) {
    return new CanvasElement(width: width, height: height);
  }

}