class SpaceTime extends SCPattern {

  SinLFO pos = new SinLFO(0, 15, 3000);
  SinLFO rate = new SinLFO(1000, 9000, 13000);
  SinLFO falloff = new SinLFO(10, 70, 5000);
  float angle = 0;

  BasicParameter rateParameter = new BasicParameter("RATE", 0.5);
  BasicParameter sizeParameter = new BasicParameter("SIZE", 0.5);

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

  void run(int deltaMs) {    
    angle += deltaMs * 0.0007;
    float sVal1 = Strip.list.size() * (0.5 + 0.5*sin(angle));
    float sVal2 = Strip.list.size() * (0.5 + 0.5*cos(angle));

    float pVal = pos.getValuef();
    float fVal = falloff.getValuef();

    int s = 0;
    for (Strip strip : Strip.list) {
      int i = 0;
      for (Point p : strip.points) {
        colors[p.index] = color(
        (lx.getBaseHuef() + 360 - p.fy*.2 + p.fz * .3) % 360, 
        constrain(.4 * min(abs(s - sVal1), abs(s - sVal2)), 20, 100),
        max(0, 100 - fVal*abs(i - pVal))
          );
        ++i;
      }
      ++s;
    }
  }
}

class Swarm extends SCPattern {

  SawLFO offset = new SawLFO(0, 16, 1000);
  SinLFO rate = new SinLFO(350, 1200, 63000);
  SinLFO falloff = new SinLFO(15, 50, 17000);
  SinLFO fY = new SinLFO(0, 250, 19000);
  SinLFO fZ = new SinLFO(0, 127, 11000);
  SinLFO hOffY = new SinLFO(0, 255, 13000);

  public Swarm(GLucose glucose) {
    super(glucose);
    addModulator(offset).trigger();
    addModulator(rate).trigger();
    addModulator(falloff).trigger();
    addModulator(fY).trigger();
    addModulator(fZ).trigger();
    addModulator(hOffY).trigger();
    offset.modulateDurationBy(rate);
  }

  float modDist(float v1, float v2, float mod) {
    v1 = v1 % mod;
    v2 = v2 % mod;
    if (v2 > v1) {
      return min(v2-v1, v1+mod-v2);
    } 
    else {
      return min(v1-v2, v2+mod-v1);
    }
  }

  void run(int deltaMs) {
    float s = 0;
    for (Strip strip : Strip.list) {
      int i = 0;
      for (Point p : strip.points) {
        float fV = max(-1, 1 - dist(p.fy/2., p.fz, fY.getValuef()/2., fZ.getValuef()) / 64.);
        colors[p.index] = color(
        (lx.getBaseHuef() + 0.3 * abs(p.fy - hOffY.getValuef())) % 360, 
        constrain(80 + 40 * fV, 0, 100), 
        constrain(100 - (30 - fV * falloff.getValuef()) * modDist(i + (s*63)%61, offset.getValuef(), 16), 0, 100)
          );
        ++i;
      }
      ++s;
    }
  }
}

class SwipeTransition extends SCTransition {
  
  final BasicParameter bleed = new BasicParameter("WIDTH", 0.5);
  
  SwipeTransition(GLucose glucose) {
    super(glucose);
    setDuration(5000);
    addParameter(bleed);
  }

  void computeBlend(int[] c1, int[] c2, double progress) {
    float bleedf = 10 + bleed.getValuef() * 200.;
    float yPos = (float) (-bleedf + progress * (255. + bleedf));
    for (Point p : Point.list) {
      float d = (p.fy - yPos) / bleedf;
      if (d < 0) {
        colors[p.index] = c2[p.index];
      } 
      else if (d > 1) {
        colors[p.index] = c1[p.index];
      } 
      else {
        colors[p.index] = lerpColor(c2[p.index], c1[p.index], d, RGB);
      }
    }
  }
}

class CubeEQ extends SCPattern {

  private FFT fft = null; 
  private LinearEnvelope[] bandVals = null;
  private int avgSize;

  private final BasicParameter thrsh = new BasicParameter("LVL", 0.35);
  private final BasicParameter range = new BasicParameter("RANG", 0.45);
  private final BasicParameter edge = new BasicParameter("EDGE", 0.5);
  private final BasicParameter speed = new BasicParameter("SPD", 0.5);
  private final BasicParameter tone = new BasicParameter("TONE", 0.5);
  private final BasicParameter clr = new BasicParameter("CLR", 0.5);

  public CubeEQ(GLucose glucose) {
    super(glucose);
    addParameter(thrsh);
    addParameter(range);
    addParameter(edge);
    addParameter(speed);
    addParameter(tone);
    addParameter(clr);
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
    }
  }

  public void run(int deltaMs) {
    this.fft.forward(this.lx.audioInput().mix);
    float toneConst = .35 + .4 * (tone.getValuef() - 0.5);
    float edgeConst = 2 + 30*(edge.getValuef()*edge.getValuef()*edge.getValuef());

    for (int i = 0; i < avgSize; ++i) {
      float value = this.fft.getAvg(i);
      value = 20*log(1 + sqrt(value));
      float sqdist = avgSize - i;
      value -= toneConst*sqdist*sqdist + .5*sqdist;
      value *= 6;
      if (value > this.bandVals[i].getValue()) {
        this.bandVals[i].setEndVal(value, 40).trigger();
      } 
      else {
        this.bandVals[i].setEndVal(value, 1000 - 900*speed.getValuef()).trigger();
      }
    }

    float jBase = 120 - 360*thrsh.getValuef();
    float jConst = 300.*(1-range.getValuef());
    float clrConst = 1.1 + clr.getValuef();

    for (Point p : Point.list) {
      float avgIndex = constrain((p.fy / 256. * avgSize), 0, avgSize-2);
      int avgFloor = (int) avgIndex;
      float j = jBase + jConst * (p.fz / 128.);
      float value = lerp(
      this.bandVals[avgFloor].getValuef(), 
      this.bandVals[avgFloor+1].getValuef(), 
      avgIndex-avgFloor
        );

      float b = constrain(edgeConst * (value - j), 0, 100);
      colors[p.index] = color(
      (480 + lx.getBaseHuef() - min(clrConst*p.fz, 120)) % 360, 
      100, 
      b);
    }
  }
}

class BoomEffect extends SCEffect {

  final BasicParameter falloff = new BasicParameter("WIDTH", 0.5);
  final BasicParameter speed = new BasicParameter("SPD", 0.5);
  final BasicParameter bright = new BasicParameter("BRT", 1.0);
  final BasicParameter sat = new BasicParameter("SAT", 0.2);
  List<Layer> layers = new ArrayList<Layer>();

  class Layer {
    LinearEnvelope boom = new LinearEnvelope(-40, 500, 1300);

    Layer() {
      addModulator(boom);
      trigger();
    }

    void trigger() {
      float falloffv = falloffv();
      boom.setRange(-100 / falloffv, 500 + 100/falloffv, 4000 - speed.getValuef() * 3300);
      boom.trigger();
    }

    void doApply(int[] colors) {
      float brightv = 100 * bright.getValuef();
      float falloffv = falloffv();
      float satv = sat.getValuef() * 100;
      float huev = lx.getBaseHuef();
      for (Point p : Point.list) {
        colors[p.index] = blendColor(
        colors[p.index], 
        color(huev, satv, constrain(brightv - falloffv*abs(boom.getValuef() - dist(2*p.fx, p.fy, 2*p.fz, 128, 128, 128)), 0, 100)), 
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

  public void doApply(int[] colors) {
    for (Layer l : layers) {
      if (l.boom.isRunning()) {
        l.doApply(colors);
      }
    }
  }
}

public class PianoKeyPattern extends SCPattern {
  
  final LinearEnvelope[] cubeBrt;
  final SinLFO base[];  
  final BasicParameter attack = new BasicParameter("ATK", 0.1);
  final BasicParameter release = new BasicParameter("REL", 0.5);
  final BasicParameter level = new BasicParameter("AMB", 0.6);
  
  PianoKeyPattern(GLucose glucose) {
    super(glucose);
    
    for (MidiInputDevice input : RWMidi.getInputDevices()) {
      input.createInput(this);
    }
    
    addParameter(attack);
    addParameter(release);
    addParameter(level);
    cubeBrt = new LinearEnvelope[Cube.list.size() / 4];
    for (int i = 0; i < cubeBrt.length; ++i) {
      addModulator(cubeBrt[i] = new LinearEnvelope(0, 0, 100));
    }
    base = new SinLFO[Cube.list.size() / 12];
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
    
  public void noteOnReceived(Note note) {
    LinearEnvelope env = getEnvelope(note.getPitch());
    env.setEndVal(min(1, env.getValuef() + (note.getVelocity() / 127.)), getAttackTime()).start();
  }
  
  public void noteOffReceived(Note note) {
    getEnvelope(note.getPitch()).setEndVal(0, getReleaseTime()).start();
  }
  
  public void run(int deltaMs) {
    int i = 0;
    float huef = lx.getBaseHuef();
    float levelf = level.getValuef();
    for (Cube c : Cube.list) {
      float v = max(getBase(i).getValuef() * levelf/4., getEnvelope(i++).getValuef());
      setColor(c, color(
        (huef + 20*v + abs(c.fy-128.)*.3 + c.fz) % 360,
        min(100, 120*v),
        100*v
      ));
    }
  }
}

class CrossSections extends SCPattern {
  
  final SinLFO y = new SinLFO(0, 255, 5000);
  final SinLFO z = new SinLFO(0, 127, 6000);
  final SinLFO x = new SinLFO(0, 127, 7000);
  
  final BasicParameter xw = new BasicParameter("XWID", 0.3);
  final BasicParameter yw = new BasicParameter("YWID", 0.3);
  final BasicParameter zw = new BasicParameter("ZWID", 0.3);  
  final BasicParameter xr = new BasicParameter("XRAT", 0.5);
  final BasicParameter yr = new BasicParameter("YRAT", 0.6);
  final BasicParameter zr = new BasicParameter("ZRAT", 0.7);
  final BasicParameter xl = new BasicParameter("XLEV", 0.5);
  final BasicParameter yl = new BasicParameter("YLEV", 1);
  final BasicParameter zl = new BasicParameter("ZLEV", 1);

  
  CrossSections(GLucose glucose) {
    super(glucose);
    addModulator(x).trigger();
    addModulator(y).trigger();
    addModulator(z).trigger();
    addParameter(xr);
    addParameter(yr);
    addParameter(zr);    
    addParameter(yw);
    addParameter(xl);
    addParameter(yl);
    addParameter(zl);
    addParameter(zw);    
    addParameter(xw);
  }
  
  void onParameterChanged(LXParameter p) {
    if (p == xr) {
      x.setDuration(10000 - 9000*p.getValuef());
    } else if (p == yr) {
      y.setDuration(10000 - 8800*p.getValuef());
    } else if (p == zr) {
      z.setDuration(10000 - 9000*p.getValuef());
    }
      
  }

  public void run(int deltaMs) {
    float xv = x.getValuef();
    float yv = y.getValuef();
    float zv = z.getValuef();    
    float xlv = 100*xl.getValuef();
    float ylv = 100*yl.getValuef();
    float zlv = 100*zl.getValuef();
    
    float xwv = 100. / (10 + 40*xw.getValuef());
    float ywv = 100. / (10 + 40*yw.getValuef());
    float zwv = 100. / (10 + 40*zw.getValuef());
    
    for (Point p : Point.list) {
      color c = 0;
      c = blendColor(c, color(
      (lx.getBaseHuef() + p.fy/10 + p.fz/3) % 360, 
      constrain(140 - 1.1*abs(p.fy - 127), 0, 100), 
      max(0, ylv - ywv*abs(p.fy - yv))
        ), ADD);
      c = blendColor(c, color(
      (lx.getBaseHuef() + 80 + p.fz/10) % 360, 
      constrain(140 - 2.2*abs(p.fz - 64), 0, 100), 
      max(0, zlv - zwv*abs(p.fz - zv))
        ), ADD); 
      c = blendColor(c, color(
      (lx.getBaseHuef() + 160 + p.fx / 10 + p.fz/2) % 360, 
      constrain(140 - 2.2*abs(p.fx - 64), 0, 100), 
      max(0, xlv - xwv*abs(p.fx - xv))
        ), ADD); 
      colors[p.index] = c;
    }
  }
}

class Blinders extends SCPattern {
    
  final SinLFO m;
  final TriangleLFO r;
  final SinLFO s;
  final TriangleLFO hs;

  public Blinders(GLucose glucose) {
    super(glucose);
    addModulator(m = new SinLFO(0.5, 80, 9000)).trigger();
    addModulator(r = new TriangleLFO(3000, 9000, 21000)).trigger();
    addModulator(s = new SinLFO(-20, 275, 4000)).trigger();
    addModulator(hs = new TriangleLFO(0.1, 0.5, 15000)).trigger();
    m.modulateDurationBy(r);
  }

  public void run(int deltaMs) {
    float hv = lx.getBaseHuef();
    for (Strip strip : Strip.list) {
      int i = 0;
      for (Point p : strip.points) {
        colors[p.index] = color(
          (hv + p.fx + p.fz*hs.getValuef()) % 360, 
          min(100, abs(p.fy - s.getValuef())/2.), 
          max(0, 100 - m.getValuef() * abs(i - 7.5))
        );
        ++i;
      }
    }
  }
}


