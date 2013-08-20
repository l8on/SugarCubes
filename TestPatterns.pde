abstract class TestPattern extends SCPattern {
  public TestPattern(GLucose glucose) {
    super(glucose);
    setEligible(false);
  }
}

/**
 * Simplest demonstration of using the rotating master hue.
 * All pixels are full-on the same color.
 */
class TestHuePattern extends TestPattern {
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
class TestXPattern extends TestPattern {
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
class TestYPattern extends TestPattern {
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
class TestZPattern extends TestPattern {
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
 * This shows how to iterate over towers, enumerated in the model.
 */
class TestTowerPattern extends TestPattern {
  private final SawLFO towerIndex = new SawLFO(0, model.towers.size(), 1000*model.towers.size());
  
  public TestTowerPattern(GLucose glucose) {
    super(glucose);
    addModulator(towerIndex).trigger();
  }

  public void run(int deltaMs) {
    int ti = 0;
    for (Tower t : model.towers) {
      for (Point p : t.points) {
        colors[p.index] = color(
          lx.getBaseHuef(),
          100,
          max(0, 100 - 80*LXUtils.wrapdistf(ti, towerIndex.getValuef(), model.towers.size()))
        );
      }
      ++ti;
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
class TestProjectionPattern extends TestPattern {
  
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
      .translateCenter(model, 0, yPos.getValuef(), 0)

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

class TestCubePattern extends TestPattern {
  
  private SawLFO index = new SawLFO(0, Cube.POINTS_PER_CUBE, Cube.POINTS_PER_CUBE*60);
  
  TestCubePattern(GLucose glucose) {
    super(glucose);
    addModulator(index).start();
  }
  
  public void run(int deltaMs) {
    for (Cube c : model.cubes) {
      int i = 0;
      for (Point p : c.points) {
        colors[p.index] = color(
          lx.getBaseHuef(),
          100,
          max(0, 100 - 80.*abs(i - index.getValuef()))
        );
        ++i;
      }
    }
  }
}

class MappingTool extends TestPattern {
    
  private int cubeIndex = 0;
  private int stripIndex = 0;
  private int channelIndex = 0;

  public final int MAPPING_MODE_ALL = 0;
  public final int MAPPING_MODE_CHANNEL = 1;
  public final int MAPPING_MODE_SINGLE_CUBE = 2;
  public int mappingMode = MAPPING_MODE_ALL;

  public final int CUBE_MODE_ALL = 0;
  public final int CUBE_MODE_SINGLE_STRIP = 1;
  public final int CUBE_MODE_STRIP_PATTERN = 2;
  public int cubeMode = CUBE_MODE_ALL;

  public boolean channelModeRed = true;
  public boolean channelModeGreen = false;
  public boolean channelModeBlue = false;
  
  private final int numChannels;
  
  private final PandaMapping[] pandaMappings;
  private PandaMapping activeMapping;
  private int mappingChannelIndex;
  
  MappingTool(GLucose glucose, PandaMapping[] pandaMappings) {
    super(glucose);
    this.pandaMappings = pandaMappings;
    numChannels = pandaMappings.length * PandaMapping.CHANNELS_PER_BOARD;
    setChannel();
  }
  
  private void setChannel() {
    mappingChannelIndex = channelIndex % PandaMapping.CHANNELS_PER_BOARD;
    activeMapping = pandaMappings[channelIndex / PandaMapping.CHANNELS_PER_BOARD];
  }
  
  private int cubeInChannel(Cube c) {
    int i = 1;
    for (int index : activeMapping.channelList[mappingChannelIndex]) {
      if (c == model.getCubeByRawIndex(index)) {
        return i;
      }
      ++i;
    }
    return 0;
  }
  
  private void printInfo() {
    println("Cube:" + cubeIndex + " Strip:" + (stripIndex+1));
  }
  
  public void cube(int delta) {
    int len = model.cubes.size();
    cubeIndex = (len + cubeIndex + delta) % len;
    printInfo();
  }
  
  public void strip(int delta) {
    int len = Cube.STRIPS_PER_CUBE;
    stripIndex = (len + stripIndex + delta) % len;
    printInfo();
  }
  
  public void run(int deltaMs) {
    color off = color(0, 0, 0);
    color c = off;
    color r = #FF0000;
    color g = #00FF00;
    color b = #0000FF;
    if (channelModeRed) c |= r;
    if (channelModeGreen) c |= g;
    if (channelModeBlue) c |= b;
    
    int ci = 0;
    for (Cube cube : model.cubes) {
      boolean cubeOn = false;
      int channelIndex = cubeInChannel(cube);
      switch (mappingMode) {
        case MAPPING_MODE_ALL: cubeOn = true; break;
        case MAPPING_MODE_SINGLE_CUBE: cubeOn = (cubeIndex == ci); break;
        case MAPPING_MODE_CHANNEL: cubeOn = (channelIndex > 0); break;
      }
      if (cubeOn) {
        if (mappingMode == MAPPING_MODE_CHANNEL) {
          color cc = off;
          switch (channelIndex) {
            case 1: cc = r; break;
            case 2: cc = r|g; break;
            case 3: cc = g; break;
            case 4: cc = b; break;
            case 5: cc = r|b; break;
          }
          setColor(cube, cc);
        } else if (cubeMode == CUBE_MODE_STRIP_PATTERN) {
          int si = 0;
          color sc = off;
          for (Strip strip : cube.strips) {
            int faceI = si / Face.STRIPS_PER_FACE;
            switch (faceI) {
              case 0: sc = r; break;
              case 1: sc = g; break;
              case 2: sc = b; break;
              case 3: sc = r|g|b; break;
            }
            if (si % Face.STRIPS_PER_FACE == 2) {
              sc = r|g;
            }
            setColor(strip, sc);
            ++si;
          }
        } else if (cubeMode == CUBE_MODE_SINGLE_STRIP) {
          setColor(cube, off);
          setColor(cube.strips.get(stripIndex), c);
        } else {
          setColor(cube, c);
        }
      } else {
        setColor(cube, off);
      }
      ++ci;
    }
    
  }
  
  public void incCube() {
    cubeIndex = (cubeIndex + 1) % model.cubes.size();
  }
  
  public void decCube() {
    --cubeIndex;
    if (cubeIndex < 0) {
      cubeIndex += model.cubes.size();
    }
  }

  public void incChannel() {
    channelIndex = (channelIndex + 1) % numChannels;
    setChannel();
  }
  
  public void decChannel() {
    --channelIndex;
    if (channelIndex < 0) {
      channelIndex += numChannels;
    }
    setChannel();    
  }
  
  public void incStrip() {
    stripIndex = (stripIndex + 1) % Cube.STRIPS_PER_CUBE;
  }
  
  public void decStrip() {
    --stripIndex;
    if (stripIndex < 0) {
      stripIndex += Cube.STRIPS_PER_CUBE;
    }
  }
  
  public void keyPressed() {
    switch (keyCode) {
      case UP: if (mappingMode == MAPPING_MODE_CHANNEL) incChannel(); else incCube(); break;
      case DOWN: if (mappingMode == MAPPING_MODE_CHANNEL) decChannel(); else decCube(); break;
      case LEFT: decStrip(); break;
      case RIGHT: incStrip(); break;
    }
    switch (key) {
      case 'r': channelModeRed = !channelModeRed; break;
      case 'g': channelModeGreen = !channelModeGreen; break;
      case 'b': channelModeBlue = !channelModeBlue; break;
    }
  }
}
