/**
 * Simplest demonstration of using the rotating master hue.
 * All pixels are full-on the same color.
 */
class TestHuePattern extends SCPattern {
  public TestHuePattern(GLucose glucose) {
    super(glucose);
  }
  
  public void run(int deltaMs) {
    // Access the core master hue via this method call
    float hv = lx.getBaseHuef();
    for (int i = 0; i < colors.length; ++i) {
      colors[i] = color(hv, 100, 100);
    }
  } 
}

/**
 * Test of a wave moving across the X axis.
 */
class TestXPattern extends SCPattern {
  private final SinLFO xPos = new SinLFO(0, model.xMax, 4000);
  public TestXPattern(GLucose glucose) {
    super(glucose);
    addModulator(xPos).trigger();
  }
  public void run(int deltaMs) {
    float hv = lx.getBaseHuef();
    for (Point p : model.points) {
      // This is a common technique for modulating brightness.
      // You can use abs() to determine the distance between two
      // values. The further away this point is from an exact
      // point, the more we decrease its brightness
      float bv = max(0, 100 - abs(p.fx - xPos.getValuef()));
      colors[p.index] = color(hv, 100, bv);
    }
  }
}

/**
 * Test of a wave on the Y axis.
 */
class TestYPattern extends SCPattern {
  private final SinLFO yPos = new SinLFO(0, model.yMax, 4000);
  public TestYPattern(GLucose glucose) {
    super(glucose);
    addModulator(yPos).trigger();
  }
  public void run(int deltaMs) {
    float hv = lx.getBaseHuef();
    for (Point p : model.points) {
      float bv = max(0, 100 - abs(p.fy - yPos.getValuef()));
      colors[p.index] = color(hv, 100, bv);
    }
  }
}

/**
 * Test of a wave on the Z axis.
 */
class TestZPattern extends SCPattern {
  private final SinLFO zPos = new SinLFO(0, model.zMax, 4000);
  public TestZPattern(GLucose glucose) {
    super(glucose);
    addModulator(zPos).trigger();
  }
  public void run(int deltaMs) {
    float hv = lx.getBaseHuef();
    for (Point p : model.points) {
      float bv = max(0, 100 - abs(p.fz - zPos.getValuef()));
      colors[p.index] = color(hv, 100, bv);
    }
  }
}

/**
 * This is a demonstration of how to use the projection library. A projection
 * creates a mutation of the coordinates of all the points in the model, creating
 * virtual x,y,z coordinates. In effect, this is like virtually rotating the entire
 * art car. However, since in reality the car does not move, the result is that
 * it appears that the object we are drawing on the car is actually moving.
 *
 * Keep in mind that what we are creating a projection of is the view coordinates.
 * Depending on your intuition, some operations may feel backwards. For instance,
 * if you translate the view to the right, it will make it seem that the object
 * you are drawing has moved to the left. If you scale the view up 2x, objects
 * drawn with the same absolute values will seem to be half the size.
 *
 * If this feels counterintuitive at first, don't worry. Just remember that you
 * are moving the pixels, not the structure. We're dealing with a finite set
 * of sparse, non-uniformly spaced pixels. Mutating the structure would move
 * things to a space where there are no pixels in 99% of the cases.
 */
class TestProjectionPattern extends SCPattern {
  
  private final Projection projection;
  private final SawLFO angle = new SawLFO(0, TWO_PI, 9000);
  private final SinLFO yPos = new SinLFO(-20, 40, 5000);
  
  public TestProjectionPattern(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);
    addModulator(angle).trigger();
    addModulator(yPos).trigger();
  }
  
  public void run(int deltaMs) {
    // For the same reasons described above, it may logically feel to you that
    // some of these operations are in reverse order. Again, just keep in mind that
    // the car itself is what's moving, not the object
    projection.reset(model)
    
      // Translate so the center of the car is the origin, offset by yPos
      .translateCenter(0, yPos.getValuef(), 0)

      // Rotate around the origin (now the center of the car) about an X-vector
      .rotate(angle.getValuef(), 1, 0, 0)

      // Scale up the Y axis (objects will look smaller in that access)
      .scale(1, 1.5, 1);

    float hv = lx.getBaseHuef();
    for (Coord c : projection) {
      float d = sqrt(c.x*c.x + c.y*c.y + c.z*c.z); // distance from origin
      // d = abs(d-60) + max(0, abs(c.z) - 20); // life saver / ring thing
      d = max(0, abs(c.y) - 10 + .3*abs(c.z) + .08*abs(c.x)); // plane / spear thing
      colors[c.index] = color(
        (hv + .6*abs(c.x) + abs(c.z)) % 360,
        100,
        constrain(140 - 10*d, 0, 100)
      );
    }
  } 
}
