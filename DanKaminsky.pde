class GenericController {
    GenericController(){}
    public void RotateKnob(int type, int num, float val){
      LXParameter p = null;
      if(type==0) {
        p = glucose.patternKnobs.get(num);
        if(p!=null) { p.setValue(val); }
      }
      if(type==1) {
        p = glucose.transitionKnobs.get(num);
        if(p!=null) { p.setValue(val); }
      }
      if(type==2) {
        p = glucose.effectKnobs.get(num);
        if(p!=null) { p.setValue(val); }
      }
    }
}

class MidiController extends GenericController {
  MidiController() {
     super();
  }  
}
//PApplet xparent;  // be sure to set



OscP5 listener;
// Setup OSC
//listener = new OscP5(this,7022);

//boolean[] noteState = new boolean[16];
//
//void controllerChangeReceived(rwmidi.Controller cc) {
//  if (debugMode) {
//    println("CC: " + cc.toString());
//  }
//  if(cc.getCC()==1){
//    for(int i=0; i<16; i++){
//      if(noteState[i] && i<8)  { LXParameter p = glucose.patternKnobs.get(i); p.setValue(cc.getValue()/127.0); }
//      else if(noteState[i] && i<12) { LXParameter p = glucose.transitionKnobs.get(i-8); p.setValue(cc.getValue()/127.0); }
//      else if(noteState[i] && i<16) { LXParameter p = glucose.effectKnobs.get(i-12); p.setValue(cc.getValue()/127.0); }
//    }
//  }
//}
//
//void noteOnReceived(Note note) {
//  if (debugMode) {
//    println("Note On: " + note.toString());
//  }
//  int pitch = note.getPitch();
//  if(pitch>=36 && pitch <36+16){
//    noteState[pitch-36]=true;
//  }
//}
//
//void noteOffReceived(Note note) {
//  if (debugMode) {
//    println("Note Off: " + note.toString());
//  }
//  int pitch = note.getPitch();
//  if(pitch>=36 && pitch <36+16){
//    noteState[pitch-36]=false;
//  }
//}
//
//void oscEvent(OscMessage theOscMessage) {
//  println(theOscMessage);
//  LXPattern currentPattern = lx.getPattern();
//  if (currentPattern instanceof OSCPattern) {
//    ((OSCPattern)currentPattern).oscEvent(theOscMessage);
//  }
//}
//


class ObjectMuckerEffect extends SCEffect {
  ObjectMuckerEffect(GLucose glucose) {
    super(glucose);
  }
  public void apply(int[] colors){
    /*for(Strip s: model.strips){
      for(int i=0; i<s.points.size(); i++){
         int index = s.points.get(i).index;
         color c = colors[index];
         colors[index] = lx.hsb((i*22.5), saturation(c), brightness(c));
      }
    }*/
  }
}

class BlendFrames extends SCEffect {
  int fcount;
  int frames[][];
  int maxfbuf;
  int blendfactor;
  BlendFrames(GLucose glucose) {
    super(glucose);
    maxfbuf = 30;
    blendfactor=30;
    fcount=0;
    frames = new int[maxfbuf][];
    for(int i=0; i<maxfbuf; i++){
       frames[i] = new int[model.points.size()];       
    }
  }
  public void apply(int[] colors) {
    if(fcount<maxfbuf){
      for(int i=0; i<colors.length; i++){
        frames[(maxfbuf-1)-fcount][i]=colors[i];
      }
      fcount++;
      return;
    } else {
      for(int i=maxfbuf-1; i>0; i--){
        frames[i] = frames[i-1];
      }
      frames[0] = new int[model.points.size()];
      
      for(int i=0; i<colors.length; i++){
        int r,g,b;
        r=g=b=0;
        for(int j=0; j<blendfactor; j++){          
          if(j==0) { frames[0][i] = colors[i]; }
          r += ((frames[j][i] >> 16) & 0xFF);
          g += ((frames[j][i] >> 8) & 0xFF);
          b += ((frames[j][i] >> 0) & 0xFF);
        }
        r/=blendfactor;
        g/=blendfactor;
        b/=blendfactor;
        colorMode(ARGB);
        colors[i] = (0xFF << 24) | (r << 16) | (g << 8) | b;
        colorMode(HSB);
      }
            
    }
  }
}


import netP5.*;
import oscP5.*;



abstract class OSCPattern extends SCPattern {
  public OSCPattern(GLucose glucose){super(glucose);}
  public abstract void oscEvent(OscMessage msg);
}

class Ball {
  public int lastSeen;
  public float x,y;
  public Ball(){
    x=y=lastSeen=0;  
  }
}

class OSC_Balls extends OSCPattern {
  Ball[] balls;
  public OSC_Balls(GLucose glucose){
    super(glucose);
    balls = new Ball[20];
    for(int i=0; i<balls.length; i++) { balls[i] = new Ball(); }    
  }
  void oscEvent(OscMessage msg){
    String pattern[] = split(msg.addrPattern(), "/");    
    int ballnum = int(pattern[3]);
    balls[ballnum].lastSeen=millis();
    balls[ballnum].x = msg.get(0).floatValue();
    balls[ballnum].y = msg.get(1).floatValue();    
  }
  
  void run(double deltaMs){
    for(LXPoint p: model.points){ colors[p.index]=0; }
    for(int i=1; i<balls.length; i++){
      if(millis() - balls[i].lastSeen < 1000) {
        for(LXPoint p: model.points){
          int x = int(balls[i].x * 255.0);
          int y = int(balls[i].y * 127.0);
          if(p.x < x+4 && p.x > x-4 && p.y < y+4 && p.y > y-4) { colors[p.index] = #FF0000; } 
        }
      }
    }
  }
}

import processing.serial.*;


/*class ScreenScrape extends SCPattern {
  PImage pret;
  ScreenShot ss;
  public ScreenScrape(GLucose glucose) {
    super(glucose);
    System.loadLibrary("ScreenShot");
    pret = new PImage(8, 128, ARGB);
    ss = new ScreenShot();
  }
  void run(double deltaMs){
     int x=(1366/2)+516;
     int y=768-516;
     int w=8;
     int h=128;
     pret.pixels = ss.getScreenShotJNI2(x, y, w, h);
     //for(int i=0; i<px.length; i++){ pret.pixels[i] = px[i]; }
     //println(pret.get(10,10));
     for(LXPoint p: model.points){
       colors[p.index] = pret.get((int(p.x)/8)*8, 128-int(p.y));
     }     
  }
}*/

