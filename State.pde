class State {

  String name;
  String fullName;
  ArrayList<String> tweets = new ArrayList();
  float wait;
  int sampleSize;
  int x, y;
  RShape statePic;
  PVector pos = new PVector(x, y);
  PVector targetPos = new PVector();
  PVector hiddenPos = new PVector(131, 253);
  PFont font = loadFont("LaGiocondaOSTT-20.vlw");

  //scroll tweets
  int tweetCounter = 0;
  int tweetDelay = 6000;
  int tweetTimer = millis();

  //state picture characteristics for highlighting
  float scaling = 1;
  String c = "#FFFFFF";
  int a = 255;

  //booleans on highlighting stuff
  boolean highlight = false;
  boolean isInside = false;
  boolean hidden = false;
  boolean showTweets = false;

  void render() {
    statePic = RG.loadShape("statePics/"+name+".svg");
    statePic.setFill(true);
    //statePic.centerIn(g, 100, 1, 1);
    textFont(font);
  }


  void update() {
    if (!hidden) {
      pushMatrix();
      if (highlight) {
        scaling = lerp(scaling, 3, .1);
        targetPos = new PVector(int(131 + 337/2 - 3*statePic.width/2), int(253 + 190/2 - 3*statePic.height/2));
        pos.lerp(targetPos, .1);
      } 
      else {
        scaling = lerp(scaling, 1, .1);
        targetPos = new PVector(x, y);
        pos.lerp(targetPos, .1);
      }

      RPoint p = new RPoint(mouseX-pos.x, mouseY-pos.y);
      if (statePic.contains(p)) {
        c = "#6F6F8C";
        //fill(#000000);
        //text(name, mouseX, mouseY);
        isInside = true;
      } 
      else {
        c = "#FFFFFF";
        isInside = false;
      }

      translate(pos.x, pos.y);
      scale(scaling);
      statePic.children[0].setFill(highlight ? "#6F6F8C": c);
      noStroke();
      statePic.children[0].draw();
      popMatrix();
      if (isInside) {
        fill(#000000);
        text(fullName, 131 + 337/2 - textWidth(fullName)/2, 253 - 20);
      }
    } 
    else {
      pushMatrix();
      scaling = lerp(scaling, 0, .1);
      translate(pos.x, pos.y);
      scale(scaling);
      //statePic.children[0].setFill(color(60, 59, 110));
      statePic.children[0].setFill("#FFFFFF");
      pos.lerp(hiddenPos, .1);
      noStroke();
      statePic.children[0].draw();
      popMatrix();
    }

    if (highlight) {
      showTweets();
    }
  }

  void fromCSV(String[] input) {
    name = input[0];
    wait = float(input[1]);
    sampleSize = int(input[2]);
    x = int(input[3]);
    y = int(input[4]);
    fullName = input[5];
  }

  void loadTweets() {
    String[] rows = loadStrings("StateTweets.csv");
    for (int i = 1; i < rows.length; i++) {
      String[] row = rows[i].split(",zzzz,");
      if (name.equals(row[1])) {
        tweets.add(row[0]);
      }
    }
  }

  void showTweets() {
    if (tweetDelay > millis() - tweetTimer) {
      String t = '"' + tweets.get(tweetCounter) + '"';
      fill(255);
      textLeading(20);
      text(t, 170, 294, 267, 135);
    } else if (tweetDelay < millis() - tweetTimer) {
      tweetCounter ++;
      if (tweetCounter >= tweets.size()) {
        tweetCounter = 0;
      }
      tweetTimer = millis();
    }
  }
}

