class VSTowers extends SCPattern {
  private BasicParameter saturationParameter = new BasicParameter("SAT", 80, 0, 100);
  private BasicParameter attackParameter = new BasicParameter("ATTK", 0.96, 0.1, 1.0);
  private BasicParameter decayParameter = new BasicParameter("DECAY", 0.7, 0.1, 1.0);
  private SawLFO hueLfo = new SawLFO(0, 360, 20000);

  private Map<Tower, Boolean> towerOn;

  class TowerFlash {
    Tower t;
    float value;
    float maxVal;
    float hue;
    boolean hasPeaked;

    TowerFlash() {
      do {
        t = model.towers.get(floor(random(model.towers.size())));
      } while (towerOn.get(t));
      towerOn.put(t, true);
      hue = (hueLfo.getValuef() + 50*(random(2)-1.0f)) % 360;
      value = 0.0;
      maxVal = random(0.4) + 0.6;
    }

    boolean run(double deltaMs) {
      if (!hasPeaked) {
        float atk = attackParameter.getValuef();
        float atkDuration = 10000 * (1/sqrt(atk) - 1.0f);
        value = value + (float)deltaMs / atkDuration;
        if (value >= maxVal) {
          value = maxVal;
          hasPeaked = true;
        }
        return false;
      } else {
        float dec = decayParameter.getValuef();
        float decDuration = 10000 * (1/sqrt(dec) - 1.0f);
        value = value - (float)deltaMs / decDuration;
        return value <= 0;
      }
    }
  }

  public VSTowers(GLucose glucose) {
    super(glucose);
    addParameter(saturationParameter);
    addParameter(attackParameter);
    addParameter(decayParameter);
    addModulator(hueLfo).trigger();
    flashes = new LinkedList<TowerFlash>();
    towerOn = new HashMap();
    for (Tower t : model.towers) {
      towerOn.put(t, false);
    }
  }

  private List<TowerFlash> flashes;
  private float accDelta = 0;

  public void run(double deltaMs) {
    accDelta += deltaMs;
    float rate = lx.tempo.rampf();
    float msPerFlash = 5000 * (1/sqrt(rate) - 1.0f);
    if (accDelta >= msPerFlash) {
      accDelta -= msPerFlash;
      if (flashes.size() < model.towers.size()) {
        flashes.add(new TowerFlash());
      }
    }
    for (LXPoint p : model.points) {
      if (random(1) < 0.2) {
        colors[p.index] = 0;
      }
    }
    for (TowerFlash tf : flashes) {
      for (LXPoint p : tf.t.points) {
        float towerHeight = model.yMin + tf.value * (model.yMax - model.yMin);
        if (p.y <= towerHeight) {
          colors[p.index] = lx.hsb(
            (tf.hue + tf.value*50 - p.y/2) % 360,
            saturationParameter.getValuef(),
            tf.value*100);
        }
      }
      if (tf.hasPeaked) {
        float towerMaxHeight = model.yMin + tf.maxVal * (model.yMax - model.yMin);
        Cube top = tf.t.cubes.get(tf.t.cubes.size()-1);
        for (int i = tf.t.cubes.size()-1; i >= 0; --i) {
          Cube c = tf.t.cubes.get(i);
          float maxY = c.points.get(0).y;
          for (LXPoint p : c.points) {
            maxY = max(maxY, p.y);
          }
          if (towerMaxHeight < maxY) {
            top = c;
          }
        }
        for (LXPoint p : top.points) {
          if (tf.value > 0.5) {
            colors[p.index] = lx.hsb(0, 0, tf.value*100);
          } else if (random(1) < 0.2) {
            colors[p.index] = 0;
          }
        }
      }
    }
    // Run flashes and remove completed ones
    Iterator<TowerFlash> it = flashes.iterator();
    while (it.hasNext()) {
      TowerFlash flash = it.next();
      if (flash.run(deltaMs)) {
        towerOn.put(flash.t, false);
        it.remove();
      }
    }
  }
}

