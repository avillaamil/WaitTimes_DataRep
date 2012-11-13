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

