color BLACK = color(0, 0, 0);

class Gimbal extends SCPattern {

  private final boolean DEBUG_MANUAL_ABG = false;
  private final int MAXIMUM_BEATS_PER_REVOLUTION = 100;
  
  private boolean first_run = true;
  private final Projection projection;
  private final BasicParameter beatsPerRevolutionParam = new BasicParameter("SLOW", 20./MAXIMUM_BEATS_PER_REVOLUTION);
  private final BasicParameter hueDeltaParam = new BasicParameter("HUED", 60./360);
  private final BasicParameter fadeFromCoreParam = new BasicParameter("FADE", 1);
  private final BasicParameter girthParam = new BasicParameter("GRTH", .18);
  private final BasicParameter ringExtendParam = new BasicParameter("XTND", 1);
  private final BasicParameter relativeSpeedParam = new BasicParameter("RLSP", .83);
  private final BasicParameter sizeParam = new BasicParameter("SIZE", .9);

  private final BasicParameter aP = new BasicParameter("a", 0);
  private final BasicParameter bP = new BasicParameter("b", 0);
  private final BasicParameter gP = new BasicParameter("g", 0);

  Gimbal(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);
    addParameter(beatsPerRevolutionParam);
    addParameter(hueDeltaParam);
    addParameter(fadeFromCoreParam);
    addParameter(girthParam);
    addParameter(ringExtendParam);
    addParameter(relativeSpeedParam);
    addParameter(sizeParam);
    
    if (DEBUG_MANUAL_ABG) {
      addParameter(aP);
      addParameter(bP);
      addParameter(gP);
    }
  }

  float a = 0, b = 0, g = 0;

  public void run(double deltaMs) {

    if (DEBUG_MANUAL_ABG) {
      a = aP.getValuef() * (2 * PI); 
      b = bP.getValuef() * (2 * PI);
      g = gP.getValuef() * (2 * PI);
    } else {
      float relativeSpeed = relativeSpeedParam.getValuef();
      float time = millis() / 1000.f;
      
      int beatsPerRevolution = (int) (beatsPerRevolutionParam.getValuef() * MAXIMUM_BEATS_PER_REVOLUTION) + 1;
      float radiansPerMs = 2 * PI             // radians / revolution
                         / beatsPerRevolution // beats / revolution
                         * lx.tempo.bpmf()    // BPM beats / min
                         / 60                 // sec / min
                         / 1000;              // ms / sec
      
      a += deltaMs * radiansPerMs * pow(relativeSpeed, 0);
      b += deltaMs * radiansPerMs * pow(relativeSpeed, 1);
      g += deltaMs * radiansPerMs * pow(relativeSpeed, 2);
      a %= 2 * PI;
      b %= 2 * PI;
      g %= 2 * PI;
    }

    float hue = lx.getBaseHuef();
    float hue_delta = hueDeltaParam.getValuef() * 360;
    
    float radius1 = model.xMax / 2 * sizeParam.getValuef();
    float radius2 = ((model.xMax + model.yMax) / 2) / 2 * sizeParam.getValuef();
    float radius3 = model.yMax / 2 * sizeParam.getValuef();
    float girth = model.xMax * girthParam.getValuef();
    Ring ring1 = new Ring((hue + hue_delta * 0) % 360, radius1, girth);
    Ring ring2 = new Ring((hue + hue_delta * 1) % 360, radius2, girth);
    Ring ring3 = new Ring((hue + hue_delta * 2) % 360, radius3, girth);

    projection.reset(model)
      // Translate so the center of the car is the origin
      .translateCenter(model, 0, 0, 0);

    for (Coord c : projection) {
      //if (first_run) println(c.x + "," + c.y + "," + c.z);

      rotate3d(c, a, 0, 0);
      rotate3d(c, PI/4, PI/4, PI/4);
      color color1 = ring1.colorFor(c);

      rotate3d(c, 0, b, 0);
      color color2 = ring2.colorFor(c);

      rotate3d(c, 0, 0, g);
      color color3 = ring3.colorFor(c);
            
      colors[c.index] = specialBlend(color1, color2, color3);      
    }

    first_run = false;
  }

  class Ring {

    float hue;
    float radius, girth;

    public Ring(float hue, float radius, float girth) {
      this.hue = hue;
      this.radius = radius;
      this.girth = girth;
    }

    public color colorFor(Coord c) {
      float theta = atan2(c.y, c.x);
      float nearest_circle_x = cos(theta) * radius;
      float nearest_circle_y = sin(theta) * radius;
      float nearest_circle_z = 0;

      float distance_to_circle
          = sqrt(pow(nearest_circle_x - c.x, 2)
               + pow(nearest_circle_y - c.y, 2)
               + pow(nearest_circle_z - c.z * ringExtendParam.getValuef(), 2));

      float xy_distance = sqrt(c.x*c.x + c.y*c.y);
      return color(this.hue, 100, (1 - distance_to_circle / girth * fadeFromCoreParam.getValuef()) * 100);
    }

  }

}






class Zebra extends SCPattern {

  private final Projection projection;
  SinLFO angleM = new SinLFO(0, PI * 2, 30000);

/*
  SinLFO x, y, z, dx, dy, dz;
  float cRad;
  _P size;
  */

  Zebra(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);

    addModulator(angleM).trigger();
  }

  color colorFor(Coord c) {
    float hue = lx.getBaseHuef();




/* SLIDE ALONG
    c.x = c.x + millis() / 100.f;
    */



    int stripe_count = 12;
    float stripe_width = model.xMax / (float)stripe_count;
    if (Math.floor((c.x) / stripe_width) % 2 == 0) {
      return color(hue, 100, 100);
    } else {
      return color((hue + 90) % 360, 100, 100);
    }


    /* OCTANTS

    if ((isPositiveBit(c.x) + isPositiveBit(c.y) + isPositiveBit(c.z)) % 2 == 0) {
      return color(lx.getBaseHuef(), 100, 100);
    } else {
      return color(0, 0, 0);
    }
    */
  }

  int isPositiveBit(float f) {
    return f > 0 ? 1 : 0;
  }

  public void run(double deltaMs) {
    float a = (millis() / 1000.f) % (2 * PI);
    float b = (millis() / 1200.f) % (2 * PI);
    float g = (millis() / 1600.f) % (2 * PI);

    projection.reset(model)
      // Translate so the center of the car is the origin
      .translateCenter(model, 0, 0, 0);

    for (Coord c : projection) {
//      rotate3d(c, a, b, g);
      colors[c.index] = colorFor(c);
    }

    first_run = false;
  }


  // Utility!
  boolean first_run = true;
  private void log(String s) {
    if (first_run) {
      println(s);
    }
  }


}

void rotate3d(Coord c, float a /* roll */, float b /* pitch */, float g /* yaw */) {
  float cosa = cos(a);
  float cosb = cos(b);
  float cosg = cos(g);
  float sina = sin(a);
  float sinb = sin(b);
  float sing = sin(g);

  float a1 = cosa*cosb;
  float a2 = cosa*sinb*sing - sina*cosg;
  float a3 = cosa*sinb*cosg + sina*sing;
  float b1 = sina*cosb;
  float b2 = sina*sinb*sing + cosa*cosg;
  float b3 = sina*sinb*cosg - cosa*sing;
  float c1 = -sinb;
  float c2 = cosb*sing;
  float c3 = cosb*cosg;

  float[] cArray = { c.x, c.y, c.z };
  c.x = dotProduct(new float[] {a1, a2, a3}, cArray);
  c.y = dotProduct(new float[] {b1, b2, b3}, cArray);
  c.z = dotProduct(new float[] {c1, c2, c3}, cArray);
}

float dotProduct(float[] a, float[] b) {
  float ret = 0;
  for (int i = 0 ; i < a.length; ++i) {
    ret += a[i] * b[i];
  }
  return ret;
}

color specialBlend(color c1, color c2, color c3) {
  float h1 = hue(c1);
  float h2 = hue(c2); 
  float h3 = hue(c3);
  
  // force h1 < h2 < h3
  while (h2 < h1) {
    h2 += 360;
  }
  while (h3 < h2) {
    h3 += 360;
  }

  float s1 = saturation(c1); 
  float s2 = saturation(c2); 
  float s3 = saturation(c3);
  
  float b1 = brightness(c1); 
  float b2 = brightness(c2);
  float b3 = brightness(c3);
  float relative_b1 = b1 / (b1 + b2 + b3);
  float relative_b2 = b2 / (b1 + b2 + b3);
  float relative_b3 = b3 / (b1 + b2 + b3);
  
  return color(
    (h1 * relative_b1 + h2 * relative_b1 + h3 * relative_b3) % 360,
     s1 * relative_b1 + s2 * relative_b2 + s3 * relative_b3,
     max(max(b1, b2), b3)
  );
}

