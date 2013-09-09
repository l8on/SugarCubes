
// import org.zeromq.ZMQ;
// import org.zeromq.ZMQ.Context;
// import org.zeromq.ZMQ.Socket;

// import java.util.Map;

public class PointSliceMap {
  public ArrayList<ArrayList<Point>> x_slices;
  public ArrayList<ArrayList<Point>> y_slices;
  public ArrayList<ArrayList<Point>> z_slices;

  public PointSliceMap(GLucose glucose) {
    for (Strip strip: glucose.model.strips) {
      x_slices = new ArrayList<ArrayList<Point>>();
      x_slices.add(new ArrayList<Point>());
    }
  }
}

class HouseOfTheRisingSun extends SCPattern {
  private float model_max_x = 0;
  private float model_max_y = 0;
  private float model_max_z = 0;

  private float center_x = 0;
  private float center_y = 0;
  private float center_z = 0;

  private float model_max_dist = 0;

  public float animation_period = 0;
  public float animation_period_max = 360;

  private float sun_x = 0;
  private float sun_y = 0;
  private float sun_z = 0;
  private float sun_r = 0;

  SinLFO period = new SinLFO(-30, 30, 600);
  SinLFO radius_modulator = new SinLFO(-1, 1, 500);
  SinLFO radius_random = new SinLFO(350, 1200, 17000);
  BasicParameter sun_height = new BasicParameter("HEIGHT", 0.5);
  BasicParameter color_shift = new BasicParameter("COLOR", 0.0);
  BasicParameter sun_radius = new BasicParameter("RADIUS", 0.3);

  public HouseOfTheRisingSun(GLucose glucose)
  {
    super(glucose);

    addModulator(period).trigger();
    addParameter(sun_height);
    addParameter(color_shift);
    addParameter(sun_radius);
    radius_modulator.modulateDurationBy(radius_random);
    period.modulateDurationBy(radius_random);

    for (Strip strip : model.strips) {
      for (Point p : strip.points) {
        if (dist(p.x, p.y, p.z, 0, 0, 0) > model_max_dist)
          model_max_dist = dist(p.x, p.y, p.z, 0, 0, 0);
        if (p.x > model_max_x)
          model_max_x = p.x;
        if (p.y > model_max_y)
          model_max_y = p.y;
        if (p.z > model_max_z)
          model_max_z = p.z;
      }
    }
    center_x = model_max_x / 2;
    center_y = model_max_y / 2;
    center_z = model_max_z / 2;

    sun_x = center_x;
    sun_y = sun_height.getValuef() * model_max_y;
    sun_z = center_z;
    sun_r = 25.0;
  }

  /*
  ======================= Psuedo Documentation =======================
  
  Inner "sun" -> Outer "atmosphere"
    - Sun center is found at (sun_x, sun_y, sun_z) and has a radius of (sun_r)
    - Functions that modify or set the parameters of the sun start with inner
    - Vector functions that modify color parameters in the sun start with innerVector

  colorMap = 
  def generateInner



  */

  public int getHueXModifier(Point p, boolean randomizer) {
    return 0;
  }

  public int innerHueCalculator(Point p) {
    return 0;
  }

  public int innerBrightnessCalculator(Point p) {
    return 100;
  }

  public void setInnerCoordinates(float s_x, float s_y, float s_z, float s_r) {

  }

  public void updateInnerCoordinates(float x_modifier, float y_modifier, float z_modifier, float r_modifier) {
    sun_x = sun_x + x_modifier;
    sun_y = sun_y + y_modifier;
    sun_z = sun_z + z_modifier;
  }

  public void updateInnerCoordinates(int deltaMs) {
    int animation_ms = 0;
  }

  void run(int deltaMs) {
    /* psudo code


    */
    // updateInnerCoordinates();
    sun_x = center_x;
    sun_y = sun_height.getValuef() * model_max_y;
    sun_z = center_z;
    sun_r = sun_radius.getValuef() * model_max_z;
    for (Strip strip : model.strips) {
      for (Point p : strip.points) {
        // if (dist(p.x, p.y, p.z, sun_x, sun_y, sun_z) < (sun_r + radius_mod.getValuef())) {
        //   colors[p.index] = color(
        //       hueCalculator(p)
        //     );
          // colors[p.index] = color(
          //   30 - dist(p.x, p.y, p.z, sun_x, sun_y, sun_z)/sun_r + (int) ((radius_mod.getValuef() / 10 - 0.5) * 10),
          //   100, 100);
        // } else {
          // colors[p.index] = color(
          //     (int) ((color_shift.getValuef()) * 2 - 1) * 30 + (int) period.getValuef() + ( (int) dist(p.x, p.y, p.z, sun_x, sun_y, sun_z)),
          //     int(140 - dist(0, p.y, 0, 0, sun_y, 0)),
          //     80
          //   );
          // float color_b = dist(p.x, p.y, p.z, planet_x, planet_y, planet_z);
          // colors[p.index] = color(
          //   /* hue */ (int) (period.getValue() + (abs(p.x-(planet_x-planet_r))*40) + (abs(p.y-(planet_y-planet_r))*25) + (abs(p.z-(planet_z-planet_r))*15)) % 360,
          //   /* Brightness */  100 - (int) dist(p.x,p.y,p.z, planet_x, planet_y, planet_z),
          //   /* saturation */ 50);
        // }
      }
    }
  }
};

class RemoteDriver extends Thread {
  void run() {
    while(true) {

    }
  }

  public ArrayList<color[]> frame_buffers;
  public color[] temp_color_buffer;
  public int NUMBER_OF_BUFFERS = 5;

  public RemoteDriver(int port) {
    frame_buffers = new ArrayList<color[]>();
    temp_color_buffer = glucose.getColors();
    for (int buf_i = 0; buf_i < NUMBER_OF_BUFFERS; buf_i++) {
      
      System.arraycopy(glucose.getColors(), 0, temp_color_buffer, 0, glucose.getColors().length);
      frame_buffers.add(temp_color_buffer);
    }

    ZMQ.Context context = ZMQ.context(1);
        //  Socket to talk to clients
    ZMQ.Socket socket = context.socket(ZMQ.REP);
    socket.bind ("tcp://*:" + Integer.toString(port));

    this.start();
  }
};

class Remote extends SCPattern {

  public RemoteDriver remote_driver;

  public Remote(GLucose glucose)
  {
    super(glucose);

    remote_driver = new RemoteDriver(5560);
  }
  void run(int deltaMs) {
    /* psudo code


    */
    for (Strip strip : model.strips) {
      for (Point p : strip.points) {
        colors[p.index] = color(p.index % 360, 50, 50);
      }
    }
  }
}

