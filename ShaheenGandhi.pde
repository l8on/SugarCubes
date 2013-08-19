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
      
      float x = (o.x*(v.y*v.y + v.z*v.z) - v.x*(o.y*v.y + o.z*v.z - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cos(t)) + p.x*cos(t) + (-o.z*v.y + o.y*v.z - v.z*p.y + v.y*p.z)*sin(t);
      float y = (o.y*(v.x*v.x + v.z*v.z) - v.y*(o.x*v.x + o.z*v.z - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cos(t)) + p.y*cos(t) + (o.z*v.x - o.x*v.z + v.z*p.x - v.x*p.z)*sin(t);
      float z = (o.z*(v.x*v.x + v.y*v.y) - v.z*(o.x*v.x + o.y*v.y - v.x*p.x - v.y*p.y - v.z*p.z))*(1 - cos(t)) + p.z*cos(t) + (-o.y*v.x + o.x*v.y - v.y*p.x + v.x*p.y)*sin(t);
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

    void step(int deltaMs) {
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

    color colorOfPoint(final PVector p) {
      float t = axis.getTValue(p);

      // For performance reasons, cut out points that are outside of
      // the tube where the toroidal coil lives.
      if (abs(PVector.dist(p, axis.getPointAt(t)) - radius) > girth*.5f) {
        return color(0,0,0);
      }

      // Find the appropriate point for the current rotation
      // of the helix.
      PVector toroidPoint = pointOnToroidalAxis(t);

      // The rotated point represents the middle of the girth of
      // the helix.  Figure out if the current point is inside that
      // region.
      float d = PVector.dist(p, toroidPoint);

      // Soften edges by fading brightness.
      float b = constrain(100*(1 - ((d-.5*girth)/(girth*.5))), 0, 100);
      return color((lx.getBaseHuef() + (360*(phase / TWO_PI)))%360, 80, b);
    }
  }

  private final Helix h1;
  private final Helix h2;

  private final BasicParameter helix1On = new BasicParameter("H1ON", 1);
  private final BasicParameter helix2On = new BasicParameter("H2ON", 1);
  private final BasicParameter basePairsOn = new BasicParameter("BPON", 1);

  private static final float helixCoilPeriod = 100;
  private static final float helixCoilRadius = 45;
  private static final float helixCoilGirth = 20;
  private static final float helixCoilRotationPeriod = 10000;

  private static final float spokePeriod = 40;
  private static final float spokeGirth = 10;
  private static final float spokePhase = 10;
  private static final float spokeRadius = 35; // helixCoilRadius - helixCoilGirth*.5f;

  public HelixPattern(GLucose glucose) {
    super(glucose);

    addParameter(helix1On);
    addParameter(helix2On);
    addParameter(basePairsOn);

    PVector origin = new PVector(100, 50, 45);
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
  }
  
  private color calculateSpokeColor(final color h1c, final color h2c, final PVector pt) {
    // Find the closest spoke's t-value and calculate its
    // axis.  Until everything animates in the model reference
    // frame, this has to be calculated at every step because
    // the helices rotate.
    float t = h1.getAxis().getTValue(pt) + spokePhase;
    float spokeAxisTValue = floor(((t + spokePeriod/2) / spokePeriod)) * spokePeriod;
    PVector h1point = h1.pointOnToroidalAxis(spokeAxisTValue);
    PVector h2point = h2.pointOnToroidalAxis(spokeAxisTValue);
    PVector spokeVector = PVector.sub(h2point, h1point);
    spokeVector.normalize();
    Line spokeLine = new Line(h1point, spokeVector);
    float spokeLength = PVector.dist(h1point, h2point);
    // TODO(shaheen) investigate why h1.getAxis().getPointAt(spokeAxisTValue) doesn't quite
    // have the same value.
    PVector spokeCenter = PVector.add(h1point, PVector.mult(spokeVector, spokeLength/2.f));
    PVector pointOnSpoke = spokeLine.projectPoint(pt);
    float b = ((PVector.dist(pt, pointOnSpoke) < spokeGirth) && (PVector.dist(pointOnSpoke, spokeCenter) < spokeRadius)) ? 100.f : 0.f;
    return color(100, 80.f, b);
  }

  void run(int deltaMs) {
    boolean h1on = helix1On.getValue() > 0.5;
    boolean h2on = helix2On.getValue() > 0.5;
    boolean spokesOn = (float)basePairsOn.getValue() > 0.5;

    h1.step(deltaMs);
    h2.step(deltaMs);

    for (Point p : model.points) {
      PVector pt = new PVector(p.x,p.y,p.z);
      color h1c = h1.colorOfPoint(pt);
      color h2c = h2.colorOfPoint(pt);
      color spokeColor = calculateSpokeColor(h1c, h2c, pt);

      if (!h1on) {
        h1c = color(0,0,0);
      }

      if (!h2on) {
        h2c = color(0,0,0);
      }

      if (!spokesOn) {
        spokeColor = color(0,0,0);
      }

      // The helices are positioned to not overlap.  If that changes,
      // a better blending formula is probably needed.
      colors[p.index] = blendColor(blendColor(h1c, h2c, ADD), spokeColor, ADD);
    }
  }
}

