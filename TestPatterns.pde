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

class TestXPattern extends SCPattern {
  private SinLFO xPos = new SinLFO(0, 255, 4000);
  public TestXPattern(GLucose glucose) {
    super(glucose);
    addModulator(xPos).trigger();
  }
  public void run(int deltaMs) {
    for (Point p : Point.list) {
      colors[p.index] = color(
        lx.getBaseHuef(),
        100,
        max(0, 100 - abs(p.fx - xPos.getValuef()))
      );      
    }
  }
}

class TestYPattern extends SCPattern {
  private SinLFO yPos = new SinLFO(0, 127, 4000);
  public TestYPattern(GLucose glucose) {
    super(glucose);
    addModulator(yPos).trigger();
  }
  public void run(int deltaMs) {
    for (Point p : Point.list) {
      colors[p.index] = color(
        lx.getBaseHuef(),
        100,
        max(0, 100 - abs(p.fy - yPos.getValuef()))
      );      
    }
  }
}

class TestZPattern extends SCPattern {
  private SinLFO zPos = new SinLFO(0, 127, 4000);
  public TestZPattern(GLucose glucose) {
    super(glucose);
    addModulator(zPos).trigger();
  }
  public void run(int deltaMs) {
    for (Point p : Point.list) {
      colors[p.index] = color(
        lx.getBaseHuef(),
        100,
        max(0, 100 - abs(p.fz - zPos.getValuef()))
      );      
    }
  }
}
