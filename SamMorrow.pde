abstract class SamPattern extends SCPattern {
  public SamPattern(GLucose glucose) {
    super(glucose);
    setEligible(false);
  }
}

class JazzRainbow extends SamPattern {
  public JazzRainbow(GLucose glucose) {
    super(glucose);
  }

  
  public void run(double deltaMs) {
    // Access the core master hue via this method call
    float hv = lx.getBaseHuef();
    for (int i = 0; i < colors.length*5; i=i+27) {
      float a = hv%250;
      if (i%2 == 0) {
        for (int b = 0; b < 70; b++) {
         colors[(i+b)%colors.length] = color(a+i%250, 100, b*a%100);
        }
      }
    }
  } 
}
