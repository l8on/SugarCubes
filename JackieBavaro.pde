class JackieSquares extends SCPattern {
  private BasicParameter rateParameter = new BasicParameter("RATE", 0.25);
  private BasicParameter maxSpreadParameter = new BasicParameter("SPREAD", 0.25);
  private BasicParameter attackParameter = new BasicParameter("ATTK", 0.3);
  private BasicParameter decayParameter = new BasicParameter("DECAY", 0.2);
  private BasicParameter saturationParameter = new BasicParameter("SAT", 0.7);
    
  SinLFO hueMod = new SinLFO(0, 360, 4000);
  SinLFO spreadMod = new SinLFO(1, 10, 8000);

  
  class FaceFlash {
    Face f;
    float value;
    float hue;
    boolean hasPeaked;
    
    FaceFlash(int n) {
      f = model.faces.get(n % model.faces.size());
      hue = random(360);
      boolean infiniteAttack = (attackParameter.getValuef() > 0.999);
      hasPeaked = infiniteAttack;
      value = (infiniteAttack ? 1 : 0);
    }
    
    // returns TRUE if this should die
    boolean age(double ms) {
      if (!hasPeaked) {
        value = value + (float) (ms / 1000.0f * ((attackParameter.getValuef() + 0.01) * 5));
        if (value >= 1.0) {
          value = 1.0;
          hasPeaked = true;
        }
        return false;
      } else {
        value = value - (float) (ms / 1000.0f * ((decayParameter.getValuef() + 0.01) * 10));
        return value <= 0;
      }
    }
  }
  
  private float leftoverMs = 0;
  private List<FaceFlash> flashes;
  private int faceNum = 0;
  
  public JackieSquares(GLucose glucose) {
    super(glucose);
    addParameter(rateParameter);
    addParameter(attackParameter);
    addParameter(decayParameter);
    addParameter(saturationParameter);
    addModulator(hueMod).trigger();
    addModulator(spreadMod).trigger();

    flashes = new LinkedList<FaceFlash>();
  }
  
  public void run(double deltaMs) {
    leftoverMs += deltaMs;
    float msPerFlash = 1000 / ((rateParameter.getValuef() + .01) * 100);
    while (leftoverMs > msPerFlash) {
      leftoverMs -= msPerFlash;
      faceNum += int(spreadMod.getValuef());
      flashes.add(new FaceFlash(faceNum));
    }
    
    for (LXPoint p : model.points) {
      colors[p.index] = 0;
    }
    
    for (FaceFlash flash : flashes) {
      float hue = (hueMod.getValuef() + flash.hue) % 360.0;
      color c = lx.hsb(hue, saturationParameter.getValuef() * 100, (flash.value) * 100);
      for (LXPoint p : flash.f.points) {
        colors[p.index] = c;
      }
    }
    
    Iterator<FaceFlash> i = flashes.iterator();
    while (i.hasNext()) {
      FaceFlash flash = i.next();
      boolean dead = flash.age(deltaMs);
      if (dead) {
        i.remove();
      }
    }
  } 
}

