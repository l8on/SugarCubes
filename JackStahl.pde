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
 * This is not done.
 */
class Breathe extends SCPattern {

  final BasicParameter hueScale = new BasicParameter("HUE", 0.3);

  class Sphere {
    float x, y, z;
  }


  // Projection stuff
  private final Projection projection;

  SinLFO sphere1Z = new SinLFO(0, 80, 15323);
  SinLFO sphere2Z = new SinLFO(-80, 0, 8323);
  SawLFO rotation = new SawLFO(- PI / 16, PI / 16, 7334);


  private final Sphere[] spheres;
  private final float centerX, centerY, centerZ, modelHeight, modelWidth, modelDepth;
  SinLFO heightMod = new SinLFO(0.6, 1.85, 17298);

  public Breathe(GLucose glucose) {
    super(glucose);

    // Unused for now
    projection = new Projection(model);

    addParameter(hueScale);

    spheres = new Sphere[2];
    centerX = (model.xMax + model.xMin) / 2;
    centerY = (model.yMax + model.yMin) / 2;
    centerZ = (model.zMax + model.zMin) / 2;
    modelHeight = model.yMax - model.yMin;
    modelWidth = model.xMax - model.xMin;
    modelDepth = model.zMax - model.zMin;

    spheres[0] = new Sphere();
    spheres[0].x = 3*modelWidth/8;
    spheres[0].y = centerY + 10;
    spheres[0].z = centerZ;

    spheres[1] = new Sphere();
    spheres[1].x = 7*modelWidth/8;
    spheres[1].y = centerY - 20;
    spheres[1].z = centerZ;


    addModulator(sphere1Z).trigger();
    addModulator(sphere2Z).trigger();

    addModulator(heightMod).trigger();
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
    float phase = (beat+ramp) * PI % (2 * PI);

    projection.reset(model)
      .rotate(rotation.getValuef(), 0, 1, 0);

    for (Coord p : projection) {
      float x_percentage = (p.x - model.xMin)/modelWidth;

      float y_in_range = heightMod.getValuef() * (2*p.y - model.yMax - model.yMin) / modelHeight;
      float sin_x =  sin(PI / 2 + phase + 2 * PI * x_percentage);       

      // Color fade near the top of the sin wave
      float v1 = sin_x > y_in_range  ? (100 + 100*(y_in_range - sin_x)) : 0;     

      float hue_color = (lx.getBaseHuef() + hueScale.getValuef() * (abs(p.x-model.xMax/2.)*.6 + abs(p.y-model.yMax/2)*.9 + abs(p.z - model.zMax/2.))) % 360;
      color c = color(hue_color, 40, v1);

      // Now draw the spheres
      for (Sphere s : spheres) {
        float phase_x = (s.x - phase * modelWidth / ( 2 * PI)) % modelWidth;        
        float x_dist = LXUtils.wrapdistf(p.x, phase_x, modelWidth);

        float sphere_z = (s == spheres[0]) ? (s.z + sphere1Z.getValuef()) : (s.z - sphere2Z.getValuef()); 

        float d = sqrt(pow(x_dist, 2) + pow(p.y - s.y, 2) + pow(p.z - sphere_z, 2));
        float r = 25;

        float distance_value = max(0, 1 - max(0, d - r) / 10);
        float beat_value = 1.0;
        if (s == spheres[0]) {
          //          beat_value = .2 + ((beat % 4 >= 2) ? ((4 - (ramp + beat)) / 2) *.8 : 0);
        } 
        else {
          //          beat_value = .2 + ((beat % 4 < 2) ? ((2 - (ramp + beat)) / 2) *.8 : 0);
        } 

        float value = min(beat_value, distance_value);

        c = blendColor(c, color((hue_color + 90) % 360, 100, min(1, value) * 100), ADD);
      }
      colors[p.index] = c;
    }
  }
}

