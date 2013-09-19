
class TelevisionStatic extends SCPattern {
  BasicParameter brightParameter = new BasicParameter("BRIGHT", 1.0);
  BasicParameter saturationParameter = new BasicParameter("SAT", 1.0);
  BasicParameter hueParameter = new BasicParameter("HUE", 1.0);
  SinLFO direction = new SinLFO(0, 10, 3000);
  
  public TelevisionStatic(GLucose glucose) {
    super(glucose);
    addModulator(direction).trigger();
    addParameter(brightParameter);
    addParameter(saturationParameter);
    addParameter(hueParameter);
  }

 void run(double deltaMs) {
    boolean d = direction.getValuef() > 5.0;
    for (Point p : model.points) {             
      colors[p.index] = color((lx.getBaseHuef() + random(hueParameter.getValuef() * 360))%360, random(saturationParameter.getValuef() * 100), random(brightParameter.getValuef() * 100));
    }
  }
}

class AbstractPainting extends SCPattern {
  
  PImage img;
  
  SinLFO colorMod = new SinLFO(0, 360, 5000);
  SinLFO brightMod = new SinLFO(0, model.zMax, 2000);
    
  public AbstractPainting(GLucose glucose) {
    super(glucose);
    addModulator(colorMod).trigger();
    addModulator(brightMod).trigger();
    
    img = loadImage("abstract.jpg");
    img.loadPixels();    
  } 
 
  void run(double deltaMs) {    
    for (Point p : model.points) {
      color c = img.get((int)((p.x / model.xMax) * img.width), img.height - (int)((p.y / model.yMax) * img.height));
      colors[p.index] = color(hue(c) + colorMod.getValuef()%360, saturation(c), brightness(c) - ((p.fz - brightMod.getValuef())/p.fz));
    }    
  }       
}

class Spirality extends SCPattern {
  final BasicParameter r = new BasicParameter("RADIUS", 0.5);
  
  float angle = 0;
  float rad = 0;
  int direction = 1;
  
  Spirality(GLucose glucose) {
    super(glucose);   
    addParameter(r);
    for (Point p : model.points) {  
      colors[p.index] = color(0, 0, 0);
    }
  }
    
  public void run(double deltaMs) {
    angle += deltaMs * 0.007;
    rad += deltaMs * .025 * direction;
    float x = model.xMax / 2 + cos(angle) * rad;
    float y = model.yMax / 2 + sin(angle) * rad;
    for (Point p : model.points) {    
      float b = dist(x,y,p.fx,p.fy);
      if (b < 90) {
        colors[p.index] = blendColor(
          colors[p.index],
          color(lx.getBaseHuef() + 25, 10, map(b, 0, 10, 100, 0)),
          ADD);        
        } else {
      colors[p.index] = blendColor(
        colors[p.index],
        color(25, 10, map(b, 0, 10, 0, 15)),
        SUBTRACT); 
      }
    }
    if (rad > model.xMax / 2 || rad <= .001) {
      direction *= -1;
    }
  }
}




