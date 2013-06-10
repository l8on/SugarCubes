class TestHuePattern extends SCPattern {
  public TestHuePattern(GLucose glucose) {
    super(glucose);
  }
  public void run(int deltaMs) {
    for (int i = 0; i < colors.length; ++i) {
      colors[i] = color(lx.getBaseHuef(), 100, 100);
    }
  } 
}

class TestRedPattern extends SCPattern {
  public TestRedPattern(GLucose glucose) {
    super(glucose);
  }

  public void run(int deltaMs) {
    for (int i = 0; i < colors.length; ++i) {
      colors[i] = color(0, 100, 100);
    }
  }
}

class TestXPattern extends SCPattern {
  private SinLFO xPos = new SinLFO(0, model.xMax, 4000);
  public TestXPattern(GLucose glucose) {
    super(glucose);
    addModulator(xPos).trigger();
  }
  public void run(int deltaMs) {
    for (Point p : model.points) {
      colors[p.index] = color(
        lx.getBaseHuef(),
        100,
        max(0, 100 - abs(p.fx - xPos.getValuef()))
      );      
    }
  }
}

class TestYPattern extends SCPattern {
  private SinLFO yPos = new SinLFO(0, model.yMax, 4000);
  public TestYPattern(GLucose glucose) {
    super(glucose);
    addModulator(yPos).trigger();
  }
  public void run(int deltaMs) {
    for (Point p : model.points) {
      colors[p.index] = color(
        lx.getBaseHuef(),
        100,
        max(0, 100 - abs(p.fy - yPos.getValuef()))
      );      
    }
  }
}

class TestZPattern extends SCPattern {
  private SinLFO zPos = new SinLFO(0, model.zMax, 4000);
  public TestZPattern(GLucose glucose) {
    super(glucose);
    addModulator(zPos).trigger();
  }
  public void run(int deltaMs) {
    for (Point p : model.points) {
      colors[p.index] = color(
        lx.getBaseHuef(),
        100,
        max(0, 100 - abs(p.fz - zPos.getValuef()))
      );      
    }
  }
}

class TestProjectionPattern extends SCPattern {
  
  final Projection projection;
  final SawLFO angle = new SawLFO(0, TWO_PI, 9000);
  final SinLFO yPos = new SinLFO(-20, 40, 5000);
  
  TestProjectionPattern(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);
    addModulator(angle).trigger();
    addModulator(yPos).trigger();
  }
  
  public void run(int deltaMs) {
    // Note: logically, you typically apply the transformations in reverse order
    projection.reset(model)
      .translate(-model.xMax/2., -model.yMax/2. + yPos.getValuef(), -model.zMax/2.)
      .rotate(angle.getValuef(), 1, 0, 0)
      .scale(1, 1.5, 1);

    for (Coord c : projection) {
      float d = sqrt(c.x*c.x + c.y*c.y + c.z*c.z); // distance from origin
      // d = abs(d-60) + max(0, abs(c.z) - 20); // life saver / ring thing
      d = max(0, abs(c.y) - 10 + .3*abs(c.z) + .08*abs(c.x)); // plane / spear thing
      colors[c.index] = color(
        (lx.getBaseHuef() + .6*abs(c.x) + abs(c.z)) % 360,
        100,
        constrain(140 - 10*d, 0, 100)
      );
    }
  } 
}
