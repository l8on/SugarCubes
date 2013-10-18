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

  public void run(double deltaMs) {
    for (Point p : model.points) {
      float hv = sin(dist(p.x + pos, p.y, 128.0, 128.0) / 8.0)
	  + sin(dist(p.x, p.y, 64.0, 64.0) / 8.0)
	  + sin(dist(p.x, p.y + pos / 7, 192.0, 64.0) / 7.0)
	  + sin(dist(p.x, p.z + pos, 192.0, 100.0) / 8.0);
      float bv = 100;
      colors[p.index] = lx.hsb((hv+2)*50, satu, bv);
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
    if (level<=0) return lx.hsb(0,0,0);
    float br=min(100,sqrt(level)*15);
    return lx.hsb(level/1.7,100,br);
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
      int x = max(0,(int(p.x)+int(p.z))%xm);
      int y = constrain(ym-int(p.y),0,ym-1);
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
        float avgdist=0.0;
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
  BasicParameter gainParameter = new BasicParameter("GAIN", 0.5);
  
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
            int seq = int(p.y*avgSize/model.yMax+pos.getValuef()+sin(p.x+p.z)*2)%avgSize;
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
  BasicParameter gainParameter = new BasicParameter("GAIN", 0.5);
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
            int seq = int((dis*avgSize*2)/model.xMax);
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

