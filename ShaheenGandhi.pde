import toxi.geom.Vec3D;
import toxi.geom.Matrix4x4;

class HelixPattern extends SCPattern {

  // Stores a line in point + vector form
  private class Line {
    private final PVector origin;
    private final PVector vector;

    Line(PVector pt, PVector v) {
      origin = pt;
      vector = v.get();
      vector.normalize();
    }

    PVector getPoint() {
      return origin;
    }

    PVector getVector() {
      return vector;
    }

    PVector getPointAt(final float t) {
      return PVector.add(origin, PVector.mult(vector, t));
    }

    boolean isColinear(final PVector pt) {
      PVector projected = projectPoint(pt);
      return projected.x==pt.x && projected.y==pt.y && projected.z==pt.z;
    }

    float getTValue(final PVector pt) {
      PVector subtraction = PVector.sub(pt, origin);
      return subtraction.dot(vector);
    }

    PVector projectPoint(final PVector pt) {
      return getPointAt(getTValue(pt));
    }

    PVector rotatePoint(final PVector p, final float t) {
      final PVector o = origin;
      final PVector v = vector;
      
      final float cost = cos(t);
      final float sint = sin(t);

      float x = (o.x*(v.y*v.y + v.z*v.z) - v.x*(o.y*v.y + o.z*v.z - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cost) + p.x*cost + (-o.z*v.y + o.y*v.z - v.z*p.y + v.y*p.z)*sint;
      float y = (o.y*(v.x*v.x + v.z*v.z) - v.y*(o.x*v.x + o.z*v.z - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cost) + p.y*cost + (o.z*v.x - o.x*v.z + v.z*p.x - v.x*p.z)*sint;
      float z = (o.z*(v.x*v.x + v.y*v.y) - v.z*(o.x*v.x + o.y*v.y - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cost) + p.z*cost + (-o.y*v.x + o.x*v.y - v.y*p.x + v.x*p.y)*sint;
      return new PVector(x, y, z);
    }
  }

  private class Helix {
    private final Line axis;
    private final float period; // period of coil
    private final float rotationPeriod; // animation period
    private final float radius; // radius of coil
    private final float girth; // girth of coil
    private final PVector referencePoint;
    private float phase;
    private PVector phaseNormal;

    Helix(Line axis, float period, float radius, float girth, float phase, float rotationPeriod) {
      this.axis = axis;
      this.period = period;
      this.radius = radius;
      this.girth = girth;
      this.phase = phase;
      this.rotationPeriod = rotationPeriod;

      // Generate a normal that will rotate to
      // produce the helical shape.
      PVector pt = new PVector(0, 1, 0);
      if (this.axis.isColinear(pt)) {
        pt = new PVector(0, 0, 1);
        if (this.axis.isColinear(pt)) {
          pt = new PVector(0, 1, 1);
        }
      }

      this.referencePoint = pt;

      // The normal is calculated by the cross product of the axis
      // and a random point that is not colinear with it.
      phaseNormal = axis.getVector().cross(referencePoint);
      phaseNormal.normalize();
      phaseNormal.mult(radius);
    }

    Line getAxis() {
      return axis;
    }
    
    PVector getPhaseNormal() {
      return phaseNormal;
    }
    
    float getPhase() {
      return phase;
    }

    void step(double deltaMs) {
      // Rotate
      if (rotationPeriod != 0) {
        this.phase = (phase + ((float)deltaMs / (float)rotationPeriod) * TWO_PI);
      }
    }

    PVector pointOnToroidalAxis(float t) {
      PVector p = axis.getPointAt(t);
      PVector middle = PVector.add(p, phaseNormal);
      return axis.rotatePoint(middle, (t / period) * TWO_PI + phase);
    }
    
    private float myDist(PVector p1, PVector p2) {
      final float x = p2.x-p1.x;
      final float y = p2.y-p1.y;
      final float z = p2.z-p1.z;
      return sqrt(x*x + y*y + z*z);
    }

    color colorOfPoint(final PVector p) {
      final float t = axis.getTValue(p);
      final PVector axisPoint = axis.getPointAt(t);

      // For performance reasons, cut out points that are outside of
      // the tube where the toroidal coil lives.
      if (abs(myDist(p, axisPoint) - radius) > girth*.5f) {
        return lx.hsb(0,0,0);
      }

      // Find the appropriate point for the current rotation
      // of the helix.
      PVector toroidPoint = axisPoint;
      toroidPoint.add(phaseNormal);
      toroidPoint = axis.rotatePoint(toroidPoint, (t / period) * TWO_PI + phase);

      // The rotated point represents the middle of the girth of
      // the helix.  Figure out if the current point is inside that
      // region.
      float d = myDist(p, toroidPoint);

      // Soften edges by fading brightness.
      float b = constrain(100*(1 - ((d-.5*girth)/(girth*.5))), 0, 100);
      return lx.hsb((lx.getBaseHuef() + (360*(phase / TWO_PI)))%360, 80, b);
    }
  }
  
  private class BasePairInfo {
    Line line;
    float colorPhase1;
    float colorPhase2;
    
    BasePairInfo(Line line, float colorPhase1, float colorPhase2) {
      this.line = line;
      this.colorPhase1 = colorPhase1;
      this.colorPhase2 = colorPhase2;
    }
  }

  private final Helix h1;
  private final Helix h2;
  private final BasePairInfo[] basePairs;

  private final BasicParameter helix1On = new BasicParameter("H1ON", 1);
  private final BasicParameter helix2On = new BasicParameter("H2ON", 1);
  private final BasicParameter basePairsOn = new BasicParameter("BPON", 1);

  private static final float helixCoilPeriod = 100;
  private static final float helixCoilRadius = 50;
  private static final float helixCoilGirth = 30;
  private static final float helixCoilRotationPeriod = 5000;

  private static final float spokePeriod = 40;
  private static final float spokeGirth = 20;
  private static final float spokePhase = 10;
  private static final float spokeRadius = helixCoilRadius - helixCoilGirth*.5f;
  
  private static final float tMin = -200;
  private static final float tMax = 200;

  public HelixPattern(GLucose glucose) {
    super(glucose);

    addParameter(helix1On);
    addParameter(helix2On);
    addParameter(basePairsOn);

    PVector origin = new PVector(100, 50, 55);
    PVector axis = new PVector(1,0,0);

    h1 = new Helix(
      new Line(origin, axis),
      helixCoilPeriod,
      helixCoilRadius,
      helixCoilGirth,
      0,
      helixCoilRotationPeriod);
    h2 = new Helix(
      new Line(origin, axis),
      helixCoilPeriod,
      helixCoilRadius,
      helixCoilGirth,
      PI,
      helixCoilRotationPeriod);
      
    basePairs = new BasePairInfo[(int)floor((tMax - tMin)/spokePeriod)];
  }

  private void calculateSpokes() {
    float colorPhase = PI/6;
    for (float t = tMin + spokePhase; t < tMax; t += spokePeriod) {
      int spokeIndex = (int)floor((t - tMin)/spokePeriod);
      PVector h1point = h1.pointOnToroidalAxis(t);
      PVector spokeCenter = h1.getAxis().getPointAt(t);
      PVector spokeVector = PVector.sub(h1point, spokeCenter);
      Line spokeLine = new Line(spokeCenter, spokeVector);
      basePairs[spokeIndex] = new BasePairInfo(spokeLine, colorPhase * spokeIndex, colorPhase * (spokeIndex + 1));
    }
  }
  
  private color calculateSpokeColor(final PVector pt) {
    // Find the closest spoke's t-value and calculate its
    // axis.  Until everything animates in the model reference
    // frame, this has to be calculated at every step because
    // the helices rotate.
    Line axis = h1.getAxis();
    float t = axis.getTValue(pt) + spokePhase;
    int spokeIndex = (int)floor((t - tMin + spokePeriod/2) / spokePeriod);
    if (spokeIndex < 0 || spokeIndex >= basePairs.length) {
      return lx.hsb(0,0,0);
    }
    BasePairInfo basePair = basePairs[spokeIndex];
    Line spokeLine = basePair.line;
    PVector pointOnSpoke = spokeLine.projectPoint(pt);
    float d = PVector.dist(pt, pointOnSpoke);
    float b = (PVector.dist(pointOnSpoke, spokeLine.getPoint()) < spokeRadius) ? constrain(100*(1 - ((d-.5*spokeGirth)/(spokeGirth*.5))), 0, 100) : 0.f;
    float phase = spokeLine.getTValue(pointOnSpoke) < 0 ? basePair.colorPhase1 : basePair.colorPhase2;
    return lx.hsb((lx.getBaseHuef() + (360*(phase / TWO_PI)))%360, 80.f, b);
  }

  void run(double deltaMs) {
    boolean h1on = helix1On.getValue() > 0.5;
    boolean h2on = helix2On.getValue() > 0.5;
    boolean spokesOn = (float)basePairsOn.getValue() > 0.5;

    h1.step(deltaMs);
    h2.step(deltaMs);
    calculateSpokes();

    for (LXPoint p : model.points) {
      PVector pt = new PVector(p.x,p.y,p.z);
      color h1c = h1.colorOfPoint(pt);
      color h2c = h2.colorOfPoint(pt);
      color spokeColor = calculateSpokeColor(pt);

      if (!h1on) {
        h1c = lx.hsb(0,0,0);
      }

      if (!h2on) {
        h2c = lx.hsb(0,0,0);
      }

      if (!spokesOn) {
        spokeColor = lx.hsb(0,0,0);
      }

      // The helices are positioned to not overlap.  If that changes,
      // a better blending formula is probably needed.
      colors[p.index] = blendColor(blendColor(h1c, h2c, ADD), spokeColor, ADD);
    }
  }
}

