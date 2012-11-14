import geomerative.*;

ArrayList<State> states = new ArrayList();

RShape flag;
PImage bg;
//PFont font = loadFont("LaGiocondaOSTT-20.vlw");

int activeState = 9999;
boolean clicked;

gif_controller gif_man;


void setup() {
  size(1200, 800);
  
  //textFont(font);
  RG.init(this);
  //RG.setPolygonizer(RG.ADAPTATIVE);
  bg = loadImage("Background.png");
  flag = RG.loadShape("Flag_Vote.svg");
  //loadBackground();
  loadData();

  gif_man=new gif_controller(this, 0.5);//this number is the playback speed for gif
  gif_man.reset_location();
  gif_man.set_speed(0);
  gif_man.set_overall_time(14400);
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
      gif_man.set_overall_time(int(states.get(i).wait*60*60));
      gif_man.set_speed(1); //map(states.get(i).wait, 0, 4, 9, .005)); //1 = 2 minutes;
    } 
    if (!clicked) {
      states.get(i).highlight = false;
      showAll();
    }
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

