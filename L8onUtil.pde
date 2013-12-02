/**
 * Base class for keeping the state of a shape for a
 * game of life simulation.
 */
class ShapeState {
  // Index of shape
   public Integer index;
   // Boolean which describes if shape is alive.
   public boolean alive;
   // Boolean which describes if strip was just changed;
   public boolean just_changed;
   // Current brightness
   public float current_brightness;

   public ShapeState(Integer index, boolean alive, float current_brightness) {
     this.index = index;
     this.alive = alive;
     this.current_brightness = current_brightness;
     this.just_changed = false;
   }
}

/**
 * Base class for keeping the state of a shape for a
 * multi-dimensional game of life situation.
 *
 * The neighbors are explicitely assigned via a list of indexes.
 */
class ShapeStateWithNeighbors extends ShapeState {

  public List<Integer> neighbors;

  public ShapeStateWithNeighbors(Integer index, boolean alive, float current_brightness, List<Integer> neighbors) {
    super(index, alive, current_brightness);

    this.neighbors = neighbors;
  }
}

/**
 * Specific classes for the different simulations
 */
class PointState extends ShapeState {
  public PointState(Integer index, boolean alive, float current_brightness) {
    super(index, alive, current_brightness);
  }
}

class CubeState extends ShapeStateWithNeighbors {
  public CubeState(Integer index, boolean alive, float current_brightness, List<Integer> neighbors) {
    super(index, alive, current_brightness, neighbors);
  }
}

class StripState extends ShapeStateWithNeighbors {
  public StripState(Integer index, boolean alive, float current_brightness, List<Integer> neighbors) {
    super(index, alive, current_brightness, neighbors);
  }
}


/*
 * A container to keep track of the different 3d strings in the color remix.
 */
class L8onWave {
    public static final int DIRECTION_X = 1;
    public static final int DIRECTION_Y = 2;

    int direction;
    float offset_multiplier;
    float hue_value;

    public L8onWave(int direction, float offset_multiplier) {
      this.direction = direction;
      this.offset_multiplier = offset_multiplier;
    }
  }
