class GlitchPlasma extends SCPattern {
  private int pos = 0;
  private float satu = 100;
  private float speed = 1;
  private float glitch = 0;
  BasicParameter saturationParameter = new BasicParameter("SATU", 1.0);
  BasicParameter speedParameter = new BasicParameter("SPEED", 0.1);
  BasicParameter glitchParameter = new BasicParameter("GLITCH", 0.0);
  
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

  public void run(int deltaMs) {
    for (Point p : model.points) {
      float hv = sin(dist(p.fx + pos, p.fy, 128.0, 128.0) / 8.0)
	  + sin(dist(p.fx, p.fy, 64.0, 64.0) / 8.0)
	  + sin(dist(p.fx, p.fy + pos / 7, 192.0, 64.0) / 7.0)
	  + sin(dist(p.fx, p.fz + pos, 192.0, 100.0) / 8.0);
      float bv = 100;
      colors[p.index] = color((hv+2)*25, satu, bv);
    }
    if (random(1.0)<glitch/20) {
      pos=pos-int(random(10,30));
    }
    pos+=speed;
    if (pos >= MAX_INT-1) pos=0;    
  }
}

// This is very much a work in progress. Trying to get a flame effect.
class FireEffect extends SCPattern {
  private float[][] intensity;
  private float hotspot;
  private float decay = 0.3;
  private int xm;
  private int ym;
  BasicParameter decayParameter = new BasicParameter("DECAY", 0.3);
  
  public FireEffect(GLucose glucose) {
    super(glucose);
    xm = int(model.xMax);
    ym = int(model.yMax);
    
    intensity = new float[xm][ym];
    addParameter(decayParameter);
  }
  public void onParameterChanged(LXParameter parameter) {
    if (parameter == decayParameter) {
      decay = parameter.getValuef();
    }
  } 
  private color flameColor(float level) {
    if (level<=0) return color(0,0,0);
    float br=min(100,sqrt(level)*15);
    return color(level/1.7,100,br);
  }
  public void run(int deltaMs) {
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
      int x = max(0,(int(p.fx)+int(p.fz))%xm);
      int y = constrain(ym-int(p.fy),0,ym-1);
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
      colorOffset[i]=random(0,100);
    }
  }
  
  public void run(int deltaMs) {
    float[] bright = new float[model.points.size()];
    for (Strip strip : model.strips) {
      for (int i=0;i<numOsc;i++) {
        float avgdist=0.0;
        avgdist = dist(strip.points.get(8).fx,strip.points.get(8).fy,strip.points.get(8).fz,fX[i].getValuef(),fY[i].getValuef(),fZ[i].getValuef());
        boolean on = avgdist<30;
        float hv = (lx.getBaseHuef()+colorOffset[i])%100;
        float br = max(0,100-avgdist*4);
        for (Point p : strip.points) {
          if (on && br>bright[p.index]) {
            colors[p.index] = color(hv,sat[i].getValuef(),br);
            bright[p.index] = br;
          }
        }
      }
    }
  }
}

class SoundCubes extends SCPattern {

  private FFT fft = null; 
  private LinearEnvelope[] bandVals = null;
  private float[] lightVals = null;
  private int avgSize;
  SawLFO pos = new SawLFO(0, 9, 8000);
  
  public SoundCubes(GLucose glucose) {
    super(glucose);
    addModulator(pos).trigger();
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
  
  public void run(int deltaMs) {
    this.fft.forward(this.lx.audioInput().mix);
    for (int i = 0; i < avgSize; ++i) {
      float value = this.fft.getAvg(i);
      this.bandVals[i].setEndVal(value,40).trigger();
      float lv = min(value*25,100);
      if (lv>lightVals[i]-6) {
        lightVals[i]=lv;
      } else {
        lightVals[i]=lightVals[i]-6;
      }
    }
    for (int i=0; i<model.strips.size(); i++) {
      //Cube c = model.cubes.get(i);
      Strip c = model.strips.get(i);
      int seq=(i+int(pos.getValuef()))%avgSize;
      float mult = 100.0/avgSize;
      for (Point p : c.points) {
        //colors[p.index] = color((avgSize-seq)*mult+bandVals[seq].getValuef(),bandVals[seq].getValuef()*25,bandVals[seq].getValuef()*20+10 );
        colors[p.index] = color((avgSize-seq)*mult,100-lightVals[seq],lightVals[seq]);
      }
    }
  }  
}
