class SpaceTime extends SCPattern {

  SinLFO pos = new SinLFO(0, 15, 3000);
  SinLFO rate = new SinLFO(1000, 9000, 13000);
  SinLFO falloff = new SinLFO(10, 70, 5000);
  float sat = 0;
  
  BasicKnob rateKnob = new BasicKnob("RATE", 0.5);
  BasicKnob sizeKnob = new BasicKnob("SIZE", 0.5);

  public SpaceTime(GLucose glucose) {
    super(glucose);
    addModulator(pos).trigger();
    addModulator(rate).trigger();
    addModulator(falloff).trigger();    
    pos.modulateDurationBy(rate);
    addKnob(rateKnob);
    addKnob(sizeKnob);
  }
  
  public void onKnobChange(Knob knob) {
    if (knob == rateKnob) {
        rate.stop().setValue(9000 - 8000*knob.getValuef());
    } else if (knob == sizeKnob) {
        falloff.stop().setValue(70 - 60*knob.getValuef());
    }
  }

  void run(int deltaMs) {    
    sat += deltaMs * 0.00004;
    float sVal1 = Strip.list.size() * (0.5 + 0.5*sin(sat));
    float sVal2 = Strip.list.size() * (0.5 + 0.5*cos(sat));

    float pVal = pos.getValuef();
    float fVal = falloff.getValuef();

    int s = 0;
    for (Strip strip : Strip.list) {
      int i = 0;
      for (Point p : strip.points) {
        colors[p.index] = color(
        (lx.getBaseHuef() + s*.2 + i*3) % 360, 
        min(100, min(abs(s - sVal1), abs(s - sVal2))), 
        max(0, 100 - fVal*abs(i - pVal))
          );
        ++i;
      }
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
  SwipeTransition(GLucose glucose) {
    super(glucose);
    setDuration(5000);
  }

  void computeBlend(int[] c1, int[] c2, double progress) {
    float bleed = 50.;
    float yPos = (float) (-bleed + progress * (255. + bleed));
    for (Point p : Point.list) {
      float d = (p.fy - yPos) / 50.;
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

class CubeEQ extends SCPattern {

  private FFT fft = null; 
  private LinearEnvelope[] bandVals = null;
  private int avgSize;

  private final BasicKnob thrsh = new BasicKnob("LVL", 0.35);
  private final BasicKnob range = new BasicKnob("RANG", 0.45);
  private final BasicKnob edge = new BasicKnob("EDGE", 0.5);
  private final BasicKnob speed = new BasicKnob("SPD", 0.5);
  private final BasicKnob tone = new BasicKnob("TONE", 0.5);
  private final BasicKnob clr = new BasicKnob("CLR", 0.5);

  public CubeEQ(GLucose glucose) {
    super(glucose);
    addKnob(thrsh);
    addKnob(range);
    addKnob(edge);
    addKnob(speed);
    addKnob(tone);
    addKnob(clr);
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
      } else {
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

