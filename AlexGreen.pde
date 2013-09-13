class SineSphere extends DPat {
 float modelrad = sqrt((model.xMax)*(model.xMax) + (model.yMax)*(model.yMax) + (model.zMax)*(model.zMax));
 //PVector modelcenter = new PVector(model.xMax, model.yMax, model.zMax);
 
  class Sphery {
  float f1xcenter, f1ycenter, f1zcenter, f2xcenter, f2ycenter, f2zcenter; //second two are for an ellipse with two foci
  private  SinLFO vibration; 
  private  SinLFO surface;
  private  SinLFO vx;
  private SinLFO xbounce;
  public SinLFO ybounce = new SinLFO(model.yMax/3, 2*model.yMax/3, 2000);
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
   addParameter( bouncerate = new BasicParameter("Rate", .5));
   addParameter(widthparameter = new BasicParameter("Width", .1));
   addParameter(huespread = new BasicParameter("Hue", .2));
  
   addModulator( vx = new SinLFO(-4000, 10000, 100000)).trigger() ;
   //addModulator(xbounce = new SinLFO(model.xMax/3, 2*model.yMax/3, 2000)).trigger(); 
   addModulator(ybounce).trigger(); //ybounce.modulateDurationBy
   addParameter(bouncerate); //ybounce.modulateDurationBy(bouncerate);
   //addModulator(bounceamp); //ybounce.setMagnitude(bouncerate);
   addModulator( vibration = new SinLFO(vibration_min , vibration_max, vperiod)).trigger(); //vibration.modulateDurationBy(vx);
   
  }
 public Sphery(float f1xcenter, float f1ycenter, float f1zcenter, float f2xcenter, float f2ycenter, float f2zcenter, 
  float vibration_min, float vibration_max, float vperiod)  {
    this.f1xcenter = f1xcenter;
   this.f1ycenter = f1ycenter;
   this.f1zcenter = f1zcenter;
   this.f2xcenter = f2xcenter;
   this.f2ycenter = f2ycenter;
   this.f2zcenter = f2zcenter;
   this.vibration_min = vibration_min;
   this.vibration_max = vibration_max;
   this.vperiod = vperiod;
   addModulator( vx = new SinLFO(-4000, 10000, 100000)).trigger();
   //addModulator(xbounce = new SinLFO(model.xMax/3, 2*model.yMax/3, 2000)).trigger(); 
   addModulator(ybounce).trigger(); 
   addModulator( vibration = new SinLFO(vibration_min , vibration_max, vperiod)).trigger(); //vibration.modulateDurationBy(vx);
   addParameter(widthparameter = new BasicParameter("Width", .1));
   addParameter(huespread = new BasicParameter("Hue", .2));
  
}


public void onParameterChanged(LXParameter parameter){
     double bampv = bounceamp.getValue();
      double brv = bouncerate.getValue();
     if (parameter == bounceamp) {
      
    //  ybounce.setRange(bampv*model.yMax/3 , bampv*2*model.yMax/3));
       }
  else if ( parameter == bouncerate ){
      ybounce.setDuration(brv*2000);

    }
  }


float distfromcirclecenter(float px, float py, float pz, float f1x, float f1y, float f1z) {
   return dist(px, py, pz, f1x, f1y, f1z);
    }
 //void updatespherey(deltaMs, )
 color spheryvalue (float px, float py, float pz , float f1xc, float f1yc, float f1zc) {
//switch(sShpape.cur() ) {}  
   return color(huespread.getValuef()*5*px, dist(px, py, pz, f1xc, f1yc, f1zc) , 
    max(0, 100 - 100*widthparameter.getValuef()*abs(dist(px, py, pz, f1xcenter, ybounce.getValuef(), f1zcenter)
      - vibration.getValuef() ) ) ); 
 }
 color ellipsevalue(float px, float py, float pz , float f1xc, float f1yc, float f1zc, float f2xc, float f2yc, float f2zc) {
//switch(sShpape.cur() ) {}  
   return color(huespread.getValuef()*5*px, dist(model.xMax-px, model.yMax-py, model.zMax-pz, f1xc, f1yc, f1zc) , 
    max(0, 100 - 100*widthparameter.getValuef() *
      abs( (dist(px, py, pz, f1xcenter, ybounce.getValuef(), f1zcenter) + 
        (dist(px, py , pz, f2xcenter, ybounce.getValuef(), f2zcenter) ) )/2   
      - vibration.getValuef() ) ) ) ; 
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
   
    spherys = new Sphery[NUM_SPHERES];
    spherys[1] = new Sphery(model.xMax/4, model.yMax/2, model.zMax/2, modelrad/16, modelrad/8, 3000) ;    
    spherys[2] = new Sphery(.75*model.xMax, model.yMax/2, model.zMax/2, modelrad/20, modelrad/10, 2000);
    spherys[3] = new Sphery(model.xMax/2, model.yMax/2, model.zMax/2, modelrad/4, modelrad/8, 2300);
  
  }



    public void StartRun(int deltaMs) {
		
		spherys[1].run(deltaMs);
		spherys[2].run(deltaMs);
    spherys[3].run(deltaMs);
	}

	
	color CalcPoint(xyz Px) {

      color c = 0; 
      
      c = blendColor(c, spherys[2].spheryvalue(Px.x, Px.y, Px.z, .75*model.xMax, model.yMax/2, model.zMax/2), ADD);
      c = blendColor(c, spherys[1].spheryvalue(Px.x, Px.y, Px.z, model.xMax/4, model.yMax/4, model.zMax/2), ADD);
      c = blendColor(c, spherys[3].spheryvalue(Px.x, Px.y, Px.z, model.xMax/2, model.yMax/2, model.zMax/2),ADD);
      

  
      
	 return c;
    }
  }


