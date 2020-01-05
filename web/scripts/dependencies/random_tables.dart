import "dart:html";
import "dart:math" as Math;
import 'Colour.dart';

//TODO strip all this out and put in classes. eventually. but for now, just fucking get thigns working
//little bobby tables

//going to refactor so that all randomness is seeded.
/*Math.seed = getRandomSeed();  //can be overwritten on load
var initial_seed = Math.seed;
dynamic rand.pickFrom(array){
	num min = 0;
	var max = array.length-1;
	var i = Math.floor(rand.nextDouble() * (max - min + 1)) + min;
	return array[i];
}*/


//http://jsfiddle.net/JKirchartz/wwckP/    horrorterror html stuff
class Zalgo {
  static Map<int, List<String>> chars = <int, List<String>>{
    0: <String>[ /* up */
      '\u030d', /*     ̍     */
      '\u030e', /*     ̎     */
      '\u0304', /*     ̄     */
      '\u0305', /*     ̅     */
      '\u033f', /*     ̿     */
      '\u0311', /*     ̑     */
      '\u0306', /*     ̆     */
      '\u0310', /*     ̐     */
      '\u0352', /*     ͒     */
      '\u0357', /*     ͗     */
      '\u0351', /*     ͑     */
      '\u0307', /*     ̇     */
      '\u0308', /*     ̈     */
      '\u030a', /*     ̊     */
      '\u0342', /*     ͂     */
      '\u0343', /*     ̓     */
      '\u0344', /*     ̈́     */
      '\u034a', /*     ͊     */
      '\u034b', /*     ͋     */
      '\u034c', /*     ͌     */
      '\u0303', /*     ̃     */
      '\u0302', /*     ̂     */
      '\u030c', /*     ̌     */
      '\u0350', /*     ͐     */
      '\u0300', /*     ̀     */
      '\u0301', /*     ́     */
      '\u030b', /*     ̋     */
      '\u030f', /*     ̏     */
      '\u0312', /*     ̒     */
      '\u0313', /*     ̓     */
      '\u0314', /*     ̔     */
      '\u033d', /*     ̽     */
      '\u0309', /*     ̉     */
      '\u0363', /*     ͣ     */
      '\u0364', /*     ͤ     */
      '\u0365', /*     ͥ     */
      '\u0366', /*     ͦ     */
      '\u0367', /*     ͧ     */
      '\u0368', /*     ͨ     */
      '\u0369', /*     ͩ     */
      '\u036a', /*     ͪ     */
      '\u036b', /*     ͫ     */
      '\u036c', /*     ͬ     */
      '\u036d', /*     ͭ     */
      '\u036e', /*     ͮ     */
      '\u036f', /*     ͯ     */
      '\u033e', /*     ̾     */
      '\u035b', /*     ͛     */
      '\u0346', /*     ͆     */
      '\u031a' /*     ̚     */
    ],
    1: <String>[ /* down */
      '\u0316', /*     ̖     */
      '\u0317', /*     ̗     */
      '\u0318', /*     ̘     */
      '\u0319', /*     ̙     */
      '\u031c', /*     ̜     */
      '\u031d', /*     ̝     */
      '\u031e', /*     ̞     */
      '\u031f', /*     ̟     */
      '\u0320', /*     ̠     */
      '\u0324', /*     ̤     */
      '\u0325', /*     ̥     */
      '\u0326', /*     ̦     */
      '\u0329', /*     ̩     */
      '\u032a', /*     ̪     */
      '\u032b', /*     ̫     */
      '\u032c', /*     ̬     */
      '\u032d', /*     ̭     */
      '\u032e', /*     ̮     */
      '\u032f', /*     ̯     */
      '\u0330', /*     ̰     */
      '\u0331', /*     ̱     */
      '\u0332', /*     ̲     */
      '\u0333', /*     ̳     */
      '\u0339', /*     ̹     */
      '\u033a', /*     ̺     */
      '\u033b', /*     ̻     */
      '\u033c', /*     ̼     */
      '\u0345', /*     ͅ     */
      '\u0347', /*     ͇     */
      '\u0348', /*     ͈     */
      '\u0349', /*     ͉     */
      '\u034d', /*     ͍     */
      '\u034e', /*     ͎     */
      '\u0353', /*     ͓     */
      '\u0354', /*     ͔     */
      '\u0355', /*     ͕     */
      '\u0356', /*     ͖     */
      '\u0359', /*     ͙     */
      '\u035a', /*     ͚     */
      '\u0323' /*     ̣     */
    ],
    2: <String>[ /* mid */
      '\u0315', /*     ̕     */
      '\u031b', /*     ̛     */
      '\u0340', /*     ̀     */
      '\u0341', /*     ́     */
      '\u0358', /*     ͘     */
      '\u0321', /*     ̡     */
      '\u0322', /*     ̢     */
      '\u0327', /*     ̧     */
      '\u0328', /*     ̨     */
      '\u0334', /*     ̴     */
      '\u0335', /*     ̵     */
      '\u0336', /*     ̶     */
      '\u034f', /*     ͏     */
      '\u035c', /*     ͜     */
      '\u035d', /*     ͝     */
      '\u035e', /*     ͞     */
      '\u035f', /*     ͟     */
      '\u0360', /*     ͠     */
      '\u0362', /*     ͢     */
      '\u0338', /*     ̸     */
      '\u0337', /*     ̷      */
      '\u0361', /*     ͡     */
      '\u0489' /*     ҉_     */
    ]
  };

  static num random([int len]) {
    var rng = new Math.Random();
    if (len == 1) return 0;
    return len != null ? (rng.nextDouble() * len + 1).floor() - 1 : rng.nextDouble();
  }

  static String generate(str) {
    var str_arr = str.split(''),
        output = str_arr.map((a) {
          ;
          if (a == " ") return a;
          for (var i = 0, l = Zalgo.random(16);
          i < l; i++) {
            var rand = Zalgo.random(3);
            a += Zalgo.chars[rand][
            Zalgo.random(Zalgo.chars[rand].length)
            ];
          }
          return a;
        });
    return output.join('');
  }
}

String turnArrayIntoHumanSentence(List<dynamic> retArray) {
  return [retArray.sublist(0, retArray.length - 1).join(', '), retArray.last].join(retArray.length < 2 ? '' : ' and ');
}

String capitilizeString(String s) {
  return "${s[0].toUpperCase()}${s.substring(1)}";
}

String capitilizeEachWord(String s) {
  List<String> words =  s.split(" ");
  String ret = "";
  for(String word in words) {
    ret += " ${capitilizeString(word)}";
  }
  return ret;
}
