class SineSphere extends SCPattern {
  float modelrad = sqrt((model.xMax)*(model.xMax) + (model.yMax)*(model.yMax) + (model.zMax)*(model.zMax));
  private final SinLFO rs = new SinLFO(0, 180, 5000);
  private final SinLFO noisey = new SinLFO(modelrad/8.0, modelrad/4.0, 2300);
  private final SinLFO band = new SinLFO (0, 10, 2000);
  PVector modelcenter = new PVector(model.xMax, model.yMax, model.zMax);
  BasicParameter widthparameter = new BasicParameter("Width", 10);
  
  
  class Sphery {
  float f1xcenter, f1ycenter, f1zcenter, f2xcenter, f2ycenter, f2zcenter;
  private  SinLFO vibration; 
  private  SinLFO surface;
  private  SinLFO vx;
  float vibration_min, vibration_max, vperiod;
  
  Sphery(float f1xcenter, float f1ycenter, float f1zcenter, float vibration_min, float vibration_max, float vperiod) {
   this.f1xcenter = f1xcenter;
   this.f1ycenter = f1ycenter;
   this.f1zcenter = f1zcenter;
   this.vibration_min = vibration_min;
   this.vibration_max = vibration_max;
   this.vperiod = vperiod;
   addModulator( vibration = new SinLFO(vibration_min , vibration_max, vperiod)).trigger(); vibration.modulateDurationBy(vx);
   addModulator( vx = new SinLFO(-1000, 1000, 10000)).trigger();
 }
    float distfromcirclecenter(float px, float py, float pz, float f1x, float f1y, float f1z) {
   return dist(px, py, pz, f1x, f1y, f1z);
    }
 
 color spheryvalue (float px, float py, float pz , float f1xcenter, float f1ycenter, float f1zcenter) {

   return color(px, dist(px, py, pz, f1xcenter, f1ycenter, f1zcenter) , max(0, 100 - 10*abs(dist(px, py, pz, f1xcenter, f1ycenter, f1zcenter)- vibration.getValuef() ) ) ); 
   
 }
   
  void run(int deltaMS) {
    final float vv = vibration.getValuef();
    final float vvx = vx.getValuef();
  }
  
  }
final int NUM_SPHERES = 5;
final Sphery[] spherys;
  SineSphere(GLucose glucose) {
    super(glucose);
    addModulator(rs).trigger();
    //addModulator(band).trigger();
    addModulator(noisey).trigger();
    spherys = new Sphery[NUM_SPHERES];
    spherys[1] = new Sphery(model.xMax/4, model.yMax/2, model.zMax/2, modelrad/16, modelrad/8, 2500) ;    
    spherys[2] = new Sphery(.75*model.xMax, model.yMax/2, model.zMax/2, modelrad/20, modelrad/10, 2000);
  }

    public void run(int deltaMs) {
    float rsv = rs.getValuef();
    float noiseyv = noisey.getValuef();
    float bandv = band.getValuef();
     
      spherys[1].run(deltaMs);
      spherys[2].run(deltaMs);
     
       for (Point p: model.points) {
       
      color c = 0; 
      
      c = blendColor(c, spherys[2].spheryvalue(p.fx, p.fy, p.fz, .75*model.xMax, model.yMax/2, model.zMax/2), ADD);
      c = blendColor(c, spherys[1].spheryvalue(p.fx, p.fy, p.fz, model.xMax/4, model.yMax/4, model.zMax/2), ADD);
      float distfromcenter = dist(p.fx, p.fy, p.fz, model.xMax/2, model.yMax/2, model.zMax/2);
      int distint = floor(distfromcenter);
      
      c = blendColor(c, color(
      
      constrain( p.fx  , 0, 360), 
      constrain( distfromcenter, 20, 80), 
      max(0, 100 - 10*abs(distfromcenter - noiseyv ) )
      ),
      ADD);
      
 
      colors[p.index]=c;
    }
  }
}

