/**
 * Not very flushed out, but kind of fun nonetheless.
 */
class TimSpheres extends SCPattern {
  private BasicParameter hueParameter = new BasicParameter("RAD", 1.0);
  private final SawLFO lfo = new SawLFO(0, 1, 10000);
  private final SinLFO sinLfo = new SinLFO(0, 1, 4000);
  private final float centerX, centerY, centerZ;
  
  class Sphere {
    float x, y, z;
    float radius;
    float hue;
  }
  
  private final Sphere[] spheres;
  
  public TimSpheres(GLucose glucose) {
    super(glucose);
    addParameter(hueParameter);
    addModulator(lfo).trigger();
    addModulator(sinLfo).trigger();
    centerX = (model.xMax + model.xMin) / 2;
    centerY = (model.yMax + model.yMin) / 2;
    centerZ = (model.zMax + model.zMin) / 2;
    
    spheres = new Sphere[2];
    
    spheres[0] = new Sphere();
    spheres[0].x = model.xMin;
    spheres[0].y = centerY;
    spheres[0].z = centerZ;
    spheres[0].hue = 0;
    spheres[0].radius = 50;
    
    spheres[1] = new Sphere();
    spheres[1].x = model.xMax;
    spheres[1].y = centerY;
    spheres[1].z = centerZ;
    spheres[1].hue = 0.33;
    spheres[1].radius = 50;
  }
  
  public void run(double deltaMs) {
    // Access the core master hue via this method call
    float hv = hueParameter.getValuef();
    float lfoValue = lfo.getValuef();
    float sinLfoValue = sinLfo.getValuef();
    
    spheres[0].x = model.xMin + sinLfoValue * model.xMax;
    spheres[1].x = model.xMax - sinLfoValue * model.xMax;
    
    spheres[0].radius = 100 * hueParameter.getValuef();
    spheres[1].radius = 100 * hueParameter.getValuef();
    
    for (Point p : model.points) {
      float value = 0;

      color c = color(0, 0, 0);      
      for (Sphere s : spheres) {
        float d = sqrt(pow(p.x - s.x, 2) + pow(p.y - s.y, 2) + pow(p.z - s.z, 2));
        float r = (s.radius); // * (sinLfoValue + 0.5));
        value = max(0, 1 - max(0, d - r) / 10);
        
        c = blendColor(c, color(((s.hue + lfoValue) % 1) * 360, 100, min(1, value) * 100), ADD);
      }
      
      colors[p.index] = c;
    }
  } 
}

class Vector2 {
  float x, y;
  
  Vector2() {
    this(0, 0);
  }
  
  Vector2(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  float distanceTo(float x, float y) {
    return sqrt(pow(x - this.x, 2) + pow(y - this.y, 2));
  }
  
  float distanceTo(Vector2 v) {
    return distanceTo(v.x, v.y);
  }
  
  Vector2 plus(float x, float y) {
    return new Vector2(this.x + x, this.y + y);
  }
  
  Vector2 plus(Vector2 v) {
    return plus(v.x, v.y);
  }
    
  Vector2 minus(Vector2 v) {
    return plus(-1 * v.x, -1 * v.y);
  }
}

class Vector3 {
  float x, y, z;
  
  Vector3() {
    this(0, 0, 0);
  }
  
  Vector3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  float distanceTo(float x, float y, float z) {
    return sqrt(pow(x - this.x, 2) + pow(y - this.y, 2) + pow(z - this.z, 2));
  }
  
  float distanceTo(Vector3 v) {
    return distanceTo(v.x, v.y, v.z);
  }
  
  float distanceTo(Point p) {
    return distanceTo(p.x, p.y, p.z);
  }
  
  void add(Vector3 other, float multiplier) {
    this.add(other.x * multiplier, other.y * multiplier, other.z * multiplier);
  }  
    
  void add(float x, float y, float z) {
    this.x += x;
    this.y += y;
    this.z += z;
  }
  
  void divide(float factor) {
    this.x /= factor;
    this.y /= factor;
    this.z /= factor;
  }
}

class Rotation {
  private float a, b, c, d, e, f, g, h, i;
  
  Rotation(float yaw, float pitch, float roll) {
    float cosYaw = cos(yaw);
    float sinYaw = sin(yaw);
    float cosPitch = cos(pitch);
    float sinPitch = sin(pitch);
    float cosRoll = cos(roll);
    float sinRoll = sin(roll);
    
    a = cosYaw * cosPitch;
    b = cosYaw * sinPitch * sinRoll - sinYaw * cosRoll;
    c = cosYaw * sinPitch * cosRoll + sinYaw * sinRoll;
    d = sinYaw * cosPitch;
    e = sinYaw * sinPitch * sinRoll + cosYaw * cosRoll;
    f = sinYaw * sinPitch * cosRoll - cosYaw * sinRoll;
    g = -1 * sinPitch;
    h = cosPitch * sinRoll;
    i = cosPitch * cosRoll;
  }
  
  Vector3 rotated(Vector3 v) {
    return new Vector3(
      rotatedX(v),
      rotatedY(v),
      rotatedZ(v));

  }
  
  float rotatedX(Vector3 v) {
    return a * v.x + b * v.y + c * v.z;
  }
  
  float rotatedY(Vector3 v) {
    return d * v.x + e * v.y + f * v.z;
  }
  
  float rotatedZ(Vector3 v) {
    return g * v.x + h * v.y + i * v.z;
  }
}

/**
 * Very literal rain effect.  Not that great as-is but some tweaking could make it nice.
 * A couple ideas:
 *   - changing hue and direction of "rain" could make a nice fire effect
 *   - knobs to change frequency and size of rain drops
 *   - sync somehow to tempo but maybe less frequently than every beat?
 */
class TimRaindrops extends SCPattern {
  Vector3 randomVector3() {
    return new Vector3(
        random(model.xMax - model.xMin) + model.xMin,
        random(model.yMax - model.yMin) + model.yMin,
        random(model.zMax - model.zMin) + model.zMin);
  }

  class Raindrop {
    Vector3 p;
    Vector3 v;
    float radius;
    float hue;
    
    Raindrop() {
      this.radius = 30;
      this.p = new Vector3(
              random(model.xMax - model.xMin) + model.xMin,
              model.yMax + this.radius,
              random(model.zMax - model.zMin) + model.zMin);
      float velMagnitude = 120;
      this.v = new Vector3(
          0,
          -3 * model.yMax,
          0);
      this.hue = random(40) + 200;
    }
    
    // returns TRUE when this should die
    boolean age(double ms) {
      p.add(v, (float) (ms / 1000.0));
      return this.p.y < (0 - this.radius);
    }
  }
  
  private float leftoverMs = 0;
  private float msPerRaindrop = 40;
  private List<Raindrop> raindrops;
  
  public TimRaindrops(GLucose glucose) {
    super(glucose);
    raindrops = new LinkedList<Raindrop>();
  }
  
  public void run(double deltaMs) {
    leftoverMs += deltaMs;
    while (leftoverMs > msPerRaindrop) {
      leftoverMs -= msPerRaindrop;
      raindrops.add(new Raindrop());
    }
    
    for (Point p : model.points) {
      color c = 
        blendColor(
          color(210, 20, (float)Math.max(0, 1 - Math.pow((model.yMax - p.y) / 10, 2)) * 50),
          color(220, 60, (float)Math.max(0, 1 - Math.pow((p.y - model.yMin) / 10, 2)) * 100),
          ADD);
      for (Raindrop raindrop : raindrops) {
        if (p.x >= (raindrop.p.x - raindrop.radius) && p.x <= (raindrop.p.x + raindrop.radius) &&
            p.y >= (raindrop.p.y - raindrop.radius) && p.y <= (raindrop.p.y + raindrop.radius)) {
          float d = raindrop.p.distanceTo(p) / raindrop.radius;
  //      float value = (float)Math.max(0, 1 - Math.pow(Math.min(0, d - raindrop.radius) / 5, 2)); 
          if (d < 1) {
            c = blendColor(c, color(raindrop.hue, 80, (float)Math.pow(1 - d, 0.01) * 100), ADD);
          }
        }
      }
      colors[p.index] = c;
    }
    
    Iterator<Raindrop> i = raindrops.iterator();
    while (i.hasNext()) {
      Raindrop raindrop = i.next();
      boolean dead = raindrop.age(deltaMs);
      if (dead) {
        i.remove();
      }
    }
  } 
}


class TimCubes extends SCPattern {
  private BasicParameter rateParameter = new BasicParameter("RATE", 0.125);
  private BasicParameter attackParameter = new BasicParameter("ATTK", 0.5);
  private BasicParameter decayParameter = new BasicParameter("DECAY", 0.5);
  private BasicParameter hueParameter = new BasicParameter("HUE", 0.5);
  private BasicParameter hueVarianceParameter = new BasicParameter("H.V.", 0.25);
  private BasicParameter saturationParameter = new BasicParameter("SAT", 0.5);
  
  class CubeFlash {
    Cube c;
    float value;
    float hue;
    boolean hasPeaked;
    
    CubeFlash() {
      c = model.cubes.get(floor(random(model.cubes.size())));
      hue = random(1);
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
  private List<CubeFlash> flashes;
  
  public TimCubes(GLucose glucose) {
    super(glucose);
    addParameter(rateParameter);
    addParameter(attackParameter);
    addParameter(decayParameter);
    addParameter(hueParameter);
    addParameter(hueVarianceParameter);
    addParameter(saturationParameter);
    flashes = new LinkedList<CubeFlash>();
  }
  
  public void run(double deltaMs) {
    leftoverMs += deltaMs;
    float msPerFlash = 1000 / ((rateParameter.getValuef() + .01) * 100);
    while (leftoverMs > msPerFlash) {
      leftoverMs -= msPerFlash;
      flashes.add(new CubeFlash());
    }
    
    for (Point p : model.points) {
      colors[p.index] = 0;
    }
    
    for (CubeFlash flash : flashes) {
      float hue = (hueParameter.getValuef() + (hueVarianceParameter.getValuef() * flash.hue)) % 1.0;
      color c = color(hue * 360, saturationParameter.getValuef() * 100, (flash.value) * 100);
      for (Point p : flash.c.points) {
        colors[p.index] = c;
      }
    }
    
    Iterator<CubeFlash> i = flashes.iterator();
    while (i.hasNext()) {
      CubeFlash flash = i.next();
      boolean dead = flash.age(deltaMs);
      if (dead) {
        i.remove();
      }
    }
  } 
}

/**
 * This one is the best but you need to play with all the knobs.  It's synced to
 * the tempo, with the WSpd knob letting you pick 4 discrete multipliers for
 * the tempo.
 *
 * Basically it's just 3 planes all rotating to the beat, but also rotated relative
 * to one another.  The intersection of the planes and the cubes over time makes
 * for a nice abstract effect.
 */
class TimPlanes extends SCPattern {
  private BasicParameter wobbleParameter = new BasicParameter("Wob", 0.166);
  private BasicParameter wobbleSpreadParameter = new BasicParameter("WSpr", 0.25);
  private BasicParameter wobbleSpeedParameter = new BasicParameter("WSpd", 0.375);
  private BasicParameter wobbleOffsetParameter = new BasicParameter("WOff", 0);
  private BasicParameter derezParameter = new BasicParameter("Drez", 0.5);
  private BasicParameter thicknessParameter = new BasicParameter("Thick", 0.4);
  private BasicParameter ySpreadParameter = new BasicParameter("ySpr", 0.2);
  private BasicParameter hueParameter = new BasicParameter("Hue", 0.75);
  private BasicParameter hueSpreadParameter = new BasicParameter("HSpr", 0.68);

  final float centerX, centerY, centerZ;
  float phase;
  
  class Plane {
    Vector3 center;
    Rotation rotation;
    float hue;
    
    Plane(Vector3 center, Rotation rotation, float hue) {
      this.center = center;
      this.rotation = rotation;
      this.hue = hue;
    }
  }
      
  TimPlanes(GLucose glucose) {
    super(glucose);
    centerX = (model.xMin + model.xMax) / 2;
    centerY = (model.yMin + model.yMax) / 2;
    centerZ = (model.zMin + model.zMax) / 2;
    phase = 0;
    addParameter(wobbleParameter);
    addParameter(wobbleSpreadParameter);
    addParameter(wobbleSpeedParameter);
//    addParameter(wobbleOffsetParameter);
    addParameter(derezParameter);
    addParameter(thicknessParameter);
    addParameter(ySpreadParameter);
    addParameter(hueParameter);
    addParameter(hueSpreadParameter);
  }
  
  int beat = 0;
  float prevRamp = 0;
  float[] wobbleSpeeds = { 1.0/8, 1.0/4, 1.0/2, 1.0 };
  
  public void run(double deltaMs) {
    float ramp = (float)lx.tempo.ramp();
    if (ramp < prevRamp) {
      beat = (beat + 1) % 32;
    }
    prevRamp = ramp;
    
    float wobbleSpeed = wobbleSpeeds[floor(wobbleSpeedParameter.getValuef() * wobbleSpeeds.length * 0.9999)];

    phase = (((beat + ramp) * wobbleSpeed + wobbleOffsetParameter.getValuef()) % 1) * 2 * PI;
    
    float ySpread = ySpreadParameter.getValuef() * 50;
    float wobble = wobbleParameter.getValuef() * PI;
    float wobbleSpread = wobbleSpreadParameter.getValuef() * PI;
    float hue = hueParameter.getValuef() * 360;
    float hueSpread = (hueSpreadParameter.getValuef() - 0.5) * 360;

    float saturation = 10 + 60.0 * pow(ramp, 0.25);
    
    float derez = derezParameter.getValuef();
    
    Plane[] planes = {
      new Plane(
        new Vector3(centerX, centerY + ySpread, centerZ),
        new Rotation(wobble - wobbleSpread, phase, 0),
        (hue + 360 - hueSpread) % 360),
      new Plane(
        new Vector3(centerX, centerY, centerZ),
        new Rotation(wobble, phase, 0),
        hue),
      new Plane(
        new Vector3(centerX, centerY - ySpread, centerZ),
        new Rotation(wobble + wobbleSpread, phase, 0),
        (hue + 360 + hueSpread) % 360)
    };

    float thickness = (thicknessParameter.getValuef() * 25 + 1);
    
    Vector3 normalizedPoint = new Vector3();

    for (Point p : model.points) {
      if (random(1.0) < derez) {
        continue;
      }
      
      color c = 0;
      
      for (Plane plane : planes) {
        normalizedPoint.x = p.x - plane.center.x;
        normalizedPoint.y = p.y - plane.center.y;
        normalizedPoint.z = p.z - plane.center.z;
        
        float v = plane.rotation.rotatedY(normalizedPoint);
        float d = abs(v);
        
        final color planeColor;
        if (d <= thickness) {
          planeColor = color(plane.hue, saturation, 100);
        } else if (d <= thickness * 2) {    
          float value = 1 - ((d - thickness) / thickness);
          planeColor = color(plane.hue, saturation, value * 100);
        } else {
          planeColor = 0;
        }

        if (planeColor != 0) {
          if (c == 0) {
            c = planeColor; 
          } else {
            c = blendColor(c, planeColor, ADD);
          }
        }
      }

      colors[p.index] = c;
    }
  }
}

/**
 * Two spinning wheels, basically XORed together, with a color palette that should
 * be pretty easy to switch around.  Timed to the beat; also introduces "clickiness"
 * which makes the movement non-linear throughout a given beat, giving it a nice
 * dance feel.  I'm not 100% sure that it's actually going to look like it's _on_
 * the beat, but that should be easy enough to adjust.
 *
 * It's particularly nice to turn down the clickiness and turn up derez during
 * slow/beatless parts of the music and then revert them at the drop :)  But maybe
 * I shouldn't be listening to so much shitty dubstep while making these...
 */
class TimPinwheels extends SCPattern { 
  private BasicParameter horizSpreadParameter = new BasicParameter("HSpr", 0.75);
  private BasicParameter vertSpreadParameter = new BasicParameter("VSpr", 0.5);
  private BasicParameter vertOffsetParameter = new BasicParameter("VOff", 1.0);
  private BasicParameter zSlopeParameter = new BasicParameter("ZSlp", 0.6);
  private BasicParameter sharpnessParameter = new BasicParameter("Shrp", 0.25);
  private BasicParameter derezParameter = new BasicParameter("Drez", 0.25);
  private BasicParameter clickinessParameter = new BasicParameter("Clic", 0.5);
  private BasicParameter hueParameter = new BasicParameter("Hue", 0.667);
  private BasicParameter hueSpreadParameter = new BasicParameter("HSpd", 0.667);

  float phase = 0;
  private final int NUM_BLADES = 12;
  
  class Pinwheel {
    Vector2 center;
    int numBlades;
    float realPhase;
    float phase;
    float speed;
    
    Pinwheel(float xCenter, float yCenter, int numBlades, float speed) {
      this.center = new Vector2(xCenter, yCenter);
      this.numBlades = numBlades;
      this.speed = speed;
    }
    
    void age(float numBeats) {
      int numSteps = numBlades;
      
      realPhase = (realPhase + numBeats / numSteps) % 2.0;
      
      float phaseStep = floor(realPhase * numSteps);
      float phaseRamp = (realPhase * numSteps) % 1.0;
      phase = (phaseStep + pow(phaseRamp, (clickinessParameter.getValuef() * 10) + 1)) / (numSteps * 2);
//      phase = (phase + deltaMs / 1000.0 * speed) % 1.0;      
    }
    
    boolean isOnBlade(float x, float y) {
      x = x - center.x;
      y = y - center.y;
      
      float normalizedAngle = (atan2(x, y) / (2 * PI) + 1 + phase) % 1;
      float v = (normalizedAngle * 4 * numBlades);
      int blade_num = floor((v + 2) / 4);
      return (blade_num % 2) == 0;
    }
  }
  
  private final List<Pinwheel> pinwheels;
  private final float[] values;
  
  TimPinwheels(GLucose glucose) {
    super(glucose);
    
    addParameter(horizSpreadParameter);
//    addParameter(vertSpreadParameter);
    addParameter(vertOffsetParameter);
    addParameter(zSlopeParameter);
    addParameter(sharpnessParameter);
    addParameter(derezParameter);
    addParameter(clickinessParameter);
    addParameter(hueParameter);
    addParameter(hueSpreadParameter);
    
    pinwheels = new ArrayList();
    pinwheels.add(new Pinwheel(0, 0, NUM_BLADES, 0.1));
    pinwheels.add(new Pinwheel(0, 0, NUM_BLADES, -0.1));
    
    this.updateHorizSpread();
    this.updateVertPositions();
    
    values = new float[model.points.size()];
  }
  
  public void onParameterChanged(LXParameter parameter) {
    if (parameter == horizSpreadParameter) {
      updateHorizSpread();
    } else if (parameter == vertSpreadParameter || parameter == vertOffsetParameter) {
      updateVertPositions();
    }
  }
  
  private void updateHorizSpread() {
    float xDist = model.xMax - model.xMin;
    float xCenter = (model.xMin + model.xMax) / 2;
    
    float spread = horizSpreadParameter.getValuef() - 0.5;
    pinwheels.get(0).center.x = xCenter - xDist * spread;
    pinwheels.get(1).center.x = xCenter + xDist * spread; 
  }
  
  private void updateVertPositions() {
    float yDist = model.yMax - model.yMin;
    float yCenter = model.yMin + yDist * vertOffsetParameter.getValuef();

    float spread = vertSpreadParameter.getValuef() - 0.5;
    pinwheels.get(0).center.y = yCenter - yDist * spread;
    pinwheels.get(1).center.y = yCenter + yDist * spread;     
  }
  
  private float prevRamp = 0;
  
  public void run(double deltaMs) {
    float ramp = lx.tempo.rampf();
    float numBeats = (1 + ramp - prevRamp) % 1;
    prevRamp = ramp;
    
    float hue = hueParameter.getValuef() * 360;
    // 0 -> -180
    // 0.5 -> 0
    // 1 -> 180
    float hueSpread = (hueSpreadParameter.getValuef() - 0.5) * 360;
    
    float fadeAmount = (float) (deltaMs / 1000.0) * pow(sharpnessParameter.getValuef() * 10, 1);
    
    for (Pinwheel pw : pinwheels) {
      pw.age(numBeats);
    }
    
    float derez = derezParameter.getValuef();
    
    float zSlope = (zSlopeParameter.getValuef() - 0.5) * 2;
    
    int i = -1;
    for (Point p : model.points) {
      ++i;
      
      int value = 0;
      for (Pinwheel pw : pinwheels) {
        value += (pw.isOnBlade(p.x, p.y - p.z * zSlope) ? 1 : 0);
      }
      if (value == 1) {
        values[i] = 1;
//        colors[p.index] = color(120, 0, 100);
      } else {
        values[i] = max(0, values[i] - fadeAmount);
        //color c = colors[p.index];
        //colors[p.index] = color(max(0, hue(c) - 10), min(100, saturation(c) + 10), brightness(c) - 5 );
      }
      
      if (random(1.0) >= derez) {
        float v = values[i];
        colors[p.index] = color((360 + hue + pow(v, 2) * hueSpread) % 360, 30 + pow(1 - v, 0.25) * 60, v * 100);
      }      
    }
  }
}

/**
 * This tries to figure out neighboring pixels from one cube to another to
 * let you have a bunch of moving points tracing all over the structure.
 * Adds a couple seconds of startup time to do the calculation, and in the
 * end just comes out looking a lot like a screensaver.  Probably not worth
 * it but there may be useful code here.
 */
class TimTrace extends SCPattern {
  private Map<Point, List<Point>> pointToNeighbors;
  private Map<Point, Strip> pointToStrip;
  //  private final Map<Strip, List<Strip>> stripToNearbyStrips;
  
  int extraMs;
  
  class MovingPoint {
    Point currentPoint;
    float hue;
    private Strip currentStrip;
    private int currentStripIndex;
    private int direction; // +1 or -1
    
    MovingPoint(Point p) {
      this.setPointOnNewStrip(p);
      hue = random(360);
    }
    
    private void setPointOnNewStrip(Point p) {
      this.currentPoint = p;
      this.currentStrip = pointToStrip.get(p);
      for (int i = 0; i < this.currentStrip.points.size(); ++i) {
        if (this.currentStrip.points.get(i) == p) {
          this.currentStripIndex = i;
          break;
        }
      }
      if (this.currentStripIndex == 0) {
        // we are at the beginning of the strip; go forwards
        this.direction = 1;
      } else if (this.currentStripIndex == this.currentStrip.points.size()) {
        // we are at the end of the strip; go backwards
        this.direction = -1;
      } else {
        // we are in the middle of a strip; randomly go one way or another
        this.direction = ((random(1.0) < 0.5) ? -1 : 1);
      }
    }
    
    void step() {
      List<Point> neighborsOnOtherStrips = pointToNeighbors.get(this.currentPoint);

      Point nextPointOnCurrentStrip = null;      
      this.currentStripIndex += this.direction;
      if (this.currentStripIndex >= 0 && this.currentStripIndex < this.currentStrip.points.size()) {
        nextPointOnCurrentStrip = this.currentStrip.points.get(this.currentStripIndex);
      }
      
      // pick which option to take; if we can keep going on the current strip then
      // add that as another option
      int option = floor(random(neighborsOnOtherStrips.size() + (nextPointOnCurrentStrip == null ? 0 : 100)));
      
      if (option < neighborsOnOtherStrips.size()) {
        this.setPointOnNewStrip(neighborsOnOtherStrips.get(option));
      } else {
        this.currentPoint = nextPointOnCurrentStrip;
      }
    }
  }
  
  List<MovingPoint> movingPoints;
  
  TimTrace(GLucose glucose) {
    super(glucose);
    
    extraMs = 0;
    
    pointToNeighbors = this.buildPointToNeighborsMap();
    pointToStrip = this.buildPointToStripMap();
    
    int numMovingPoints = 1000;
    movingPoints = new ArrayList();
    for (int i = 0; i < numMovingPoints; ++i) {
      movingPoints.add(new MovingPoint(model.points.get(floor(random(model.points.size())))));
    }
    
  }
  
  private Map<Strip, List<Strip>> buildStripToNearbyStripsMap() {
    Map<Strip, Vector3> stripToCenter = new HashMap();
    for (Strip s : model.strips) {
      Vector3 v = new Vector3();
      for (Point p : s.points) {
        v.add(p.x, p.y, p.z);
      }
      v.divide(s.points.size());
      stripToCenter.put(s, v);
    }
    
    Map<Strip, List<Strip>> stripToNeighbors = new HashMap();
    for (Strip s : model.strips) {
      List<Strip> neighbors = new ArrayList();
      Vector3 sCenter = stripToCenter.get(s);
      for (Strip potentialNeighbor : model.strips) {
        if (s != potentialNeighbor) {
          float distance = sCenter.distanceTo(stripToCenter.get(potentialNeighbor));
          if (distance < 25) {
            neighbors.add(potentialNeighbor);
          }
        }
      }
      stripToNeighbors.put(s, neighbors);
    }
    
    return stripToNeighbors;
  }
  
  private Map<Point, List<Point>> buildPointToNeighborsMap() {
    Map<Point, List<Point>> m = new HashMap();
    Map<Strip, List<Strip>> stripToNearbyStrips = this.buildStripToNearbyStripsMap();
    
    for (Strip s : model.strips) {
      List<Strip> nearbyStrips = stripToNearbyStrips.get(s);
      
      for (Point p : s.points) {
        Vector3 v = new Vector3(p.x, p.y, p.z);
        
        List<Point> neighbors = new ArrayList();
        
        for (Strip nearbyStrip : nearbyStrips) {
          Point closestPoint = null;
          float closestPointDistance = 100000;
          
          for (Point nsp : nearbyStrip.points) {
            float distance = v.distanceTo(nsp.x, nsp.y, nsp.z);
            if (closestPoint == null || distance < closestPointDistance) {
              closestPoint = nsp;
              closestPointDistance = distance;
            }
          }
          
          if (closestPointDistance < 15) {
            neighbors.add(closestPoint);
          }
        }
        
        m.put(p, neighbors);
      }
    }
    
    return m;
  }
  
  private Map<Point, Strip> buildPointToStripMap() {
    Map<Point, Strip> m = new HashMap();
    for (Strip s : model.strips) {
      for (Point p : s.points) {
        m.put(p, s);
      }
    }
    return m;
  }
  
  public void run(double deltaMs) {
    for (Point p : model.points) {
      color c = colors[p.index];
      colors[p.index] = color(hue(c), saturation(c), brightness(c) - 3);
    }
    
    for (MovingPoint mp : movingPoints) {
      mp.step();
      colors[mp.currentPoint.index] = blendColor(colors[mp.currentPoint.index], color(mp.hue, 10, 100), ADD);
    }
  }
}
