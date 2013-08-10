class WarmPlasma extends SCPattern {
  private int pos = 0;
  private float satu = 100;
  private float speed = 1;
  private float glitch = 0;
  BasicParameter saturationParameter = new BasicParameter("SATU", 1.0);
  BasicParameter speedParameter = new BasicParameter("SPEED", 0.1);
  BasicParameter glitchParameter = new BasicParameter("GLITCH", 0.0);
  
  public WarmPlasma(GLucose glucose) {
    super(glucose);
    addParameter(saturationParameter);
    addParameter(speedParameter);
    addParameter(glitchParameter);
  }
  public void onParameterChanged(LXParameter parameter) {
    if (parameter == saturationParameter) {
      satu = 100*parameter.getValuef();
    } else if (parameter == speedParameter) {
      speed = 10*parameter.getValuef();
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
    if (random(1.0)<glitch/10) {
      pos=pos-20;
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

