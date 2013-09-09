import netP5.*;
import oscP5.*;

public class PointSliceMap {
  public int X = 0;
  public int Y = 1;
  public int Z = 2;
  public int NUM_AXES = 3;
  public int[] axes_list = new int[NUM_AXES];

  public ArrayList<ArrayList<Point>> x_slices;
  public ArrayList<ArrayList<Point>> y_slices;
  public ArrayList<ArrayList<Point>> z_slices;
  public ArrayList[] slices = new ArrayList[NUM_AXES];

  private int slice_magnification = 1000;
  private int slice_size = 0;
  private int slices_longest_axis = 100;
  private int[] model_min = new int[NUM_AXES];
  private int model_min_x = slice_magnification * slices_longest_axis;
  private int model_min_y = slice_magnification * slices_longest_axis;
  private int model_min_z = slice_magnification * slices_longest_axis;
  private int model_max_x = - model_min_x;
  private int model_max_y = - model_min_y;
  private int model_max_z = - model_min_z;
  private int[] model_max = new int[NUM_AXES];
  private int model_x_range = 0;
  private int model_y_range = 0;
  private int model_z_range = 0;
  private int[] model_range = new int[NUM_AXES];
  public int num_x_slices = 0;
  public int num_y_slices = 0;
  public int num_z_slices = 0;
  private int[] num_slices = new int[NUM_AXES];
  private int longest_axis = 0;

  

  public void debugPrint() {
    println("Slice Size: " + slice_size);
    println("Longest axis: " + longest_axis);
    println("Model x range: (" + model_min_x + ") - (" + model_max_x + "); Total: (" + model_x_range +  "); # Slices: " + num_x_slices);
    println("Model y range: (" + model_min_y + ") - (" + model_max_y + "); Total: (" + model_y_range +  "); # Slices: " + num_y_slices);
    println("Model z range: (" + model_min_z + ") - (" + model_max_z + "); Total: (" + model_z_range +  "); # Slices: " + num_z_slices);
  }

  /* Convert float coordinate to integer slice map coordinate */
  public int magnify(float val) {
    return (int) (val * slice_magnification);
  }

  /* Convert magnified point coordinate to slice index in axis (x = 0, y = 1, z = 2) */
  public int getPointSliceIndex(int axis, int coor) {
    int mag = coor - model_min[axis] + slice_magnification;
    return ((mag - (mag % slice_size))) / slice_size;
  }

  /* Convert magnified point coordinate to slice index in axis (x = 0, y = 1, z = 2) */
  public int getPointSliceIndex(int axis, float coor) {
    return getPointSliceIndex(axis, magnify(coor));
  }

  /* Get the x slice index the point resides in */
  public int getPointXSliceIndex(Point point) {
    return getPointSliceIndex(X, magnify(point.x));
  }

  /* Get the y slice index the point resides in */
  public int getPointYSliceIndex(Point point) {
    return getPointSliceIndex(Y, magnify(point.y));
  }

  /* Get the z slice index the point resides in */
  public int getPointZSliceIndex(Point point) {
    return getPointSliceIndex(Z, magnify(point.z));
  }

  public PointSliceMap(GLucose glucose) {
    for (int axis_i = 0; axis_i < NUM_AXES; axis_i++)
      axes_list[axis_i] = axis_i;

    for (int axis_i : axes_list)
      slices[axis_i] = new ArrayList<ArrayList<Point>>();

    // Get minimum and maximum int coordinates for axes
    for (Strip strip: glucose.model.strips) {
      for (Point point: strip.points) {
        int[] point_coor = {magnify(point.x), magnify(point.y), magnify(point.y)};
        for (int axis_i : axes_list)
          if (point_coor[axis_i] > model_max[axis_i])
            model_max[axis_i] = point_coor[axis_i];
          else if (point_coor[axis_i] < model_min[axis_i])
            model_min[axis_i] = point_coor[axis_i];
      }
    }

    // Calculate model ranges with margin for slices
    for (int axis_i : axes_list)
      model_range[axis_i] = model_max[axis_i] - model_min[axis_i] + slice_magnification * 2;

    // Find the longest axis
    for (int axis_i : axes_list)
      if (model_range[axis_i] > longest_axis)
        longest_axis = model_range[axis_i];

    // Find number of slices per axis
    slice_size = (int) (longest_axis / slices_longest_axis);
    for (int axis_i : axes_list)
      num_slices[axis_i] = (model_range[axis_i] - (model_range[axis_i] % slice_size) + slice_size) / slice_size;

    for (int axis_i : axes_list)
      for (int slice_i = 0; slice_i < num_slices[axis_i]; slice_i++)
        slices[axis_i].add(new ArrayList<Point>());

    for (Strip strip: glucose.model.strips) {
      for (Point point: strip.points) {
        // slices[X].get(getPointXSliceIndex(point)).add(point);
      }
    }
  }
}

class HouseOfTheRisingSun extends SCPattern {
  private int debug_print = 0;

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

  private PointSliceMap slice_map;

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

    slice_map = new PointSliceMap(glucose);

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

  // public void 

  void run(int deltaMs) {
    /* psudo code


    */
    if (debug_print == 0) {
      slice_map.debugPrint();
      debug_print++;
    }

    // updateInnerCoordinates();
    sun_x = center_x;
    sun_y = sun_height.getValuef() * model_max_y;
    sun_z = center_z;
    sun_r = sun_radius.getValuef() * model_max_z;
    for (Strip strip : model.strips) {
      for (Point p : strip.points) {
        // float br_ratio = ((float) slice_map.getPointYSliceIndex(p) / (float) slice_map.num_y_slices * 100);
        // int x_sin_mod = 20 - (int) (20 + 20 * Math.sin(2.0f * 3.14f * p.x / model_max_x));
        // int br = (int) (50 * (Math.log((80 - br_ratio) * .9 - 10) / Math.log(10))) + 2 + x_sin_mod;
        // // println(br_ratio + " "  + br + " " + slice_map.getPointYSliceIndex(p) + " " + slice_map.num_y_slices);
        // colors[p.index] = color(
        //     slice_map.getPointXSliceIndex(p)*3.6,
        //     100,
        //     br
        //   );
      }
    }
  }
};

/* House of the Rising Sun test code before slice map */
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

class RemoteDriver extends Thread {
  OscP5 tcp_server;
  // OscP5 tcp_client;

  void run() {
    tcp_server = new OscP5(this, port, OscP5.TCP);

    while(true) {
      // sleep(1);
    }
  }

  public ArrayList<color[]> frame_buffers;
  public int NUMBER_OF_BUFFERS = 5;
  public int buffer_ready
  public int port = 0;

  public RemoteDriver(int port_) {
    port = port_;
    frame_buffers = new ArrayList<color[]>();
    for (int buf_i = 0; buf_i < NUMBER_OF_BUFFERS; buf_i++) {
      frame_buffers.add(new color[glucose.getColors().length]);
      System.arraycopy(glucose.getColors(), 0, frame_buffers.get(buf_i), 0, glucose.getColors().length);
    }

    this.start();
  }

  public void oscEvent(OscMessage osc_msg) {
    if (osc_msg.checkAddrPattern("/framebuffer/set/index")) {
      /* ========== /framebuffer/set ==========
          
                                                */
      String security_code = osc_msg.get(0).stringValue();
      int frame_index = osc_msg.get(0).intValue();
    }
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
    int prt_cnt = 0;
    for (Strip strip : model.strips) {
      for (Point p : strip.points) {
        colors[p.index] = color(p.index % 3, 50, 50);
        remote_driver.frame_buffers.get(0)[p.index] = color(10, 50, 50);
        remote_driver.frame_buffers.get(1)[p.index] = color(100, 50, 50);
        remote_driver.frame_buffers.get(2)[p.index] = color(150, 50, 50);
        remote_driver.frame_buffers.get(3)[p.index] = color(200, 50, 50);
        remote_driver.frame_buffers.get(4)[p.index] = color(250, 50, 50);
        if (prt_cnt < 5) {
          println("Original: " + colors[p.index]);
          println("Copy 1: " + remote_driver.frame_buffers.get(0)[p.index]);
          println("Copy 2: " + remote_driver.frame_buffers.get(1)[p.index]);
          println("Copy 3: " + remote_driver.frame_buffers.get(2)[p.index]);
          println("Copy 4: " + remote_driver.frame_buffers.get(3)[p.index]);
          println("Copy 5: " + remote_driver.frame_buffers.get(4)[p.index]);
          prt_cnt++;
        }
      }
    }
  }
}

