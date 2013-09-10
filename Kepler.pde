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

    // Instantiate axis slices
    for (int axis_i : axes_list)
      for (int slice_i = 0; slice_i < num_slices[axis_i]; slice_i++)
        slices[axis_i].add(new ArrayList<Point>());

    // Sort points into slices
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

class RemoteDriver extends Thread {

  // TODO: IMPLEMENT SYNCHRONIZATION TO AVOID MISSED PACKETS
  OscP5 udp_server;

  void run() {
    // Create UDP server for secure (NOT)  transmission of frame data packets 
    // containing LED indices
    udp_server = new OscP5(this, port);

    while(true) {
      // TODO: Find something to do here; sleep?
    }
  }

  // Dynamic array of frame buffers
  // TODO: Change to static array?
  public ArrayList<color[]> frame_buffers;

  // Length of buffer and colors array
  public int colors_length = 0;

  // Buffer set to all color(0, 0, 0)
  public color[] null_buffer;

  // Number of frame buffers to allocate
  public int NUMBER_OF_BUFFERS = 5;

  // Frame set to color(0, 0, 0) and ready to be filled
  public int FRAMEBUFFER_NULLED = -1;
  // Frame ready to be filled but there is no guarantee of existing pixel color
  public int FRAMEBUFFER_EMPTY = 0;
  // Frame is ready to be drawn by the remote pattern
  public int FRAMEBUFFER_READY = 1;
  public int FRAMEBUFFER_SENDING = 2;
  public int[] buffer_status = new int[NUMBER_OF_BUFFERS];

  // Absolute frame count of last frame loaded into buffer
  public int[] frame_count = new int[NUMBER_OF_BUFFERS];

  // Absolute frame count
  public int frame_number = 0;

  // Index of last frame loaded
  public int last_frame = 0;
  // Index of next empty frame
  public int frame_next = 0;

  public int port = 0;


  public RemoteDriver(int port_) {
    port = port_;
    colors_length = glucose.getColors().length;
    frame_buffers = new ArrayList<color[]>();
    null_buffer = new color[colors_length];
    // Set null buffer to all color(0, 0, 0)
    for (int null_i = 0; null_i < colors_length; null_i++)
      null_buffer[null_i] = color(0, 0, 0);
    // Create and null frame buffers
    for (int buf_i = 0; buf_i < NUMBER_OF_BUFFERS; buf_i++) {
      frame_buffers.add(new color[colors_length]);
      nullFrameBuffer(buf_i);
    }

    this.start();
  }

  /* Sets all pixels in a frame buffer to color(0, 0, 0)
      Arguments:
        int frame_index: Index of frame to null
          If the frame does not exist, it nulls all frames (CHANGE) */
  public void nullFrameBuffer(int frame_index) {
    // TODO: Add exceptions
    //        Frame index out of bounds
    //        frame_index < 0 = wipe all or out of bounds?
    if (frame_index < 0 || frame_index >= NUMBER_OF_BUFFERS)
      for (int buf_i = 0; buf_i < NUMBER_OF_BUFFERS; buf_i++)
      {
        System.arraycopy(null_buffer, 0, frame_buffers.get(buf_i), 0, colors_length);
        buffer_status[buf_i] = FRAMEBUFFER_NULLED;
      }
    else {
      System.arraycopy(null_buffer, 0, frame_buffers.get(frame_index), 0, colors_length);
      buffer_status[frame_index] = FRAMEBUFFER_NULLED;
    }
  }

  public void sendOscErrorCode(OscMessage osc_msg, int error_code) {

  }

  /* OSC server event handler */
  public void oscEvent(OscMessage osc_msg) {
    println("Received OSC Message");
    println("Address: " + osc_msg.addrPattern());
    if (osc_msg.checkAddrPattern("/framebuffer/set")) {
      /* ========== /framebuffer/set ==========
          Sets pixel values in next available buffer 

          Parameters:
            String security_code: Reserved for authentication in the future
            int frame_index: Index of frame to set or -1 for next empty frame
            int payload_length: Length of packet data contents
            byte[] payload: Packet data contents


          Payload Point Array Format @ 6 Bytes/Pixel
            unsigned short int point_index:
              byte 0          - high byte
              byte 1          - low byte
                ([byte 0] << 8) + ([byte 1])
            color/int point_color:
              byte 2-5        - high to low bytes
              ([byte 2] << 24) + ([byte 3] << 16) + ([byte 4] << 8) + ([byte 5])
          ^ CERTIFIABLY RETARDED ^ - Change to for loop that gets color with starting point index
                                                 */
      String security_code = osc_msg.get(0).stringValue();
      println("Security Code: " + security_code);
      int frame_index = osc_msg.get(1).intValue();
      println("Frame Index: " + frame_index);
      int payload_length = osc_msg.get(2).intValue();
      println("Payload Length: " + payload_length);
      byte[] payload = new byte[payload_length];
      // payload = osc_msg.get(3).bytesValue();
      println("Creating payload debug string...");
      // String payload_debug = new String(payload);
      println("Payload: TESTING SHIT SO HOLD ON");


      // TODO: Raise exception for -1 > frame_index >= NUMBER_OF_BUFFERS
      // TODO: Interaction of frame_index and frame_next will be weird
      if (frame_index < 0 || frame_index >= NUMBER_OF_BUFFERS)
        frame_index = frame_next;

       String payload_debug = new String(payload);
      println("Security Code: " + security_code);
      println("Frame Index: " + frame_index);
      println("Payload Length: " + payload_length);
      println("Payload: " + payload_debug);
      // for (int payload_index = 0; payload_index < payload_length; payload_index++) {
      //   // Combine byte 0 and 1 for point index in colors array
      //   int p_index = ((int) payload[payload_index*6] << 8) + ((int) payload[payload_index*6+1]);
      //   int new_color = 0;
      //   // Combine bytes 2-5 into point color as 32 bit int
      //   for (int byte_i = 0; byte_i < 4; byte_i++)
      //     new_color += (int) payload[payload_index * 6 + 2 + byte_i] << (8 * (3 - byte_i));
      //   // If point exists (ignore point 0 for now), set the color in the frame buffer
      //   if (colors_length > p_index && p_index > 0) {
      //     frame_buffers.get(frame_index)[p_index] = new_color;
      //   }
      // }
    }
    if (osc_msg.checkAddrPattern("/framebuffer/ready")) {
      // TODO: Add locks to prevent race conditions (draw functions will try to copy buffer )
      String security_code = osc_msg.get(0).stringValue();
      int frame_index = osc_msg.get(0).intValue();
      println("Security Code: " + security_code);
      println("Frame Index: " + frame_index);
      if (frame_index < 0 || frame_index >= NUMBER_OF_BUFFERS) {
        int old_frame_next = frame_next;
        frame_number++;
        frame_count[old_frame_next] = frame_number;
        frame_next = getNextFrameIndex(frame_count[old_frame_next]);
      } else {
        // TODO: Implement checks on buffer status before setting it
      }
    }
    // if (osc_msg.checkAddrPattern("/framebuffer/next") {

    // }
  }

  /* Returns the index of the next empty or nulled frame 
      frame_num = frame count of the last set frame buffer */
  public int getNextFrameIndex(int frame_num) {
    int lowest_frame_cnt = frame_count[frame_next];
    int temp_frame_next = 0;
    for (int frame_i = 0; frame_i < NUMBER_OF_BUFFERS; frame_i++)
        if (buffer_status[frame_i] < FRAMEBUFFER_READY && frame_count[frame_i] < lowest_frame_cnt) {
          lowest_frame_cnt = frame_count[frame_i];
          temp_frame_next = frame_i;
        }
    return temp_frame_next;
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
    /* psudo codes


    */
    
    for (Strip strip : model.strips) {
      for (Point p : strip.points) {
        colors[p.index] = color(p.index % 3, 50, 50);
      }
    }
  }
}

