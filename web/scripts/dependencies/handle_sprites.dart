import "dart:async";
import "dart:html";
import "dart:math" as Math;

import "SBURBSim.dart";

bool ouija = false;


ImageElement imageSelector(String path) {
  return querySelector("#${escapeId(path)}");
}

abstract class ReferenceColours {
  static Colour BLACK = new Colour.fromHex(0x000000);
  static Colour RED = new Colour.fromHex(0xFF0000);


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

}

abstract class Drawing {

  static void addImageTag(String url) {
    ////print(url);
    //only do it if image hasn't already been added.
    if (imageSelector(url) == null) {
      String tag = '<img id="${escapeId(url)}" src = "images/$url" class="loadedimg">';
      querySelector("#image_staging").appendHtml(tag, treeSanitizer: NodeTreeSanitizer.trusted);
    }
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


}