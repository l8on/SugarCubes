class SineSphere extends SCPattern {
  private SawLFO yrot = new SawLFO(0, TWO_PI, 3000);
  private SawLFO yrot2 = new SawLFO(0, -TWO_PI,  8000);
  public BasicParameter huespread = new BasicParameter("Hue", 0, 180);
  public BasicParameter widthparameter= new BasicParameter("Width", .2);
  private int pitch = 0; 
  private int channel = 0; 
  private int velocity = 0; 
  public final LXProjection sinespin; 
  public final LXProjection sinespin2;
 float modelrad = sqrt((model.xMax)*(model.xMax) + (model.yMax)*(model.yMax) + (model.zMax)*(model.zMax));
  Pick Sshape; 

  //to-do:  how to sync all hues across sphery's via one basicparameter 
  //public BasicParameter huespread = new BasicParameter("HueSpread", 180, 360);
  public BasicParameter rotationx = new BasicParameter("rotx", 0, 0, 1 );
  public BasicParameter rotationy = new BasicParameter("roty", 1, 0, 1);
  public BasicParameter rotationz = new BasicParameter("rotz", 0, 0, 1);
  
  public final PVector P = new PVector();

  class Sphery {
  float f1xcenter, f1ycenter, f1zcenter, f2xcenter , f2ycenter, f2zcenter; //second three are for an ellipse with two foci
  private  SinLFO vibration; 
  private  SinLFO surface;
  private  SinLFO vx;
  private SinLFO xbounce;
  public SinLFO ybounce;
  private SinLFO zbounce;
  float vibration_min, vibration_max, vperiod;
  
  //public BasicParameter huespread;
  public BasicParameter bouncerate;
  public BasicParameter bounceamp;
  public BasicParameter vibrationrate;
  public final PVector circlecenter = new PVector(); 
 
  public Sphery(float f1xcenter, float f1ycenter, float f1zcenter, float vibration_min, float vibration_max, float vperiod) 
  {
   this.f1xcenter = f1xcenter;
   this.f1ycenter = f1ycenter;
   this.f1zcenter = f1zcenter;
   this.vibration_min = vibration_min;
   this.vibration_max = vibration_max;
   this.vperiod = vperiod;
   //addParameter(bounceamp = new BasicParameter("Amp", .5));
   //addParameter(bouncerate = new BasicParameter("Rate", .5));  //ybounce.modulateDurationBy(bouncerate);
   //addParameter(vibrationrate = new BasicParameter("vibration", 1000, 10000));
    //addParameter(widthparameter = new BasicParameter("Width", .2));
    
   
   addModulator( vx = new SinLFO(500, 10000, 100000)).trigger() ;
   //addModulator(xbounce = new SinLFO(model.xMax/3, 2*model.yMax/3, 2000)).trigger(); 
   addModulator(ybounce= new SinLFO(model.yMax/3, 2*model.yMax/3, 240000./lx.tempo.bpm())).trigger(); //bounce.modulateDurationBy
    
   //addModulator(bounceamp); //ybounce.setMagnitude(bouncerate);
   addModulator( vibration = new SinLFO(vibration_min , vibration_max, 10000)).trigger(); //vibration.setPeriod(240000/lx.tempo.bpm());
      
  }

  //for an ellipse
//  public Sphery(float f1xcenter, float f1ycenter, float f1zcenter, float f2xcenter, float f2ycenter, float f2zcenter, 
//   float vibration_min, float vibration_max, float vperiod)  
 
//  {
//     this.f1xcenter = f1xcenter;
//    this.f1ycenter = f1ycenter;
//    this.f1zcenter = f1zcenter;
//    this.f2xcenter = f2xcenter;
//    this.f2ycenter = f2ycenter;
//    this.f2zcenter = f2zcenter;
//    this.vibration_min = vibration_min;
//    this.vibration_max = vibration_max;
//    this.vperiod = vperiod;
//    //addModulator(xbounce = new SinLFO(model.xMax/3, 2*model.yMax/3, 2000)).trigger(); 
//    addModulator(ybounce).trigger(); 
//    addModulator( vibration = new SinLFO(vibration_min , vibration_max, lx.tempo.rampf())).trigger(); //vibration.modulateDurationBy(vx);
//    addParameter(widthparameter = new BasicParameter("Width", .1));
//    //addParameter(huespread = new BasicParameter("bonk", .2));
  
// }
 


void setVibrationPeriod(double period){
// to-do:  make this conditional upon time signature

vibration.setPeriod(period);

}


float distfromcirclecenter(float px, float py, float pz, float f1x, float f1y, float f1z) 
{
   return dist(px, py, pz, f1x, f1y, f1z);
    }
 //void updatespherey(deltaMs, )

 float quadrant(PVector q) {
   float qtheta = atan2(  (q.x-f1xcenter) , (q.z - f1zcenter) ); 


    return map(qtheta, -PI/2, PI/2, 160-huespread.getValuef(), 240 +huespread.getValuef());
  //if (q.x > f1xcenter ) {return 140 ;}
    //else  {return 250;}  
 }
 color spheryvalue (PVector p, float f1xcenter, float f1ycenter, float f1zcenter) {
   circlecenter.set(f1xcenter, f1ycenter, f1zcenter); 

  
//switch(sShpape.cur() ) {}  

   float b = max(0, 100 - 100*widthparameter.getValuef()*abs(p.dist(circlecenter)
      - vibration.getValuef() ) );

   if (b <= 0) {
     return 0;
   }

   return lx.hsb(
     constrain(quadrant(p), 0, 360),
     80,
     b
   ); 
 }
 color ellipsevalue(float px, float py, float pz , float f1xc, float f1yc, float f1zc, float f2xc, float f2yc, float f2zc)
  {
//switch(sShpape.cur() ) {}  
   return lx.hsb(huespread.getValuef()*5*px, dist(model.xMax-px, model.yMax-py, model.zMax-pz, f1xc, f1yc, f1zc) , 
    max(0, 100 - 100*widthparameter.getValuef() *
      abs( (dist(px, py, pz, f1xc, ybounce.getValuef(), f1zc) + 
        (dist(px, py , pz, f2xc, ybounce.getValuef(), f2zc) ) )/2  
      - 1.2*vibration.getValuef() ) ) ) ; 
  }

void run(double deltaMs) {
      float vv = vibration.getValuef();
      float ybv = ybounce.getValuef();
      
    }
  
}  

// public boolean gridPressed(int row, int co){
// midiengine.grid.setState();

// return true;

// }

public boolean noteOn(Note note)  {
pitch= note.getPitch();  
velocity=note.getVelocity();
channel=note.getChannel();
return true;
}

final Sphery[] spherys;
 
  SineSphere(GLucose glucose) 
  {
    super(glucose);
    sinespin = new LXProjection(model);
    sinespin2 = new LXProjection(model);
    addParameter(huespread);
    addParameter(rotationx);
    addParameter(rotationy);
    addParameter(rotationz);
    addModulator(yrot).trigger();
    addModulator(yrot2).trigger(); 
    
    //addParameter(huespread);
    //Sshape = addPick("Shape", , 1);
    spherys = new Sphery[] {
      new Sphery(model.xMax/4, model.yMax/2, model.zMax/2, modelrad/16, modelrad/8, 3000),
      new Sphery(.75*model.xMax, model.yMax/2, model.zMax/2, modelrad/20, modelrad/10, 2000),
      new Sphery(model.xMax/2, model.yMax/2, model.zMax/2,  modelrad/4, modelrad/8, 2300),

      new Sphery(.3*model.xMax, .4*model.yMax, .6*model.zMax, modelrad/16, modelrad/8, 4000),
      new Sphery(.75*model.xMax, model.yMax/2, model.zMax/2, modelrad/20, modelrad/10, 2000),
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
     double t = lx.tempo.ramp();
     double bpm = lx.tempo.bpm();
     //spherys[0].run(deltaMs);
     //spherys[1].run(deltaMs);
     //spherys[2].run(deltaMs);
     //spherys[3].run(deltaMs);]
     sinespin.reset()
     .center() 
     // .scale(1.3,1.3,1.3)
      // Rotate around the origin (now the center of the car) about an y-vector
      .rotate(yrot.getValuef(), rotationx.getValuef(), rotationy.getValuef() , rotationz.getValuef())
      .translate(model.cx, model.cy, model.cz);
     switch (pitch) 
    {
     case 53: t = .5*t;   bpm = .5*bpm;  break;

     case 54: t = t;   bpm = bpm;   break;

     case 55: t = 2*t;  bpm = 2*bpm; break;

     default: t= t;   bpm = bpm; 
     }
     
      
      
      for ( Sphery s: spherys){
      s.setVibrationPeriod(480000/bpm);
      s.vibration.setBasis(t);
       }
     sinespin.reset()
     
    
     // Translate so the center of the car is the origin, offset 
      .center()
     // .scale(1.3,1.3,1.3)
      // Rotate around the origin (now the center of the car) about an y-vector
      .rotate(yrot.getValuef(), rotationx.getValuef(), rotationy.getValuef() , rotationz.getValuef())
      .translate(model.cx, model.cy, model.cz);
      

   
   

     for (LXVector p: sinespin)
   // for (Point p: model.points)
     {
       P.set(p.x, p.y, p.z);
      // PVector P = new PVector(p.x, p.y, p.z);
    color c = #000000;
    c = blendIfColor(c, spherys[1].spheryvalue(P, .75*model.xMax, model.yMax/2, model.zMax/2), ADD);
    c = blendIfColor(c, spherys[0].spheryvalue(P, model.xMax/4, model.yMax/4, model.zMax/2), ADD);
    c = blendIfColor(c, spherys[2].spheryvalue(P, model.xMax/2, model.yMax/2, model.zMax/2),ADD);
    

    colors[p.index] = c;
    
      
               }
   sinespin2.reset()
   .center()
   .rotate(yrot.getValuef(), rotationx.getValuef(), rotationy.getValuef() , rotationz.getValuef())
   .translate(model.cx,model.cy,model.cz);

    for (LXVector p: sinespin2)
    {   color c = 0;
      // PVector P = new PVector(p.x, p.y, p.z);
        P.set(p.x, p.y, p.z);
        c = blendIfColor(c, spherys[3].spheryvalue(P, .3*model.xMax, .7*model.yMax, .6*model.zMax),ADD);
         
        colors[p.index] = blendIfColor(colors[p.index], c , ADD);

    }  

  }
  
  color blendIfColor(color c1, color c2, int mode) {
    if (c2 != 0) {
      return blendColor(c1, c2, mode);
    }
    return c1;
  }
  

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
  centerlist.add(new PVector(a.cx, a.cy, a.cz) );
  
} 

}
//there is definitely a better way of doing this!
PVector centerofcube(int i) { 
Cube c = model.cubes.get(i);

println(" cube #:  " + i + " c.x  "  +  c.x  + "  c.y   "  + c.y   + "  c.z  "  +   c.z  );
// PVector cubeangle = new PVector(c.rx, c.ry, c.rz);
println("raw x angle:  " + c.rx + "raw y angle:  " + c.ry + "raw z angle:  " + c.rz);
PVector cubecenter = new PVector(c.x + CW/2, c.y + CH/2, c.z + CW/2);
println("cubecenter unrotated:  "  + cubecenter.x + "  "  +cubecenter.y + "  " +cubecenter.z );
PVector centerrot = new PVector(cos(c.rx)*CW/2 - sin(c.rx)*CW/2, cubecenter.y, cos(c.rz)*CW/2 + sin(c.rz)*CW/2);
 // nCos*(y-o.y) - nSin*(z-o.z) + o.y
cubecenter = PVector.add(new PVector(c.x, c.y, c.z), centerrot);
println( "  cubecenter.x  " + cubecenter.x  + " cubecenter.y  " +  cubecenter.y + " cubecenter.z  "   +  cubecenter.z  + "   ");


return cubecenter;
}


void run(double deltaMs){
for (int i =0; i < model.cubes.size(); i++)  {
Cube c = model.cubes.get(i);
float cfloor = c.y;

// if (i%3 == 0){

// for (LXPoint p : c.points ){
//  // colors[p.index]=color(0,0,0);
//   //float dif = (p.y - c.y);
//   //colors[p.index] = color( bg.getValuef() , 80 , dif < curl.getValuef() ? 80 : 0, ADD);
//    }
//  }

// else if (i%3 == 1) {
  
//  for (LXPoint p: c.points){
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
   for (LXPoint p: c.points) {
    PVector pv = new PVector(p.x, p.y, p.z);
     colors[p.index] =color( constrain(4* pv.dist(centerlist.get(i)), 0, 360)  , 50, 100 );
   // colors[p.index] =color(constrain(centerlist[i].x, 0, 360), constrain(centerlist[i].y, 0, 100),  );


    }


  //}

   }
  }
 }

 class HueTestHSB extends SCPattern{
  BasicParameter HueT = new BasicParameter("Hue", .5);
  BasicParameter SatT = new BasicParameter("Sat", .5);
  BasicParameter BriT = new BasicParameter("Bright", .5);

HueTestHSB(GLucose glucose) {
  super(glucose);
  addParameter(HueT);
  addParameter(SatT);
  addParameter(BriT);
}
  void run(double deltaMs){

  for (LXPoint p : model.points) {
    color c = 0;
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
