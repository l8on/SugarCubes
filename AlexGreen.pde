class SineSphere extends DPat {
 float modelrad = sqrt((model.xMax)*(model.xMax) + (model.yMax)*(model.yMax) + (model.zMax)*(model.zMax));
 //PVector modelcenter = new PVector(model.xMax, model.yMax, model.zMax);
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
   addParameter(bounceamp = new BasicParameter("Amp", .5));
   addParameter(bouncerate = new BasicParameter("Rate", .5));  //ybounce.modulateDurationBy(bouncerate);
   addParameter(widthparameter = new BasicParameter("Width", .1));
   addParameter(huespread = new BasicParameter("Hue", .2));
  
   addModulator( vx = new SinLFO(-4000, 10000, 100000)).trigger() ;
   //addModulator(xbounce = new SinLFO(model.xMax/3, 2*model.yMax/3, 2000)).trigger(); 
   addModulator(ybounce= new SinLFO(model.yMax/3, 2*model.yMax/3, 240000./lx.tempo.bpm())).trigger(); //ybounce.modulateDurationBy
    
   //addModulator(bounceamp); //ybounce.setMagnitude(bouncerate);
   addModulator( vibration = new SinLFO(vibration_min , vibration_max, 240000./lx.tempo.bpm())).trigger(); //vibration.modulateDurationBy(vx);
   
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
   addParameter(widthparameter = new BasicParameter("Width", .1));
   addParameter(huespread = new BasicParameter("Hue", .2));
  
}





float distfromcirclecenter(float px, float py, float pz, float f1x, float f1y, float f1z) 
{
   return dist(px, py, pz, f1x, f1y, f1z);
    }
 //void updatespherey(deltaMs, )
 color spheryvalue (float px, float py, float pz , float f1xc, float f1yc, float f1zc) 
 {
//switch(sShpape.cur() ) {}  
   return color(constrain(huespread.getValuef()*5*px, 0, 360) , dist(px, py, pz, f1xc, f1yc, f1zc) , 
    max(0, 100 - 100*widthparameter.getValuef()*abs(dist(px, py, pz, f1xcenter, ybounce.getValuef(), f1zcenter)
      - vibration.getValuef() ) ) ); 
 }
 color ellipsevalue(float px, float py, float pz , float f1xc, float f1yc, float f1zc, float f2xc, float f2yc, float f2zc)
  {
//switch(sShpape.cur() ) {}  
   return color(huespread.getValuef()*5*px, dist(model.xMax-px, model.yMax-py, model.zMax-pz, f1xc, f1yc, f1zc) , 
    max(0, 100 - 100*widthparameter.getValuef() *
      abs( (dist(px, py, pz, f1xc, ybounce.getValuef(), f1zc) + 
        (dist(px, py , pz, f2xc, ybounce.getValuef(), f2zc) ) )/2  
      - 1.2*vibration.getValuef() ) ) ) ; 
  }


   void run(int deltaMS) { };
  
}  


final Sphery[] spherys;
  SineSphere(GLucose glucose) 
  {
    super(glucose);
    //Sshape = addPick("Shape", , 1);
    spherys = new Sphery[] {
      new Sphery(model.xMax/4, model.yMax/2, model.zMax/2, modelrad/16, modelrad/8, 3000),
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

     void StartRun(int deltaMs) {
     float t = lx.tempo.rampf();
     float bpm = lx.tempo.bpmf();
     //spherys[1].run(deltaMs);
     //spherys[2].run(deltaMs);
     //spherys[3].run(deltaMs);
  
       


  }
  int spheremode = 0;
  
   // void keyPressed() {
   //   spheremode++;
   //     }

  color CalcPoint(xyz Px) 
  { 
       // if (spheremode == 0 )
              //{
             color c = 0;
             c = blendColor(c, spherys[1].spheryvalue(Px.x, Px.y, Px.z, .75*model.xMax, model.yMax/2, model.zMax/2), ADD);
             c = blendColor(c, spherys[0].spheryvalue(Px.x, Px.y, Px.z, model.xMax/4, model.yMax/4, model.zMax/2), ADD);
             c = blendColor(c, spherys[2].spheryvalue(Px.x, Px.y, Px.z, model.xMax/2, model.yMax/2, model.zMax/2),ADD);
             return c;
             //}
      //   else if (spheremode == 1)
      // {

      //   color c = 0;
      //   c = blendColor(c, spherys[3].ellipsevalue(Px.x, Px.y, Px.z, model.xMax/4, model.yMax/4, model.zMax/4, 3*model.xMax/4, 3*model.yMax/4, 3*model.zMax/4),ADD);
      //   return c; 
      // }
      // return color(0,0,0);
      //  // else if(spheremode ==2)
       // { color c = 0;
       //   return color(CalcCone( (xyz by = new xyz(0,spherys[2].ybounce.getValuef(),0) ), Px, mid) );

       // }

  
          } 
        
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
 this.diag = sqrt(CH*CH + CW*CW + CW*CW);


ArrayList<PVector> centerlistrelative = new ArrayList<PVector>();
for (int i = 0; i < model.cubes.size(); i++){
  Cube a = model.cubes.get(i);
  cubeorigin.add(new PVector(a.x, a.y, a.z));
  centerlist.add(centerofcube(i));
  
} 

}
//there is definitely a better way of doing this!
PVector centerofcube(int i) { 
Cube c = model.cubes.get(i);
PVector cubeangle = new PVector(c.rx, c.ry, c.rz);
println("raw x" + cubeangle.x + "raw y" + cubeangle.y + "raw z" + cubeangle.z);
cubeangle.normalize();
println( "norm"+ cubeangle.x + "norm" + cubeangle.y +"norm" + cubeangle.z);
PVector cubecenter = PVector.add(cubeorigin.get(i), PVector.mult(cubeangle, diag));

//PVector cubecenter = new PVector(c.x+ CW/2, c.y + CH/2, c.z + CW/2);
//println("cubecenter raw" + " : " +  cubecenter.x + "  " + cubecenter.y + "  " + cubecenter.z ); 
//PVector cubecenterf = new PVector(cubecenter.x + cos(c.ry)*CW/2, cubecenter.y , cubecenter.z - tan(c.ry) * CW/2);
//println("cubecenter angled" + " : " +  cubecenterf.x + "  " + cubecenterf.y + "  " + cubecenterf.z );
return cubecenter;
}


void run(double deltaMs){
for (int i =0; i < model.cubes.size(); i++)  {
Cube c = model.cubes.get(i);
float cfloor = c.y;

if (i%3 == 0){

for (Point p : c.points ){
 // colors[p.index]=color(0,0,0);
  //float dif = (p.y - c.y);
  //colors[p.index] = color( bg.getValuef() , 80 , dif < curl.getValuef() ? 80 : 0, ADD);
   }
 }

else if (i%3 == 1) {
  
 for (Point p: c.points){
  colors[p.index]=color(0,0,0);
  float dif = (p.y - c.y);
  // colors[p.index] = 
  // color(bg.getValuef(),
  //   map(curl.getValuef(), 0, Cube.EDGE_HEIGHT, 20, 100), 
  //   100 - 10*abs(dif - curl.getValuef()), ADD );
     }
    }
else if (i%3 == 2){
 // centerlist[i].sub(cubeorigin(i);
   for (Point p: c.points) {
    PVector pv = new PVector(p.x, p.y, p.z);
     colors[p.index] =color( constrain(5*pv.dist(centerlist.get(i)), 0, 360)  , 50, 100 );
   // colors[p.index] =color(constrain(centerlist[i].x, 0, 360), constrain(centerlist[i].y, 0, 100),  );


    }


  }

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

  for (Point p : model.points) {
    color c = 0;
    c = blendColor(c, color(360*HueT.getValuef(), 100*SatT.getValuef(), 100*BriT.getValuef()), ADD);
    colors[p.index]= c;
  }
   int now= millis();
   if (now % 1000 <= 20)
   {
   println("Hue: " + 360*HueT.getValuef() + "Sat: " + 100*SatT.getValuef() + "Bright:  " + 100*BriT.getValuef());
   }
  }

 }