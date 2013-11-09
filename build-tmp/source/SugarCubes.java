import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import netP5.*; 
import oscP5.*; 
import processing.serial.*; 
import java.util.LinkedHashMap; 
import toxi.geom.Vec3D; 
import toxi.geom.Matrix4x4; 

import heronarts.lx.font.*; 
import heronarts.lx.transition.*; 
import glucose.transform.*; 
import netP5.*; 
import heronarts.lx.pattern.*; 
import glucose.pattern.*; 
import heronarts.lx.model.*; 
import toxi.geom.mesh2d.*; 
import heronarts.lx.client.*; 
import glucose.*; 
import toxi.util.datatypes.*; 
import toxi.math.waves.*; 
import heronarts.lx.kinet.*; 
import oscP5.*; 
import toxi.geom.*; 
import toxi.util.events.*; 
import heronarts.lx.modulator.*; 
import rwmidi.*; 
import glucose.transition.*; 
import glucose.effect.*; 
import glucose.model.*; 
import toxi.math.conversion.*; 
import heronarts.lx.effect.*; 
import heronarts.lx.control.*; 
import glucose.control.*; 
import toxi.math.noise.*; 
import toxi.util.*; 
import heronarts.lx.*; 
import toxi.math.*; 
import heronarts.lx.audio.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SugarCubes extends PApplet {

/**
 *           +-+-+-+-+-+               +-+-+-+-+-+
 *          /         /|               |\         \
 *         /         / +               + \         \
 *        +-+-+-+-+-+  |   +-+-+-+-+   |  +-+-+-+-+-+
 *        |         |  +  /         \  +  |         |
 *        +   THE   + /  /           \  \ +  CUBES  +
 *        |         |/  +-+-+-+-+-+-+-+  \|         |
 *        +-+-+-+-+-+   |             |   +-+-+-+-+-+
 *                      +             +
 *                      |    SUGAR    |
 *                      +             +
 *                      |             |
 *                      +-+-+-+-+-+-+-+
 *
 * Welcome to the Sugar Cubes! This Processing sketch is a fun place to build
 * animations, effects, and interactions for the platform. Most of the icky
 * code guts are embedded in the GLucose library extension. If you're an
 * artist, you shouldn't need to worry about any of that.
 *
 * Below, you will find definitions of the Patterns, Effects, and Interactions.
 * If you're an artist, create a new tab in the Processing environment with
 * your name. Implement your classes there, and add them to the list below.
 */ 

public LXPattern[] patterns(GLucose glucose) {
  return new LXPattern[] {

    
    // Slee
    new Cathedrals(glucose),
    new MidiMusic(glucose),
    new Pulley(glucose),
    new Swarm(glucose),
    new ViolinWave(glucose),
    new BouncyBalls(glucose),
    new SpaceTime(glucose),
    new ShiftingPlane(glucose),
    new AskewPlanes(glucose),
    new Blinders(glucose),
    new CrossSections(glucose),
    new Psychedelia(glucose),
    
    new Traktor(glucose).setEligible(false),
    new BassPod(glucose).setEligible(false),
    new CubeEQ(glucose).setEligible(false),
    new PianoKeyPattern(glucose).setEligible(false),

    // DanH
    new Noise(glucose),
    new Play (glucose),
    new Pong (glucose),
    new Worms(glucose),

    // Alex G
     new SineSphere(glucose),
//     new CubeCurl(glucose),

    // Shaheen
    new HelixPattern(glucose).setEligible(false),
    
    // Toby
    new GlitchPlasma(glucose),
    new FireEffect(glucose).setEligible(false),
    new StripBounce(glucose),
    new SoundRain(glucose).setEligible(false),
    new SoundSpikes(glucose).setEligible(false),
    new FaceSync(glucose),

    // Jack
    new Swim(glucose),
    new Balance(glucose),

    // Tim
    new TimPlanes(glucose),
    new TimPinwheels(glucose),
    new TimRaindrops(glucose),
    new TimCubes(glucose),
    // new TimTrace(glucose),
    new TimSpheres(glucose),

    // Ben
    // new Sandbox(glucose),
    new TowerParams(glucose),
    new DriveableCrossSections(glucose),
    new GranimTestPattern2(glucose),
    
    //JR
    new Gimbal(glucose),
    
    // Sam
    new JazzRainbow(glucose),
    
    // Arjun
    new TelevisionStatic(glucose),
    new AbstractPainting(glucose),
    new Spirality(glucose),

    // Basic test patterns for reference, not art    
    new TestCubePattern(glucose),
    new TestTowerPattern(glucose),
    new TestProjectionPattern(glucose),
    new TestStripPattern(glucose),
    new TestBassMapping(glucose),
    new TestFloorMapping(glucose),
    new TestSpeakerMapping(glucose),    
    new TestPerformancePattern(glucose),
    // new TestHuePattern(glucose),
    // new TestXPattern(glucose),
    // new TestYPattern(glucose),
    // new TestZPattern(glucose),

  };
}

public LXTransition[] transitions(GLucose glucose) {
  return new LXTransition[] {
    new DissolveTransition(lx),
    new AddTransition(glucose),
    new MultiplyTransition(glucose),
    new OverlayTransition(glucose),
    new DodgeTransition(glucose),
    new SwipeTransition(glucose),
    new FadeTransition(lx),
//  new SubtractTransition(glucose),	// similar to multiply - dh
//  new BurnTransition(glucose),		// similar to multiply - dh
//  new ScreenTransition(glucose), 		// same as add -dh
//  new SoftLightTransition(glucose),	// same as overlay -dh
  };
}

// Handles to globally triggerable effects 
class Effects {
  FlashEffect flash = new FlashEffect(lx);
  BoomEffect boom = new BoomEffect(glucose);
  BlurEffect blur = new BlurEffect(glucose);
  QuantizeEffect quantize = new QuantizeEffect(glucose);
  ColorFuckerEffect colorFucker = new ColorFuckerEffect(glucose);
  
  Effects() {
    blur.enable();
    quantize.enable();
    colorFucker.enable();
  }
}

class SineSphere extends SCPattern {
  private SinLFO yrot = new SinLFO(0, TWO_PI, 2000);
  public final Projection sinespin; 
 float modelrad = sqrt((model.xMax)*(model.xMax) + (model.yMax)*(model.yMax) + (model.zMax)*(model.zMax));
  Pick Sshape; 

  class Sphery {
  float f1xcenter, f1ycenter, f1zcenter, f2xcenter , f2ycenter, f2zcenter; //second three are for an ellipse with two foci
  private  SinLFO vibration; 
  private  SinLFO surface;
  private  SinLFO vx;
  private SinLFO xbounce;
  public SinLFO ybounce;
  private SinLFO zbounce;
  float vibration_min, vibration_max, vperiod;
  public BasicParameter widthparameter;
  public BasicParameter huespread;
  public BasicParameter bouncerate;
  public BasicParameter bounceamp;
  
  
 
  public Sphery(float f1xcenter, float f1ycenter, float f1zcenter, float vibration_min, float vibration_max, float vperiod) 
  {
   this.f1xcenter = f1xcenter;
   this.f1ycenter = f1ycenter;
   this.f1zcenter = f1zcenter;
   this.vibration_min = vibration_min;
   this.vibration_max = vibration_max;
   this.vperiod = vperiod;
   addParameter(bounceamp = new BasicParameter("Amp", .5f));
   addParameter(bouncerate = new BasicParameter("Rate", .5f));  //ybounce.modulateDurationBy(bouncerate);
   addParameter(widthparameter = new BasicParameter("Width", .1f));
   addParameter(huespread = new BasicParameter("Hue", .2f));
   
   addModulator( vx = new SinLFO(-4000, 10000, 100000)).trigger() ;
   //addModulator(xbounce = new SinLFO(model.xMax/3, 2*model.yMax/3, 2000)).trigger(); 
   addModulator(ybounce= new SinLFO(model.yMax/3, 2*model.yMax/3, 240000.f/lx.tempo.bpm())).trigger(); //ybounce.modulateDurationBy
    
   //addModulator(bounceamp); //ybounce.setMagnitude(bouncerate);
   addModulator( vibration = new SinLFO(vibration_min , vibration_max, 240000.f/lx.tempo.bpm())).trigger(); //vibration.modulateDurationBy(vx);
   
  }
 public Sphery(float f1xcenter, float f1ycenter, float f1zcenter, float f2xcenter, float f2ycenter, float f2zcenter, 
  float vibration_min, float vibration_max, float vperiod)  
 {
    this.f1xcenter = f1xcenter;
   this.f1ycenter = f1ycenter;
   this.f1zcenter = f1zcenter;
   this.f2xcenter = f2xcenter;
   this.f2ycenter = f2ycenter;
   this.f2zcenter = f2zcenter;
   this.vibration_min = vibration_min;
   this.vibration_max = vibration_max;
   this.vperiod = vperiod;
   //addModulator(xbounce = new SinLFO(model.xMax/3, 2*model.yMax/3, 2000)).trigger(); 
   addModulator(ybounce).trigger(); 
   addModulator( vibration = new SinLFO(vibration_min , vibration_max, lx.tempo.rampf())).trigger(); //vibration.modulateDurationBy(vx);
   addParameter(widthparameter = new BasicParameter("Width", .1f));
   addParameter(huespread = new BasicParameter("Hue", .2f));
  
}





public float distfromcirclecenter(float px, float py, float pz, float f1x, float f1y, float f1z) 
{
   return dist(px, py, pz, f1x, f1y, f1z);
    }
 //void updatespherey(deltaMs, )
 public int spheryvalue (float px, float py, float pz , float f1xc, float f1yc, float f1zc) 
 {
//switch(sShpape.cur() ) {}  
   return lx.hsb(constrain(huespread.getValuef()*5*px, 0, 360) , dist(px, py, pz, f1xc, f1yc, f1zc) , 
    max(0, 100 - 100*widthparameter.getValuef()*abs(dist(px, py, pz, f1xcenter, ybounce.getValuef(), f1zcenter)
      - vibration.getValuef() ) ) ); 
 }
 public int ellipsevalue(float px, float py, float pz , float f1xc, float f1yc, float f1zc, float f2xc, float f2yc, float f2zc)
  {
//switch(sShpape.cur() ) {}  
   return lx.hsb(huespread.getValuef()*5*px, dist(model.xMax-px, model.yMax-py, model.zMax-pz, f1xc, f1yc, f1zc) , 
    max(0, 100 - 100*widthparameter.getValuef() *
      abs( (dist(px, py, pz, f1xc, ybounce.getValuef(), f1zc) + 
        (dist(px, py , pz, f2xc, ybounce.getValuef(), f2zc) ) )/2  
      - 1.2f*vibration.getValuef() ) ) ) ; 
  }

public void run(double deltaMs) {
      float vv = vibration.getValuef();
      float ybv = ybounce.getValuef();
      
    }
  
}  


final Sphery[] spherys;
  SineSphere(GLucose glucose) 
  {
    super(glucose);
    sinespin = new Projection(model);
    addModulator(yrot).trigger();
    //Sshape = addPick("Shape", , 1);
    spherys = new Sphery[] {
      new Sphery(model.xMax/4, model.yMax/2, model.zMax/2, modelrad/16, modelrad/8, 3000),
      new Sphery(.75f*model.xMax, model.yMax/2, model.zMax/2, modelrad/20, modelrad/10, 2000),
      new Sphery(model.xMax/2, model.yMax/2, model.zMax/2,  modelrad/4, modelrad/8, 2300),
    };
  
  }

// public void onParameterChanged(LXParameter parameter)
// {


//     for (Sphery s : spherys) {
//       if (s == null) continue;
//       double bampv = s.bounceamp.getValue();
//       double brv = s.bouncerate.getValue();
//       double tempobounce = lx.tempo.bpm();
//       if (parameter == s.bounceamp) 
//       {
//         s.ybounce.setRange(bampv*model.yMax/3 , bampv*2*model.yMax/3, brv);
//       }
//       else if ( parameter == s.bouncerate )   
//       {
//         s.ybounce.setDuration(120000./tempobounce);
//       }
//     }
//   }

     public void run( double deltaMs) {
     float t = lx.tempo.rampf();
     float bpm = lx.tempo.bpmf();
     //spherys[1].run(deltaMs);
     //spherys[2].run(deltaMs);
     //spherys[3].run(deltaMs);]
     sinespin.reset(model)

     // Translate so the center of the car is the origin, offset by yPos
      .translateCenter(model, 0, 0, 0)

      // Rotate around the origin (now the center of the car) about an X-vector
      .rotate(yrot.getValuef(), 0, 1, 0);



     for (Point p: model.points){
    int c = 0;
    c = blendColor(c, spherys[1].spheryvalue(p.x, p.y, p.z, .75f*model.xMax, model.yMax/2, model.zMax/2), ADD);
    c = blendColor(c, spherys[0].spheryvalue(p.x, p.y, p.z, model.xMax/4, model.yMax/4, model.zMax/2), ADD);
    c = blendColor(c, spherys[2].spheryvalue(p.x, p.y, p.z, model.xMax/2, model.yMax/2, model.zMax/2),ADD);
     
      colors[p.index] = lx.hsb(lx.h(c), lx.s(c), lx.b(c));

               }
      


  }
  int spheremode = 0;
  
   // void keyPressed() {
   //   spheremode++;
   //     }

  // color CalcPoint(PVector Px) 
  // { 
  //      // if (spheremode == 0 )
              //{
            
             //}
      //   else if (spheremode == 1)
      // {

      //   color c = 0;
      //   c = blendColor(c, spherys[3].ellipsevalue(Px.x, Px.y, Px.z, model.xMax/4, model.yMax/4, model.zMax/4, 3*model.xMax/4, 3*model.yMax/4, 3*model.zMax/4),ADD);
      //   return c; 
      // }
      // return lx.hsb(0,0,0);
      //  // else if(spheremode ==2)
       // { color c = 0;
       //   return lx.hsb(CalcCone( (xyz by = new xyz(0,spherys[2].ybounce.getValuef(),0) ), Px, mid) );

       // }

  
       //   } 
        
  }

class CubeCurl extends SCPattern{
float CH, CW, diag;
ArrayList<PVector> cubeorigin = new ArrayList<PVector>();
ArrayList<PVector> centerlist = new ArrayList<PVector>();
private SinLFO curl = new SinLFO(0, Cube.EDGE_HEIGHT, 5000 ); 

private SinLFO bg = new SinLFO(180, 220, 3000);

CubeCurl(GLucose glucose){
super(glucose);
addModulator(curl).trigger();
addModulator(bg).trigger();
 this.CH = Cube.EDGE_HEIGHT;
 this.CW = Cube.EDGE_WIDTH;
 this.diag = sqrt(CW*CW + CW*CW);


ArrayList<PVector> centerlistrelative = new ArrayList<PVector>();
for (int i = 0; i < model.cubes.size(); i++){
  Cube a = model.cubes.get(i);
  cubeorigin.add(new PVector(a.x, a.y, a.z));
  centerlist.add(centerofcube(i));
  
} 

}
//there is definitely a better way of doing this!
public PVector centerofcube(int i) { 
Cube c = model.cubes.get(i);

println(" cube #:  " + i + " c.x  "  +  c.x  + "  c.y   "  + c.y   + "  c.z  "  +   c.z  );
PVector cubeangle = new PVector(c.rx, c.ry, c.rz);
//println("raw x" + cubeangle.x + "raw y" + cubeangle.y + "raw z" + cubeangle.z);
PVector cubecenter = new PVector(c.x + CW/2, c.y + CH/2, c.z + CW/2);
println("cubecenter unrotated:  "  + cubecenter.x + "  "  +cubecenter.y + "  " +cubecenter.z );
PVector centerrot = new PVector(cos(c.rx)*CW/2 - sin(c.rx)*CW/2, 0, cos(c.rz)*CW/2 + sin(c.rz)*CW/2);
 // nCos*(y-o.y) - nSin*(z-o.z) + o.y
cubecenter = PVector.add(cubecenter, centerrot);
println( "  cubecenter.x  " + cubecenter.x  + " cubecenter.y  " +  cubecenter.y + " cubecenter.z  "   +  cubecenter.z  + "   ");


return cubecenter;
}


public void run(double deltaMs){
for (int i =0; i < model.cubes.size(); i++)  {
Cube c = model.cubes.get(i);
float cfloor = c.y;

// if (i%3 == 0){

// for (Point p : c.points ){
//  // colors[p.index]=color(0,0,0);
//   //float dif = (p.y - c.y);
//   //colors[p.index] = color( bg.getValuef() , 80 , dif < curl.getValuef() ? 80 : 0, ADD);
//    }
//  }

// else if (i%3 == 1) {
  
//  for (Point p: c.points){
//   colors[p.index]=color(0,0,0);
//   float dif = (p.y - c.y);
//   // colors[p.index] = 
//   // color(bg.getValuef(),
//   //   map(curl.getValuef(), 0, Cube.EDGE_HEIGHT, 20, 100), 
//   //   100 - 10*abs(dif - curl.getValuef()), ADD );
//      }
//     }
// else if (i%3 == 2){
 // centerlist[i].sub(cubeorigin(i);
   for (Point p: c.points) {
    PVector pv = new PVector(p.x, p.y, p.z);
     colors[p.index] =color( constrain(4* pv.dist(centerlist.get(i)), 0, 360)  , 50, 100 );
   // colors[p.index] =color(constrain(centerlist[i].x, 0, 360), constrain(centerlist[i].y, 0, 100),  );


    }


  //}

   }
  }
 }

 class HueTestHSB extends SCPattern{
  BasicParameter HueT = new BasicParameter("Hue", .5f);
  BasicParameter SatT = new BasicParameter("Sat", .5f);
  BasicParameter BriT = new BasicParameter("Bright", .5f);

HueTestHSB(GLucose glucose) {
  super(glucose);
  addParameter(HueT);
  addParameter(SatT);
  addParameter(BriT);
}
  public void run(double deltaMs){

  for (Point p : model.points) {
    int c = 0;
    c = blendColor(c, lx.hsb(360*HueT.getValuef(), 100*SatT.getValuef(), 100*BriT.getValuef()), ADD);
    colors[p.index]= c;
  }
   int now= millis();
   if (now % 1000 <= 20)
   {
   println("Hue: " + 360*HueT.getValuef() + "Sat: " + 100*SatT.getValuef() + "Bright:  " + 100*BriT.getValuef());
   }
  }

 }

class TelevisionStatic extends SCPattern {
  BasicParameter brightParameter = new BasicParameter("BRIGHT", 1.0f);
  BasicParameter saturationParameter = new BasicParameter("SAT", 1.0f);
  BasicParameter hueParameter = new BasicParameter("HUE", 1.0f);
  SinLFO direction = new SinLFO(0, 10, 3000);
  
  public TelevisionStatic(GLucose glucose) {
    super(glucose);
    addModulator(direction).trigger();
    addParameter(brightParameter);
    addParameter(saturationParameter);
    addParameter(hueParameter);
  }

 public void run(double deltaMs) {
    boolean d = direction.getValuef() > 5.0f;
    for (Point p : model.points) {             
      colors[p.index] = lx.hsb((lx.getBaseHuef() + random(hueParameter.getValuef() * 360))%360, random(saturationParameter.getValuef() * 100), random(brightParameter.getValuef() * 100));
    }
  }
}

class AbstractPainting extends SCPattern {
  
  PImage img;
  
  SinLFO colorMod = new SinLFO(0, 360, 5000);
  SinLFO brightMod = new SinLFO(0, model.zMax, 2000);
    
  public AbstractPainting(GLucose glucose) {
    super(glucose);
    addModulator(colorMod).trigger();
    addModulator(brightMod).trigger();
    
    img = loadImage("abstract.jpg");
    img.loadPixels();    
  } 
 
  public void run(double deltaMs) {    
    for (Point p : model.points) {
      int c = img.get((int)((p.x / model.xMax) * img.width), img.height - (int)((p.y / model.yMax) * img.height));
      colors[p.index] = lx.hsb(hue(c) + colorMod.getValuef()%360, saturation(c), brightness(c) - ((p.z - brightMod.getValuef())/p.z));
    }    
  }       
}

class Spirality extends SCPattern {
  final BasicParameter r = new BasicParameter("RADIUS", 0.5f);
  
  float angle = 0;
  float rad = 0;
  int direction = 1;
  
  Spirality(GLucose glucose) {
    super(glucose);   
    addParameter(r);
    for (Point p : model.points) {  
      colors[p.index] = lx.hsb(0, 0, 0);
    }
  }
    
  public void run(double deltaMs) {
    angle += deltaMs * 0.007f;
    rad += deltaMs * .025f * direction;
    float x = model.xMax / 2 + cos(angle) * rad;
    float y = model.yMax / 2 + sin(angle) * rad;
    for (Point p : model.points) {    
      float b = dist(x,y,p.x,p.y);
      if (b < 90) {
        colors[p.index] = blendColor(
          colors[p.index],
          lx.hsb(lx.getBaseHuef() + 25, 10, map(b, 0, 10, 100, 0)),
          ADD);        
        } else {
      colors[p.index] = blendColor(
        colors[p.index],
        lx.hsb(25, 10, map(b, 0, 10, 0, 15)),
        SUBTRACT); 
      }
    }
    if (rad > model.xMax / 2 || rad <= .001f) {
      direction *= -1;
    }
  }
}




/**
 * This is a reusable equalizer class that lets you get averaged
 * bands with dB scaling and smoothing.
 */
public static class GraphicEQ {
  
  private final LX lx;
  
  public final BasicParameter level = new BasicParameter("LVL", 0.5f);
  public final BasicParameter range = new BasicParameter("RNGE", 0.5f);
  public final BasicParameter slope = new BasicParameter("SLOP", 0.5f);
  public final BasicParameter attack = new BasicParameter("ATK", 0.5f);
  public final BasicParameter release = new BasicParameter("REL", 0.5f);    

  private final FFT fft;
  private final int numBands;

  private final LinearEnvelope[] bandVals;
  
  public final static int DEFAULT_NUM_BANDS = 16;

  public GraphicEQ(LX lx) {
    this(lx, DEFAULT_NUM_BANDS);
  }
  
  /**
   * Note that the number of bands is a suggestion. Due to the FFT implementation
   * the actual number may be slightly different.
   */
  public GraphicEQ(LX lx, int num) {
    this.lx = lx;
    fft = new FFT(lx.audioInput().bufferSize(), lx.audioInput().sampleRate());
    fft.window(FFT.HAMMING);
    fft.logAverages(50, num/8);
    numBands = this.fft.avgSize();
    bandVals = new LinearEnvelope[numBands];
    for (int i = 0; i < bandVals.length; ++i) {
      (bandVals[i] = new LinearEnvelope(0, 0, 500)).trigger();
    }
  }
  
  static final float logTen = log(10);
  public static float log10(float val) {
    return log(val) / logTen;
  }
  
  public float getLevel(int band) {
    return bandVals[band].getValuef();
  }
  
  public float getAverageLevel(int minBand, int numBands) {
    float avg = 0;
    for (int i = minBand; i < minBand + numBands; ++i) {
      avg += bandVals[i].getValuef();
    }
    avg /= numBands;
    return avg;
  }
  
  public void run(double deltaMs) {
    fft.forward(lx.audioInput().mix);
    float zeroDBReference = pow(10, 100*(1-level.getValuef())/20.f);
    float decibelRange = 12 + range.getValuef() * 60;
    float decibelSlope = slope.getValuef() * 60.f / numBands;
    for (int i = 0; i < numBands; ++i) {
      float raw = fft.getAvg(i);
      float decibels = 20*log10(raw / zeroDBReference);
      float positiveDecibels = decibels + decibelRange;
      positiveDecibels += i*decibelSlope;
      float value = constrain(positiveDecibels / decibelRange, 0, 1);
      
      if (value > bandVals[i].getValuef()) {
        bandVals[i].setRangeFromHereTo(value, attack.getValuef() * 20).trigger();
      }
    }
    for (LinearEnvelope band : bandVals) {
      band.run(deltaMs);
      if (!band.isRunning() && band.getValuef() > 0) {
        band.setRangeFromHereTo(0, release.getValuef() * 1600).trigger();
      }
    }    
  }
}


class TowerParams extends SCPattern
{
	BasicParameter hueoff = new BasicParameter("Hueoff", 0.0f);
	BasicParameter hueSpan = new BasicParameter("HueRange", 0.0f);
	BasicParameter t1 = new BasicParameter("T1", 0.0f);
	BasicParameter t2 = new BasicParameter("T2", 0.0f);
	BasicParameter t3 = new BasicParameter("T3", 0.0f);
	BasicParameter t4 = new BasicParameter("T4", 0.0f);
	BasicParameter t5 = new BasicParameter("T5", 0.0f);
	BasicParameter t6 = new BasicParameter("T6", 0.0f);
	BasicParameter t7 = new BasicParameter("T7", 0.0f);
	BasicParameter t8 = new BasicParameter("T8", 0.0f);
	BasicParameter t9 = new BasicParameter("T9", 0.0f);
	BasicParameter t10 = new BasicParameter("T10", 0.0f);
	BasicParameter t11 = new BasicParameter("T11", 0.0f);
	BasicParameter t12 = new BasicParameter("T12", 0.0f);
	BasicParameter t13 = new BasicParameter("T13", 0.0f);
	BasicParameter t14 = new BasicParameter("T14", 0.0f);
	BasicParameter t15 = new BasicParameter("T15", 0.0f);
	BasicParameter t16 = new BasicParameter("T16", 0.0f);

	ArrayList<BasicParameter> towerParams;
	int towerSize;
	int colorSpan;
	TowerParams(GLucose glucose) {
		super(glucose);

		towerParams = new ArrayList<BasicParameter>();
		addParameter(hueoff);
		addParameter(hueSpan);
		towerParams.add(t1);
		towerParams.add(t2);
		towerParams.add(t3);
		towerParams.add(t4);
		towerParams.add(t5);
		towerParams.add(t6);
		towerParams.add(t7);
		towerParams.add(t8);
		towerParams.add(t9);
		towerParams.add(t10);
		towerParams.add(t11);
		towerParams.add(t12);
		towerParams.add(t13);
		towerParams.add(t14);
		towerParams.add(t15);
		towerParams.add(t16);
		for(BasicParameter p : towerParams)
		{
			addParameter(p);
		}
		towerSize = model.towers.size();
		colorSpan = 255 / towerSize;
	}

	public void run(double deltaMs)
	{
		clearALL();
		Tower t;
		for(int i=0; i<towerSize ;i++)
		{	
			t= model.towers.get(i);
			for(Point p : t.points)
			{
				if(p.y<towerParams.get(i).getValuef()*200)
				{
					colors[p.index]=lx.hsb(255 * hueoff.getValuef()+colorSpan * hueSpan.getValuef() * i, 255, 255);
				}
			}
		}

	}

	public void clearALL()
	{
		for(Point p : model.points)
		{
			colors[p.index] = 0;
		}
	}

}
class Sandbox extends SCPattern
{
	int c=0;
	int prevC=0;
	int huerange=255;
	int pointrange= model.points.size();
	int striprange= model.strips.size();
	int facerange= model.faces.size();
	int cuberange = model.cubes.size();
	int towerrange = model.towers.size();
	int counter=0;

	Sandbox(GLucose glucose) {
		super(glucose);
		println("points "+pointrange);
		println("strips "+striprange);
		println("faces "+facerange);
		println("cubes "+cuberange);
		println("towers "+towerrange);
	}
	
	public void run(double deltaMs) {
		

		if(counter % 10 ==0)
		{
			doDraw(c,0);
			c = (c + 1) % towerrange;
			long col = lx.hsb(Math.round(Math.random()*255),255,255) ;
			doDraw(c,col);
		}
		counter++;

	}

	public void doDraw(int c,long col)
	{
			Tower t= model.towers.get((int) c);
			for(Point p : t.points)
			{
				colors[p.index] = (int) col;
			}
	}
};

class GranimTestPattern extends GranimPattern
{
	GranimTestPattern(GLucose glucose)
	{
		super(glucose);
		addGraphic("myReds",new RedsGraphic(100));
		int[] dots = {0,128,0,128,0,128,0,128,0,128,0,128};
		addGraphic("myOtherColors",new ColorDotsGraphic(dots));

		getGraphicByName("myOtherColors").position=100;
	}
	int counter=0;
	public void run(double deltaMs) 
	{
		clearALL();
		super.run(deltaMs);
		
		if(counter % 3 ==0)
		{
			Graphic reds = getGraphicByName("myReds");
			Graphic others = getGraphicByName("myOtherColors");
			reds.position = reds.position + 1 % 19000;
			others.position = others.position + 10 % 19000;
		}
	}
	public void clearALL()
	{
		for(int i = 0; i < colors.length; i++)
		{
			colors[i] = 0;
		}
	}


}

class GranimTestPattern2 extends GranimPattern
{
	GranimTestPattern2(GLucose glucose)
	{
		super(glucose);
		/*for(int i = 0;i < 100; i++)
		{
			Graphic g = addGraphic("myReds_"+i,new RedsGraphic(Math.round(Math.random() * 100)));

		}*/
		Graphic g = addGraphic("myRandoms",new RandomsGranim(50));
		g.position = 200;
		
	}
	int counter=0;
	float count=0;
	public void run(double deltaMs) 
	{
		clearALL();
		super.run(deltaMs);
		Graphic randomsGraphic = getGraphicByName("myRandoms");
		randomsGraphic.position = Math.round(sin(count)*1000)+5000;
		count+= 0.005f;
	}
	public void clearALL()
	{
		for(Point p : model.points)
		{
			colors[p.index] = 0;
		}
	}


};

class DriveableCrossSections extends CrossSections
{
	BasicParameter xd; 
	BasicParameter yd;
	BasicParameter zd;
	BasicParameter mode; 

	DriveableCrossSections(GLucose glucose) {
		super(glucose);	
	}

	public void addParams()
	{
		mode = new BasicParameter("Mode", 0.0f);
		xd = new BasicParameter("XD", 0.0f);
		yd = new BasicParameter("YD", 0.0f);
		zd = new BasicParameter("ZD", 0.0f);
		addParameter(mode);
		addParameter(xd);
	    addParameter(yd);
	    addParameter(zd);

	   super.addParams();
	}

	public void onParameterChanged(LXParameter p) {
			if(p == mode)
			{
				if(interactive())
				{
					copyValuesToKnobs();
				}else{
					copyKnobsToValues();
				}
			}
	}

	public void copyValuesToKnobs()
	{
		xd.setValue(x.getValue()/200);
		yd.setValue(y.getValue()/115);
		zd.setValue(z.getValue()/100);
	}

	public void copyKnobsToValues()
	{
		x.setValue(xd.getValue()*200);
		y.setValue(yd.getValue()*115);
		z.setValue(zd.getValue()*100);
	}

	public boolean interactive()
	{
		return Math.round(mode.getValuef())>0.5f;
	}

	public void updateXYZVals()
  	{
  		if(interactive())
  		{
		  	xv = xd.getValuef()*200;
		    yv = yd.getValuef()*115;
		    zv = zd.getValuef()*100;
		}else{
			super.updateXYZVals();
			copyValuesToKnobs();
		}
  	}

}
//----------------------------------------------------------------------------------------------------------------------------------
public class Pong extends DPat {
	SinLFO x,y,z,dx,dy,dz;
	float cRad;	BasicParameter pSize;
	Pick 	pChoose;
	PVector	v = new PVector(), vMir =  new PVector();

	Pong(GLucose glucose) {
		super(glucose);
		cRad = mMax.x/10;
		addModulator(dx = new SinLFO(6000,  500, 30000	)).trigger();
		addModulator(dy = new SinLFO(3000,  500, 22472	)).trigger();
		addModulator(dz = new SinLFO(1000,  500, 18420	)).trigger();
		addModulator(x  = new SinLFO(cRad, mMax.x - cRad, 0)).trigger();	x.modulateDurationBy(dx);
		addModulator(y  = new SinLFO(cRad, mMax.y - cRad, 0)).trigger();	y.modulateDurationBy(dy);
		addModulator(z  = new SinLFO(cRad, mMax.z - cRad, 0)).trigger();	z.modulateDurationBy(dz);
	    pSize	= addParam	("Size"			, 0.4f	);
	    pChoose = addPick	("Animiation"	, 2, 2, new String[] {"Pong", "Ball", "Cone"}	);
	}

	public void  	StartRun(double deltaMs) 	{ cRad = mMax.x*val(pSize)/6; }
	public int	CalcPoint(PVector p) 	  	{
		v.set(x.getValuef(), y.getValuef(), z.getValuef());
		v.z=0;p.z=0;// ignore z dimension
		switch(pChoose.Cur()) {
		case 0: vMir.set(mMax); vMir.sub(p);
				return lx.hsb(lxh(),100,c1c(1 - min(v.dist(p), v.dist(vMir))*.5f/cRad));		// balls
		case 1: return lx.hsb(lxh(),100,c1c(1 - v.dist(p)*.5f/cRad));							// ball
		case 2: vMir.set(mMax.x/2,0,mMax.z/2);
				return lx.hsb(lxh(),100,c1c(1 - calcCone(p,v,vMir) * max(.02f,.45f-val(pSize))));  	// spot
		}
		return lx.hsb(0,0,0);
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class NDat {
	float 	xz, yz, zz, hue, speed, angle, den;
	float	xoff,yoff,zoff;
	float	sinAngle, cosAngle;
	boolean isActive;
	NDat 		  () { isActive=false; }
	public boolean	Active() { return isActive; }
	public void	set 	(float _hue, float _xz, float _yz, float _zz, float _den, float _speed, float _angle) {
		isActive = true;
		hue=_hue; xz=_xz; yz=_yz; zz =_zz; den=_den; speed=_speed; angle=_angle;
		xoff = random(100e3f); yoff = random(100e3f); zoff = random(100e3f);
	}
}

public class Noise extends DPat
{
	int				CurAnim, iSymm;
	int 			XSym=1,YSym=2,RadSym=3;
	float 			zTime , zTheta=0, zSin, zCos, rtime, ttime;
	BasicParameter	pSpeed , pDensity, pSharp;
	Pick 			pChoose, pSymm;
	int				_ND = 4;
	NDat			N[] = new NDat[_ND];

	Noise(GLucose glucose) {
		super(glucose);
		pSpeed		= addParam("Fast"	, .55f);
		pDensity	= addParam("Dens" 	 , .5f);
		pSharp		= addParam("Shrp" 	 ,  0);
		pSymm 		= addPick("Symmetry" , 0, 3, new String[] {"None", "X", "Y", "Radial"}	);
		pChoose 	= addPick("Animation", 6, 7, new String[] {"Drip", "Cloud", "Rain", "Fire", "Machine", "Spark","VWave", "Wave"}	);
		for (int i=0; i<_ND; i++) N[i] = new NDat();
	}

	public void onActive() { zTime = random(500); zTheta=0; rtime = 0; ttime = 0; }

	public void StartRun(double deltaMs) {
		zTime 	+= deltaMs*(val(pSpeed)-.5f)*.002f	;
		zTheta	+= deltaMs*(spin()-.5f)*.01f	;
		rtime	+= deltaMs;
		iSymm	 = pSymm.Cur();
		zSin	= sin(zTheta);
		zCos	= cos(zTheta);

		if (pChoose.Cur() != CurAnim) {
			CurAnim = pChoose.Cur(); ttime = rtime;
			pSpin		.reset();	zTheta 		= 0;
			pDensity	.reset();	pSpeed		.reset();
			for (int i=0; i<_ND; i++) { N[i].isActive = false; }
			
			switch(CurAnim) {
			//                          hue xz yz zz den mph angle
			case 0: N[0].set(0  ,75 ,75 ,150,45 ,3  ,0  ); pSharp.setValue(1 ); break; 	// drip
			case 1: N[0].set(0  ,100,100,200,45 ,3  ,180); pSharp.setValue(0 ); break;	// clouds
			case 2: N[0].set(0  ,2  ,400,2  ,20 ,3  ,0  ); pSharp.setValue(.5f); break;	// rain
			case 3: N[0].set(40 ,100,100,200,10 ,1  ,180); 
					N[1].set(0  ,100,100,200,10 ,5  ,180); pSharp.setValue(0 ); break;	// fire 1
			case 4: N[0].set(0  ,40 ,40 ,40 ,15 ,2.5f,180);
					N[1].set(20 ,40 ,40 ,40 ,15 ,4  ,0  );
					N[2].set(40 ,40 ,40 ,40 ,15 ,2  ,90 );
					N[3].set(60 ,40 ,40 ,40 ,15 ,3  ,-90); pSharp.setValue(.5f); break; // machine
			case 5: N[0].set(0  ,400,100,2  ,15 ,3  ,90 );
					N[1].set(20 ,400,100,2  ,15 ,2.5f,0  );
					N[2].set(40 ,100,100,2  ,15 ,2  ,180);
					N[3].set(60 ,100,100,2  ,15 ,1.5f,270); pSharp.setValue(.5f); break; // spark
			}
		}
		
		for (int i=0; i<_ND; i++) if (N[i].Active()) {
			N[i].sinAngle = sin(radians(N[i].angle));
			N[i].cosAngle = cos(radians(N[i].angle));
		}
	}

	public int CalcPoint(PVector p) {
		int c = 0;
		rotateZ(p, mCtr, zSin, zCos);

		if (CurAnim == 6 || CurAnim == 7) {
			setNorm(p);
			return lx.hsb(lxh(),100, 100 * (
							constrain(1-50*(1-val(pDensity))*abs(p.y-sin(zTime*10  + p.x*(300))*.5f - .5f),0,1) + 
			(CurAnim == 7 ? constrain(1-50*(1-val(pDensity))*abs(p.x-sin(zTime*10  + p.y*(300))*.5f - .5f),0,1) : 0))
			);
		}			

		if (iSymm == XSym && p.x > mMax.x/2) p.x = mMax.x-p.x;
		if (iSymm == YSym && p.y > mMax.y/2) p.y = mMax.y-p.y;

		for (int i=0;i<_ND; i++) if (N[i].Active()) {
			NDat  n     = N[i];
			float zx    = zTime * n.speed * n.sinAngle,
				  zy    = zTime * n.speed * n.cosAngle;

			float b     = (iSymm==RadSym ? noise(zTime*n.speed+n.xoff-p.dist(mCtr)/n.xz)
										 : noise(p.x/n.xz+zx+n.xoff,p.y/n.yz+zy+n.yoff,p.z/n.zz+n.zoff))
							*1.8f;

			b += 	n.den/100 -.4f + val(pDensity) -1;
			c = 	blendColor(c,lx.hsb(lxh()+n.hue,100,c1c(b)),ADD);
		}
		return c;
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class Play extends DPat
{
	public class rAngle {
		float 	prvA, dstA, c;
		float 	prvR, dstR, r;		
		float 	_cos, _sin, x, y;
		public float 	fixAngle	(float a, float b) { return a<b ?
										(abs(a-b) > abs(a+2*PI-b) ? a : a+2*PI) :
										(abs(a-b) > abs(a-2*PI-b) ? a : a-2*PI)	; }
		public float	getX(float r)	{	return mCtr.x + _cos*r; }
		public float	getY(float r)	{	return mCtr.y + _sin*r; }
		public void	move() 			{	c 		= interp(t,prvA,dstA); 
									r 		= interp(t,prvR,dstR);
									_cos 	= cos(c); 	_sin 	= sin(c);
	                               x 		= getX(r); 	y 		= getY(r);		}		
		public void	set() 			{	prvA 	= dstA; 	dstA 	= random(2*PI); 	prvA = fixAngle(prvA, dstA);
									prvR 	= dstR; 	dstR 	= random(mCtr.y);									}
	}

	BasicParameter 	pAmp, pRadius, pBounce;
	Pick			pTimePattern, pTempoMult, pShape;

	ArrayList<rWave> waves = new ArrayList<rWave>(10);

	int		nBeats	=  	0;
	float 	t,amp,rad,bnc,zTheta=0;

	rAngle	a1 		= new rAngle(), a2 			= new rAngle(),
			a3 		= new rAngle(), a4 			= new rAngle();
	PVector	cPrev 	= new PVector(), cRand		= new PVector(),
			cMid 	= new PVector(), V 			= new PVector(),
			theta 	= new PVector(), tSin		= new PVector(),
			tCos	= new PVector(), cMidNorm 	= new PVector(),
			Pn		= new PVector();
	float	LastBeat=3, LastMeasure=3;
	int		curRandTempo = 1, curRandTPat = 1;

	Play(GLucose glucose) {
		super(glucose);
	    pRadius		= addParam("Rad" 	, .1f  	);
		pBounce		= addParam("Bnc"	, .2f	);
	    pAmp  		= addParam("Amp" 	, .2f	);
		pTempoMult 	= addPick ("TMult"	, 5 , 5		, new String[] {"1x", "2x", "4x", "8x", "16x", "Rand"	}	);
		pTimePattern= addPick ("TPat"	, 7 , 7		, new String[] {"Bounce", "Sin", "Roll", "Quant", "Accel", "Deccel", "Slide", "Rand"}	);
		pShape	 	= addPick ("Shape"	, 7 , 15	, new String[] {"Line", "Tap", "V", "RandV",
																	"Pyramid", "Wings", "W2", "Clock",
																	"Triangle", "Quad", "Sphere", "Cone",
																	"Noise", "Wave", "?", "?"} 						);
	}

	public class rWave {
		float v0, a0, x0, t,damp,a;
		boolean bDone=false;
		final float len=8;
		rWave(float _x0, float _a0, float _v0, float _damp) { x0=_x0*len; a0=_a0; v0=_v0; t=0; damp = _damp; }
		public void move(double deltaMs) {
			t += deltaMs*.001f;
			if (t>4) bDone=true;
		}
		public float val(float _x) {
			_x*=len;
			float dist = t*v0 - abs(_x-x0);
			if (dist<0) { a=1; return 0; }
			a  = a0*exp(-dist*damp) * exp(-abs(_x-x0)/(.2f*len)); // * max(0,1-t/dur)
			return	-a*sin(dist);
		}
	}

	public void onReset()  { zTheta=0; super.onReset(); }
	public void onActive() { 
		zTheta=0; 
		while (lx.tempo.bpm() > 40) lx.tempo.setBpm(lx.tempo.bpm()/2);
	}

	int KeyPressed = -1;
	public boolean noteOn(Note note) {
		int row = note.getPitch(), col = note.getChannel();
		if (row == 57) {KeyPressed = col; return true; }
		return super.noteOn(note);
	}

	public void StartRun(double deltaMs) {
		t 	= lx.tempo.rampf();
		amp = pAmp		.getValuef();
		rad	= pRadius	.getValuef();
		bnc	= pBounce	.getValuef();		
		zTheta	+= deltaMs*(val(pSpin)-.5f)*.01f;

		theta	.set(val(pRotX)*PI*2, val(pRotY)*PI*2, val(pRotZ)*PI*2 + zTheta);
		tSin	.set(sin(theta.x), sin(theta.y), sin(theta.z));
		tCos	.set(cos(theta.x), cos(theta.y), cos(theta.z));

		if (t<LastMeasure) {
			if (random(3) < 1) { curRandTempo = PApplet.parseInt(random(4)); if (curRandTempo == 3) curRandTempo = PApplet.parseInt(random(4));	}
			if (random(3) < 1) { curRandTPat  = pShape.Cur() > 6 ? 2+PApplet.parseInt(random(5)) : PApplet.parseInt(random(7)); 					}
		} LastMeasure = t;
			
		int nTempo = pTempoMult	 .Cur(); if (nTempo == 5) nTempo = curRandTempo;
		int nTPat  = pTimePattern.Cur(); if (nTPat  == 7) nTPat  = curRandTPat ;

		switch (nTempo) {
			case 0: 	t = t;								break;
			case 1: 	t = (t*2.f )%1.f;						break;
			case 2: 	t = (t*4.f )%1.f;						break;
			case 3: 	t = (t*8.f )%1.f;						break;
			case 4: 	t = (t*16.f)%1.f;						break;
		}

		int i=0; while (i< waves.size()) {
			rWave w = waves.get(i);
			w.move(deltaMs); if (w.bDone) waves.remove(i); else i++;
		}

		if ((t<LastBeat && pShape.Cur()!=14) || KeyPressed>-1) {
			waves.add(new rWave(
						KeyPressed>-1 ? map(KeyPressed,0,7,0,1) : random(1),		// location
						bnc*10,			// bounciness
						7,				// velocity
						2*(1-amp)));	// dampiness
			KeyPressed=-1;
			if (waves.size() > 5) waves.remove(0);
		}
		
		if (t<LastBeat) {
			cPrev.set(cRand); setRand(cRand);
			a1.set(); a2.set(); a3.set(); a4.set();
		} LastBeat = t;

		switch (nTPat) {
			case 0: 	t = sin(PI*t);							break;	// bounce
			case 1: 	t = norm(sin(2*PI*(t+PI/2)),-1,1);		break;	// sin
			case 2: 	t = t; 									break;	// roll
			case 3: 	t = constrain(PApplet.parseInt(t*8)/7.f,0,1);			break;	// quant
			case 4: 	t = t*t*t;								break;	// accel
			case 5: 	t = sin(PI*t*.5f);						break;	// deccel
			case 6: 	t = .5f*(1-cos(PI*t));					break;	// slide
		}
		
		cMid.set		(cPrev);	interpolate(t,cMid,cRand);
		cMidNorm.set	(cMid);		setNorm(cMidNorm);
		a1.move(); a2.move(); a3.move(); a4.move();
	}

	public int CalcPoint(PVector Px) {
		if (theta.x != 0) rotateX(Px, mCtr, tSin.x, tCos.x);
		if (theta.y != 0) rotateY(Px, mCtr, tSin.y, tCos.y);
		if (theta.z != 0) rotateZ(Px, mCtr, tSin.z, tCos.z);
		
		Pn.set(Px); setNorm(Pn);

		float mp	= min(Pn.x, Pn.z);
		float yt 	= map(t,0,1,.5f-bnc/2,.5f+bnc/2);
		float r,d;

		switch (pShape.Cur()) {
		case 0:		V.set(Pn.x, yt							 	, Pn.z); 							break;	// bouncing line
		case 1:		V.set(Pn.x, map(cos(PI*t * Pn.x),-1,1,0,1)  , Pn.z); 							break;	// top tap
		case 2:		V.set(Pn.x, bnc*map(Pn.x<.5f?Pn.x:1-Pn.x,0,.5f ,0,t-.5f)+.5f, Pn.z);				break;	// V shape
		case 3:		V.set(Pn.x, Pn.x < cMidNorm.x ? map(Pn.x,0,cMidNorm.x, .5f,yt) :
												map(Pn.x,cMidNorm.x,1, yt,.5f), Pn.z);	  			break;	//  Random V shape

		case 4:		V.set(Pn.x,	.5f*(Pn.x < cMidNorm.x ? 	map(Pn.x,0,cMidNorm.x, .5f,yt) :
														map(Pn.x,cMidNorm.x,1, yt,.5f)) +
							.5f*(Pn.z < cMidNorm.z ? 	map(Pn.z,0,cMidNorm.z, .5f,yt) :
														map(Pn.z,cMidNorm.z,1, yt,.5f)), Pn.z); 		break;	//  Random Pyramid shape
													
		case 5:		V.set(Pn.x, bnc*map((Pn.x-.5f)*(Pn.x-.5f),0,.25f,0,t-.5f)+.5f, Pn.z);				break;	// wings
		case 6:		V.set(Pn.x, bnc*map((mp  -.5f)*(mp  -.5f),0,.25f,0,t-.5f)+.5f, Pn.z);				break;	// wings

		case 7:		d = min(
						distToSeg(Px.x, Px.y, a1.getX(70),a1.getY(70), mCtr.x, mCtr.y),
						distToSeg(Px.x, Px.y, a2.getX(40),a2.getY(40), mCtr.x, mCtr.y));
					d = constrain(30*(rad*40-d),0,100);
					return lx.hsb(lxh(),100, d); // clock

		case 8:		r = amp*200 * map(bnc,0,1,1,sin(PI*t));
					d = min(
						distToSeg(Px.x, Px.y, a1.getX(r),a1.getY(r), a2.getX(r),a2.getY(r)),
						distToSeg(Px.x, Px.y, a2.getX(r),a2.getY(r), a3.getX(r),a3.getY(r)),
						distToSeg(Px.x, Px.y, a3.getX(r),a3.getY(r), a1.getX(r),a1.getY(r))				// triangle
						);
					d = constrain(30*(rad*40-d),0,100);
					return lx.hsb(lxh(),100, d); // clock

		case 9:		r = amp*200 * map(bnc,0,1,1,sin(PI*t));
					d = min(
						distToSeg(Px.x, Px.y, a1.getX(r),a1.getY(r), a2.getX(r),a2.getY(r)),
						distToSeg(Px.x, Px.y, a2.getX(r),a2.getY(r), a3.getX(r),a3.getY(r)),
						distToSeg(Px.x, Px.y, a3.getX(r),a3.getY(r), a4.getX(r),a4.getY(r)),
						distToSeg(Px.x, Px.y, a4.getX(r),a4.getY(r), a1.getX(r),a1.getY(r))				// quad
					);
					d = constrain(30*(rad*40-d),0,100);
					return lx.hsb(lxh(),100, d); // clock

		case 10:
					r = map(bnc,0,1,a1.r,amp*200*sin(PI*t));
					return lx.hsb(lxh(),100,c1c(.9f+2*rad - dist(Px.x,Px.y,a1.getX(r),a1.getY(r))*.03f) );		// sphere

		case 11:
					Px.z=mCtr.z; cMid.z=mCtr.z;
					return lx.hsb(lxh(),100,c1c(1 - calcCone(Px,cMid,mCtr) * 0.02f > .5f?1:0));  				// cone

		case 12:	return lx.hsb(lxh() + noise(Pn.x,Pn.y,Pn.z + (NoiseMove+50000)/1000.f)*200,
						85,c1c(Pn.y < noise(Pn.x + NoiseMove/2000.f,Pn.z)*(1+amp)-amp/2.f-.1f ? 1 : 0));	// noise

		case 13:	
		case 14:	float y=0; for (rWave w : waves) y += .5f*w.val(Pn.x);	// wave
					V.set(Pn.x, .7f+y, Pn.z);
					break;

		default:	return lx.hsb(0,0,0);
		}

		return lx.hsb(lxh(), 100, c1c(1 - V.dist(Pn)/rad));
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
boolean dDebug = false;
class dCursor {
	dVertex vCur, vNext, vDest;
	float 	destSpeed;
	int 	posStop, pos,posNext;	// 0 - 65535
	int 	clr;

	dCursor() {}

	public boolean isDone	() 									{ return pos==posStop; 										 }
	public boolean atDest  ()									{ return vCur.s==vDest.s || 
																 xyDist(vCur.getPoint(0), vDest.getPoint(0)) < 12 || 
																 xyDist(vCur.getPoint(0), vDest.getPoint(15))< 12;}
	public void 	setCur 	(dVertex _v, int _p) 				{ p2=null; vCur=_v; pos=_p; pickNext(); 					 }
	public void 	setCur	(dPixel  _p) 						{ setCur(_p.v, _p.pos); 									 }
	public void	setNext (dVertex _v, int _p, int _s)		{ vNext = _v; posNext = _p<<12; posStop = _s<<12;		 	 }
	public void	setDest (dVertex _v, float _speed)			{ vDest = _v; destSpeed = _speed;							 }
	public void	onDone	()									{ setCur(vNext, posNext); pickNext(); 						 }

	float  	minDist;
	int 	nTurns;
	boolean bRandEval;

	public void 	evaluate(dVertex v, int p, int s) {
		if (v == null) return; ++nTurns;
		if (bRandEval) {
			if (random(nTurns) < 1) setNext(v,p,s); return; }
		else {
			float d = xyDist(v.getPoint(15), vDest.getPoint(0));
			if (d <  minDist)					{ minDist=d; setNext(v,p,s); }
			if (d == minDist && random(2)<1)  	{ minDist=d; setNext(v,p,s); }
		}
	}

	public void 	evalTurn(dTurn t) { 
		if (t == null || t.pos0<<12 <= pos) return; 
		evaluate(t.v 	,    t.pos1, t.pos0);
		evaluate(t.v.opp, 16-t.pos1, t.pos0);
	}

	public void 	pickNext() 	{
		bRandEval = random(.05f+destSpeed) < .05f; minDist=500; nTurns=0;
		evaluate(vCur.c0, 0, 16);  	evaluate(vCur.c1, 0, 16);
		evaluate(vCur.c2, 0, 16);  	evaluate(vCur.c3, 0, 16);
		evalTurn(vCur.t0);			evalTurn(vCur.t1);
		evalTurn(vCur.t2);			evalTurn(vCur.t3);
	}

	Point 	p1, p2; int i2;

	public int draw(int nAmount, SCPattern pat) {
		int nFrom	= (pos    ) >> 12;
		int	nMv 	= min(nAmount, posStop-pos);
		int	nTo 	= min(15,(pos+nMv) >> 12);
		dVertex v 	= vCur;

		if (dDebug) { 	p1 = v.getPoint(nFrom); float d = (p2 == null ? 0 : pointDist(p1,p2)); if (d>5) { println("too wide! quitting: " + d); exit(); }}
								for (int i = nFrom; i <= nTo; i++) { pat.getColors()[v.ci 	   + v.dir*i 	 ] = clr; }
		if (v.same != null)		for (int i = nFrom; i <= nTo; i++) { pat.getColors()[v.same.ci + v.same.dir*i] = clr; }

		if (dDebug) { 	p2 = v.getPoint(nTo); i2 = nTo; }

		pos += nMv; return nAmount - nMv;
			}	
}

//----------------------------------------------------------------------------------------------------------------------------------
class Worms extends SCPattern {
	float 	StripsPerSec 	= 10;
	float	TrailTime		= 3000;
	int 	numCursors		= 50;
	ArrayList<dCursor> cur  = new ArrayList<dCursor>(30);

	private GraphicEQ eq = null;

	private BasicParameter pBeat	  = new BasicParameter("BEAT",  0);
	private BasicParameter pSpeed     = new BasicParameter("FAST", .2f);
	private BasicParameter pBlur      = new BasicParameter("BLUR", .3f);
	private BasicParameter pWorms     = new BasicParameter("WRMS", .3f);
	private BasicParameter pConfusion = new BasicParameter("CONF", .1f);
	private BasicParameter pEQ  	  = new BasicParameter("EQ"  ,  0);
	private BasicParameter pSpawn  	  = new BasicParameter("DIR" ,  0);
	private BasicParameter pColor  	  = new BasicParameter("CLR" ,  .1f);

	float 	zMidLat = 82.f;
	float 	nConfusion;
	private final Click moveChase = new Click(1000);

	PVector	middle;
	public int 	AnimNum() { return floor(pSpawn.getValuef()*(4-.01f)); 	}
	public float   randX() { return random(model.xMax-model.xMin)+model.xMin; }
	public float   randY() { return random(model.yMax-model.yMin)+model.yMin; }
	public PVector	randEdge() { 
		return random(2) < 1 ? 	new PVector(random(2)<1 ? model.xMin:model.xMax, randY(), zMidLat) 	:
				 				new PVector(randX(), random(2)<1 ? model.yMin:model.yMax, zMidLat)	;
	}

	Worms(GLucose glucose) {
		super(glucose); 
	    addModulator(moveChase).start();
	    addParameter(pBeat);    addParameter(pSpeed);
	    addParameter(pBlur);    addParameter(pWorms);
	    addParameter(pEQ);	    addParameter(pConfusion);
		addParameter(pSpawn);	addParameter(pColor);

	    middle = new PVector(1.5f*model.cx, 1.5f*model.cy, 71);
		if (lattice == null) lattice = new dLattice();
		for (int i=0; i<numCursors; i++) { dCursor c = new dCursor(); reset(c); cur.add(c); }
		onParameterChanged(pEQ); setNewDest();
	}

	public void onParameterChanged(LXParameter parameter) {
		super.onParameterChanged(parameter);
		nConfusion = 1-pConfusion.getValuef();
		for (int i=0; i<numCursors; i++) {
			if (parameter==pSpawn) reset(cur.get(i));
			cur.get(i).destSpeed = nConfusion;
		}
	}

	public float getClr() { return lx.getBaseHuef() + random(pColor.getValuef()*300); }
	public void reset(dCursor c) {
		switch(AnimNum()) {
			case 0:	c.clr = lx.hsb(getClr(),100,100);			// middle to edges
					c.setDest(lattice.getClosest(randEdge()).v, nConfusion);
					c.setCur (lattice.getClosest(middle));
					break;

			case 1:	c.clr = lx.hsb(getClr(),100,100);				// top to bottom
					float xLin = randX();
					c.setDest(lattice.getClosest(new PVector(xLin, 0         , zMidLat)).v, nConfusion);
					c.setCur (lattice.getClosest(new PVector(xLin, model.yMax, zMidLat)));
					break;

			case 2: c.clr = lx.hsb(getClr(),100,100); break; 		// chase a point around

			case 3: boolean bLeft = random(2)<1;
					c.clr = lx.hsb(getClr()+random(120),100,100);				// sideways
					float yLin = randX();
					c.setDest(lattice.getClosest(new PVector(bLeft ? 0 : model.xMax,yLin,zMidLat)).v, nConfusion);
					c.setCur (lattice.getClosest(new PVector(bLeft ? model.xMax : 0,yLin,zMidLat)));
					break;
		}
		if (pBlur.getValuef() == 1 && random(2)<1) c.clr = lx.hsb(0,0,0);
	}

	public void setNewDest() {
		if (AnimNum() != 2) return;
		PVector dest = new PVector(randX(), randY(), zMidLat);
		for (int i=0; i<numCursors; i++) {
			cur.get(i).setDest(lattice.getClosest(dest).v, nConfusion);
			cur.get(i).clr = lx.hsb(getClr()+75,100,100);	// chase a point around
		}
	}

	public void run(double deltaMs) { 
		if (deltaMs > 100) return;
	    if (moveChase.click()) setNewDest();

	    float fBass=0, fTreble=0;
	    if (pEQ.getValuef()>0) {		// EQ
		    eq.run(deltaMs);
		    fBass 	= eq.getAverageLevel(0, 4);
		    fTreble = eq.getAverageLevel(eq.numBands-7, 7);
		}

		if (pBlur.getValuef() < 1) {	// trails
			for (int i=0,s=model.points.size(); i<s; i++) {
				int c = colors[i]; float b = lx.b(c); 
				if (b>0) colors[i] = lx.hsb(lx.h(c), lx.s(c), constrain((float)(b-100*deltaMs/(pBlur.getValuef()*TrailTime)),0,100));
			}
		}

		int nWorms = floor(pWorms.getValuef() * numCursors * 
					 map(pEQ.getValuef(),0,1,1,constrain(2*fTreble,0,1)));

		for (int i=0; i<nWorms; i++) {
			dCursor c = cur.get(i);
			int nLeft = floor((float)deltaMs*.001f*StripsPerSec * 65536 * (5*pSpeed.getValuef()));
			nLeft *= (1 - lx.tempo.rampf()*pBeat.getValuef());
			while(nLeft > 0) { 
				nLeft = c.draw(nLeft,this); if (!c.isDone()) continue;
				c.onDone(); if (c.atDest()) reset(c);
			}
		}
	}


	public void onActive() { if (eq == null) {
		eq = new GraphicEQ(lx, 16);		eq.slope.setValue(0.6f);
		eq.level.setValue(0.65f);		eq.range.setValue(0.35f);
		eq.release.setValue(0.4f);
	}}
}
//----------------------------------------------------------------------------------------------------------------------------------
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
  public void oscEvent(OscMessage msg){
    String pattern[] = split(msg.addrPattern(), "/");    
    int ballnum = PApplet.parseInt(pattern[3]);
    balls[ballnum].lastSeen=millis();
    balls[ballnum].x = msg.get(0).floatValue();
    balls[ballnum].y = msg.get(1).floatValue();    
  }
  
  public void run(double deltaMs){
    for(Point p: model.points){ colors[p.index]=0; }
    for(int i=1; i<balls.length; i++){
      if(millis() - balls[i].lastSeen < 1000) {
        for(Point p: model.points){
          int x = PApplet.parseInt(balls[i].x * 255.0f);
          int y = PApplet.parseInt(balls[i].y * 127.0f);
          if(p.x < x+4 && p.x > x-4 && p.y < y+4 && p.y > y-4) { colors[p.index] = 0xffFF0000; } 
        }
      }
    }
  }
}




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
     for(Point p: model.points){
       colors[p.index] = pret.get((int(p.x)/8)*8, 128-int(p.y));
     }     
  }
}*/

//----------------------------------------------------------------------------------------------------------------------------------
int			NumApcRows=4, NumApcCols=8;

public boolean btwn  	(int 		a,int 	 b,int 		c)		{ return a >= b && a <= c; 	}
public boolean btwn  	(double 	a,double b,double 	c)		{ return a >= b && a <= c; 	}
public float	interp 	(float a, float b, float c) { return (1-a)*b + a*c; }
public float	randctr	(float a) { return random(a) - a*.5f; }
public float	min		(float a, float b, float c, float d) { return min(min(a,b),min(c,d)); 	}
public float   pointDist(Point p1, Point p2) { return dist(p1.x,p1.y,p1.z,p2.x,p2.y,p2.z); 	}
public float   xyDist   (Point p1, Point p2) { return dist(p1.x,p1.y,p2.x,p2.y); 				}
public float 	distToSeg(float x, float y, float x1, float y1, float x2, float y2) {
	float A 			= x - x1, B = y - y1, C = x2 - x1, D = y2 - y1;
	float dot 			= A * C + B * D, len_sq	= C * C + D * D;
	float xx, yy,param 	= dot / len_sq;
	
	if (param < 0 || (x1 == x2 && y1 == y2)) { 	xx = x1; yy = y1; }
	else if (param > 1) {						xx = x2; yy = y2; }
	else {										xx = x1 + param * C;
												yy = y1 + param * D; }
	float dx = x - xx, dy = y - yy;
	return sqrt(dx * dx + dy * dy);
}

public class Pick {
	int 	NumPicks, Default	,	
			CurRow	, CurCol	,
			StartRow, EndRow	;
	String  tag		, Desc[]	;

	Pick	(String label, int _Def, int _Num, 	int nStart, String d[])	{
		NumPicks 	= _Num; 	Default = _Def; 
		StartRow 	= nStart;	EndRow	= StartRow + floor((NumPicks-1) / NumApcCols);
		tag			= label; 	Desc 	= d;
		reset();
	}

	public int		Cur() 	 		{ return (CurRow-StartRow)*NumApcCols + CurCol;					}
	public String	CurDesc() 		{ return Desc[Cur()]; }
	public void	reset() 		{ CurCol = Default % NumApcCols; CurRow	= StartRow + Default / NumApcCols; }

	public boolean set(int r, int c)	{
		if (!btwn(r,StartRow,EndRow) || !btwn(c,0,NumApcCols-1) ||
			!btwn((r-StartRow)*NumApcCols + c,0,NumPicks-1)) 	return false;
		CurRow=r; CurCol=c; 									return true;
	}
}

public class DBool {
	boolean def, b;
	String	tag;
	int		row, col;
	public void 	reset() { b = def; }
	public boolean set	(int r, int c, boolean val) { if (r != row || c != col) return false; b = val; return true; }
	DBool(String _tag, boolean _def, int _row, int _col) {
		def = _def; b = _def; tag = _tag; row = _row; col = _col;
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
public class DPat extends SCPattern
{
	ArrayList<Pick>   picks  = new ArrayList<Pick>  ();
	ArrayList<DBool>  bools  = new ArrayList<DBool> ();

	PVector		mMax, mCtr, mHalf;

	MidiOutput  APCOut;
	int			nMaxRow  	= 53;
	float		LastJog = -1;
	float[]		xWaveNz, yWaveNz;
	int 		nPoint	, nPoints;
	PVector		xyzJog = new PVector(), modmin;

	float			NoiseMove	= random(10000);
	BasicParameter	pSpark, pWave, pRotX, pRotY, pRotZ, pSpin, pTransX, pTransY;
	DBool			pXsym, pYsym, pRsym, pXdup, pXtrip, pJog, pGrey;

	public float		lxh		() 									{ return lx.getBaseHuef(); 											}
	public int			c1c		 (float a) 							{ return round(100*constrain(a,0,1));								}
	public float 		interpWv(float i, float[] vals) 			{ return interp(i-floor(i), vals[floor(i)], vals[ceil(i)]); 		}
	public void 		setNorm (PVector vec)						{ vec.set(vec.x/mMax.x, vec.y/mMax.y, vec.z/mMax.z); 				}
	public void		setRand	(PVector vec)						{ vec.set(random(mMax.x), random(mMax.y), random(mMax.z)); 			}
	public void		setVec 	(PVector vec, Point p)				{ vec.set(p.x, p.y, p.z);  											}
	public void		interpolate(float i, PVector a, PVector b)	{ a.set(interp(i,a.x,b.x), interp(i,a.y,b.y), interp(i,a.z,b.z)); 	}
	public void  		StartRun(double deltaMs) 					{ }
	public float 		val		(BasicParameter p) 					{ return p.getValuef();												}
	public int		CalcPoint(PVector p) 						{ return lx.hsb(0,0,0); 											}
	public int		blend3(int c1, int c2, int c3)		{ return blendColor(c1,blendColor(c2,c3,ADD),ADD); 					}

	public void	rotateZ (PVector p, PVector o, float nSin, float nCos) { p.set(    nCos*(p.x-o.x) - nSin*(p.y-o.y) + o.x    , nSin*(p.x-o.x) + nCos*(p.y-o.y) + o.y,p.z); }
	public void	rotateX (PVector p, PVector o, float nSin, float nCos) { p.set(p.x,nCos*(p.y-o.y) - nSin*(p.z-o.z) + o.y    , nSin*(p.y-o.y) + nCos*(p.z-o.z) + o.z    ); }
	public void	rotateY (PVector p, PVector o, float nSin, float nCos) { p.set(    nSin*(p.z-o.z) + nCos*(p.x-o.x) + o.x,p.y, nCos*(p.z-o.z) - nSin*(p.x-o.x) + o.z    ); }

	public BasicParameter	addParam(String label, double value) 	{ BasicParameter p = new BasicParameter(label, value); addParameter(p); return p; }

	PVector 	vT1 = new PVector(), vT2 = new PVector();
	public float 		calcCone (PVector v1, PVector v2, PVector c) 	{	vT1.set(v1); vT2.set(v2); vT1.sub(c); vT2.sub(c);
																	return degrees(PVector.angleBetween(vT1,vT2)); }

	public Pick 		addPick(String name, int def, int _max, String[] desc) {
		Pick P 		= new Pick(name, def, _max+1, nMaxRow, desc); 
		nMaxRow		= P.EndRow + 1;
		picks.add(P);
		return P;
	}

    public boolean 	noteOff(Note note) {
		int row = note.getPitch(), col = note.getChannel();
		for (int i=0; i<bools.size(); i++) if (bools.get(i).set(row, col, false)) { presetManager.dirty(this); return true; }
		updateLights(); return false;
	}

    public boolean 	noteOn(Note note) {
		int row = note.getPitch(), col = note.getChannel();
		for (int i=0; i<picks.size(); i++) if (picks.get(i).set(row, col)) 	  		{ presetManager.dirty(this); return true; }
		for (int i=0; i<bools.size(); i++) if (bools.get(i).set(row, col, true)) 	{ presetManager.dirty(this); return true; }
		println("row: " + row + "  col:   " + col); return false;
	}

	public void 		onInactive() 			{ uiDebugText.setText(""); }
	public void 		onReset() 				{
		for (int i=0; i<bools .size(); i++) bools.get(i).reset();
		for (int i=0; i<picks .size(); i++) picks.get(i).reset();
		presetManager.dirty(this); 
		updateLights(); 
	}

	DPat(GLucose glucose) {
		super(glucose);

		pSpark		=	addParam("Sprk",  0);
		pWave		=	addParam("Wave",  0);
		pTransX		=	addParam("TrnX", .5f);
		pTransY		=	addParam("TrnY", .5f);
		pRotX 		= 	addParam("RotX", .5f);
		pRotY 		= 	addParam("RotY", .5f);
		pRotZ 		= 	addParam("RotZ", .5f);
		pSpin		= 	addParam("Spin", .5f);

		nPoints 	=	model.points.size();
		pXsym 		=	new DBool("X-SYM", false, 48, 0);	bools.add(pXsym	);
		pYsym 		=	new DBool("Y-SYM", false, 48, 1);	bools.add(pYsym	);
		pRsym 		=	new DBool("R-SYM", false, 48, 2);	bools.add(pRsym );
		pXdup		=	new DBool("X-DUP", false, 48, 3);	bools.add(pXdup );
		pJog		=	new DBool("JOG"  , false, 48, 4);	bools.add(pJog	);
		pGrey		=	new DBool("GREY" , false, 48, 5);	bools.add(pGrey );

		modmin		=	new PVector(model.xMin, model.yMin, model.zMin);
		mMax		= 	new PVector(model.xMax, model.yMax, model.zMax); mMax.sub(modmin);
		mCtr		= 	new PVector(); mCtr.set(mMax); mCtr.mult(.5f);
		mHalf		= 	new PVector(.5f,.5f,.5f);
		xWaveNz		=	new float[ceil(mMax.y)+1];
		yWaveNz		=	new float[ceil(mMax.x)+1];

		//println (model.xMin + " " + model.yMin + " " +  model.zMin);
		//println (model.xMax + " " + model.yMax + " " +  model.zMax);
	  //for (MidiOutputDevice o: RWMidi.getOutputDevices()) { if (o.toString().contains("APC")) { APCOut = o.createOutput(); break;}}
	}

	public float spin() {
	  float raw = val(pSpin);
	  if (raw <= 0.45f) {
	    return raw + 0.05f;
	  } else if (raw >= 0.55f) {
	    return raw - 0.05f;
    }
    return 0.5f;
	}
	
	public void setAPCOutput(MidiOutput output) {
	  APCOut = output;
	}

	public void updateLights() { if (APCOut == null) return;
	    for (int i = 0; i < NumApcRows; ++i) 
	    	for (int j = 0; j < 8; ++j) 		APCOut.sendNoteOn(j, 53+i,  0);
		for (int i=0; i<picks .size(); i++) 	APCOut.sendNoteOn(picks.get(i).CurCol, picks.get(i).CurRow, 3);
		for (int i=0; i<bools .size(); i++) 	if (bools.get(i).b) 	APCOut.sendNoteOn	(bools.get(i).col, bools.get(i).row, 1);
												else					APCOut.sendNoteOff	(bools.get(i).col, bools.get(i).row, 0);
	}

	public void run(double deltaMs)
	{
		if (deltaMs > 100) return;

		if (this == midiEngine.getFocusedDeck().getActivePattern()) {
			String Text1="", Text2="";
			for (int i=0; i<bools.size(); i++) if (bools.get(i).b) Text1 += " " + bools.get(i).tag       + "   ";
			for (int i=0; i<picks.size(); i++) Text1 += picks.get(i).tag + ": " + picks.get(i).CurDesc() + "   ";
			uiDebugText.setText(Text1, Text2);
		}

		NoiseMove   	+= deltaMs; NoiseMove = NoiseMove % 1e7f;
		StartRun		(deltaMs);
		PVector P 		= new PVector(), tP = new PVector(), pSave = new PVector();
		PVector pTrans 	= new PVector(val(pTransX)*200-100, val(pTransY)*100-50,0);
		nPoint 	= 0;

		if (pJog.b) {
			float tRamp	= (lx.tempo.rampf() % .25f);
			if (tRamp < LastJog) xyzJog.set(randctr(mMax.x*.2f), randctr(mMax.y*.2f), randctr(mMax.z*.2f));
			LastJog = tRamp; 
		}

		// precalculate this stuff
		float wvAmp = val(pWave), sprk = val(pSpark);
		if (wvAmp > 0) {
			for (int i=0; i<ceil(mMax.x)+1; i++)
				yWaveNz[i] = wvAmp * (noise(i/(mMax.x*.3f)-(2e3f+NoiseMove)/1500.f) - .5f) * (mMax.y/2.f);

			for (int i=0; i<ceil(mMax.y)+1; i++)
				xWaveNz[i] = wvAmp * (noise(i/(mMax.y*.3f)-(1e3f+NoiseMove)/1500.f) - .5f) * (mMax.x/2.f);
		}

		for (Point p : model.points) { nPoint++;
			setVec(P,p);
			P.sub(modmin);
			P.sub(pTrans);
			if (sprk  > 0) {P.y += sprk*randctr(50); P.x += sprk*randctr(50); P.z += sprk*randctr(50); }
			if (wvAmp > 0) 	P.y += interpWv(p.x-modmin.x, yWaveNz);
			if (wvAmp > 0) 	P.x += interpWv(p.y-modmin.y, xWaveNz);
			if (pJog.b)		P.add(xyzJog);


			int cNew, cOld = colors[p.index];
							{ tP.set(P); 				  					cNew = CalcPoint(tP);							}
 			if (pXsym.b)	{ tP.set(mMax.x-P.x,P.y,P.z); 					cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pYsym.b) 	{ tP.set(P.x,mMax.y-P.y,P.z); 					cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pRsym.b) 	{ tP.set(mMax.x-P.x,mMax.y-P.y,mMax.z-P.z);		cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pXdup.b) 	{ tP.set((P.x+mMax.x*.5f)%mMax.x,P.y,P.z);		cNew = blendColor(cNew, CalcPoint(tP), ADD);	}
			if (pGrey.b)	{ cNew = lx.hsb(0, 0, lx.b(cNew)); }
			colors[p.index] = cNew;
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------------------
class dTurn { 
	dVertex v; 
	int pos0, pos1;
	dTurn(int _pos0, dVertex _v, int _pos1) { v = _v; pos0 = _pos0; pos1 = _pos1; }
}

class dVertex {
	dVertex c0, c1, c2, c3, 	// connections on the cube
			opp, same;			// opp - same strip, opp direction
								// same - same strut, diff strip, dir
	dTurn 	t0, t1, t2, t3;
	Strip   s;
	int 	dir, ci;		// dir -- 1 or -1.
							// ci  -- color index

	dVertex(Strip _s, Point _p)  { s = _s; ci  = _p.index; }
	public Point 	getPoint(int i) 	 { return s.points.get(dir>0 ? i : 15-i);  }
	public void 	setOpp(dVertex _opp) { opp = _opp; dir = (ci < opp.ci ? 1 : -1); }
}
//----------------------------------------------------------------------------------------------------------------------------------
class dPixel   { dVertex v; int pos; dPixel(dVertex _v, int _pos) { v=_v; pos=_pos; } }
class dLattice {
	public void	addTurn  (dVertex v0, int pos0, dVertex v1, int pos1) {	dTurn t = new dTurn(pos0, v1, pos1); 
																	if (v0.t0 == null) { v0.t0=t; return; }
																	if (v0.t1 == null) { v0.t1=t; return; }
																	if (v0.t2 == null) { v0.t2=t; return; }
																	if (v0.t3 == null) { v0.t3=t; return; }
																}
	public float   dist2	 (Strip s1, int pos1, Strip s2, int pos2) 	{ 	return pointDist(s1.points.get(pos1), s2.points.get(pos2)); }
	public float   pd2 	 (Point p1, float x, float y, float z) 		{ 	return dist(p1.x,p1.y,p1.z,x,y,z); }
	public boolean sameSame (Strip s1, Strip s2) 						{	return max(dist2(s1, 0, s2, 0), dist2(s1,15, s2,15)) < 5 ;	}	// same strut, same direction
	public boolean sameOpp  (Strip s1, Strip s2) 						{	return max(dist2(s1, 0, s2,15), dist2(s1,15, s2,0 )) < 5 ;	}	// same strut, opp direction
	public boolean sameBar  (Strip s1, Strip s2) 						{	return sameSame(s1,s2) || sameOpp(s1,s2);					}	// 2 strips on same strut


	public void 	addJoint (dVertex v1, dVertex v2) {
		// should probably replace parallel but further with the new one
		if (v1.c0 != null && sameBar(v2.s, v1.c0.s)) return;
		if (v1.c1 != null && sameBar(v2.s, v1.c1.s)) return;
		if (v1.c2 != null && sameBar(v2.s, v1.c2.s)) return;
		if (v1.c3 != null && sameBar(v2.s, v1.c3.s)) return;

		if 		(v1.c0 == null) v1.c0 = v2; 
		else if (v1.c1 == null) v1.c1 = v2; 
		else if (v1.c2 == null) v1.c2 = v2; 
		else if (v1.c3 == null) v1.c3 = v2;
	}

	public dVertex v0(Strip s) { return (dVertex)s.obj1; }
	public dVertex v1(Strip s) { return (dVertex)s.obj2; }

	public dPixel getClosest(PVector p) {
		dVertex v = null; int pos=0; float d = 500;

		for (Strip s : glucose.model.strips) {
			float nd = pd2(s.points.get(0),p.x,p.y,p.z); if (nd < d) { v=v0(s); d=nd; pos=0; }
			if (nd > 30) continue;
			for (int k=0; k<=15; k++) {
				nd = pd2(s.points.get(k),p.x,p.y,p.z); if (nd < d) { v =v0(s); d=nd; pos=k; }
			}
		}
		return random(2) < 1 ? new dPixel(v,pos) : new dPixel(v.opp,15-pos);
	}

	dLattice() {
		lattice=this;

		for (Strip s  : glucose.model.strips) {
			dVertex vrtx0 = new dVertex(s,s.points.get(0 )); s.obj1=vrtx0;
			dVertex vrtx1 = new dVertex(s,s.points.get(15)); s.obj2=vrtx1;
			vrtx0.setOpp(vrtx1); vrtx1.setOpp(vrtx0);
		}

		for (Strip s1 : glucose.model.strips) { for (Strip s2 : glucose.model.strips) {
			if (s1.points.get(0).index < s2.points.get(0).index) continue;
			int c=0;
			if (sameSame(s1,s2)) 	{	v0(s1).same = v0(s2); v1(s1).same = v1(s2);
										v0(s2).same = v0(s1); v1(s2).same = v1(s1); continue; } // parallel
			if (sameOpp (s1,s2)) 	{	v0(s1).same = v1(s2); v1(s1).same = v0(s2);
										v0(s2).same = v1(s1); v1(s2).same = v0(s1); continue; } // parallel
			if (dist2(s1, 0, s2, 0) < 5) { c++; addJoint(v1(s1), v0(s2)); addJoint(v1(s2), v0(s1)); }
			if (dist2(s1, 0, s2,15) < 5) { c++; addJoint(v1(s1), v1(s2)); addJoint(v0(s2), v0(s1)); }
			if (dist2(s1,15, s2, 0) < 5) { c++; addJoint(v0(s1), v0(s2)); addJoint(v1(s2), v1(s1)); }
			if (dist2(s1,15, s2,15) < 5) { c++; addJoint(v0(s1), v1(s2)); addJoint(v0(s2), v1(s1)); }
			if (c>0) continue;

			// Are they touching at all?
			int pos1=0, pos2=0; float d = 100;

			while (pos1 < 15 || pos2 < 15) {
				float oldD = d;
				if (pos1<15) { float d2 = dist2(s1, pos1+1, s2, pos2+0); if (d2 < d) { d=d2; pos1++; } }
				if (pos2<15) { float d2 = dist2(s1, pos1+0, s2, pos2+1); if (d2 < d) { d=d2; pos2++; } }
				if (d > 50  || oldD == d) break ;
			}

			if (d>5) continue;
			addTurn(v0(s1), pos1, v0(s2), pos2); addTurn(v1(s1), 15-pos1, v0(s2), pos2); 
			addTurn(v0(s2), pos2, v0(s1), pos1); addTurn(v1(s2), 15-pos2, v0(s1), pos1);
		}}
	}
}

dLattice lattice;
//----------------------------------------------------------------------------------------------------------------------------------

class Graphic
{
	public boolean changed = false;
	public int position  = 0;
	public ArrayList<Integer> graphicBuffer;
	Graphic()
	{	
		graphicBuffer = new ArrayList<Integer>();
	}
	public int width()
	{
		return graphicBuffer.size();
	}

	
};
class Granim extends Graphic
{
	HashMap<String,Graphic> displayList;
	
	Granim()
	{
		displayList = new HashMap<String,Graphic>();
	}
	public Graphic addGraphic(String name, Graphic g)
	{
		while(width()< g.position+1)
		{
				graphicBuffer.add(lx.hsb(0,0,0));
		}
		drawAll();
		displayList.put(name , g);
		changed =true;
		return g;
	}

	public Graphic getGraphicByName(String name)
	{
		return displayList.get(name);
	}

	public void update()
	{
		
		for(Graphic g : displayList.values())
		{
			if(g instanceof Granim)
			{
				((Granim) g).update();
				
			}
			changed = changed || g.changed;
			if(changed)
			{
				while(width()< g.position + g.width())
				{
					graphicBuffer.add(lx.hsb(0,0,0));
				}
				if(g.changed)
				{
					drawOne(g);
					g.changed =false;
				}
			}
		}
		changed = false;

	}
	public void drawOne(Graphic g)
	{
		graphicBuffer.addAll(g.position,g.graphicBuffer);
	}
	public void drawAll()
	{
	}
};
class GranimPattern extends SCPattern
{
	HashMap<String,Graphic> displayList;

	GranimPattern(GLucose glucose)
	{
		super(glucose);
		displayList = new HashMap<String,Graphic>();
	}

	public Graphic addGraphic(String name, Graphic g)
	{
		displayList.put(name,g);
		return g;
	}

	public Graphic getGraphicByName(String name)
	{
		return displayList.get(name);
	}

	public void run(double deltaMs) 
	{
		drawToPointList();
	}
	private Integer[] gbuffer;
	public void drawToPointList()
	{
		for(Graphic g : displayList.values())
		{
			if(g instanceof Granim)
			{
				((Granim) g).update();
			}
			List<Point> drawList = model.points.subList(Math.min(g.position,colors.length-1), Math.min(g.position + g.width(),colors.length-1));
			//println("drawlistsize "+drawList.size());
			
			gbuffer = g.graphicBuffer.toArray(new Integer[0]);
			
			for (int i=0; i < drawList.size(); i++)
			{
				colors[drawList.get(i).index] = gbuffer[i];
			}
			g.changed = false;
		}
	}

};

class RedsGraphic extends Graphic
{
	RedsGraphic()
	{
		super();
		drawit(10);
	}
	RedsGraphic(int len)
	{
		super();
		drawit(len);
		
	}
	public void drawit(int len)
	{
		for(int i = 0; i < len ;i++)
		{
			graphicBuffer.add(lx.hsb(0,255,255));
		}
	}
};

class RedsGranim extends Granim
{
	RedsGranim()
	{
		super();
		addGraphic("myreds", new RedsGraphic(10));
	}
	RedsGranim(int len)
	{
		super();
		addGraphic("myreds", new RedsGraphic(len));
	}
	public float count = 0.0f;
	public void update()
	{
		Graphic g=getGraphicByName("myreds");
		g.position = Math.round(sin(count)*20)+100;
		count+= 0.1f;
		if(count>Math.PI*2)
		{
			count=0;
		}
		super.update();
	}
	
};

class RandomsGranim extends Granim
{
	private int _len =0 ;
	RandomsGranim()
	{
		super();
		_len =100;
		addGraphic("myrandoms", makeGraphic(_len));
	}
	RandomsGranim(int len)
	{
		super();
		_len=len;
		addGraphic("myrandoms", makeGraphic(len));
	}
	int colorLid=0;
	public Graphic makeGraphic(int len)
	{

		int[] colors= new int[len]; 
		for(int i =0;i<len;i++)
		{
			colors[i]=(int) Math.round(Math.random()*80)+colorLid;
			
		}
		colorLid+=4;
		return new ColorDotsGraphic(colors);
	}
	private int count =1;
	private int instanceCount =0;
	public void update()
	{
		
		if(instanceCount<90 && count % 20==0)
		{
			instanceCount++;
			Graphic h=addGraphic("myrandoms_"+instanceCount, makeGraphic(_len));
			h.position = instanceCount*(_len+100);
			//println("one more " + instanceCount+" at "+h.position);
			count=0;
			changed = true;
		}
		count++;
		super.update();
	}
	
};


class ColorDotsGraphic extends Graphic
{
	ColorDotsGraphic(int[] colorSequence)
	{
		super();
		for (int colorVal : colorSequence)
		{
			graphicBuffer.add(lx.hsb(colorVal, 255, 255));
		}
		changed = true;
	}
};
int BLACK = 0xff000000;

class Gimbal extends SCPattern {

  private final boolean DEBUG_MANUAL_ABG = false;
  private final int MAXIMUM_BEATS_PER_REVOLUTION = 100;
  
  private boolean first_run = true;
  private final Projection projection;
  private final BasicParameter beatsPerRevolutionParam = new BasicParameter("SLOW", 20.f/MAXIMUM_BEATS_PER_REVOLUTION);
  private final BasicParameter hueDeltaParam = new BasicParameter("HUED", 60.f/360);
  private final BasicParameter fadeFromCoreParam = new BasicParameter("FADE", 1);
  private final BasicParameter girthParam = new BasicParameter("GRTH", .18f);
  private final BasicParameter ringExtendParam = new BasicParameter("XTND", 1);
  private final BasicParameter relativeSpeedParam = new BasicParameter("RLSP", .83f);
  private final BasicParameter sizeParam = new BasicParameter("SIZE", .9f);

  private final BasicParameter aP = new BasicParameter("a", 0);
  private final BasicParameter bP = new BasicParameter("b", 0);
  private final BasicParameter gP = new BasicParameter("g", 0);

  Gimbal(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);
    addParameter(beatsPerRevolutionParam);
    addParameter(hueDeltaParam);
    addParameter(fadeFromCoreParam);
    addParameter(girthParam);
    addParameter(ringExtendParam);
    addParameter(relativeSpeedParam);
    addParameter(sizeParam);
    
    if (DEBUG_MANUAL_ABG) {
      addParameter(aP);
      addParameter(bP);
      addParameter(gP);
    }
  }

  float a = 0, b = 0, g = 0;

  public void run(double deltaMs) {

    if (DEBUG_MANUAL_ABG) {
      a = aP.getValuef() * (2 * PI); 
      b = bP.getValuef() * (2 * PI);
      g = gP.getValuef() * (2 * PI);
    } else {
      float relativeSpeed = relativeSpeedParam.getValuef();
      float time = millis() / 1000.f;
      
      int beatsPerRevolution = (int) (beatsPerRevolutionParam.getValuef() * MAXIMUM_BEATS_PER_REVOLUTION) + 1;
      float radiansPerMs = 2 * PI             // radians / revolution
                         / beatsPerRevolution // beats / revolution
                         * lx.tempo.bpmf()    // BPM beats / min
                         / 60                 // sec / min
                         / 1000;              // ms / sec
      
      a += deltaMs * radiansPerMs * pow(relativeSpeed, 0);
      b += deltaMs * radiansPerMs * pow(relativeSpeed, 1);
      g += deltaMs * radiansPerMs * pow(relativeSpeed, 2);
      a %= 2 * PI;
      b %= 2 * PI;
      g %= 2 * PI;
    }

    float hue = lx.getBaseHuef();
    float hue_delta = hueDeltaParam.getValuef() * 360;
    
    float radius1 = model.xMax / 2 * sizeParam.getValuef();
    float radius2 = ((model.xMax + model.yMax) / 2) / 2 * sizeParam.getValuef();
    float radius3 = model.yMax / 2 * sizeParam.getValuef();
    float girth = model.xMax * girthParam.getValuef();
    Ring ring1 = new Ring((hue + hue_delta * 0) % 360, radius1, girth);
    Ring ring2 = new Ring((hue + hue_delta * 1) % 360, radius2, girth);
    Ring ring3 = new Ring((hue + hue_delta * 2) % 360, radius3, girth);

    projection.reset(model)
      // Translate so the center of the car is the origin
      .translateCenter(model, 0, 0, 0);

    for (Coord c : projection) {
      //if (first_run) println(c.x + "," + c.y + "," + c.z);

      rotate3d(c, a, 0, 0);
      rotate3d(c, PI/4, PI/4, PI/4);
      int color1 = ring1.colorFor(c);

      rotate3d(c, 0, b, 0);
      int color2 = ring2.colorFor(c);

      rotate3d(c, 0, 0, g);
      int color3 = ring3.colorFor(c);
            
      colors[c.index] = specialBlend(color1, color2, color3);      
    }

    first_run = false;
  }

  class Ring {

    float hue;
    float radius, girth;

    public Ring(float hue, float radius, float girth) {
      this.hue = hue;
      this.radius = radius;
      this.girth = girth;
    }

    public int colorFor(Coord c) {
      float theta = atan2(c.y, c.x);
      float nearest_circle_x = cos(theta) * radius;
      float nearest_circle_y = sin(theta) * radius;
      float nearest_circle_z = 0;

      float distance_to_circle
          = sqrt(pow(nearest_circle_x - c.x, 2)
               + pow(nearest_circle_y - c.y, 2)
               + pow(nearest_circle_z - c.z * ringExtendParam.getValuef(), 2));

      float xy_distance = sqrt(c.x*c.x + c.y*c.y);
      return lx.hsb(this.hue, 100, (1 - distance_to_circle / girth * fadeFromCoreParam.getValuef()) * 100);
    }

  }

}






class Zebra extends SCPattern {

  private final Projection projection;
  SinLFO angleM = new SinLFO(0, PI * 2, 30000);

/*
  SinLFO x, y, z, dx, dy, dz;
  float cRad;
  _P size;
  */

  Zebra(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);

    addModulator(angleM).trigger();
  }

  public int colorFor(Coord c) {
    float hue = lx.getBaseHuef();




/* SLIDE ALONG
    c.x = c.x + millis() / 100.f;
    */



    int stripe_count = 12;
    float stripe_width = model.xMax / (float)stripe_count;
    if (Math.floor((c.x) / stripe_width) % 2 == 0) {
      return lx.hsb(hue, 100, 100);
    } else {
      return lx.hsb((hue + 90) % 360, 100, 100);
    }


    /* OCTANTS

    if ((isPositiveBit(c.x) + isPositiveBit(c.y) + isPositiveBit(c.z)) % 2 == 0) {
      return lx.hsb(lx.getBaseHuef(), 100, 100);
    } else {
      return lx.hsb(0, 0, 0);
    }
    */
  }

  public int isPositiveBit(float f) {
    return f > 0 ? 1 : 0;
  }

  public void run(double deltaMs) {
    float a = (millis() / 1000.f) % (2 * PI);
    float b = (millis() / 1200.f) % (2 * PI);
    float g = (millis() / 1600.f) % (2 * PI);

    projection.reset(model)
      // Translate so the center of the car is the origin
      .translateCenter(model, 0, 0, 0);

    for (Coord c : projection) {
//      rotate3d(c, a, b, g);
      colors[c.index] = colorFor(c);
    }

    first_run = false;
  }


  // Utility!
  boolean first_run = true;
  private void log(String s) {
    if (first_run) {
      println(s);
    }
  }


}

public void rotate3d(Coord c, float a /* roll */, float b /* pitch */, float g /* yaw */) {
  float cosa = cos(a);
  float cosb = cos(b);
  float cosg = cos(g);
  float sina = sin(a);
  float sinb = sin(b);
  float sing = sin(g);

  float a1 = cosa*cosb;
  float a2 = cosa*sinb*sing - sina*cosg;
  float a3 = cosa*sinb*cosg + sina*sing;
  float b1 = sina*cosb;
  float b2 = sina*sinb*sing + cosa*cosg;
  float b3 = sina*sinb*cosg - cosa*sing;
  float c1 = -sinb;
  float c2 = cosb*sing;
  float c3 = cosb*cosg;

  float[] cArray = { c.x, c.y, c.z };
  c.x = dotProduct(new float[] {a1, a2, a3}, cArray);
  c.y = dotProduct(new float[] {b1, b2, b3}, cArray);
  c.z = dotProduct(new float[] {c1, c2, c3}, cArray);
}

public float dotProduct(float[] a, float[] b) {
  float ret = 0;
  for (int i = 0 ; i < a.length; ++i) {
    ret += a[i] * b[i];
  }
  return ret;
}

public int specialBlend(int c1, int c2, int c3) {
  float h1 = hue(c1);
  float h2 = hue(c2); 
  float h3 = hue(c3);
  
  // force h1 < h2 < h3
  while (h2 < h1) {
    h2 += 360;
  }
  while (h3 < h2) {
    h3 += 360;
  }

  float s1 = saturation(c1); 
  float s2 = saturation(c2); 
  float s3 = saturation(c3);
  
  float b1 = brightness(c1); 
  float b2 = brightness(c2);
  float b3 = brightness(c3);
  float relative_b1 = b1 / (b1 + b2 + b3);
  float relative_b2 = b2 / (b1 + b2 + b3);
  float relative_b3 = b3 / (b1 + b2 + b3);
  
  return lx.hsb(
    (h1 * relative_b1 + h2 * relative_b1 + h3 * relative_b3) % 360,
     s1 * relative_b1 + s2 * relative_b2 + s3 * relative_b3,
     max(max(b1, b2), b3)
  );
}

/**
 * A Projection of sin wave in 3d space. 
 * It sort of looks like an animal swiming around in water.
 * Angle sliders are sort of a work in progress that allow yo to change the crazy ways it moves around.
 * Hue slider allows you to control how different the colors are along the wave. 
 *
 * This code copied heavily from Tim and Slee.
 */
class Swim extends SCPattern {

  // Projection stuff
  private final Projection projection;
  SawLFO rotation = new SawLFO(0, TWO_PI, 19000);
  SinLFO yPos = new SinLFO(-25, 25, 12323);
  final BasicParameter xAngle = new BasicParameter("XANG", 0.9f);
  final BasicParameter yAngle = new BasicParameter("YANG", 0.3f);
  final BasicParameter zAngle = new BasicParameter("ZANG", 0.3f);

  final BasicParameter hueScale = new BasicParameter("HUE", 0.3f);

  public Swim(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);

    addParameter(xAngle);
    addParameter(yAngle);
    addParameter(zAngle);
    addParameter(hueScale);

    addModulator(rotation).trigger();
    addModulator(yPos).trigger();
  }


  int beat = 0;
  float prevRamp = 0;
  public void run(double deltaMs) {

    // Sync to the beat
    float ramp = (float)lx.tempo.ramp();
    if (ramp < prevRamp) {
      beat = (beat + 1) % 4;
    }
    prevRamp = ramp;
    float phase = (beat+ramp) / 2.0f * 2 * PI;

    float denominator = max(xAngle.getValuef() + yAngle.getValuef() + zAngle.getValuef(), 1);

    projection.reset(model)
      // Swim around the world
      .rotate(rotation.getValuef(), xAngle.getValuef() / denominator, yAngle.getValuef() / denominator, zAngle.getValuef() / denominator)
        .translateCenter(model, 0, 50 + yPos.getValuef(), 0);

    float model_height =  model.yMax - model.yMin;
    float model_width =  model.xMax - model.xMin;
    for (Coord p : projection) {
      float x_percentage = (p.x - model.xMin)/model_width;

      // Multiply by 1.4 to shrink the size of the sin wave to be less than the height of the cubes.
      float y_in_range = 1.4f * (2*p.y - model.yMax - model.yMin) / model_height;
      float sin_x =  sin(phase + 2 * PI * x_percentage);       

      // Color fade near the top of the sin wave
      float v1 = sin_x > y_in_range  ? (100 + 100*(y_in_range - sin_x)) : 0;     

      float hue_color = (lx.getBaseHuef() + hueScale.getValuef() * (abs(p.x-model.xMax/2.f)*.3f + abs(p.y-model.yMax/2)*.9f + abs(p.z - model.zMax/2.f))) % 360;
      colors[p.index] = lx.hsb(hue_color, 70, v1);
    }
  }
}

/** 
 * The idea here is to do another sin wave pattern, but with less rotation and more of a breathing / heartbeat affect with spheres above / below the wave.
 * This is not done.
 */
class Balance extends SCPattern {

  final BasicParameter hueScale = new BasicParameter("Hue", 0.4f);

  class Sphere {
    float x, y, z;
  }


  // Projection stuff
  private final Projection projection;

  SinLFO sphere1Z = new SinLFO(0, 0, 15323);
  SinLFO sphere2Z = new SinLFO(0, 0, 8323);
  SinLFO rotationX = new SinLFO(-PI/32, PI/32, 9000);
  SinLFO rotationY = new SinLFO(-PI/16, PI/16, 7000);
  SinLFO rotationZ = new SinLFO(-PI/16, PI/16, 11000);
  SawLFO phaseLFO = new SawLFO(0, 2 * PI, 5000 - 4500 * 0.5f);
  final BasicParameter phaseParam = new BasicParameter("Spd", 0.5f);
  final BasicParameter crazyParam = new BasicParameter("Crzy", 0.2f);


  private final Sphere[] spheres;
  private final float centerX, centerY, centerZ, modelHeight, modelWidth, modelDepth;
  SinLFO heightMod = new SinLFO(0.8f, 1.9f, 17298);

  public Balance(GLucose glucose) {
    super(glucose);

    projection = new Projection(model);

    addParameter(hueScale);
    addParameter(phaseParam);
    addParameter(crazyParam);

    spheres = new Sphere[2];
    centerX = (model.xMax + model.xMin) / 2;
    centerY = (model.yMax + model.yMin) / 2;
    centerZ = (model.zMax + model.zMin) / 2;
    modelHeight = model.yMax - model.yMin;
    modelWidth = model.xMax - model.xMin;
    modelDepth = model.zMax - model.zMin;

    spheres[0] = new Sphere();
    spheres[0].x = 1*modelWidth/2 + model.xMin;
    spheres[0].y = centerY + 20;
    spheres[0].z = centerZ;

    spheres[1] = new Sphere();
    spheres[1].x = model.xMin;
    spheres[1].y = centerY - 20;
    spheres[1].z = centerZ;

    addModulator(rotationX).trigger();
    addModulator(rotationY).trigger();
    addModulator(rotationZ).trigger();


    addModulator(sphere1Z).trigger();
    addModulator(sphere2Z).trigger();
    addModulator(phaseLFO).trigger();

    addModulator(heightMod).trigger();
  }

  public void onParameterChanged(LXParameter parameter) {
    if (parameter == phaseParam) {
      phaseLFO.setDuration(5000 - 4500 * parameter.getValuef());
    }
  }

  int beat = 0;
  float prevRamp = 0;
  public void run(double deltaMs) {

    // Sync to the beat
    float ramp = (float)lx.tempo.ramp();
    if (ramp < prevRamp) {
      beat = (beat + 1) % 4;
    }
    prevRamp = ramp;
    float phase = phaseLFO.getValuef();

    float crazy_factor = crazyParam.getValuef() / 0.2f;
    projection.reset(model)
      .rotate(rotationZ.getValuef() * crazy_factor,  0, 1, 0)
        .rotate(rotationX.getValuef() * crazy_factor, 0, 0, 1)
          .rotate(rotationY.getValuef() * crazy_factor, 0, 1, 0);

    for (Coord p : projection) {
      float x_percentage = (p.x - model.xMin)/modelWidth;

      float y_in_range = heightMod.getValuef() * (2*p.y - model.yMax - model.yMin) / modelHeight;
      float sin_x =  sin(PI / 2 + phase + 2 * PI * x_percentage);       

      // Color fade near the top of the sin wave
      float v1 = max(0, 100 * (1 - 4*abs(sin_x - y_in_range)));     

      float hue_color = (lx.getBaseHuef() + hueScale.getValuef() * (abs(p.x-model.xMax/2.f) + abs(p.y-model.yMax/2)*.2f + abs(p.z - model.zMax/2.f)*.5f)) % 360;
      int c = lx.hsb(hue_color, 80, v1);

      // Now draw the spheres
      for (Sphere s : spheres) {
        float phase_x = (s.x - phase / (2 * PI) * modelWidth) % modelWidth;    
        float x_dist = LXUtils.wrapdistf(p.x, phase_x, modelWidth);

        float sphere_z = (s == spheres[0]) ? (s.z + sphere1Z.getValuef()) : (s.z - sphere2Z.getValuef()); 


        float d = sqrt(pow(x_dist, 2) + pow(p.y - s.y, 2) + pow(p.z - sphere_z, 2));

        float distance_from_beat =  (beat % 2 == 1) ? 1 - ramp : ramp;

        min(ramp, 1-ramp);

        float r = 40 - pow(distance_from_beat, 0.75f) * 20;

        float distance_value = max(0, 1 - max(0, d - r) / 10);
        float beat_value = 1.0f;

        float value = min(beat_value, distance_value);

        float sphere_color = (lx.getBaseHuef() - (1 - hueScale.getValuef()) * d/r * 45) % 360;

        c = blendColor(c, lx.hsb((sphere_color + 270) % 360, 60, min(1, value) * 100), ADD);
      }
      colors[p.index] = c;
    }
  }
}
class Cathedrals extends SCPattern {
  
  private final BasicParameter xpos = new BasicParameter("XPOS", 0.5f);
  private final BasicParameter wid = new BasicParameter("WID", 0.5f);
  private final BasicParameter arms = new BasicParameter("ARMS", 0.5f);
  private final BasicParameter sat = new BasicParameter("SAT", 0.5f);
  private GraphicEQ eq;
  
  Cathedrals(GLucose glucose) {
    super(glucose);
    addParameter(xpos);
    addParameter(wid);
    addParameter(arms);
    addParameter(sat);
  }
 
  protected void onActive() {
    if (eq == null) {
      eq = new GraphicEQ(lx, 16);
      eq.slope.setValue(0.7f);
      eq.range.setValue(0.4f);
      eq.attack.setValue(0.4f);
      eq.release.setValue(0.4f);
      addParameter(eq.level);
      addParameter(eq.range);
      addParameter(eq.attack);
      addParameter(eq.release);
      addParameter(eq.slope);
    }
  }

 
  public void run(double deltaMs) {
    eq.run(deltaMs);
    float bassLevel = eq.getAverageLevel(0, 4);
    float trebleLevel = eq.getAverageLevel(8, 6);
    
    float falloff = 100 / (2 + 14*wid.getValuef());
    float cx = model.xMin + (model.xMax-model.xMin) * xpos.getValuef();
    float barm = 12 + 60*arms.getValuef()*max(0, 2*(bassLevel-0.1f));
    float tarm = 12 + 60*arms.getValuef()*max(0, 2*(trebleLevel-0.1f));
    
    float arm = 0;
    float middle = 0;
    
    float sf = 100.f / (70 - 69.9f*sat.getValuef());

    for (Point p : model.points) {
      float d = MAX_FLOAT;
      if (p.y > model.cy) {
        arm = tarm;
        middle = model.yMax * 3/5.f;
      } else {
        arm = barm;
        middle = model.yMax * 1/5.f;
      }
      if (abs(p.x - cx) < arm) {
        d = min(abs(p.x - cx), abs(p.y - middle));
      }
      colors[p.index] = color(
        (lx.getBaseHuef() + .2f*abs(p.y - model.cy)) % 360,
        min(100, sf*dist(abs(p.x - cx), p.y, arm, middle)),
        max(0, 120 - d*falloff));
    }
  } 
}
  
class MidiMusic extends SCPattern {
  
  private final Stack<LXLayer> newLayers = new Stack<LXLayer>();
  
  private final Map<Integer, LightUp> lightMap = new HashMap<Integer, LightUp>();
  private final List<LightUp> lights = new ArrayList<LightUp>();
  private final BasicParameter lightSize = new BasicParameter("SIZE", 0.5f);

  private final List<Sweep> sweeps = new ArrayList<Sweep>();

  private final LinearEnvelope sparkle = new LinearEnvelope(0, 1, 500);
  private boolean sparkleDirection = true;
  private float sparkleBright = 100;
  
  private final BasicParameter wave = new BasicParameter("WAVE", 0);
  
  MidiMusic(GLucose glucose) {
    super(glucose);
    addParameter(lightSize);
    addParameter(wave);
    addModulator(sparkle).setValue(1);
  }
  
  public void onReset() {
    for (LightUp light : lights) {
      light.noteOff(null);
    }
  }
  
  class Sweep extends LXLayer {
    
    final LinearEnvelope position = new LinearEnvelope(0, 1, 1000);
    float bright = 100;
    float falloff = 10;
    
    Sweep() {
      addModulator(position);
    }
    
    public void run(double deltaMs, int[] colors) {
      if (!position.isRunning()) {
        return;
      }
      float posf = position.getValuef();
      for (Point p : model.points) {
        colors[p.index] = blendColor(colors[p.index], color(
          (lx.getBaseHuef() + .2f*abs(p.x - model.cx) + .2f*abs(p.y - model.cy)) % 360,
          100,
          max(0, bright - posf*100 - falloff*abs(p.y - posf*model.yMax))
        ), ADD);
      }
    }
  }
  
  class LightUp extends LXLayer {
    
    private final LinearEnvelope brt = new LinearEnvelope(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, 0);
    private float xPos;
    
    LightUp() {
      addModulator(brt);
      addModulator(yPos);
    }
    
    public boolean isAvailable() {
      return brt.getValuef() <= 0;
    }
    
    public void noteOn(Note note) {
      xPos = lerp(0, model.xMax, constrain(0.5f + (note.getPitch() - 60) / 28.f, 0, 1));
      yPos.setValue(lerp(20, model.yMax*.72f, note.getVelocity() / 127.f)).stop();
      brt.setRangeFromHereTo(lerp(40, 100, note.getVelocity() / 127.f), 20).start();     
    }

    public void noteOff(Note note) {
      yPos.setVelocity(0).setAcceleration(-380).start();
      brt.setRangeFromHereTo(0, 1000).start();
    }
    
    public void run(double deltaMs, int[] colors) {
      float bVal = brt.getValuef();
      if (bVal <= 0) {
        return;
      }
      float yVal = yPos.getValuef();
      for (Point p : model.points) {
        float falloff = 6 - 5*lightSize.getValuef();
        float b = max(0, bVal - falloff*dist(p.x, p.y, xPos, yVal));
        if (b > 0) {
          colors[p.index] = blendColor(colors[p.index], lx.hsb(
            (lx.getBaseHuef() + .2f*abs(p.x - model.cx) + .2f*abs(p.y - model.cy)) % 360,
            100,
            b
          ), ADD);
        }
      }
    }
  }
  
  private LightUp getLight() {
    for (LightUp light : lights) {
      if (light.isAvailable()) {
        return light;
      }
    }
    LightUp newLight = new LightUp();
    lights.add(newLight);
    synchronized(newLayers) {
      newLayers.push(newLight);
    }
    return newLight;
  }
  
  private Sweep getSweep() {
    for (Sweep s : sweeps) {
      if (!s.position.isRunning()) {
        return s;
      }
    }
    Sweep newSweep = new Sweep();
    sweeps.add(newSweep);
    synchronized(newLayers) {
      newLayers.push(newSweep);
    }
    return newSweep;
  }
  
  public synchronized boolean noteOn(Note note) {
    if (note.getChannel() == 0) {
      LightUp light = getLight();
      lightMap.put(note.getPitch(), light);
      light.noteOn(note);
    } else if (note.getChannel() == 1) {
    } else if (note.getChannel() == 9) {
      if (note.getVelocity() > 0) {
        switch (note.getPitch()) {
          case 36:
            Sweep s = getSweep();
            s.bright = 50 + note.getVelocity() / 127.f * 50;
            s.falloff = 20 - note.getVelocity() / 127.f * 17;
            s.position.trigger();
            break;
          case 37:
            sparkleBright = note.getVelocity() / 127.f * 100;
            sparkleDirection = true;
            sparkle.trigger();
            break;
          case 38:
            sparkleBright = note.getVelocity() / 127.f * 100;
            sparkleDirection = false;
            sparkle.trigger();       
            break;
          case 39:
            effects.boom.trigger();
            break;
          case 40:
            effects.flash.trigger();
            break;
        }
      }
    }
    return true;
  }
  
  public synchronized boolean noteOff(Note note) {
    if (note.getChannel() == 0) {
      LightUp light = lightMap.get(note.getPitch());
      if (light != null) {
        light.noteOff(note);
      }
    }
    return true;
  }
  
  final float[] wval = new float[16];
  float wavoff = 0;
  
  public synchronized void run(double deltaMs) {
    wavoff += deltaMs * .001f;
    for (int i = 0; i < wval.length; ++i) {
      wval[i] = model.cy + 0.2f * model.yMax/2.f * sin(wavoff + i / 1.9f);
    }
    float sparklePos = (sparkleDirection ? sparkle.getValuef() : (1 - sparkle.getValuef())) * (Cube.POINTS_PER_STRIP)/2.f;
    float maxBright = sparkleBright * (1 - sparkle.getValuef());
    for (Strip s : model.strips) {
      int i = 0;
      for (Point p : s.points) {
        int wavi = (int) constrain(p.x / model.xMax * wval.length, 0, wval.length-1);
        float wavb = max(0, wave.getValuef()*100.f - 8.f*abs(p.y - wval[wavi]));
        colors[p.index] = color(
          (lx.getBaseHuef() + .2f*abs(p.x - model.cx) + .2f*abs(p.y - model.cy)) % 360,
          100,
          constrain(wavb + max(0, maxBright - 40.f*abs(sparklePos - abs(i - (Cube.POINTS_PER_STRIP-1)/2.f))), 0, 100)
        );
        ++i;
      }
    }
        
    if (!newLayers.isEmpty()) {
      synchronized(newLayers) {
        while (!newLayers.isEmpty()) {
          addLayer(newLayers.pop());
        }
      }
    }
  }
}

class Pulley extends SCPattern {
  
  final int NUM_DIVISIONS = 16;
  private final Accelerator[] gravity = new Accelerator[NUM_DIVISIONS];
  private final Click[] delays = new Click[NUM_DIVISIONS];
  
  private final Click reset = new Click(9000);
  private boolean isRising = false;
  
  private BasicParameter sz = new BasicParameter("SIZE", 0.5f);
  private BasicParameter beatAmount = new BasicParameter("BEAT", 0);
  
  Pulley(GLucose glucose) {
    super(glucose);
    for (int i = 0; i < NUM_DIVISIONS; ++i) {
      addModulator(gravity[i] = new Accelerator(0, 0, 0));
      addModulator(delays[i] = new Click(0));
    }
    addModulator(reset).start();
    addParameter(sz);
    addParameter(beatAmount);
    trigger();

  }
  
  private void trigger() {
    isRising = !isRising;
    int i = 0;
    for (Accelerator g : gravity) {
      if (isRising) {
        g.setSpeed(random(20, 33), 0).start();
      } else {
        g.setVelocity(0).setAcceleration(-420);
        delays[i].setDuration(random(0, 500)).trigger();
      }
      ++i;
    }
  }
  
  public void run(double deltaMs) {
    if (reset.click()) {
      trigger();
    }
        
    if (isRising) {
      // Fucking A, had to comment this all out because of that bizarre
      // Processing bug where some simple loop takes an absurd amount of
      // time, must be some pre-processor bug
//      for (Accelerator g : gravity) {
//        if (g.getValuef() > model.yMax) {
//          g.stop();
//        } else if (g.getValuef() > model.yMax*.55) {
//          if (g.getVelocityf() > 10) {
//            g.setAcceleration(-16);
//          } else {
//            g.setAcceleration(0);
//          }
//        }
//      }
    } else {
      int j = 0;
      for (Click d : delays) {
        if (d.click()) {
          gravity[j].start();
          d.stop();
        }
        ++j;
      }
      for (Accelerator g : gravity) {
        if (g.getValuef() < 0) {
          g.setValue(-g.getValuef());
          g.setVelocity(-g.getVelocityf() * random(0.74f, 0.84f));
        }
      }
    }

    // A little silliness to test the grid API    
    if (midiEngine != null && midiEngine.getFocusedPattern() == this) {
	    for (int i = 0; i < 5; ++i) {
        for (int j = 0; j < 8; ++j) {
          int gi = (int) constrain(j * NUM_DIVISIONS / 8, 0, NUM_DIVISIONS-1);
          float b = 1 - 4.f*abs((6-i)/6.f - gravity[gi].getValuef() / model.yMax);
          midiEngine.grid.setState(i, j, (b < 0) ? 0 : 3);
        }
      }
    }
    
    float fPos = 1 - lx.tempo.rampf();
    if (fPos < .2f) {
      fPos = .2f + 4 * (.2f - fPos);
    }
    float falloff = 100.f / (3 + sz.getValuef() * 36 + fPos * beatAmount.getValuef()*48);
    for (Point p : model.points) {
      int gi = (int) constrain((p.x - model.xMin) * NUM_DIVISIONS / (model.xMax - model.xMin), 0, NUM_DIVISIONS-1);
      colors[p.index] = lx.hsb(
        (lx.getBaseHuef() + abs(p.x - model.cx)*.8f + p.y*.4f) % 360,
        constrain(130 - p.y*.8f, 0, 100),
        max(0, 100 - abs(p.y - gravity[gi].getValuef())*falloff)
      );
    }
  }
}

class ViolinWave extends SCPattern {
  
  BasicParameter level = new BasicParameter("LVL", 0.45f);
  BasicParameter range = new BasicParameter("RNG", 0.5f);
  BasicParameter edge = new BasicParameter("EDG", 0.5f);
  BasicParameter release = new BasicParameter("RLS", 0.5f);
  BasicParameter speed = new BasicParameter("SPD", 0.5f);
  BasicParameter amp = new BasicParameter("AMP", 0.25f);
  BasicParameter period = new BasicParameter("WAVE", 0.5f);
  BasicParameter pSize = new BasicParameter("PSIZE", 0.5f);
  BasicParameter pSpeed = new BasicParameter("PSPD", 0.5f);
  BasicParameter pDensity = new BasicParameter("PDENS", 0.25f);
  
  LinearEnvelope dbValue = new LinearEnvelope(0, 0, 10);

  ViolinWave(GLucose glucose) {
    super(glucose);
    addParameter(level);
    addParameter(edge);
    addParameter(range);
    addParameter(release);
    addParameter(speed);
    addParameter(amp);
    addParameter(period);
    addParameter(pSize);
    addParameter(pSpeed);
    addParameter(pDensity);

    addModulator(dbValue);
  }
  
  final List<Particle> particles = new ArrayList<Particle>();
  
  class Particle {
    
    LinearEnvelope x = new LinearEnvelope(0, 0, 0);
    LinearEnvelope y = new LinearEnvelope(0, 0, 0);
    
    Particle() {
      addModulator(x);
      addModulator(y);
    }
    
    public Particle trigger(boolean direction) {
      float xInit = random(model.xMin, model.xMax);
      float time = 3000 - 2500*pSpeed.getValuef();
      x.setRange(xInit, xInit + random(-40, 40), time).trigger();
      y.setRange(model.cy + 10, direction ? model.yMax + 50 : model.yMin - 50, time).trigger();
      return this;
    }
    
    public boolean isActive() {
      return x.isRunning() || y.isRunning();
    }
    
    public void run(double deltaMs) {
      if (!isActive()) {
        return;
      }
      
      float pFalloff = (30 - 27*pSize.getValuef());
      for (Point p : model.points) {
        float b = 100 - pFalloff * (abs(p.x - x.getValuef()) + abs(p.y - y.getValuef()));
        if (b > 0) {
          colors[p.index] = blendColor(colors[p.index], lx.hsb(
            lx.getBaseHuef(), 20, b
          ), ADD);
        }
      }
    }
  }
  
  float[] centers = new float[30];
  double accum = 0;
  boolean rising = true;
  
  public void fireParticle(boolean direction) {
    boolean gotOne = false;
    for (Particle p : particles) {
      if (!p.isActive()) {
       p.trigger(direction);
       return;
      }
    }
    particles.add(new Particle().trigger(direction));
  }
  
  public void run(double deltaMs) {
    accum += deltaMs / (1000.f - 900.f*speed.getValuef());
    for (int i = 0; i < centers.length; ++i) {
      centers[i] = model.cy + 30*amp.getValuef()*sin((float) (accum + (i-centers.length/2.f)/(1.f + 9.f*period.getValuef())));
    }
    
    float zeroDBReference = pow(10, (50 - 190*level.getValuef())/20.f);
    float dB = 20*GraphicEQ.log10(lx.audioInput().mix.level() / zeroDBReference);
    if (dB > dbValue.getValuef()) {
      rising = true;
      dbValue.setRangeFromHereTo(dB, 10).trigger();
    } else {
      if (rising) {
        for (int j = 0; j < pDensity.getValuef()*3; ++j) {
          fireParticle(true);
          fireParticle(false);
        }
      }
      rising = false;
      dbValue.setRangeFromHereTo(max(dB, -96), 50 + 1000*release.getValuef()).trigger();
    }
    float edg = 1 + edge.getValuef() * 40;
    float rng = (78 - 64 * range.getValuef()) / (model.yMax - model.cy);
    float val = max(2, dbValue.getValuef());
    
    for (Point p : model.points) {
      int ci = (int) lerp(0, centers.length-1, (p.x - model.xMin) / (model.xMax - model.xMin));
      float rFactor = 1.0f -  0.9f * abs(p.x - model.cx) / (model.xMax - model.cx);
      colors[p.index] = lx.hsb(
        (lx.getBaseHuef() + abs(p.x - model.cx)) % 360,
        min(100, 20 + 8*abs(p.y - centers[ci])),
        constrain(edg*(val*rFactor - rng * abs(p.y-centers[ci])), 0, 100)
      );
    }
    
    for (Particle p : particles) {
      p.run(deltaMs);
    }
  }
}

class BouncyBalls extends SCPattern {
  
  static final int NUM_BALLS = 6;
  
  class BouncyBall {
       
    Accelerator yPos;
    TriangleLFO xPos = new TriangleLFO(0, model.xMax, random(8000, 19000));
    float zPos;
    
    BouncyBall(int i) {
      addModulator(xPos.setBasis(random(0, TWO_PI)).start());
      addModulator(yPos = new Accelerator(0, 0, 0));
      zPos = lerp(model.zMin, model.zMax, (i+2.f) / (NUM_BALLS + 4.f));
    }
    
    public void bounce(float midiVel) {
      float v = 100 + 8*midiVel;
      yPos.setSpeed(v, getAccel(v, 60 / lx.tempo.bpmf())).start();
    }
    
    public float getAccel(float v, float oneBeat) {
      return -2*v / oneBeat;
    }
    
    public void run(double deltaMs) {
      float flrLevel = flr.getValuef() * model.xMax/2.f;
      if (yPos.getValuef() < flrLevel) {
        if (yPos.getVelocity() < -50) {
          yPos.setValue(2*flrLevel-yPos.getValuef());
          float v = -yPos.getVelocityf() * bounce.getValuef();
          yPos.setSpeed(v, getAccel(v, 60 / lx.tempo.bpmf()));
        } else {
          yPos.setValue(flrLevel).stop();
        }
      }
      float falloff = 130.f / (12 + blobSize.getValuef() * 36);
      float xv = xPos.getValuef();
      float yv = yPos.getValuef();
      
      for (Point p : model.points) {
        float d = sqrt((p.x-xv)*(p.x-xv) + (p.y-yv)*(p.y-yv) + .1f*(p.z-zPos)*(p.z-zPos));
        float b = constrain(130 - falloff*d, 0, 100);
        if (b > 0) {
          colors[p.index] = blendColor(colors[p.index], lx.hsb(
            (lx.getBaseHuef() + p.y*.5f + abs(model.cx - p.x) * .5f) % 360,
            max(0, 100 - .45f*(p.y - flrLevel)),
            b
          ), ADD);
        }
      }
    }
  }
  
  final BouncyBall[] balls = new BouncyBall[NUM_BALLS];
  
  final BasicParameter bounce = new BasicParameter("BNC", .8f);
  final BasicParameter flr = new BasicParameter("FLR", 0);
  final BasicParameter blobSize = new BasicParameter("SIZE", 0.5f);
  
  BouncyBalls(GLucose glucose) {
    super(glucose);
    for (int i = 0; i < balls.length; ++i) {
      balls[i] = new BouncyBall(i);
    }
    addParameter(bounce);
    addParameter(flr);
    addParameter(blobSize);
  }
  
  public void run(double deltaMs) {
    setColors(0xff000000);
    for (BouncyBall b : balls) {
      b.run(deltaMs);
    }
  }
  
  public boolean noteOn(Note note) {
    int pitch = (note.getPitch() + note.getChannel()) % NUM_BALLS;
    balls[pitch].bounce(note.getVelocity());
    return true;
  }
}

class SpaceTime extends SCPattern {

  SinLFO pos = new SinLFO(0, 1, 3000);
  SinLFO rate = new SinLFO(1000, 9000, 13000);
  SinLFO falloff = new SinLFO(10, 70, 5000);
  float angle = 0;

  BasicParameter rateParameter = new BasicParameter("RATE", 0.5f);
  BasicParameter sizeParameter = new BasicParameter("SIZE", 0.5f);


  public SpaceTime(GLucose glucose) {
    super(glucose);
    
    addModulator(pos).trigger();
    addModulator(rate).trigger();
    addModulator(falloff).trigger();    
    pos.modulateDurationBy(rate);
    addParameter(rateParameter);
    addParameter(sizeParameter);
  }

  public void onParameterChanged(LXParameter parameter) {
    if (parameter == rateParameter) {
      rate.stop().setValue(9000 - 8000*parameter.getValuef());
    }  else if (parameter == sizeParameter) {
      falloff.stop().setValue(70 - 60*parameter.getValuef());
    }
  }

  public void run(double deltaMs) {    
    angle += deltaMs * 0.0007f;
    float sVal1 = model.strips.size() * (0.5f + 0.5f*sin(angle));
    float sVal2 = model.strips.size() * (0.5f + 0.5f*cos(angle));

    float pVal = pos.getValuef();
    float fVal = falloff.getValuef();

    int s = 0;
    for (Strip strip : model.strips) {
      int i = 0;
      for (Point p : strip.points) {
        colors[p.index] = lx.hsb(
          (lx.getBaseHuef() + 360 - p.x*.2f + p.y * .3f) % 360, 
          constrain(.4f * min(abs(s - sVal1), abs(s - sVal2)), 20, 100),
          max(0, 100 - fVal*abs(i - pVal*(strip.metrics.numPoints - 1)))
        );
        ++i;
      }
      ++s;
    }
  }
}

class Swarm extends SCPattern {
  
  SawLFO offset = new SawLFO(0, 1, 1000);
  SinLFO rate = new SinLFO(350, 1200, 63000);
  SinLFO falloff = new SinLFO(15, 50, 17000);
  SinLFO fX = new SinLFO(0, model.xMax, 19000);
  SinLFO fY = new SinLFO(0, model.yMax, 11000);
  SinLFO hOffX = new SinLFO(0, model.xMax, 13000);

  public Swarm(GLucose glucose) {
    super(glucose);
    
    addModulator(offset).trigger();
    addModulator(rate).trigger();
    addModulator(falloff).trigger();
    addModulator(fX).trigger();
    addModulator(fY).trigger();
    addModulator(hOffX).trigger();
    offset.modulateDurationBy(rate);
  }

  public float modDist(float v1, float v2, float mod) {
    v1 = v1 % mod;
    v2 = v2 % mod;
    if (v2 > v1) {
      return min(v2-v1, v1+mod-v2);
    } 
    else {
      return min(v1-v2, v2+mod-v1);
    }
  }

  public void run(double deltaMs) {
    float s = 0;
    for (Strip strip : model.strips  ) {
      int i = 0;
      for (Point p : strip.points) {
        float fV = max(-1, 1 - dist(p.x/2.f, p.y, fX.getValuef()/2.f, fY.getValuef()) / 64.f);
        colors[p.index] = lx.hsb(
        (lx.getBaseHuef() + 0.3f * abs(p.x - hOffX.getValuef())) % 360, 
        constrain(80 + 40 * fV, 0, 100), 
        constrain(100 - (30 - fV * falloff.getValuef()) * modDist(i + (s*63)%61, offset.getValuef() * strip.metrics.numPoints, strip.metrics.numPoints), 0, 100)
          );
        ++i;
      }
      ++s;
    }
  }
}

class SwipeTransition extends SCTransition {
  
  final BasicParameter bleed = new BasicParameter("WIDTH", 0.5f);
  
  SwipeTransition(GLucose glucose) {
    super(glucose);
    setDuration(5000);
    addParameter(bleed);
  }

  public void computeBlend(int[] c1, int[] c2, double progress) {
    float bleedf = 10 + bleed.getValuef() * 200.f;
    float xPos = (float) (-bleedf + progress * (model.xMax + bleedf));
    for (Point p : model.points) {
      float d = (p.x - xPos) / bleedf;
      if (d < 0) {
        colors[p.index] = c2[p.index];
      } else if (d > 1) {
        colors[p.index] = c1[p.index];
      } else {
        colors[p.index] = lerpColor(c2[p.index], c1[p.index], d, RGB);
      }
    }
  }
}

abstract class BlendTransition extends SCTransition {
  
  final int blendType;
  
  BlendTransition(GLucose glucose, int blendType) {
    super(glucose);
    this.blendType = blendType;
  }

  public void computeBlend(int[] c1, int[] c2, double progress) {
    if (progress < 0.5f) {
      for (int i = 0; i < c1.length; ++i) {
        colors[i] = lerpColor(
          c1[i],
          blendColor(c1[i], c2[i], blendType),
          (float) (2.f*progress),
          RGB);
      }
    } else {
      for (int i = 0; i < c1.length; ++i) {
        colors[i] = lerpColor(
          c2[i],
          blendColor(c1[i], c2[i], blendType),
          (float) (2.f*(1.f - progress)),
          RGB);
      }
    }
  }
}

class MultiplyTransition extends BlendTransition {
  MultiplyTransition(GLucose glucose) {
    super(glucose, MULTIPLY);
  }
}

class ScreenTransition extends BlendTransition {
  ScreenTransition(GLucose glucose) {
    super(glucose, SCREEN);
  }
}

class BurnTransition extends BlendTransition {
  BurnTransition(GLucose glucose) {
    super(glucose, BURN);
  }
}

class DodgeTransition extends BlendTransition {
  DodgeTransition(GLucose glucose) {
    super(glucose, DODGE);
  }
}

class OverlayTransition extends BlendTransition {
  OverlayTransition(GLucose glucose) {
    super(glucose, OVERLAY);
  }
}

class AddTransition extends BlendTransition {
  AddTransition(GLucose glucose) {
    super(glucose, ADD);
  }
}

class SubtractTransition extends BlendTransition {
  SubtractTransition(GLucose glucose) {
    super(glucose, SUBTRACT);
  }
}

class SoftLightTransition extends BlendTransition {
  SoftLightTransition(GLucose glucose) {
    super(glucose, SOFT_LIGHT);
  }
}

class BassPod extends SCPattern {

  private GraphicEQ eq = null;
  
  private final BasicParameter clr = new BasicParameter("CLR", 0.5f);
  
  public BassPod(GLucose glucose) {
    super(glucose);
    addParameter(clr);
  }
  
  protected void onActive() {
    if (eq == null) {
      eq = new GraphicEQ(lx, 16);
      eq.range.setValue(0.4f);
      eq.level.setValue(0.4f);
      eq.slope.setValue(0.6f);
      addParameter(eq.level);
      addParameter(eq.range);
      addParameter(eq.attack);
      addParameter(eq.release);
      addParameter(eq.slope);
    }
  }

  public void run(double deltaMs) {
    eq.run(deltaMs);
    
    float bassLevel = eq.getAverageLevel(0, 5);
    
    float satBase = bassLevel*480*clr.getValuef();
    
    for (Point p : model.points) {
      int avgIndex = (int) constrain(1 + abs(p.x-model.cx)/(model.cx)*(eq.numBands-5), 0, eq.numBands-5);
      float value = 0;
      for (int i = avgIndex; i < avgIndex + 5; ++i) {
        value += eq.getLevel(i);
      }
      value /= 5.f;

      float b = constrain(8 * (value*model.yMax - abs(p.y-model.yMax/2.f)), 0, 100);
      colors[p.index] = lx.hsb(
        (lx.getBaseHuef() + abs(p.y - model.cy) + abs(p.x - model.cx)) % 360,
        constrain(satBase - .6f*dist(p.x, p.y, model.cx, model.cy), 0, 100),
        b
      );
    }
  }
}


class CubeEQ extends SCPattern {

  private GraphicEQ eq = null;

  private final BasicParameter edge = new BasicParameter("EDGE", 0.5f);
  private final BasicParameter clr = new BasicParameter("CLR", 0.5f);
  private final BasicParameter blockiness = new BasicParameter("BLK", 0.5f);

  public CubeEQ(GLucose glucose) {
    super(glucose);
  }

  protected void onActive() {
    if (eq == null) {
      eq = new GraphicEQ(lx, 16);
      addParameter(eq.level);
      addParameter(eq.range);
      addParameter(eq.attack);
      addParameter(eq.release);
      addParameter(eq.slope);
      addParameter(edge);
      addParameter(clr);
      addParameter(blockiness);
    }
  }

  public void run(double deltaMs) {
    eq.run(deltaMs);

    float edgeConst = 2 + 30*edge.getValuef();
    float clrConst = 1.1f + clr.getValuef();

    for (Point p : model.points) {
      float avgIndex = constrain(2 + p.x / model.xMax * (eq.numBands-4), 0, eq.numBands-4);
      int avgFloor = (int) avgIndex;

      float leftVal = eq.getLevel(avgFloor);
      float rightVal = eq.getLevel(avgFloor+1);
      float smoothValue = lerp(leftVal, rightVal, avgIndex-avgFloor);
      
      float chunkyValue = (
        eq.getLevel(avgFloor/4*4) +
        eq.getLevel(avgFloor/4*4 + 1) +
        eq.getLevel(avgFloor/4*4 + 2) +
        eq.getLevel(avgFloor/4*4 + 3)
      ) / 4.f; 
      
      float value = lerp(smoothValue, chunkyValue, blockiness.getValuef());

      float b = constrain(edgeConst * (value*model.yMax - p.y), 0, 100);
      colors[p.index] = lx.hsb(
        (480 + lx.getBaseHuef() - min(clrConst*p.y, 120)) % 360, 
        100, 
        b
      );
    }
  }
}

class BoomEffect extends SCEffect {

  final BasicParameter falloff = new BasicParameter("WIDTH", 0.5f);
  final BasicParameter speed = new BasicParameter("SPD", 0.5f);
  final BasicParameter bright = new BasicParameter("BRT", 1.0f);
  final BasicParameter sat = new BasicParameter("SAT", 0.2f);
  List<Layer> layers = new ArrayList<Layer>();
  final float maxr = sqrt(model.xMax*model.xMax + model.yMax*model.yMax + model.zMax*model.zMax) + 10;

  class Layer {
    LinearEnvelope boom = new LinearEnvelope(-40, 500, 1300);

    Layer() {
      addModulator(boom);
      trigger();
    }

    public void trigger() {
      float falloffv = falloffv();
      boom.setRange(-100 / falloffv, maxr + 100/falloffv, 4000 - speed.getValuef() * 3300);
      boom.trigger();
    }

    public void apply(int[] colors) {
      float brightv = 100 * bright.getValuef();
      float falloffv = falloffv();
      float satv = sat.getValuef() * 100;
      float huev = lx.getBaseHuef();
      for (Point p : model.points) {
        colors[p.index] = blendColor(
        colors[p.index], 
        lx.hsb(huev, satv, constrain(brightv - falloffv*abs(boom.getValuef() - dist(p.x, 2*p.y, 3*p.z, model.xMax/2, model.yMax, model.zMax*1.5f)), 0, 100)), 
        ADD);
      }
    }
  }

  BoomEffect(GLucose glucose) {
    super(glucose, true);
    addParameter(falloff);
    addParameter(speed);
    addParameter(bright);
    addParameter(sat);
  }

  public void onEnable() {
    for (Layer l : layers) {
      if (!l.boom.isRunning()) {
        l.trigger();
        return;
      }
    }
    layers.add(new Layer());
  }

  private float falloffv() {
    return 20 - 19 * falloff.getValuef();
  }

  public void onTrigger() {
    onEnable();
  }

  public void apply(int[] colors) {
    for (Layer l : layers) {
      if (l.boom.isRunning()) {
        l.apply(colors);
      }
    }
  }
}

public class PianoKeyPattern extends SCPattern {
  
  final LinearEnvelope[] cubeBrt;
  final SinLFO base[];  
  final BasicParameter attack = new BasicParameter("ATK", 0.1f);
  final BasicParameter release = new BasicParameter("REL", 0.5f);
  final BasicParameter level = new BasicParameter("AMB", 0.6f);
  
  PianoKeyPattern(GLucose glucose) {
    super(glucose);
        
    addParameter(attack);
    addParameter(release);
    addParameter(level);
    cubeBrt = new LinearEnvelope[model.cubes.size() / 4];
    for (int i = 0; i < cubeBrt.length; ++i) {
      addModulator(cubeBrt[i] = new LinearEnvelope(0, 0, 100));
    }
    base = new SinLFO[model.cubes.size() / 12];
    for (int i = 0; i < base.length; ++i) {
      addModulator(base[i] = new SinLFO(0, 1, 7000 + 1000*i)).trigger();
    }
  }
  
  private float getAttackTime() {
    return 15 + attack.getValuef()*attack.getValuef() * 2000;
  }
  
  private float getReleaseTime() {
    return 15 + release.getValuef() * 3000;
  }
  
  private LinearEnvelope getEnvelope(int index) {
    return cubeBrt[index % cubeBrt.length];
  }
  
  private SinLFO getBase(int index) {
    return base[index % base.length];
  }
    
  public boolean noteOn(Note note) {
    LinearEnvelope env = getEnvelope(note.getPitch());
    env.setEndVal(min(1, env.getValuef() + (note.getVelocity() / 127.f)), getAttackTime()).start();
    return true;
  }
  
  public boolean noteOff(Note note) {
    getEnvelope(note.getPitch()).setEndVal(0, getReleaseTime()).start();
    return true;
  }
  
  public void run(double deltaMs) {
    int i = 0;
    float huef = lx.getBaseHuef();
    float levelf = level.getValuef();
    for (Cube c : model.cubes) {
      float v = max(getBase(i).getValuef() * levelf/4.f, getEnvelope(i++).getValuef());
      setColor(c, lx.hsb(
        (huef + 20*v + abs(c.cx-model.xMax/2.f)*.3f + c.cy) % 360,
        min(100, 120*v),
        100*v
      ));
    }
  }
}

class CrossSections extends SCPattern {
  
  final SinLFO x = new SinLFO(0, model.xMax, 5000);
  final SinLFO y = new SinLFO(0, model.yMax, 6000);
  final SinLFO z = new SinLFO(0, model.zMax, 7000);
  
  final BasicParameter xw = new BasicParameter("XWID", 0.3f);
  final BasicParameter yw = new BasicParameter("YWID", 0.3f);
  final BasicParameter zw = new BasicParameter("ZWID", 0.3f);  
  final BasicParameter xr = new BasicParameter("XRAT", 0.7f);
  final BasicParameter yr = new BasicParameter("YRAT", 0.6f);
  final BasicParameter zr = new BasicParameter("ZRAT", 0.5f);
  final BasicParameter xl = new BasicParameter("XLEV", 1);
  final BasicParameter yl = new BasicParameter("YLEV", 1);
  final BasicParameter zl = new BasicParameter("ZLEV", 0.5f);

  
  CrossSections(GLucose glucose) {
    super(glucose);
    addModulator(x).trigger();
    addModulator(y).trigger();
    addModulator(z).trigger();
    addParams();
  }
  
  protected void addParams() {
    addParameter(xr);
    addParameter(yr);
    addParameter(zr);    
    addParameter(xw);
    addParameter(xl);
    addParameter(yl);
    addParameter(zl);
    addParameter(yw);    
    addParameter(zw);
  }
  
  public void onParameterChanged(LXParameter p) {
    if (p == xr) {
      x.setDuration(10000 - 8800*p.getValuef());
    } else if (p == yr) {
      y.setDuration(10000 - 9000*p.getValuef());
    } else if (p == zr) {
      z.setDuration(10000 - 9000*p.getValuef());
    }
  }
  
  float xv, yv, zv;
  
  protected void updateXYZVals() {
    xv = x.getValuef();
    yv = y.getValuef();
    zv = z.getValuef();    
  }

  public void run(double deltaMs) {
    updateXYZVals();
    
    float xlv = 100*xl.getValuef();
    float ylv = 100*yl.getValuef();
    float zlv = 100*zl.getValuef();
    
    float xwv = 100.f / (10 + 40*xw.getValuef());
    float ywv = 100.f / (10 + 40*yw.getValuef());
    float zwv = 100.f / (10 + 40*zw.getValuef());
    
    for (Point p : model.points) {
      int c = 0;
      c = blendColor(c, lx.hsb(
      (lx.getBaseHuef() + p.x/10 + p.y/3) % 360, 
      constrain(140 - 1.1f*abs(p.x - model.xMax/2.f), 0, 100), 
      max(0, xlv - xwv*abs(p.x - xv))
        ), ADD);
      c = blendColor(c, lx.hsb(
      (lx.getBaseHuef() + 80 + p.y/10) % 360, 
      constrain(140 - 2.2f*abs(p.y - model.yMax/2.f), 0, 100), 
      max(0, ylv - ywv*abs(p.y - yv))
        ), ADD); 
      c = blendColor(c, lx.hsb(
      (lx.getBaseHuef() + 160 + p.z / 10 + p.y/2) % 360, 
      constrain(140 - 2.2f*abs(p.z - model.zMax/2.f), 0, 100), 
      max(0, zlv - zwv*abs(p.z - zv))
        ), ADD); 
      colors[p.index] = c;
    }
  }
}

class Blinders extends SCPattern {
    
  final SinLFO[] m;
  final TriangleLFO r;
  final SinLFO s;
  final TriangleLFO hs;

  public Blinders(GLucose glucose) {
    super(glucose);
    m = new SinLFO[12];
    for (int i = 0; i < m.length; ++i) {  
      addModulator(m[i] = new SinLFO(0.5f, 120, (120000.f / (3+i)))).trigger();
    }
    addModulator(r = new TriangleLFO(9000, 15000, 29000)).trigger();
    addModulator(s = new SinLFO(-20, 275, 11000)).trigger();
    addModulator(hs = new TriangleLFO(0.1f, 0.5f, 15000)).trigger();
    s.modulateDurationBy(r);
  }

  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    int si = 0;
    for (Strip strip : model.strips) {
      int i = 0;
      float mv = m[si % m.length].getValuef();
      for (Point p : strip.points) {
        colors[p.index] = lx.hsb(
          (hv + p.z + p.y*hs.getValuef()) % 360, 
          min(100, abs(p.x - s.getValuef())/2.f), 
          max(0, 100 - mv/2.f - mv * abs(i - (strip.metrics.length-1)/2.f))
        );
        ++i;
      }
      ++si;
    }
  }
}

class Psychedelia extends SCPattern {
  
  final int NUM = 3;
  SinLFO m = new SinLFO(-0.5f, NUM-0.5f, 9000);
  SinLFO s = new SinLFO(-20, 147, 11000);
  TriangleLFO h = new TriangleLFO(0, 240, 19000);
  SinLFO c = new SinLFO(-.2f, .8f, 31000);

  Psychedelia(GLucose glucose) {
    super(glucose);
    addModulator(m).trigger();
    addModulator(s).trigger();
    addModulator(h).trigger();
    addModulator(c).trigger();
  }

  public void run(double deltaMs) {
    float huev = h.getValuef();
    float cv = c.getValuef();
    float sv = s.getValuef();
    float mv = m.getValuef();
    int i = 0;
    for (Strip strip : model.strips) {
      for (Point p : strip.points) {
        colors[p.index] = lx.hsb(
          (huev + i*constrain(cv, 0, 2) + p.z/2.f + p.x/4.f) % 360, 
          min(100, abs(p.y-sv)), 
          max(0, 100 - 50*abs((i%NUM) - mv))
        );
      }
      ++i;
    }
  }
}

class AskewPlanes extends SCPattern {
  
  class Plane {
    private final SinLFO a;
    private final SinLFO b;
    private final SinLFO c;
    float av = 1;
    float bv = 1;
    float cv = 1;
    float denom = 0.1f;
    
    Plane(int i) {
      addModulator(a = new SinLFO(-1, 1, 4000 + 1029*i)).trigger();
      addModulator(b = new SinLFO(-1, 1, 11000 - 1104*i)).trigger();
      addModulator(c = new SinLFO(-50, 50, 4000 + 1000*i * ((i % 2 == 0) ? 1 : -1))).trigger();      
    }
    
    public void run(double deltaMs) {
      av = a.getValuef();
      bv = b.getValuef();
      cv = c.getValuef();
      denom = sqrt(av*av + bv*bv);
    }
  }
    
  final Plane[] planes;
  final int NUM_PLANES = 3;
  
  AskewPlanes(GLucose glucose) {
    super(glucose);
    planes = new Plane[NUM_PLANES];
    for (int i = 0; i < planes.length; ++i) {
      planes[i] = new Plane(i);
    }
  }
  
  public void run(double deltaMs) {
    float huev = lx.getBaseHuef();
    
    // This is super fucking bizarre. But if this is a for loop, the framerate
    // tanks to like 30FPS, instead of 60. Call them manually and it works fine.
    // Doesn't make ANY sense... there must be some weird side effect going on
    // with the Processing internals perhaps?
//    for (Plane plane : planes) {
//      plane.run(deltaMs);
//    }
    planes[0].run(deltaMs);
    planes[1].run(deltaMs);
    planes[2].run(deltaMs);    
    
    for (Point p : model.points) {
      float d = MAX_FLOAT;
      for (Plane plane : planes) {
        if (plane.denom != 0) {
          d = min(d, abs(plane.av*(p.x-model.cx) + plane.bv*(p.y-model.cy) + plane.cv) / plane.denom);
        }
      }
      colors[p.index] = lx.hsb(
        (huev + abs(p.x-model.cx)*.3f + p.y*.8f) % 360,
        max(0, 100 - .8f*abs(p.x - model.cx)),
        constrain(140 - 10.f*d, 0, 100)
      );
    }
  }
}

class ShiftingPlane extends SCPattern {

  final SinLFO a = new SinLFO(-.2f, .2f, 5300);
  final SinLFO b = new SinLFO(1, -1, 13300);
  final SinLFO c = new SinLFO(-1.4f, 1.4f, 5700);
  final SinLFO d = new SinLFO(-10, 10, 9500);

  ShiftingPlane(GLucose glucose) {
    super(glucose);
    addModulator(a).trigger();
    addModulator(b).trigger();
    addModulator(c).trigger();
    addModulator(d).trigger();    
  }
  
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    float av = a.getValuef();
    float bv = b.getValuef();
    float cv = c.getValuef();
    float dv = d.getValuef();    
    float denom = sqrt(av*av + bv*bv + cv*cv);
    for (Point p : model.points) {
      float d = abs(av*(p.x-model.cx) + bv*(p.y-model.cy) + cv*(p.z-model.cz) + dv) / denom;
      colors[p.index] = lx.hsb(
        (hv + abs(p.x-model.cx)*.6f + abs(p.y-model.cy)*.9f + abs(p.z - model.cz)) % 360,
        constrain(110 - d*6, 0, 100),
        constrain(130 - 7*d, 0, 100)
      );
    }
  }
}

class Traktor extends SCPattern {

  final int FRAME_WIDTH = 60;
  
  final BasicParameter speed = new BasicParameter("SPD", 0.5f);
  
  private float[] bass = new float[FRAME_WIDTH];
  private float[] treble = new float[FRAME_WIDTH];
    
  private int index = 0;
  private GraphicEQ eq = null;

  public Traktor(GLucose glucose) {
    super(glucose);
    for (int i = 0; i < FRAME_WIDTH; ++i) {
      bass[i] = 0;
      treble[i] = 0;
    }
    addParameter(speed);
  }

  public void onActive() {
    if (eq == null) {
      eq = new GraphicEQ(lx, 16);
      eq.slope.setValue(0.6f);
      eq.level.setValue(0.65f);
      eq.range.setValue(0.35f);
      eq.release.setValue(0.4f);
      addParameter(eq.level);
      addParameter(eq.range);
      addParameter(eq.attack);
      addParameter(eq.release);
      addParameter(eq.slope);
    }
  }

  int counter = 0;
  
  public void run(double deltaMs) {
    eq.run(deltaMs);
    
    int stepThresh = (int) (40 - 39*speed.getValuef());
    counter += deltaMs;
    if (counter < stepThresh) {
      return;
    }
    counter = counter % stepThresh;

    index = (index + 1) % FRAME_WIDTH;
    
    float rawBass = eq.getAverageLevel(0, 4);
    float rawTreble = eq.getAverageLevel(eq.numBands-7, 7);
    
    bass[index] = rawBass * rawBass * rawBass * rawBass;
    treble[index] = rawTreble * rawTreble;

    for (Point p : model.points) {
      int i = (int) constrain((model.xMax - p.x) / model.xMax * FRAME_WIDTH, 0, FRAME_WIDTH-1);
      int pos = (index + FRAME_WIDTH - i) % FRAME_WIDTH;
      
      colors[p.index] = lx.hsb(
        (360 + lx.getBaseHuef() + .8f*abs(p.x-model.cx)) % 360,
        100,
        constrain(9 * (bass[pos]*model.cy - abs(p.y - model.cy + 5)), 0, 100)
      );
      colors[p.index] = blendColor(colors[p.index], lx.hsb(
        (400 + lx.getBaseHuef() + .5f*abs(p.x-model.cx)) % 360,
        60,
        constrain(5 * (treble[pos]*.6f*model.cy - abs(p.y - model.cy)), 0, 100)

      ), ADD);
    }
  }
}

class ColorFuckerEffect extends SCEffect {
  
  final BasicParameter level = new BasicParameter("BRT", 1);
  final BasicParameter desat = new BasicParameter("DSAT", 0);
  final BasicParameter hueShift = new BasicParameter("HSHFT", 0);
  final BasicParameter sharp = new BasicParameter("SHARP", 0);
  final BasicParameter soft = new BasicParameter("SOFT", 0);
  final BasicParameter mono = new BasicParameter("MONO", 0);
  final BasicParameter invert = new BasicParameter("INVERT", 0);

  
  float[] hsb = new float[3];
  
  ColorFuckerEffect(GLucose glucose) {
    super(glucose);
    addParameter(level);
    addParameter(desat);
    addParameter(sharp);
    addParameter(hueShift);
    addParameter(soft);
    addParameter(mono);
    addParameter(invert);
  }
  
  public void apply(int[] colors) {
    if (!enabled) {
      return;
    }
    float bMod = level.getValuef();
    float sMod = 1 - desat.getValuef();
    float hMod = hueShift.getValuef();
    float fSharp = 1/(1.0001f-sharp.getValuef());
    float fSoft = soft.getValuef();
    boolean mon = mono.getValuef() > 0.5f;
    boolean ivt = invert.getValuef() > 0.5f;
    if (bMod < 1 || sMod < 1 || hMod > 0 || fSharp > 0 || ivt || mon || fSoft > 0) {
      for (int i = 0; i < colors.length; ++i) {
        lx.RGBtoHSB(colors[i], hsb);
        if (mon) {
          hsb[0] = lx.getBaseHuef() / 360.f;
        }
        if (ivt) {
          hsb[2] = 1 - hsb[2];
        }
        if (fSharp > 0) {
          hsb[2] = hsb[2] < .5f ? pow(hsb[2],fSharp) : 1-pow(1-hsb[2],fSharp);
        }
        if (fSoft > 0) {
          if (hsb[2] > 0.5f) {
            hsb[2] = lerp(hsb[2], 0.5f + 2 * (hsb[2]-0.5f)*(hsb[2]-0.5f), fSoft);
          } else {
            hsb[2] = lerp(hsb[2], 0.5f * sqrt(2*hsb[2]), fSoft);
          }
        }
        colors[i] = lx.hsb(
          (360.f * hsb[0] + hMod*360.f) % 360,
          100.f * hsb[1] * sMod,
          100.f * hsb[2] * bMod
        );
      }
    }
  }
}

class QuantizeEffect extends SCEffect {
  
  int[] quantizedFrame;
  float lastQuant;
  final BasicParameter amount = new BasicParameter("AMT", 0);
  
  QuantizeEffect(GLucose glucose) {
    super(glucose);
    quantizedFrame = new int[glucose.lx.total];
    lastQuant = 0;
  } 
  
  public void apply(int[] colors) {
    float fQuant = amount.getValuef();
    if (fQuant > 0) {
      float tRamp = (lx.tempo.rampf() % (1.f/pow(2,floor((1-fQuant) * 4))));
      float f = lastQuant;
      lastQuant = tRamp;
      if (tRamp > f) {
        for (int i = 0; i < colors.length; ++i) {
          colors[i] = quantizedFrame[i];
        }
        return;
      }
    }
    for (int i = 0; i < colors.length; ++i) {
      quantizedFrame[i] = colors[i];
    }
  }
}

class BlurEffect extends SCEffect {
  
  final LXParameter amount = new BasicParameter("AMT", 0);
  final int[] frame;
  final LinearEnvelope env = new LinearEnvelope(0, 1, 100);
  
  BlurEffect(GLucose glucose) {
    super(glucose);
    addParameter(amount);
    addModulator(env);
    frame = new int[lx.total];
    for (int i = 0; i < frame.length; ++i) {
      frame[i] = 0xff000000;
    }
  }
  
  public void onEnable() {
    env.setRangeFromHereTo(1, 400).start();
    for (int i = 0; i < frame.length; ++i) {
      frame[i] = 0xff000000;
    }
  }
  
  public void onDisable() {
    env.setRangeFromHereTo(0, 1000).start();
  }
  
  public void apply(int[] colors) {
    float amt = env.getValuef() * amount.getValuef();
    if (amt > 0) {    
      amt = (1 - amt);
      amt = 1 - (amt*amt*amt);
      for (int i = 0; i < colors.length; ++i) {
        // frame[i] = colors[i] = blendColor(colors[i], lerpColor(#000000, frame[i], amt, RGB), SCREEN);
        frame[i] = colors[i] = lerpColor(colors[i], blendColor(colors[i], frame[i], SCREEN), amt, RGB);
      }
    }
      
  }  
}
abstract class SamPattern extends SCPattern {
  public SamPattern(GLucose glucose) {
    super(glucose);
    setEligible(false);
  }
}

class JazzRainbow extends SamPattern {
  public JazzRainbow(GLucose glucose) {
    super(glucose);
  }

  
  public void run(double deltaMs) {
    // Access the core master hue via this method call
    float hv = lx.getBaseHuef();
    for (int i = 0; i < colors.length*5; i=i+27) {
      float a = hv%250;
      if (i%2 == 0) {
        for (int b = 0; b < 70; b++) {
         colors[(i+b)%colors.length] = lx.hsb(a+i%250, 100, b*a%100);
        }
      }
    }
  } 
}



class HelixPattern extends SCPattern {

  // Stores a line in point + vector form
  private class Line {
    private final PVector origin;
    private final PVector vector;

    Line(PVector pt, PVector v) {
      origin = pt;
      vector = v.get();
      vector.normalize();
    }

    public PVector getPoint() {
      return origin;
    }

    public PVector getVector() {
      return vector;
    }

    public PVector getPointAt(final float t) {
      return PVector.add(origin, PVector.mult(vector, t));
    }

    public boolean isColinear(final PVector pt) {
      PVector projected = projectPoint(pt);
      return projected.x==pt.x && projected.y==pt.y && projected.z==pt.z;
    }

    public float getTValue(final PVector pt) {
      PVector subtraction = PVector.sub(pt, origin);
      return subtraction.dot(vector);
    }

    public PVector projectPoint(final PVector pt) {
      return getPointAt(getTValue(pt));
    }

    public PVector rotatePoint(final PVector p, final float t) {
      final PVector o = origin;
      final PVector v = vector;
      
      final float cost = cos(t);
      final float sint = sin(t);

      float x = (o.x*(v.y*v.y + v.z*v.z) - v.x*(o.y*v.y + o.z*v.z - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cost) + p.x*cost + (-o.z*v.y + o.y*v.z - v.z*p.y + v.y*p.z)*sint;
      float y = (o.y*(v.x*v.x + v.z*v.z) - v.y*(o.x*v.x + o.z*v.z - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cost) + p.y*cost + (o.z*v.x - o.x*v.z + v.z*p.x - v.x*p.z)*sint;
      float z = (o.z*(v.x*v.x + v.y*v.y) - v.z*(o.x*v.x + o.y*v.y - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cost) + p.z*cost + (-o.y*v.x + o.x*v.y - v.y*p.x + v.x*p.y)*sint;
      return new PVector(x, y, z);
    }
  }

  private class Helix {
    private final Line axis;
    private final float period; // period of coil
    private final float rotationPeriod; // animation period
    private final float radius; // radius of coil
    private final float girth; // girth of coil
    private final PVector referencePoint;
    private float phase;
    private PVector phaseNormal;

    Helix(Line axis, float period, float radius, float girth, float phase, float rotationPeriod) {
      this.axis = axis;
      this.period = period;
      this.radius = radius;
      this.girth = girth;
      this.phase = phase;
      this.rotationPeriod = rotationPeriod;

      // Generate a normal that will rotate to
      // produce the helical shape.
      PVector pt = new PVector(0, 1, 0);
      if (this.axis.isColinear(pt)) {
        pt = new PVector(0, 0, 1);
        if (this.axis.isColinear(pt)) {
          pt = new PVector(0, 1, 1);
        }
      }

      this.referencePoint = pt;

      // The normal is calculated by the cross product of the axis
      // and a random point that is not colinear with it.
      phaseNormal = axis.getVector().cross(referencePoint);
      phaseNormal.normalize();
      phaseNormal.mult(radius);
    }

    public Line getAxis() {
      return axis;
    }
    
    public PVector getPhaseNormal() {
      return phaseNormal;
    }
    
    public float getPhase() {
      return phase;
    }

    public void step(double deltaMs) {
      // Rotate
      if (rotationPeriod != 0) {
        this.phase = (phase + ((float)deltaMs / (float)rotationPeriod) * TWO_PI);
      }
    }

    public PVector pointOnToroidalAxis(float t) {
      PVector p = axis.getPointAt(t);
      PVector middle = PVector.add(p, phaseNormal);
      return axis.rotatePoint(middle, (t / period) * TWO_PI + phase);
    }
    
    private float myDist(PVector p1, PVector p2) {
      final float x = p2.x-p1.x;
      final float y = p2.y-p1.y;
      final float z = p2.z-p1.z;
      return sqrt(x*x + y*y + z*z);
    }

    public int colorOfPoint(final PVector p) {
      final float t = axis.getTValue(p);
      final PVector axisPoint = axis.getPointAt(t);

      // For performance reasons, cut out points that are outside of
      // the tube where the toroidal coil lives.
      if (abs(myDist(p, axisPoint) - radius) > girth*.5f) {
        return lx.hsb(0,0,0);
      }

      // Find the appropriate point for the current rotation
      // of the helix.
      PVector toroidPoint = axisPoint;
      toroidPoint.add(phaseNormal);
      toroidPoint = axis.rotatePoint(toroidPoint, (t / period) * TWO_PI + phase);

      // The rotated point represents the middle of the girth of
      // the helix.  Figure out if the current point is inside that
      // region.
      float d = myDist(p, toroidPoint);

      // Soften edges by fading brightness.
      float b = constrain(100*(1 - ((d-.5f*girth)/(girth*.5f))), 0, 100);
      return lx.hsb((lx.getBaseHuef() + (360*(phase / TWO_PI)))%360, 80, b);
    }
  }
  
  private class BasePairInfo {
    Line line;
    float colorPhase1;
    float colorPhase2;
    
    BasePairInfo(Line line, float colorPhase1, float colorPhase2) {
      this.line = line;
      this.colorPhase1 = colorPhase1;
      this.colorPhase2 = colorPhase2;
    }
  }

  private final Helix h1;
  private final Helix h2;
  private final BasePairInfo[] basePairs;

  private final BasicParameter helix1On = new BasicParameter("H1ON", 1);
  private final BasicParameter helix2On = new BasicParameter("H2ON", 1);
  private final BasicParameter basePairsOn = new BasicParameter("BPON", 1);

  private static final float helixCoilPeriod = 100;
  private static final float helixCoilRadius = 50;
  private static final float helixCoilGirth = 30;
  private static final float helixCoilRotationPeriod = 5000;

  private static final float spokePeriod = 40;
  private static final float spokeGirth = 20;
  private static final float spokePhase = 10;
  private static final float spokeRadius = helixCoilRadius - helixCoilGirth*.5f;
  
  private static final float tMin = -200;
  private static final float tMax = 200;

  public HelixPattern(GLucose glucose) {
    super(glucose);

    addParameter(helix1On);
    addParameter(helix2On);
    addParameter(basePairsOn);

    PVector origin = new PVector(100, 50, 55);
    PVector axis = new PVector(1,0,0);

    h1 = new Helix(
      new Line(origin, axis),
      helixCoilPeriod,
      helixCoilRadius,
      helixCoilGirth,
      0,
      helixCoilRotationPeriod);
    h2 = new Helix(
      new Line(origin, axis),
      helixCoilPeriod,
      helixCoilRadius,
      helixCoilGirth,
      PI,
      helixCoilRotationPeriod);
      
    basePairs = new BasePairInfo[(int)floor((tMax - tMin)/spokePeriod)];
  }

  private void calculateSpokes() {
    float colorPhase = PI/6;
    for (float t = tMin + spokePhase; t < tMax; t += spokePeriod) {
      int spokeIndex = (int)floor((t - tMin)/spokePeriod);
      PVector h1point = h1.pointOnToroidalAxis(t);
      PVector spokeCenter = h1.getAxis().getPointAt(t);
      PVector spokeVector = PVector.sub(h1point, spokeCenter);
      Line spokeLine = new Line(spokeCenter, spokeVector);
      basePairs[spokeIndex] = new BasePairInfo(spokeLine, colorPhase * spokeIndex, colorPhase * (spokeIndex + 1));
    }
  }
  
  private int calculateSpokeColor(final PVector pt) {
    // Find the closest spoke's t-value and calculate its
    // axis.  Until everything animates in the model reference
    // frame, this has to be calculated at every step because
    // the helices rotate.
    Line axis = h1.getAxis();
    float t = axis.getTValue(pt) + spokePhase;
    int spokeIndex = (int)floor((t - tMin + spokePeriod/2) / spokePeriod);
    if (spokeIndex < 0 || spokeIndex >= basePairs.length) {
      return lx.hsb(0,0,0);
    }
    BasePairInfo basePair = basePairs[spokeIndex];
    Line spokeLine = basePair.line;
    PVector pointOnSpoke = spokeLine.projectPoint(pt);
    float d = PVector.dist(pt, pointOnSpoke);
    float b = (PVector.dist(pointOnSpoke, spokeLine.getPoint()) < spokeRadius) ? constrain(100*(1 - ((d-.5f*spokeGirth)/(spokeGirth*.5f))), 0, 100) : 0.f;
    float phase = spokeLine.getTValue(pointOnSpoke) < 0 ? basePair.colorPhase1 : basePair.colorPhase2;
    return lx.hsb((lx.getBaseHuef() + (360*(phase / TWO_PI)))%360, 80.f, b);
  }

  public void run(double deltaMs) {
    boolean h1on = helix1On.getValue() > 0.5f;
    boolean h2on = helix2On.getValue() > 0.5f;
    boolean spokesOn = (float)basePairsOn.getValue() > 0.5f;

    h1.step(deltaMs);
    h2.step(deltaMs);
    calculateSpokes();

    for (Point p : model.points) {
      PVector pt = new PVector(p.x,p.y,p.z);
      int h1c = h1.colorOfPoint(pt);
      int h2c = h2.colorOfPoint(pt);
      int spokeColor = calculateSpokeColor(pt);

      if (!h1on) {
        h1c = lx.hsb(0,0,0);
      }

      if (!h2on) {
        h2c = lx.hsb(0,0,0);
      }

      if (!spokesOn) {
        spokeColor = lx.hsb(0,0,0);
      }

      // The helices are positioned to not overlap.  If that changes,
      // a better blending formula is probably needed.
      colors[p.index] = blendColor(blendColor(h1c, h2c, ADD), spokeColor, ADD);
    }
  }
}

class BlankPattern extends SCPattern {
  BlankPattern(GLucose glucose) {
    super(glucose);
  }
  
  public void run(double deltaMs) {
    setColors(0xff000000);
  }
}

abstract class TestPattern extends SCPattern {
  public TestPattern(GLucose glucose) {
    super(glucose);
    setEligible(false);
  }
}

class TestSpeakerMapping extends TestPattern {
  TestSpeakerMapping(GLucose glucose) {
    super(glucose);
  }
  
  public void run(double deltaMs) {
    int h = 0;
    for (Speaker speaker : model.speakers) {
      for (Strip strip : speaker.strips) {
        float b = 100;
        for (Point p : strip.points) {
          colors[p.index] = lx.hsb(h % 360, 100, b);
          b = max(0, b - 10);
        }
        h += 70;
      }
    }
  }

}

class TestBassMapping extends TestPattern {
  TestBassMapping(GLucose glucose) {
    super(glucose);
  }
  
  public void run(double deltaMs) {
    int[] strips = { 2, 1, 0, 3, 13, 12, 15, 14, 9, 8, 11, 10, 5, 4, 7, 6 };
    int h = 0;
    for (int si : strips) {
      float b = 100;
      for (Point p : model.bassBox.strips.get(si).points) {
        colors[p.index] = lx.hsb(h % 360, 100, b);
        b = max(0, b - 10);
      }
      h += 70;
    }
  }
}

class TestFloorMapping extends TestPattern {
  TestFloorMapping(GLucose glucose) {
    super(glucose);
  }

  public void run(double deltaMs) {
    int[] strutIndices = {6, 5, 4, 3, 2, 1, 0, 7};
    int h = 0;
    for (int si : strutIndices) {
      float b = 100;
      for (Point p : model.bassBox.struts.get(si).points) {
        colors[p.index] = lx.hsb(h % 360, 100, b);
        b = max(0, b - 10);
      }
      h += 50;
    }
    int[] floorIndices = {0, 1, 2, 3};
    h = 0;
    for (int fi : floorIndices) {
      float b = 100;
      for (Point p : model.boothFloor.strips.get(fi).points) {
        colors[p.index] = lx.hsb(h, 100, b);
        b = max(0, b - 3);
      }
      h += 90;
    }
  }
}

class TestPerformancePattern extends TestPattern {
  
  final BasicParameter ops = new BasicParameter("OPS", 0);
  final BasicParameter iter = new BasicParameter("ITER", 0);
  
  TestPerformancePattern(GLucose glucose) {
    super(glucose);
    addParameter(ops);
    addParameter(iter);
  }
  
  public void run(double deltaMs) {
    float x = 1;
    for (int j = 0; j < ops.getValuef() * 400000; ++j) {
      x *= random(0, 1);
    }

    if (iter.getValuef() < 0.25f) {
      for (Point p : model.points) {
        colors[p.index] = lx.hsb(
          (p.x*.1f + p.y*.1f) % 360,
          100,
          100
        );
      }
    } else if (iter.getValuef() < 0.5f) {
      for (int i = 0; i < colors.length; ++i) {
        colors[i] = lx.hsb(
          (90 + model.px[i]*.1f + model.py[i]*.1f) % 360,
          100,
          100
        );
      }
    } else if (iter.getValuef() < 0.75f) {
      for (int i = 0; i < colors.length; ++i) {
        colors[i] = lx.hsb(
          (180 + model.p[3*i]*.1f + model.p[3*i+1]*.1f) % 360,
          100,
          100
        );
      }
    } else {
      for (int i = 0; i < colors.length; ++i) {
        colors[i] = lx.hsb(
          (270 + model.x(i)*.1f + model.y(i)*.1f) % 360,
          100,
          100
        );
      }
    }
  }
}

class TestStripPattern extends TestPattern {
  
  SinLFO d = new SinLFO(4, 40, 4000);
  
  public TestStripPattern(GLucose glucose) {
    super(glucose);
    addModulator(d).trigger();
  }
  
  public void run(double deltaMs) {
    for (Strip s : model.strips) {
      for (Point p : s.points) {
        colors[p.index] = lx.hsb(
          lx.getBaseHuef(),
          100,
          max(0, 100 - d.getValuef()*dist(p.x, p.y, s.cx, s.cy))
        );
      }
    }
  }
}

/**
 * Simplest demonstration of using the rotating master hue.
 * All pixels are full-on the same color.
 */
class TestHuePattern extends TestPattern {
  public TestHuePattern(GLucose glucose) {
    super(glucose);
  }
  
  public void run(double deltaMs) {
    // Access the core master hue via this method call
    float hv = lx.getBaseHuef();
    for (int i = 0; i < colors.length; ++i) {
      colors[i] = lx.hsb(hv, 100, 100);
    }
  } 
}

/**
 * Test of a wave moving across the X axis.
 */
class TestXPattern extends TestPattern {
  private final SinLFO xPos = new SinLFO(0, model.xMax, 4000);
  public TestXPattern(GLucose glucose) {
    super(glucose);
    addModulator(xPos).trigger();
  }
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    for (Point p : model.points) {
      // This is a common technique for modulating brightness.
      // You can use abs() to determine the distance between two
      // values. The further away this point is from an exact
      // point, the more we decrease its brightness
      float bv = max(0, 100 - abs(p.x - xPos.getValuef()));
      colors[p.index] = lx.hsb(hv, 100, bv);
    }
  }
}

/**
 * Test of a wave on the Y axis.
 */
class TestYPattern extends TestPattern {
  private final SinLFO yPos = new SinLFO(0, model.yMax, 4000);
  public TestYPattern(GLucose glucose) {
    super(glucose);
    addModulator(yPos).trigger();
  }
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    for (Point p : model.points) {
      float bv = max(0, 100 - abs(p.y - yPos.getValuef()));
      colors[p.index] = lx.hsb(hv, 100, bv);
    }
  }
}

/**
 * Test of a wave on the Z axis.
 */
class TestZPattern extends TestPattern {
  private final SinLFO zPos = new SinLFO(0, model.zMax, 4000);
  public TestZPattern(GLucose glucose) {
    super(glucose);
    addModulator(zPos).trigger();
  }
  public void run(double deltaMs) {
    float hv = lx.getBaseHuef();
    for (Point p : model.points) {
      float bv = max(0, 100 - abs(p.z - zPos.getValuef()));
      colors[p.index] = lx.hsb(hv, 100, bv);
    }
  }
}

/**
 * This shows how to iterate over towers, enumerated in the model.
 */
class TestTowerPattern extends TestPattern {
  private final SawLFO towerIndex = new SawLFO(0, model.towers.size(), 1000*model.towers.size());
  
  public TestTowerPattern(GLucose glucose) {
    super(glucose);
    addModulator(towerIndex).trigger();
  }

  public void run(double deltaMs) {
    int ti = 0;
    for (Tower t : model.towers) {
      for (Point p : t.points) {
        colors[p.index] = lx.hsb(
          lx.getBaseHuef(),
          100,
          max(0, 100 - 80*LXUtils.wrapdistf(ti, towerIndex.getValuef(), model.towers.size()))
        );
      }
      ++ti;
    }
  }
  
}

/**
 * This is a demonstration of how to use the projection library. A projection
 * creates a mutation of the coordinates of all the points in the model, creating
 * virtual x,y,z coordinates. In effect, this is like virtually rotating the entire
 * art car. However, since in reality the car does not move, the result is that
 * it appears that the object we are drawing on the car is actually moving.
 *
 * Keep in mind that what we are creating a projection of is the view coordinates.
 * Depending on your intuition, some operations may feel backwards. For instance,
 * if you translate the view to the right, it will make it seem that the object
 * you are drawing has moved to the left. If you scale the view up 2x, objects
 * drawn with the same absolute values will seem to be half the size.
 *
 * If this feels counterintuitive at first, don't worry. Just remember that you
 * are moving the pixels, not the structure. We're dealing with a finite set
 * of sparse, non-uniformly spaced pixels. Mutating the structure would move
 * things to a space where there are no pixels in 99% of the cases.
 */
class TestProjectionPattern extends TestPattern {
  
  private final Projection projection;
  private final SawLFO angle = new SawLFO(0, TWO_PI, 9000);
  private final SinLFO yPos = new SinLFO(-20, 40, 5000);
  
  public TestProjectionPattern(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);
    addModulator(angle).trigger();
    addModulator(yPos).trigger();
  }
  
  public void run(double deltaMs) {
    // For the same reasons described above, it may logically feel to you that
    // some of these operations are in reverse order. Again, just keep in mind that
    // the car itself is what's moving, not the object
    projection.reset(model)
    
      // Translate so the center of the car is the origin, offset by yPos
      .translateCenter(model, 0, yPos.getValuef(), 0)

      // Rotate around the origin (now the center of the car) about an X-vector
      .rotate(angle.getValuef(), 1, 0, 0)

      // Scale up the Y axis (objects will look smaller in that access)
      .scale(1, 1.5f, 1);

    float hv = lx.getBaseHuef();
    for (Coord c : projection) {
      float d = sqrt(c.x*c.x + c.y*c.y + c.z*c.z); // distance from origin
      // d = abs(d-60) + max(0, abs(c.z) - 20); // life saver / ring thing
      d = max(0, abs(c.y) - 10 + .1f*abs(c.z) + .02f*abs(c.x)); // plane / spear thing
      colors[c.index] = lx.hsb(
        (hv + .6f*abs(c.x) + abs(c.z)) % 360,
        100,
        constrain(140 - 40*d, 0, 100)
      );
    }
  } 
}

class TestCubePattern extends TestPattern {
  
  private SawLFO index = new SawLFO(0, Cube.POINTS_PER_CUBE, Cube.POINTS_PER_CUBE*60);
  
  TestCubePattern(GLucose glucose) {
    super(glucose);
    addModulator(index).start();
  }
  
  public void run(double deltaMs) {
    for (Cube c : model.cubes) {
      int i = 0;
      for (Point p : c.points) {
        colors[p.index] = lx.hsb(
          lx.getBaseHuef(),
          100,
          max(0, 100 - 80.f*abs(i - index.getValuef()))
        );
        ++i;
      }
    }
  }
}

class MappingTool extends TestPattern {
    
  private int cubeIndex = 0;
  private int stripIndex = 0;
  private int channelIndex = 0;

  public final int MAPPING_MODE_ALL = 0;
  public final int MAPPING_MODE_CHANNEL = 1;
  public final int MAPPING_MODE_SINGLE_CUBE = 2;
  public int mappingMode = MAPPING_MODE_ALL;

  public final int CUBE_MODE_ALL = 0;
  public final int CUBE_MODE_SINGLE_STRIP = 1;
  public final int CUBE_MODE_STRIP_PATTERN = 2;
  public int cubeMode = CUBE_MODE_ALL;

  public boolean channelModeRed = true;
  public boolean channelModeGreen = false;
  public boolean channelModeBlue = false;
  
  private final int numChannels;
  
  private final PandaMapping[] pandaMappings;
  private PandaMapping activePanda;
  private ChannelMapping activeChannel;
  
  MappingTool(GLucose glucose, PandaMapping[] pandaMappings) {
    super(glucose);
    this.pandaMappings = pandaMappings;
    numChannels = pandaMappings.length * PandaMapping.CHANNELS_PER_BOARD;
    setChannel();
  }

  public int numChannels() {
    return numChannels;
  }
  
  private void setChannel() {
    activePanda = pandaMappings[channelIndex / PandaMapping.CHANNELS_PER_BOARD];
    activeChannel = activePanda.channelList[channelIndex % PandaMapping.CHANNELS_PER_BOARD];
  }
  
  private int indexOfCubeInChannel(Cube c) {
    if (activeChannel.mode == ChannelMapping.MODE_CUBES) {
      int i = 1;
      for (int index : activeChannel.objectIndices) {
        if ((index >= 0) && (c == model.getCubeByRawIndex(index))) {
          return i;
        }
        ++i;
      }
    }
    return 0;
  }
  
  private void printInfo() {
    println("Cube:" + cubeIndex + " Strip:" + (stripIndex+1));
  }
  
  public void cube(int delta) {
    int len = model.cubes.size();
    cubeIndex = (len + cubeIndex + delta) % len;
    printInfo();
  }
  
  public void strip(int delta) {
    int len = Cube.STRIPS_PER_CUBE;
    stripIndex = (len + stripIndex + delta) % len;
    printInfo();
  }
  
  public void run(double deltaMs) {
    int off = 0xff000000;
    int c = off;
    int r = 0xffFF0000;
    int g = 0xff00FF00;
    int b = 0xff0000FF;
    if (channelModeRed) c |= r;
    if (channelModeGreen) c |= g;
    if (channelModeBlue) c |= b;
    
    int ci = 0;
    for (Cube cube : model.cubes) {
      boolean cubeOn = false;
      int indexOfCubeInChannel = indexOfCubeInChannel(cube);
      switch (mappingMode) {
        case MAPPING_MODE_ALL: cubeOn = true; break;
        case MAPPING_MODE_SINGLE_CUBE: cubeOn = (cubeIndex == ci); break;
        case MAPPING_MODE_CHANNEL: cubeOn = (indexOfCubeInChannel > 0); break;
      }
      if (cubeOn) {
        if (mappingMode == MAPPING_MODE_CHANNEL) {
          int cc = off;
          switch (indexOfCubeInChannel) {
            case 1: cc = r; break;
            case 2: cc = r|g; break;
            case 3: cc = g; break;
            case 4: cc = b; break;
            case 5: cc = r|b; break;
          }
          setColor(cube, cc);
        } else if (cubeMode == CUBE_MODE_STRIP_PATTERN) {
          int si = 0;
          int sc = off;
          for (Strip strip : cube.strips) {
            int faceI = si / Face.STRIPS_PER_FACE;
            switch (faceI) {
              case 0: sc = r; break;
              case 1: sc = g; break;
              case 2: sc = b; break;
              case 3: sc = r|g|b; break;
            }
            if (si % Face.STRIPS_PER_FACE == 2) {
              sc = r|g;
            }
            setColor(strip, sc);
            ++si;
          }
        } else if (cubeMode == CUBE_MODE_SINGLE_STRIP) {
          setColor(cube, off);
          setColor(cube.strips.get(stripIndex), c);
        } else {
          setColor(cube, c);
        }
      } else {
        setColor(cube, off);
      }
      ++ci;
    }
  }
  
  public void setCube(int index) {
    cubeIndex = index % model.cubes.size();
  }
  
  public void incCube() {
    cubeIndex = (cubeIndex + 1) % model.cubes.size();
  }
  
  public void decCube() {
    --cubeIndex;
    if (cubeIndex < 0) {
      cubeIndex += model.cubes.size();
    }
  }
  
  public void setChannel(int index) {
    channelIndex = index % numChannels;
    setChannel();
  }

  public void incChannel() {
    channelIndex = (channelIndex + 1) % numChannels;
    setChannel();
  }
  
  public void decChannel() {
    channelIndex = (channelIndex + numChannels - 1) % numChannels;
    setChannel();    
  }
  
  public void setStrip(int index) {
    stripIndex = index % Cube.STRIPS_PER_CUBE;
  }
  
  public void incStrip() {
    stripIndex = (stripIndex + 1) % Cube.STRIPS_PER_CUBE;
  }
  
  public void decStrip() {
    stripIndex = (stripIndex + Cube.STRIPS_PER_CUBE - 1) % Cube.STRIPS_PER_CUBE;
  }
  
  public void keyPressed(UIMapping uiMapping) {
    switch (keyCode) {
      case UP: if (mappingMode == MAPPING_MODE_CHANNEL) incChannel(); else incCube(); break;
      case DOWN: if (mappingMode == MAPPING_MODE_CHANNEL) decChannel(); else decCube(); break;
      case LEFT: decStrip(); break;
      case RIGHT: incStrip(); break;
    }
    switch (key) {
      case 'r': channelModeRed = !channelModeRed; break;
      case 'g': channelModeGreen = !channelModeGreen; break;
      case 'b': channelModeBlue = !channelModeBlue; break;
    }
    uiMapping.setChannelID(channelIndex+1);
    uiMapping.setCubeID(cubeIndex+1);
    uiMapping.setStripID(stripIndex+1);
    uiMapping.redraw();
  }

}
/**
 * Not very flushed out, but kind of fun nonetheless.
 */
class TimSpheres extends SCPattern {
  private BasicParameter hueParameter = new BasicParameter("RAD", 1.0f);
  private final SawLFO lfo = new SawLFO(0, 1, 10000);
  private final SinLFO sinLfo = new SinLFO(0, 1, 4000);
  private final float centerX, centerY, centerZ;
  
  class Sphere {
    float x, y, z;
    float radius;
    float hue;
  }
  
  private final Sphere[] spheres;
  
  public TimSpheres(GLucose glucose) {
    super(glucose);
    addParameter(hueParameter);
    addModulator(lfo).trigger();
    addModulator(sinLfo).trigger();
    centerX = (model.xMax + model.xMin) / 2;
    centerY = (model.yMax + model.yMin) / 2;
    centerZ = (model.zMax + model.zMin) / 2;
    
    spheres = new Sphere[2];
    
    spheres[0] = new Sphere();
    spheres[0].x = model.xMin;
    spheres[0].y = centerY;
    spheres[0].z = centerZ;
    spheres[0].hue = 0;
    spheres[0].radius = 50;
    
    spheres[1] = new Sphere();
    spheres[1].x = model.xMax;
    spheres[1].y = centerY;
    spheres[1].z = centerZ;
    spheres[1].hue = 0.33f;
    spheres[1].radius = 50;
  }
  
  public void run(double deltaMs) {
    // Access the core master hue via this method call
    float hv = hueParameter.getValuef();
    float lfoValue = lfo.getValuef();
    float sinLfoValue = sinLfo.getValuef();
    
    spheres[0].x = model.xMin + sinLfoValue * model.xMax;
    spheres[1].x = model.xMax - sinLfoValue * model.xMax;
    
    spheres[0].radius = 100 * hueParameter.getValuef();
    spheres[1].radius = 100 * hueParameter.getValuef();
    
    for (Point p : model.points) {
      float value = 0;

      int c = lx.hsb(0, 0, 0);      
      for (Sphere s : spheres) {
        float d = sqrt(pow(p.x - s.x, 2) + pow(p.y - s.y, 2) + pow(p.z - s.z, 2));
        float r = (s.radius); // * (sinLfoValue + 0.5));
        value = max(0, 1 - max(0, d - r) / 10);
        
        c = blendColor(c, lx.hsb(((s.hue + lfoValue) % 1) * 360, 100, min(1, value) * 100), ADD);
      }
      
      colors[p.index] = c;
    }
  } 
}

class Vector2 {
  float x, y;
  
  Vector2() {
    this(0, 0);
  }
  
  Vector2(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  public float distanceTo(float x, float y) {
    return sqrt(pow(x - this.x, 2) + pow(y - this.y, 2));
  }
  
  public float distanceTo(Vector2 v) {
    return distanceTo(v.x, v.y);
  }
  
  public Vector2 plus(float x, float y) {
    return new Vector2(this.x + x, this.y + y);
  }
  
  public Vector2 plus(Vector2 v) {
    return plus(v.x, v.y);
  }
    
  public Vector2 minus(Vector2 v) {
    return plus(-1 * v.x, -1 * v.y);
  }
}

class Vector3 {
  float x, y, z;
  
  Vector3() {
    this(0, 0, 0);
  }
  
  Vector3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public float distanceTo(float x, float y, float z) {
    return sqrt(pow(x - this.x, 2) + pow(y - this.y, 2) + pow(z - this.z, 2));
  }
  
  public float distanceTo(Vector3 v) {
    return distanceTo(v.x, v.y, v.z);
  }
  
  public float distanceTo(Point p) {
    return distanceTo(p.x, p.y, p.z);
  }
  
  public void add(Vector3 other, float multiplier) {
    this.add(other.x * multiplier, other.y * multiplier, other.z * multiplier);
  }  
    
  public void add(float x, float y, float z) {
    this.x += x;
    this.y += y;
    this.z += z;
  }
  
  public void divide(float factor) {
    this.x /= factor;
    this.y /= factor;
    this.z /= factor;
  }
}

class Rotation {
  private float a, b, c, d, e, f, g, h, i;
  
  Rotation(float yaw, float pitch, float roll) {
    float cosYaw = cos(yaw);
    float sinYaw = sin(yaw);
    float cosPitch = cos(pitch);
    float sinPitch = sin(pitch);
    float cosRoll = cos(roll);
    float sinRoll = sin(roll);
    
    a = cosYaw * cosPitch;
    b = cosYaw * sinPitch * sinRoll - sinYaw * cosRoll;
    c = cosYaw * sinPitch * cosRoll + sinYaw * sinRoll;
    d = sinYaw * cosPitch;
    e = sinYaw * sinPitch * sinRoll + cosYaw * cosRoll;
    f = sinYaw * sinPitch * cosRoll - cosYaw * sinRoll;
    g = -1 * sinPitch;
    h = cosPitch * sinRoll;
    i = cosPitch * cosRoll;
  }
  
  public Vector3 rotated(Vector3 v) {
    return new Vector3(
      rotatedX(v),
      rotatedY(v),
      rotatedZ(v));

  }
  
  public float rotatedX(Vector3 v) {
    return a * v.x + b * v.y + c * v.z;
  }
  
  public float rotatedY(Vector3 v) {
    return d * v.x + e * v.y + f * v.z;
  }
  
  public float rotatedZ(Vector3 v) {
    return g * v.x + h * v.y + i * v.z;
  }
}

/**
 * Very literal rain effect.  Not that great as-is but some tweaking could make it nice.
 * A couple ideas:
 *   - changing hue and direction of "rain" could make a nice fire effect
 *   - knobs to change frequency and size of rain drops
 *   - sync somehow to tempo but maybe less frequently than every beat?
 */
class TimRaindrops extends SCPattern {
  public Vector3 randomVector3() {
    return new Vector3(
        random(model.xMax - model.xMin) + model.xMin,
        random(model.yMax - model.yMin) + model.yMin,
        random(model.zMax - model.zMin) + model.zMin);
  }

  class Raindrop {
    Vector3 p;
    Vector3 v;
    float radius;
    float hue;
    
    Raindrop() {
      this.radius = 30;
      this.p = new Vector3(
              random(model.xMax - model.xMin) + model.xMin,
              model.yMax + this.radius,
              random(model.zMax - model.zMin) + model.zMin);
      float velMagnitude = 120;
      this.v = new Vector3(
          0,
          -3 * model.yMax,
          0);
      this.hue = random(40) + 200;
    }
    
    // returns TRUE when this should die
    public boolean age(double ms) {
      p.add(v, (float) (ms / 1000.0f));
      return this.p.y < (0 - this.radius);
    }
  }
  
  private float leftoverMs = 0;
  private float msPerRaindrop = 40;
  private List<Raindrop> raindrops;
  
  public TimRaindrops(GLucose glucose) {
    super(glucose);
    raindrops = new LinkedList<Raindrop>();
  }
  
  public void run(double deltaMs) {
    leftoverMs += deltaMs;
    while (leftoverMs > msPerRaindrop) {
      leftoverMs -= msPerRaindrop;
      raindrops.add(new Raindrop());
    }
    
    for (Point p : model.points) {
      int c = 
        blendColor(
          lx.hsb(210, 20, (float)Math.max(0, 1 - Math.pow((model.yMax - p.y) / 10, 2)) * 50),
          lx.hsb(220, 60, (float)Math.max(0, 1 - Math.pow((p.y - model.yMin) / 10, 2)) * 100),
          ADD);
      for (Raindrop raindrop : raindrops) {
        if (p.x >= (raindrop.p.x - raindrop.radius) && p.x <= (raindrop.p.x + raindrop.radius) &&
            p.y >= (raindrop.p.y - raindrop.radius) && p.y <= (raindrop.p.y + raindrop.radius)) {
          float d = raindrop.p.distanceTo(p) / raindrop.radius;
  //      float value = (float)Math.max(0, 1 - Math.pow(Math.min(0, d - raindrop.radius) / 5, 2)); 
          if (d < 1) {
            c = blendColor(c, lx.hsb(raindrop.hue, 80, (float)Math.pow(1 - d, 0.01f) * 100), ADD);
          }
        }
      }
      colors[p.index] = c;
    }
    
    Iterator<Raindrop> i = raindrops.iterator();
    while (i.hasNext()) {
      Raindrop raindrop = i.next();
      boolean dead = raindrop.age(deltaMs);
      if (dead) {
        i.remove();
      }
    }
  } 
}


class TimCubes extends SCPattern {
  private BasicParameter rateParameter = new BasicParameter("RATE", 0.125f);
  private BasicParameter attackParameter = new BasicParameter("ATTK", 0.5f);
  private BasicParameter decayParameter = new BasicParameter("DECAY", 0.5f);
  private BasicParameter hueParameter = new BasicParameter("HUE", 0.5f);
  private BasicParameter hueVarianceParameter = new BasicParameter("H.V.", 0.25f);
  private BasicParameter saturationParameter = new BasicParameter("SAT", 0.5f);
  
  class CubeFlash {
    Cube c;
    float value;
    float hue;
    boolean hasPeaked;
    
    CubeFlash() {
      c = model.cubes.get(floor(random(model.cubes.size())));
      hue = random(1);
      boolean infiniteAttack = (attackParameter.getValuef() > 0.999f);
      hasPeaked = infiniteAttack;
      value = (infiniteAttack ? 1 : 0);
    }
    
    // returns TRUE if this should die
    public boolean age(double ms) {
      if (!hasPeaked) {
        value = value + (float) (ms / 1000.0f * ((attackParameter.getValuef() + 0.01f) * 5));
        if (value >= 1.0f) {
          value = 1.0f;
          hasPeaked = true;
        }
        return false;
      } else {
        value = value - (float) (ms / 1000.0f * ((decayParameter.getValuef() + 0.01f) * 10));
        return value <= 0;
      }
    }
  }
  
  private float leftoverMs = 0;
  private List<CubeFlash> flashes;
  
  public TimCubes(GLucose glucose) {
    super(glucose);
    addParameter(rateParameter);
    addParameter(attackParameter);
    addParameter(decayParameter);
    addParameter(hueParameter);
    addParameter(hueVarianceParameter);
    addParameter(saturationParameter);
    flashes = new LinkedList<CubeFlash>();
  }
  
  public void run(double deltaMs) {
    leftoverMs += deltaMs;
    float msPerFlash = 1000 / ((rateParameter.getValuef() + .01f) * 100);
    while (leftoverMs > msPerFlash) {
      leftoverMs -= msPerFlash;
      flashes.add(new CubeFlash());
    }
    
    for (Point p : model.points) {
      colors[p.index] = 0;
    }
    
    for (CubeFlash flash : flashes) {
      float hue = (hueParameter.getValuef() + (hueVarianceParameter.getValuef() * flash.hue)) % 1.0f;
      int c = lx.hsb(hue * 360, saturationParameter.getValuef() * 100, (flash.value) * 100);
      for (Point p : flash.c.points) {
        colors[p.index] = c;
      }
    }
    
    Iterator<CubeFlash> i = flashes.iterator();
    while (i.hasNext()) {
      CubeFlash flash = i.next();
      boolean dead = flash.age(deltaMs);
      if (dead) {
        i.remove();
      }
    }
  } 
}

/**
 * This one is the best but you need to play with all the knobs.  It's synced to
 * the tempo, with the WSpd knob letting you pick 4 discrete multipliers for
 * the tempo.
 *
 * Basically it's just 3 planes all rotating to the beat, but also rotated relative
 * to one another.  The intersection of the planes and the cubes over time makes
 * for a nice abstract effect.
 */
class TimPlanes extends SCPattern {
  private BasicParameter wobbleParameter = new BasicParameter("Wob", 0.166f);
  private BasicParameter wobbleSpreadParameter = new BasicParameter("WSpr", 0.25f);
  private BasicParameter wobbleSpeedParameter = new BasicParameter("WSpd", 0.375f);
  private BasicParameter wobbleOffsetParameter = new BasicParameter("WOff", 0);
  private BasicParameter derezParameter = new BasicParameter("Drez", 0.5f);
  private BasicParameter thicknessParameter = new BasicParameter("Thick", 0.4f);
  private BasicParameter ySpreadParameter = new BasicParameter("ySpr", 0.2f);
  private BasicParameter hueParameter = new BasicParameter("Hue", 0.75f);
  private BasicParameter hueSpreadParameter = new BasicParameter("HSpr", 0.68f);

  final float centerX, centerY, centerZ;
  float phase;
  
  class Plane {
    Vector3 center;
    Rotation rotation;
    float hue;
    
    Plane(Vector3 center, Rotation rotation, float hue) {
      this.center = center;
      this.rotation = rotation;
      this.hue = hue;
    }
  }
      
  TimPlanes(GLucose glucose) {
    super(glucose);
    centerX = (model.xMin + model.xMax) / 2;
    centerY = (model.yMin + model.yMax) / 2;
    centerZ = (model.zMin + model.zMax) / 2;
    phase = 0;
    addParameter(wobbleParameter);
    addParameter(wobbleSpreadParameter);
    addParameter(wobbleSpeedParameter);
//    addParameter(wobbleOffsetParameter);
    addParameter(derezParameter);
    addParameter(thicknessParameter);
    addParameter(ySpreadParameter);
    addParameter(hueParameter);
    addParameter(hueSpreadParameter);
  }
  
  int beat = 0;
  float prevRamp = 0;
  float[] wobbleSpeeds = { 1.0f/8, 1.0f/4, 1.0f/2, 1.0f };
  
  public void run(double deltaMs) {
    float ramp = (float)lx.tempo.ramp();
    if (ramp < prevRamp) {
      beat = (beat + 1) % 32;
    }
    prevRamp = ramp;
    
    float wobbleSpeed = wobbleSpeeds[floor(wobbleSpeedParameter.getValuef() * wobbleSpeeds.length * 0.9999f)];

    phase = (((beat + ramp) * wobbleSpeed + wobbleOffsetParameter.getValuef()) % 1) * 2 * PI;
    
    float ySpread = ySpreadParameter.getValuef() * 50;
    float wobble = wobbleParameter.getValuef() * PI;
    float wobbleSpread = wobbleSpreadParameter.getValuef() * PI;
    float hue = hueParameter.getValuef() * 360;
    float hueSpread = (hueSpreadParameter.getValuef() - 0.5f) * 360;

    float saturation = 10 + 60.0f * pow(ramp, 0.25f);
    
    float derez = derezParameter.getValuef();
    
    Plane[] planes = {
      new Plane(
        new Vector3(centerX, centerY + ySpread, centerZ),
        new Rotation(wobble - wobbleSpread, phase, 0),
        (hue + 360 - hueSpread) % 360),
      new Plane(
        new Vector3(centerX, centerY, centerZ),
        new Rotation(wobble, phase, 0),
        hue),
      new Plane(
        new Vector3(centerX, centerY - ySpread, centerZ),
        new Rotation(wobble + wobbleSpread, phase, 0),
        (hue + 360 + hueSpread) % 360)
    };

    float thickness = (thicknessParameter.getValuef() * 25 + 1);
    
    Vector3 normalizedPoint = new Vector3();

    for (Point p : model.points) {
      if (random(1.0f) < derez) {
        continue;
      }
      
      int c = 0;
      
      for (Plane plane : planes) {
        normalizedPoint.x = p.x - plane.center.x;
        normalizedPoint.y = p.y - plane.center.y;
        normalizedPoint.z = p.z - plane.center.z;
        
        float v = plane.rotation.rotatedY(normalizedPoint);
        float d = abs(v);
        
        final int planeColor;
        if (d <= thickness) {
          planeColor = lx.hsb(plane.hue, saturation, 100);
        } else if (d <= thickness * 2) {    
          float value = 1 - ((d - thickness) / thickness);
          planeColor = lx.hsb(plane.hue, saturation, value * 100);
        } else {
          planeColor = 0;
        }

        if (planeColor != 0) {
          if (c == 0) {
            c = planeColor; 
          } else {
            c = blendColor(c, planeColor, ADD);
          }
        }
      }

      colors[p.index] = c;
    }
  }
}

/**
 * Two spinning wheels, basically XORed together, with a color palette that should
 * be pretty easy to switch around.  Timed to the beat; also introduces "clickiness"
 * which makes the movement non-linear throughout a given beat, giving it a nice
 * dance feel.  I'm not 100% sure that it's actually going to look like it's _on_
 * the beat, but that should be easy enough to adjust.
 *
 * It's particularly nice to turn down the clickiness and turn up derez during
 * slow/beatless parts of the music and then revert them at the drop :)  But maybe
 * I shouldn't be listening to so much shitty dubstep while making these...
 */
class TimPinwheels extends SCPattern { 
  private BasicParameter horizSpreadParameter = new BasicParameter("HSpr", 0.75f);
  private BasicParameter vertSpreadParameter = new BasicParameter("VSpr", 0.5f);
  private BasicParameter vertOffsetParameter = new BasicParameter("VOff", 1.0f);
  private BasicParameter zSlopeParameter = new BasicParameter("ZSlp", 0.6f);
  private BasicParameter sharpnessParameter = new BasicParameter("Shrp", 0.25f);
  private BasicParameter derezParameter = new BasicParameter("Drez", 0.25f);
  private BasicParameter clickinessParameter = new BasicParameter("Clic", 0.5f);
  private BasicParameter hueParameter = new BasicParameter("Hue", 0.667f);
  private BasicParameter hueSpreadParameter = new BasicParameter("HSpd", 0.667f);

  float phase = 0;
  private final int NUM_BLADES = 12;
  
  class Pinwheel {
    Vector2 center;
    int numBlades;
    float realPhase;
    float phase;
    float speed;
    
    Pinwheel(float xCenter, float yCenter, int numBlades, float speed) {
      this.center = new Vector2(xCenter, yCenter);
      this.numBlades = numBlades;
      this.speed = speed;
    }
    
    public void age(float numBeats) {
      int numSteps = numBlades;
      
      realPhase = (realPhase + numBeats / numSteps) % 2.0f;
      
      float phaseStep = floor(realPhase * numSteps);
      float phaseRamp = (realPhase * numSteps) % 1.0f;
      phase = (phaseStep + pow(phaseRamp, (clickinessParameter.getValuef() * 10) + 1)) / (numSteps * 2);
//      phase = (phase + deltaMs / 1000.0 * speed) % 1.0;      
    }
    
    public boolean isOnBlade(float x, float y) {
      x = x - center.x;
      y = y - center.y;
      
      float normalizedAngle = (atan2(x, y) / (2 * PI) + 1 + phase) % 1;
      float v = (normalizedAngle * 4 * numBlades);
      int blade_num = floor((v + 2) / 4);
      return (blade_num % 2) == 0;
    }
  }
  
  private final List<Pinwheel> pinwheels;
  private final float[] values;
  
  TimPinwheels(GLucose glucose) {
    super(glucose);
    
    addParameter(horizSpreadParameter);
//    addParameter(vertSpreadParameter);
    addParameter(vertOffsetParameter);
    addParameter(zSlopeParameter);
    addParameter(sharpnessParameter);
    addParameter(derezParameter);
    addParameter(clickinessParameter);
    addParameter(hueParameter);
    addParameter(hueSpreadParameter);
    
    pinwheels = new ArrayList();
    pinwheels.add(new Pinwheel(0, 0, NUM_BLADES, 0.1f));
    pinwheels.add(new Pinwheel(0, 0, NUM_BLADES, -0.1f));
    
    this.updateHorizSpread();
    this.updateVertPositions();
    
    values = new float[model.points.size()];
  }
  
  public void onParameterChanged(LXParameter parameter) {
    if (parameter == horizSpreadParameter) {
      updateHorizSpread();
    } else if (parameter == vertSpreadParameter || parameter == vertOffsetParameter) {
      updateVertPositions();
    }
  }
  
  private void updateHorizSpread() {
    float xDist = model.xMax - model.xMin;
    float xCenter = (model.xMin + model.xMax) / 2;
    
    float spread = horizSpreadParameter.getValuef() - 0.5f;
    pinwheels.get(0).center.x = xCenter - xDist * spread;
    pinwheels.get(1).center.x = xCenter + xDist * spread; 
  }
  
  private void updateVertPositions() {
    float yDist = model.yMax - model.yMin;
    float yCenter = model.yMin + yDist * vertOffsetParameter.getValuef();

    float spread = vertSpreadParameter.getValuef() - 0.5f;
    pinwheels.get(0).center.y = yCenter - yDist * spread;
    pinwheels.get(1).center.y = yCenter + yDist * spread;     
  }
  
  private float prevRamp = 0;
  
  public void run(double deltaMs) {
    float ramp = lx.tempo.rampf();
    float numBeats = (1 + ramp - prevRamp) % 1;
    prevRamp = ramp;
    
    float hue = hueParameter.getValuef() * 360;
    // 0 -> -180
    // 0.5 -> 0
    // 1 -> 180
    float hueSpread = (hueSpreadParameter.getValuef() - 0.5f) * 360;
    
    float fadeAmount = (float) (deltaMs / 1000.0f) * pow(sharpnessParameter.getValuef() * 10, 1);
    
    for (Pinwheel pw : pinwheels) {
      pw.age(numBeats);
    }
    
    float derez = derezParameter.getValuef();
    
    float zSlope = (zSlopeParameter.getValuef() - 0.5f) * 2;
    
    int i = -1;
    for (Point p : model.points) {
      ++i;
      
      int value = 0;
      for (Pinwheel pw : pinwheels) {
        value += (pw.isOnBlade(p.x, p.y - p.z * zSlope) ? 1 : 0);
      }
      if (value == 1) {
        values[i] = 1;
//        colors[p.index] = lx.hsb(120, 0, 100);
      } else {
        values[i] = max(0, values[i] - fadeAmount);
        //color c = colors[p.index];
        //colors[p.index] = lx.hsb(max(0, lx.h(c) - 10), min(100, lx.s(c) + 10), lx.b(c) - 5 );
      }
      
      if (random(1.0f) >= derez) {
        float v = values[i];
        colors[p.index] = lx.hsb((360 + hue + pow(v, 2) * hueSpread) % 360, 30 + pow(1 - v, 0.25f) * 60, v * 100);
      }      
    }
  }
}

/**
 * This tries to figure out neighboring pixels from one cube to another to
 * let you have a bunch of moving points tracing all over the structure.
 * Adds a couple seconds of startup time to do the calculation, and in the
 * end just comes out looking a lot like a screensaver.  Probably not worth
 * it but there may be useful code here.
 */
class TimTrace extends SCPattern {
  private Map<Point, List<Point>> pointToNeighbors;
  private Map<Point, Strip> pointToStrip;
  //  private final Map<Strip, List<Strip>> stripToNearbyStrips;
  
  int extraMs;
  
  class MovingPoint {
    Point currentPoint;
    float hue;
    private Strip currentStrip;
    private int currentStripIndex;
    private int direction; // +1 or -1
    
    MovingPoint(Point p) {
      this.setPointOnNewStrip(p);
      hue = random(360);
    }
    
    private void setPointOnNewStrip(Point p) {
      this.currentPoint = p;
      this.currentStrip = pointToStrip.get(p);
      for (int i = 0; i < this.currentStrip.points.size(); ++i) {
        if (this.currentStrip.points.get(i) == p) {
          this.currentStripIndex = i;
          break;
        }
      }
      if (this.currentStripIndex == 0) {
        // we are at the beginning of the strip; go forwards
        this.direction = 1;
      } else if (this.currentStripIndex == this.currentStrip.points.size()) {
        // we are at the end of the strip; go backwards
        this.direction = -1;
      } else {
        // we are in the middle of a strip; randomly go one way or another
        this.direction = ((random(1.0f) < 0.5f) ? -1 : 1);
      }
    }
    
    public void step() {
      List<Point> neighborsOnOtherStrips = pointToNeighbors.get(this.currentPoint);

      Point nextPointOnCurrentStrip = null;      
      this.currentStripIndex += this.direction;
      if (this.currentStripIndex >= 0 && this.currentStripIndex < this.currentStrip.points.size()) {
        nextPointOnCurrentStrip = this.currentStrip.points.get(this.currentStripIndex);
      }
      
      // pick which option to take; if we can keep going on the current strip then
      // add that as another option
      int option = floor(random(neighborsOnOtherStrips.size() + (nextPointOnCurrentStrip == null ? 0 : 100)));
      
      if (option < neighborsOnOtherStrips.size()) {
        this.setPointOnNewStrip(neighborsOnOtherStrips.get(option));
      } else {
        this.currentPoint = nextPointOnCurrentStrip;
      }
    }
  }
  
  List<MovingPoint> movingPoints;
  
  TimTrace(GLucose glucose) {
    super(glucose);
    
    extraMs = 0;
    
    pointToNeighbors = this.buildPointToNeighborsMap();
    pointToStrip = this.buildPointToStripMap();
    
    int numMovingPoints = 1000;
    movingPoints = new ArrayList();
    for (int i = 0; i < numMovingPoints; ++i) {
      movingPoints.add(new MovingPoint(model.points.get(floor(random(model.points.size())))));
    }
    
  }
  
  private Map<Strip, List<Strip>> buildStripToNearbyStripsMap() {
    Map<Strip, Vector3> stripToCenter = new HashMap();
    for (Strip s : model.strips) {
      Vector3 v = new Vector3();
      for (Point p : s.points) {
        v.add(p.x, p.y, p.z);
      }
      v.divide(s.points.size());
      stripToCenter.put(s, v);
    }
    
    Map<Strip, List<Strip>> stripToNeighbors = new HashMap();
    for (Strip s : model.strips) {
      List<Strip> neighbors = new ArrayList();
      Vector3 sCenter = stripToCenter.get(s);
      for (Strip potentialNeighbor : model.strips) {
        if (s != potentialNeighbor) {
          float distance = sCenter.distanceTo(stripToCenter.get(potentialNeighbor));
          if (distance < 25) {
            neighbors.add(potentialNeighbor);
          }
        }
      }
      stripToNeighbors.put(s, neighbors);
    }
    
    return stripToNeighbors;
  }
  
  private Map<Point, List<Point>> buildPointToNeighborsMap() {
    Map<Point, List<Point>> m = new HashMap();
    Map<Strip, List<Strip>> stripToNearbyStrips = this.buildStripToNearbyStripsMap();
    
    for (Strip s : model.strips) {
      List<Strip> nearbyStrips = stripToNearbyStrips.get(s);
      
      for (Point p : s.points) {
        Vector3 v = new Vector3(p.x, p.y, p.z);
        
        List<Point> neighbors = new ArrayList();
        
        for (Strip nearbyStrip : nearbyStrips) {
          Point closestPoint = null;
          float closestPointDistance = 100000;
          
          for (Point nsp : nearbyStrip.points) {
            float distance = v.distanceTo(nsp.x, nsp.y, nsp.z);
            if (closestPoint == null || distance < closestPointDistance) {
              closestPoint = nsp;
              closestPointDistance = distance;
            }
          }
          
          if (closestPointDistance < 15) {
            neighbors.add(closestPoint);
          }
        }
        
        m.put(p, neighbors);
      }
    }
    
    return m;
  }
  
  private Map<Point, Strip> buildPointToStripMap() {
    Map<Point, Strip> m = new HashMap();
    for (Strip s : model.strips) {
      for (Point p : s.points) {
        m.put(p, s);
      }
    }
    return m;
  }
  
  public void run(double deltaMs) {
    for (Point p : model.points) {
      int c = colors[p.index];
      colors[p.index] = lx.hsb(lx.h(c), lx.s(c), lx.b(c) - 3);
    }
    
    for (MovingPoint mp : movingPoints) {
      mp.step();
      colors[mp.currentPoint.index] = blendColor(colors[mp.currentPoint.index], lx.hsb(mp.hue, 10, 100), ADD);
    }
  }
}
class GlitchPlasma extends SCPattern {
  private int pos = 0;
  private float satu = 100;
  private float speed = 1;
  private float glitch = 0;
  BasicParameter saturationParameter = new BasicParameter("SATU", 1.0f);
  BasicParameter speedParameter = new BasicParameter("SPEED", 0.1f);
  BasicParameter glitchParameter = new BasicParameter("GLITCH", 0.0f);
  
  public GlitchPlasma(GLucose glucose) {
    super(glucose);
    addParameter(saturationParameter);
    addParameter(speedParameter);
    addParameter(glitchParameter);
  }
  public void onParameterChanged(LXParameter parameter) {
    if (parameter == saturationParameter) {
      satu = 100*parameter.getValuef();
    } else if (parameter == speedParameter) {
      speed = 8*parameter.getValuef();
    } else if (parameter == glitchParameter) {
      glitch = parameter.getValuef();
    }
  }

  public void run(double deltaMs) {
    for (Point p : model.points) {
      float hv = sin(dist(p.x + pos, p.y, 128.0f, 128.0f) / 8.0f)
	  + sin(dist(p.x, p.y, 64.0f, 64.0f) / 8.0f)
	  + sin(dist(p.x, p.y + pos / 7, 192.0f, 64.0f) / 7.0f)
	  + sin(dist(p.x, p.z + pos, 192.0f, 100.0f) / 8.0f);
      float bv = 100;
      colors[p.index] = lx.hsb((hv+2)*50, satu, bv);
    }
    if (random(1.0f)<glitch/20) {
      pos=pos-PApplet.parseInt(random(10,30));
    }
    pos+=speed;
    if (pos >= MAX_INT-1) pos=0;    
  }
}

// This is very much a work in progress. Trying to get a flame effect.
class FireEffect extends SCPattern {
  private float[][] intensity;
  private float hotspot;
  private float decay = 0.3f;
  private int xm;
  private int ym;
  BasicParameter decayParameter = new BasicParameter("DECAY", 0.3f);
  
  public FireEffect(GLucose glucose) {
    super(glucose);
    xm = PApplet.parseInt(model.xMax);
    ym = PApplet.parseInt(model.yMax);
    
    intensity = new float[xm][ym];
    addParameter(decayParameter);
  }
  public void onParameterChanged(LXParameter parameter) {
    if (parameter == decayParameter) {
      decay = parameter.getValuef();
    }
  } 
  private int flameColor(float level) {
    if (level<=0) return lx.hsb(0,0,0);
    float br=min(100,sqrt(level)*15);
    return lx.hsb(level/1.7f,100,br);
  }
  public void run(double deltaMs) {
    for (int x=10;x<xm-10;x++) {
        if (x%50>45 || x%50<5) {
          intensity[x][ym-1] = random(30,100);
        } else {
          intensity[x][ym-1] = random(0,50);
        }
    }
    for (int x=1;x<xm-1;x++) {
      for (int y=0;y<ym-1;y++) {        
        intensity[x][y] = (intensity[x-1][y+1]+intensity[x][y+1]+intensity[x+1][y+1])/3-decay;
      }
    }
    
    for (Point p : model.points) {
      int x = max(0,(PApplet.parseInt(p.x)+PApplet.parseInt(p.z))%xm);
      int y = constrain(ym-PApplet.parseInt(p.y),0,ym-1);
      colors[p.index] = flameColor(intensity[x][y]);
    }
  }
}

class StripBounce extends SCPattern {
  private final int numOsc = 30;
  SinLFO[] fX = new SinLFO[numOsc]; //new SinLFO(0, model.xMax, 5000);
  SinLFO[] fY = new SinLFO[numOsc]; //new SinLFO(0, model.yMax, 4000);
  SinLFO[] fZ = new SinLFO[numOsc]; //new SinLFO(0, model.yMax, 3000);
  SinLFO[] sat = new SinLFO[numOsc];
  float[] colorOffset = new float[numOsc];
  
  public StripBounce(GLucose glucose) {
    super(glucose);
    for (int i=0;i<numOsc;i++) {
      fX[i] = new SinLFO(0, model.xMax, random(2000,20000)); 
      fY[i] = new SinLFO(0, model.yMax, random(2000,20000)); 
      fZ[i] = new SinLFO(0, model.zMax, random(2000,20000)); 
      sat[i] = new SinLFO(60, 100, random(2000,50000)); 
      addModulator(fX[i]).trigger();      
      addModulator(fY[i]).trigger();
      addModulator(fZ[i]).trigger();
      colorOffset[i]=random(0,256);
    }
  }
  
  public void run(double deltaMs) {
    float[] bright = new float[model.points.size()];
    for (Strip strip : model.strips) {
      for (int i=0;i<numOsc;i++) {
        float avgdist=0.0f;
        avgdist = dist(strip.points.get(8).x,strip.points.get(8).y,strip.points.get(8).z,fX[i].getValuef(),fY[i].getValuef(),fZ[i].getValuef());
        boolean on = avgdist<30;
        float hv = (lx.getBaseHuef()+colorOffset[i])%360;
        float br = max(0,100-avgdist*4);
        for (Point p : strip.points) {
          if (on && br>bright[p.index]) {
            colors[p.index] = lx.hsb(hv,sat[i].getValuef(),br);
            bright[p.index] = br;
          }
        }
      }
    }
  }
}

class SoundRain extends SCPattern {

  private FFT fft = null; 
  private LinearEnvelope[] bandVals = null;
  private float[] lightVals = null;
  private int avgSize;
  private float gain = 25;
  SawLFO pos = new SawLFO(0, 9, 8000);
  SinLFO col1 = new SinLFO(0, model.xMax, 5000);
  BasicParameter gainParameter = new BasicParameter("GAIN", 0.5f);
  
  public SoundRain(GLucose glucose) {
    super(glucose);
    addModulator(pos).trigger();
    addModulator(col1).trigger();
    addParameter(gainParameter);
  }

  public void onParameterChanged(LXParameter parameter) {
    if (parameter == gainParameter) {
      gain = 50*parameter.getValuef();
    }
  }
  protected void onActive() {
    if (this.fft == null) {
      this.fft = new FFT(lx.audioInput().bufferSize(), lx.audioInput().sampleRate());
      this.fft.window(FFT.HAMMING);
      this.fft.logAverages(40, 1);
      this.avgSize = this.fft.avgSize();
      this.bandVals = new LinearEnvelope[this.avgSize];
      for (int i = 0; i < this.bandVals.length; ++i) {
        this.addModulator(this.bandVals[i] = (new LinearEnvelope(0, 0, 700+i*4))).trigger();
      }
      lightVals = new float[avgSize];
    }
  }
  
  public void run(double deltaMs) {
    this.fft.forward(this.lx.audioInput().mix);
    for (int i = 0; i < avgSize; ++i) {
      float value = this.fft.getAvg(i);
      this.bandVals[i].setEndVal(value,40).trigger();
      float lv = min(value*gain,100);
      if (lv>lightVals[i]) {
        lightVals[i]=min(lightVals[i]+15,lv,100);
      } else {
        lightVals[i]=max(lv,lightVals[i]-5,0);
      }
    }
    for (Cube c : model.cubes) {
      for (int j=0; j<c.strips.size(); j++) {
        Strip s = c.strips.get(j);
        if (j%4!=0 && j%4!=2) {
          for (Point p : s.points) {
            int seq = PApplet.parseInt(p.y*avgSize/model.yMax+pos.getValuef()+sin(p.x+p.z)*2)%avgSize;
            seq=min(abs(seq-(avgSize/2)),avgSize-1);
            colors[p.index] = lx.hsb(200,max(0,100-abs(p.x-col1.getValuef())/2),lightVals[seq]);
          }
        }
      }
    }
  }  
}

class FaceSync extends SCPattern {
  SinLFO xosc = new SinLFO(-10, 10, 3000);
  SinLFO zosc = new SinLFO(-10, 10, 3000);
  SinLFO col1 = new SinLFO(0, model.xMax, 5000);
  SinLFO col2 = new SinLFO(0, model.xMax, 4000);

  public FaceSync(GLucose glucose) {
    super(glucose);
    addModulator(xosc).trigger();
    addModulator(zosc).trigger();
    zosc.setValue(0);
    addModulator(col1).trigger();
    addModulator(col2).trigger();    
    col2.setValue(model.xMax);
  }

  public void run(double deltaMs) {
    int i=0;
    for (Strip s : model.strips) {
      i++;
      for (Point p : s.points) {
        float dx, dz;
        if (i%32 < 16) {
          dx = p.x - (s.cx+xosc.getValuef());
          dz = p.z - (s.cz+zosc.getValuef());
        } else {
          dx = p.x - (s.cx+zosc.getValuef());
          dz = p.z - (s.cz+xosc.getValuef());
        }                
        //println(dx);
        float a1=max(0,100-abs(p.x-col1.getValuef()));
        float a2=max(0,100-abs(p.x-col2.getValuef()));        
        float sat = max(a1,a2);
        float h = (359*a1+200*a2) / (a1+a2);
        colors[p.index] = lx.hsb(h,sat,100-abs(dx*5)-abs(dz*5));
      }
    }
  }
}

class SoundSpikes extends SCPattern {
  private FFT fft = null; 
  private LinearEnvelope[] bandVals = null;
  private float[] lightVals = null;
  private int avgSize;
  private float gain = 25;
  BasicParameter gainParameter = new BasicParameter("GAIN", 0.5f);
  SawLFO pos = new SawLFO(0, model.xMax, 8000);

  public SoundSpikes(GLucose glucose) {
    super(glucose);
    addParameter(gainParameter);
    addModulator(pos).trigger();
  }

  public void onParameterChanged(LXParameter parameter) {
    if (parameter == gainParameter) {
      gain = 50*parameter.getValuef();
    }
  }
  protected void onActive() {
    if (this.fft == null) {
      this.fft = new FFT(lx.audioInput().bufferSize(), lx.audioInput().sampleRate());
      this.fft.window(FFT.HAMMING);
      this.fft.logAverages(40, 1);
      this.avgSize = this.fft.avgSize();
      this.bandVals = new LinearEnvelope[this.avgSize];
      for (int i = 0; i < this.bandVals.length; ++i) {
        this.addModulator(this.bandVals[i] = (new LinearEnvelope(0, 0, 700+i*4))).trigger();
      }
      lightVals = new float[avgSize];
    }
  }
  
  public void run(double deltaMs) {
    this.fft.forward(this.lx.audioInput().mix);
    for (int i = 0; i < avgSize; ++i) {
      float value = this.fft.getAvg(i);
      this.bandVals[i].setEndVal(value,40).trigger();
      float lv = min(value*gain,model.yMax+10);
      if (lv>lightVals[i]) {
        lightVals[i]=min(lightVals[i]+30,lv,model.yMax+10);
      } else {
        lightVals[i]=max(lv,lightVals[i]-10,0);
      }
    }
    int i = 0;
    for (Cube c : model.cubes) {
      for (int j=0; j<c.strips.size(); j++) {
        Strip s = c.strips.get(j);
        if (j%4!=0 && j%4!=2) {
          for (Point p : s.points) {
            float dis = (abs(p.x-model.xMax/2)+pos.getValuef())%model.xMax/2;
            int seq = PApplet.parseInt((dis*avgSize*2)/model.xMax);
            if (seq>avgSize) seq=avgSize-seq;
            seq=constrain(seq,0,avgSize-1);
            float br=max(0, lightVals[seq]-p.y);
            colors[p.index] = lx.hsb((dis*avgSize*65)/model.xMax,90,br);
          }
        }
      }
    }
  }  
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SugarCubes" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
