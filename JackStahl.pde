/**
 * A Projection of sin wave in 3d space. 
 * It sort of looks like an animal swiming around in water.
 * Angle sliders are sort of a work in progress that allow yo to change the crazy ways it moves around.
 * Hue slider allows you to control how different the colors are along the wave. 
 *
 * This code copied heavily from Tim and Slee.
 */
class Swim extends SCPattern {

  // Projection stuff
  private final Projection projection;
  SawLFO rotation = new SawLFO(0, TWO_PI, 19000);
  SinLFO yPos = new SinLFO(-25, 25, 12323);
  final BasicParameter xAngle = new BasicParameter("XANG", 0.9);
  final BasicParameter yAngle = new BasicParameter("YANG", 0.3);
  final BasicParameter zAngle = new BasicParameter("ZANG", 0.3);
  
  final BasicParameter hueScale = new BasicParameter("HUE", 0.3);

  public Swim(GLucose glucose) {
    super(glucose);
    projection = new Projection(model);

    addParameter(xAngle);
    addParameter(yAngle);
    addParameter(zAngle);
    addParameter(hueScale);

    addModulator(rotation).trigger();
    addModulator(yPos).trigger();

  }


  int beat = 0;
  float prevRamp = 0;
  void run(int deltaMs) {

    // Sync to the beat
    float ramp = (float)lx.tempo.ramp();
    if (ramp < prevRamp) {
      beat = (beat + 1) % 4;
    }
    prevRamp = ramp;
    float phase = (beat+ramp) / 2.0 * 2 * PI;

    float denominator = max(xAngle.getValuef() + yAngle.getValuef() + zAngle.getValuef(), 1);

    projection.reset(model)
      // Swim around the world
      .rotate(rotation.getValuef(), xAngle.getValuef() / denominator, yAngle.getValuef() / denominator, zAngle.getValuef() / denominator)
        .translateCenter(model, 0, 50 + yPos.getValuef(), 0);

    float model_height =  model.yMax - model.yMin;
    float model_width =  model.xMax - model.xMin;
    for (Coord p : projection) {
      float x_percentage = (p.x - model.xMin)/model_width;

      // Multiply by 1.4 to shrink the size of the sin wave to be less than the height of the cubes.
      float y_in_range = 1.4 * (2*p.y - model.yMax - model.yMin) / model_height;
      float sin_x =  sin(phase + 2 * PI * x_percentage);       

      // Color fade near the top of the sin wave
      float v1 = sin_x > y_in_range  ? (100 + 100*(y_in_range - sin_x)) : 0;     

      float hue_color = (lx.getBaseHuef() + hueScale.getValuef() * (abs(p.x-model.xMax/2.)*.3 + abs(p.y-model.yMax/2)*.9 + abs(p.z - model.zMax/2.))) % 360;
      colors[p.index] = color(hue_color, 70, v1);
    }
  }
}

/** 
 * The idea here is to do another sin wave pattern, but with less rotation and more of a breathing / heartbeat affect with spheres above / below the wave.
 * TODO
 */ 
class Breathe extends SCPattern {

  final BasicParameter hueScale = new BasicParameter("HUE", 0.3);

  public Breathe(GLucose glucose) {
    super(glucose);

    addParameter(hueScale);
  }


  int beat = 0;
  float prevRamp = 0;
  void run(int deltaMs) {

    // Sync to the beat
    float ramp = (float)lx.tempo.ramp();
    if (ramp < prevRamp) {
      beat = (beat + 1) % 4;
    }
    prevRamp = ramp;
    float phase = (beat+ramp) / 2.0 * 2 * PI;

    float model_height =  model.yMax - model.yMin;
    float model_width =  model.xMax - model.xMin;
    for (Point p : model.points) {
      float x_percentage = (p.x - model.xMin)/model_width;

      // Multiply by 1.4 to shrink the size of the sin wave to be less than the height of the truck.
      float y_in_range = 1.4 * (2*p.y - model.yMax - model.yMin) / model_height;
      // xcxc add back phase
      float sin_x =  sin(phase + 2 * PI * x_percentage);       

      // Color fade near the top of the sin wave
      float v1 = sin_x > y_in_range  ? (100 + 100*(y_in_range - sin_x)) : 0;     

      float hue_color = (lx.getBaseHuef() + hueScale.getValuef() * (abs(p.x-model.xMax/2.)*.6 + abs(p.y-model.yMax/2)*.9 + abs(p.z - model.zMax/2.))) % 360;
      colors[p.index] = color(hue_color, 70, v1);
    }
  }
}


