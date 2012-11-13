import geomerative.*;

ArrayList<State> states = new ArrayList();

RShape flag;
PImage bg;

int activeState = 9999;
boolean clicked;

gif_controller gif_man;


void setup() {
  size(1200, 800);
  RG.init(this);
  //RG.setPolygonizer(RG.ADAPTATIVE);
  bg = loadImage("Background.png");
  flag = RG.loadShape("Flag_Vote.svg");
  //loadBackground();
  loadData();

  gif_man=new gif_controller(this, 0.5);//this number is the playback speed for gif
  gif_man.reset_location();
  gif_man.set_speed(0);
  gif_man.set_overall_time(7200);
}


void draw() {
  loadBackground();
  for (State s:states) {
    s.update();
  }
  gif_man.move();
  gif_man.draw();
}



void loadData() {
  String[] rows = loadStrings("StateTime.csv");
  for (int i = 1; i < 39; i++) {
    State s = new State();
    s.fromCSV(rows[i].split(","));
    s.loadTweets();
    states.add(s);
    RG.init(this);
    RG.setPolygonizer(RG.ADAPTATIVE);
    states.get(i-1).render();
  }
}


void loadBackground() {
  image(bg, 0, 0);
  fill(255);
  noStroke();
  rect(131, 253, 938, 494);

  pushMatrix();
  translate(131, 253);
  //flag.centerIn(g);
  flag.draw();
  popMatrix();
}

void mouseClicked() {
  clicked = !clicked;
  for (int i = 0; i < states.size(); i ++) {
    if (clicked && states.get(i).isInside) {
      hideAll();
    }
    if (states.get(i).isInside && clicked) {
      states.get(i).hidden = false;
      states.get(i).highlight = true;
      gif_man.reset_location();
      gif_man.set_speed(states.get(i).wait);
      //states.get(i).showTweets();
      //clicked = true;

      //activeState = i;
    } 
    if (!clicked) {
      states.get(i).highlight = false;
      showAll();
    }


    /*
    else if (!states.get(i).isInside && clicked) {
     states.get(i).highlight = false;
     states.get(i).hidden = true;
     } 
     else {
     states.get(i).highlight = false;
     states.get(i).hidden = false;
     clicked = false;
     }
     */
  }
}

void hideAll() {
  for (State s:states) {
    s.hidden = true;
  }
}

void showAll() {
  for (State s:states) {
    s.hidden = false;
  }
}

class State {

  String name;
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

import gifAnimation.*;
class gif_controller {
  PFont bubble_font= loadFont("LaGiocondaOSTT-20.vlw");
  Gif loopingGif;
  PImage bubble, plus_1;
  PImage[] animation;
  float frame_step=1;
  float frame_counter=0;
  float pos_x, pos_y;
  float speed=1;
  float phase=0;
  boolean facing_right=true;
  boolean finished=false;
  String left_time="??:??:?? to go!";
  int full_time_in_seconds=3600;
  gif_controller(PApplet parent, float frame_step_) {
    bubble=loadImage("SpeechBubble.png");
    plus_1=loadImage("PlusOne.png");
    frame_step= frame_step_;
    animation=Gif.getPImages(parent, "gw6.gif");
    println(animation.length);
    reset_location();
  }
  void reset_location() {
    pos_x=400;
    pos_y=95;
    phase=0;
    //phase=(550+79)*3+((900+79)*4-79)-100;  //for test
    finished=false;
  }
  void set_speed(float speed_) {
    speed=speed_;
  }
  void set_overall_time(int full_time_in_seconds_) {
    full_time_in_seconds=full_time_in_seconds_;
  }

  void move() {
    if (finished==false) phase+=speed;
    calc_phase();

    int time_left=(int)(full_time_in_seconds*(1-phase/((550+79)*3+((900+79)*4-79))));
    if (time_left<0) time_left=0;
    int seconds=time_left%60;
    time_left=time_left/60;
    int minutes=time_left%60;
    int hours=time_left/60;
    left_time=nf(hours, 2)+":"+nf(minutes, 2)+":"+nf(seconds, 2)+" to go!";
  }

  void draw() {
    frame_counter+=frame_step;
    if (frame_counter>=12) frame_counter-=12;

    // image((animation[(int)frame_counter]), , pos_y, 200, 184);


    pushMatrix();
    int offset=50;
    translate(pos_x+58+offset, pos_y+90);
    //if (mousePressed) scale(-1, 1); 
    if (!facing_right) scale(-1, 1); 
    image((animation[(int)frame_counter]), -offset, 0, 103, 95);
    popMatrix();
    if (finished==false) {
      image(bubble, pos_x+140, pos_y+85);
      textFont(bubble_font);
      fill(0);
      text(left_time, pos_x+147, pos_y+108);
    }
    else {
      image(plus_1, pos_x+140, pos_y+95);
    }
    //  println(mouseX + " " +mouseY);
    // frame
  }

  void calc_phase() {
    int level=0;
    float phase_level=0;
    if (phase<(550+79)*3) {  //first 3 lines
      level=int(phase/(550+79));
      phase_level=phase-level*(550+79);
      if (phase_level<550) {
        if (level%2==0) {//0,2
          pos_x=400+phase_level;
        }
        else {
          pos_x=950-phase_level;
        }
        pos_y=95+76*level;
      }
      else {
        pos_x=(level%2==0?950:400);
        pos_y=95+76*level+(phase_level-550);
      }
      facing_right=(level%2==0);
    }
    else if (phase<(550+79)*3+((900+79)*4-79)) {
      level=int((phase-(550+79)*3)/(900+79));
      phase_level=(phase-(550+79)*3)-level*(900+79);
      if (phase_level<900) {
        if (level%2==1) {//0,2
          pos_x=50+phase_level;
        }
        else {
          pos_x=950-phase_level;
        }
        pos_y=95+76*(level+3);
      }
      else {
        pos_x=(level%2==1?950:50);
        pos_y=95+76*(level+3)+(phase_level-900);
      }
      facing_right=(level%2==1);
    }
    else {
      finished=true;
    }

    // println( phase_level + " " +level);
  }
}


