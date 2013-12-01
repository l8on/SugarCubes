/**
 * A "Game of Life" simulation in 2 dimensions with the cubes as cells.
 *
 * The "DELAY parameter controls the rate of change.
 * The "MUT" parameter controls the probability of mutations. Useful when life oscillates between few states.
 * The "SAT" parameter controls the saturation.
 */
class L8onLife extends SCPattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("DELAY", 200, 0.0, 1000.0);
  // Controls the probability of a mutation in the cycleOfLife
  private BasicParameter mutationParameter = new BasicParameter("MUT", 0.000000011, 0.0, 0.1);
  // Controls the saturation.
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);

  // Alive probability ranges for randomization
  public final double MIN_ALIVE_PROBABILITY = 0.2;
  public final double MAX_ALIVE_PROBABILITY = 0.9;
  
  // The maximum brightness for an alive cell.
  public final float MAX_ALIVE_BRIGHTNESS = 90.0;

  // Cube position oscillator used to select color.
  private final SawLFO cubePos = new SawLFO(0, model.cubes.size(), 4000);

  class CubeState {
     // Index of cube in glucose.model.cubes
     public Integer index;
     // Boolean which describes if cube is alive.
     public boolean alive;
     // Boolean which describes if strip was just changed;
     public boolean just_changed;
     // Current brightness
     public float current_brightness;
     // List of this cubes neighbors
     public List<Integer> neighbors;

     public CubeState(Integer index, boolean alive, float current_brightness, List<Integer> neighbors) {
       this.index = index;
       this.alive = alive;
       this.current_brightness = current_brightness;
       this.neighbors = neighbors;
     }
  }

  // Contains the state of all cubes by index.
  private List<CubeState> cube_states;
  // Contains the amount of time since the last cycle of life.
  private int time_since_last_run;
  // Boolean describing if life changes were made during the current run.
  private boolean any_changes_this_run;
  // Hold the new lives
  private List<Boolean> new_lives;
  
  public L8onLife(GLucose glucose) {
     super(glucose);  
     
     //Print debug info about the cubes.
     //outputCubeInfo();
     
     initCubeStates();
     time_since_last_run = 0;
     any_changes_this_run = false;
     new_lives = new ArrayList<Boolean>();
     
     addParameter(rateParameter);     
     addParameter(mutationParameter);
     addParameter(saturationParameter);
     addModulator(cubePos).trigger();
  }
  
  public void run(double deltaMs) {        
    Integer i = 0;    
    CubeState cube_state;    
    
    any_changes_this_run = false;        
    new_lives.clear();
    time_since_last_run += deltaMs;
    
    for (Cube cube : model.cubes) {
      cube_state = this.cube_states.get(i);

      if(shouldLightCube(cube_state)) {
        lightLiveCube(cube, cube_state, deltaMs);
      } else {
        lightDeadCube(cube, cube_state, deltaMs);
      } 
      
      i++;      
    }
    
    // If we have landed in a static state, randomize cubes.
    if(!any_changes_this_run) {
      randomizeCubeStates();  
    } else {
      // Apply new states AFTER all new states are decided.
      applyNewLives();
    }
    
    if(time_since_last_run >= rateParameter.getValuef()) {
      time_since_last_run = 0;
    }    
  }
  
  private void lightLiveCube(Cube cube, CubeState cube_state, double deltaMs) {
    float cube_dist = LXUtils.wrapdistf((float) cube_state.index, cubePos.getValuef(), model.cubes.size());
    float hv = (cube_dist / model.cubes.size()) * 360;
    float bv = cube_state.current_brightness;

    // Only change brightness if we are between "ticks" or if there is not enough time to fade.
    if(!cube_state.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = min(MAX_ALIVE_BRIGHTNESS, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(cube_state.current_brightness < bv) {
        cube_state.current_brightness = bv;
      } else {
        bv = cube_state.current_brightness;
      }
    }

    for (LXPoint p : cube.points) {
      colors[p.index] = lx.hsb(
        hv,
        saturationParameter.getValuef(),        
        bv
      );
    }        
  }
  
  private void lightDeadCube(Cube cube, CubeState cube_state, double deltaMs) {
    float cube_dist = LXUtils.wrapdistf((float) cube_state.index, cubePos.getValuef(), model.cubes.size());
    float hv = (cube_dist / (float) model.cubes.size()) * 360;
    float bv =  cube_state.current_brightness;

    // Only change brightness if we are between "ticks" or if there is not enough time to fade.
    if(!cube_state.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = 1.0 - min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = max(0.0, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(cube_state.current_brightness > bv) {
        cube_state.current_brightness = bv;
      } else {
        bv = cube_state.current_brightness;
      }
    }

    for (LXPoint p : cube.points) {
      colors[p.index] = lx.hsb(
        hv,
        saturationParameter.getValuef(),        
        bv
      );     
    }  
  } 
    
  private void outputCubeInfo() {
    int i = 0;      
    for (Cube c : model.cubes) {
      print("Cube " + i + ": " + c.x + "," + c.y + "," + c.z + "\n");
      ++i;
    }
    print("Edgeheight: " + Cube.EDGE_HEIGHT + "\n");
    print("Edgewidth: " + Cube.EDGE_WIDTH + "\n");
    print("Channelwidth: " + Cube.CHANNEL_WIDTH + "\n");
  }
  
  private void initCubeStates() {
    List<Integer> neighbors;
    boolean alive = false;  
    CubeState cube_state;      
    this.cube_states = new ArrayList<CubeState>();
    float current_brightness = 0.0;
    Integer i = 0;     
    
    for (Cube c : model.cubes) {
      neighbors = findCubeNeighbors(c, i);
      alive = true;
      cube_state = new CubeState(i, alive, current_brightness, neighbors);
      this.cube_states.add(cube_state);      
      ++i;
    }      
  }
 
  private void randomizeCubeStates() {  
    double prob_range = (1.0 - MIN_ALIVE_PROBABILITY) - (1.0 - MAX_ALIVE_PROBABILITY);
    double prob = MIN_ALIVE_PROBABILITY + (prob_range * Math.random());
    
    //print("Randomizing cubes! p = " + prob + "\n");
     
    for (CubeState cube_state: this.cube_states) {   
      cube_state.alive = (Math.random() <= prob);            
    }    
  }
  
  private List<Integer> findCubeNeighbors(Cube cube, Integer index) {
    List<Integer> neighbors = new LinkedList<Integer>();
    Integer i = 0;
    
    for (Cube c : model.cubes) {          
      if(index != i)  {                   
        if(abs(c.x - cube.x) < (Cube.EDGE_WIDTH * 2) && abs(c.y - cube.y) < (Cube.EDGE_HEIGHT * 2)) {      
          //print("Cube " + i + " is a neighbor of " + index + "\n");
          neighbors.add(i);
        }
      }
      
      i++;
    }

    return neighbors;    
  }
  
  private boolean shouldLightCube(CubeState cube_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      cube_state.just_changed = false;
      return cube_state.alive;
    } else {
      boolean new_life = cycleOfLife(cube_state);
      new_lives.add(new_life);
      return new_life;
    }
  }

  private void applyNewLives() {
    int index = 0;
    for(boolean liveliness: new_lives) {
      CubeState cube_state = this.cube_states.get(index);
      cube_state.alive = new_lives.get(index);
      index++;
    }
  }
      
  private boolean cycleOfLife(CubeState cube_state) {
    Integer index = cube_state.index;
    Integer alive_neighbor_count = countLiveNeighbors(cube_state);               
    boolean before_alive = cube_state.alive;
    boolean after_alive = before_alive;
    double mutation = Math.random();
              
    if(cube_state.alive) {
      if(alive_neighbor_count < 2 || alive_neighbor_count > 3) {
        after_alive = false;
      } else {
        after_alive = true;
      }
      
    } else {
      if(alive_neighbor_count == 2) {
        after_alive = true;
      } else {
        after_alive = false;
      }
    }

    if(mutation <= mutationParameter.getValuef()) {
      after_alive = !after_alive;
    }

    if(before_alive != after_alive) {
      cube_state.just_changed = true;
      any_changes_this_run = true;
    }

    return after_alive;
  }
      
  private Integer countLiveNeighbors(CubeState cube_state) {
    Integer count = 0;    
    CubeState neighbor_cube_state;     
    
    for(Integer neighbor_index: cube_state.neighbors) {      
       neighbor_cube_state = this.cube_states.get(neighbor_index);
       if(neighbor_cube_state.alive) {
         count++;  
       }
    }   
    
    return count;
  }         
}


/**
 * A "Game of Life" simulation in 1 dimension with the points as cells.
 *
 * The "DELAY parameter controls the rate of change.
 * The "MUT" parameter controls the probability of mutations. Useful when life oscillates between few states.
 * The "SAT" parameter controls the saturation.
 */
class L8onAutomata extends SCPattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("DELAY", 75.0, 0.0, 1000.0);
  // Controls the probability of a mutation in the cycleOfStripperLife
  private BasicParameter mutationParameter = new BasicParameter("MUT", 0.000000011, 0.0, 0.1);
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);

  private final SawLFO pointPos = new SawLFO(0, model.points.size(), 8000);

  public final double MIN_ALIVE_PROBABILITY = 0.2;
  public final double MAX_ALIVE_PROBABILITY = 0.5;

  public final float MAX_ALIVE_BRIGHTNESS = 90.0;

  class PointState {
     // Index of cube in glucose.model.cubes
     public Integer index;
     // Boolean which describes if cube is alive.
     public boolean alive;
     // Boolean which describes if strip was just changed;
     public boolean just_changed;
     // Current brightness
     public float current_brightness;

     public PointState(Integer index, boolean alive, float current_brightness) {
       this.index = index;
       this.alive = alive;
       this.current_brightness = current_brightness;
       this.just_changed = false;
     }
  }

  // Contains the state of all cubes by index.
  private List<PointState> point_states;
  // Contains the amount of time since the last cycle of life.
  private int time_since_last_run;
  // Boolean describing if life changes were made during the current run.
  private boolean any_changes_this_run;
  // Hold the new lives
  private List<Boolean> new_states;

  public L8onAutomata(GLucose glucose) {
     super(glucose);

     //Print debug info about the cubes.
     //outputCubeInfo();

     initPointStates();
     randomizePointStates();
     time_since_last_run = 0;
     any_changes_this_run = false;
     new_states = new ArrayList<Boolean>();

     addParameter(mutationParameter);
     addParameter(rateParameter);
     addParameter(saturationParameter);
     addModulator(pointPos).trigger();
  }

  public void run(double deltaMs) {
    Integer i = 0;
    PointState point_state;

    any_changes_this_run = false;
    new_states.clear();
    time_since_last_run += deltaMs;

    for (LXPoint p : model.points) {
      point_state = this.point_states.get(i);

      if(shouldLightPoint(point_state)) {
        lightLivePoint(p, point_state, deltaMs);
      } else {
        lightDeadPoint(p, point_state, deltaMs);
      }
      i++;
    }

    if(!any_changes_this_run) {
      randomizePointStates();
    } else {
      applyNewStates();
    }

    if(time_since_last_run >= rateParameter.getValuef()) {
      time_since_last_run = 0;
    }
  }

  private void lightLivePoint(LXPoint p, PointState point_state, double deltaMs) {
    float point_dist = LXUtils.wrapdistf((float) point_state.index, pointPos.getValuef(), model.points.size());
    float hv = (point_dist / model.points.size()) * 360;
    float bv = point_state.current_brightness;

    if(deltaMs >= rateParameter.getValuef() || !point_state.just_changed) {
      float bright_prop = min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = min(MAX_ALIVE_BRIGHTNESS, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(point_state.current_brightness < bv) {
        point_state.current_brightness = bv;
      } else {
        bv = point_state.current_brightness;
      }
    }

    colors[p.index] = lx.hsb(
      hv,
      saturationParameter.getValuef(),
      bv
    );
  }

  private void lightDeadPoint(LXPoint p, PointState point_state, double deltaMs) {
    float point_dist = LXUtils.wrapdistf((float) point_state.index, pointPos.getValuef(), model.points.size());
    float hv = (point_dist / model.points.size()) * 360;
    float bv = point_state.current_brightness;

    if(!point_state.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = 1.0 - min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = max(0.0, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(point_state.current_brightness > bv) {
        point_state.current_brightness = bv;
      } else {
        bv = point_state.current_brightness;
      }
    }

    colors[p.index] = lx.hsb(
      hv,
      saturationParameter.getValuef(),
      bv
    );
  }

  private boolean shouldLightPoint(PointState point_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      point_state.just_changed = false;
      return point_state.alive;
    } else {
      boolean new_state = cycleOfAutomata(point_state);
      new_states.add(new_state);
      return new_state;
    }
  }

  private boolean cycleOfAutomata(PointState point_state) {
    Integer index = point_state.index;
    Integer alive_neighbor_count = countLiveNeighbors(point_state);
    boolean before_alive = point_state.alive;
    boolean after_alive = before_alive;
    double mutation = Math.random();

    if(point_state.alive) {
      if(alive_neighbor_count == 1) {
        after_alive = true;
      } else {
        after_alive = false;
      }

    } else {
      if(alive_neighbor_count == 1) {
        after_alive = true;
      } else {
        after_alive = false;
      }
    }

    if(mutation < mutationParameter.getValuef()) {
      after_alive = !after_alive;
    }

    if(before_alive != after_alive) {
      any_changes_this_run = true;
      point_state.just_changed = true;
    }

    return after_alive;
  }

  private void initPointStates() {
    boolean alive = true;
    PointState point_state;
    this.point_states = new ArrayList<PointState>();
    Integer i = 0;
    float current_brightness = 0.0;

    for (LXPoint p : model.points) {
      point_state = new PointState(i, alive, current_brightness);
      this.point_states.add(point_state);
      ++i;
    }
  }

  private int countLiveNeighbors(PointState point_state) {
    int count = 0;

    if (point_state.index > 0) {
      PointState before_neighbor = point_states.get(point_state.index - 1);
      if(before_neighbor.alive) {
        count++;
      }
    }

    if (point_state.index < (point_states.size() - 1)) {
      PointState after_neighbor = point_states.get(point_state.index + 1);
      if(after_neighbor.alive) {
        count++;
      }
    }

    return count;
  }

  private void applyNewStates() {
    int index = 0;
    for(boolean new_state: new_states) {
      PointState point_state = this.point_states.get(index);
      point_state.alive = new_states.get(index);
      index++;
    }
  }

  private void randomizePointStates() {
    double prob_range = (1.0 - MIN_ALIVE_PROBABILITY) - (1.0 - MAX_ALIVE_PROBABILITY);
    double prob = MIN_ALIVE_PROBABILITY + (prob_range * Math.random());

    //print("Randomizing points! p = " + prob + "\n");

    for (PointState point_state: this.point_states) {
      point_state.alive = (Math.random() <= prob);
      point_state.just_changed = true;
    }
  }
}

/**
 * A "Game of Life" simulation in 3 dimensions with the strips as cells.
 *
 * The "DELAY parameter controls the rate of change.
 * The "MUT" parameter controls the probability of mutations. Useful when life oscillates between few states.
 * The "SAT" parameter controls the saturation.
 */
class L8onStripLife extends SCPattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("DELAY", 200, 1.0, 1000.0);
  // Controls the probability of a mutation in the cycleOfStripperLife
  private BasicParameter mutationParameter = new BasicParameter("MUT", 0.000000011, 0.0, 0.1);
  // Controls the saturation.
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);

  public final double MIN_ALIVE_PROBABILITY = 0.4;
  public final double MAX_ALIVE_PROBABILITY = 0.7;

  public final float MAX_ALIVE_BRIGHTNESS = 90.0;

  private final SawLFO stripPos = new SawLFO(0, model.strips.size(), 8000);

  class StripState {
     // Index of strip in glucose.model.strips
     public Integer index;
     // Boolean which describes if strip is alive.
     public boolean alive;
     // Boolean which describes if strip was just changed;
     public boolean just_changed;
     // Current brightness
     public float current_brightness;
     // List of this cubes neighbors
     public List<Integer> neighbors;

     public StripState(Integer index, boolean alive, float current_brightness, List<Integer> neighbors) {
       this.index = index;
       this.alive = alive;
       this.current_brightness = current_brightness;
       this.neighbors = neighbors;
       this.just_changed = false;
     }
  }

  // Contains the state of all cubes by index.
  private List<StripState> strip_states;
  // Contains the amount of time since the last cycle of life.
  private int time_since_last_run;
  // Boolean describing if life changes were made during the current run.
  private boolean any_changes_this_run;
  // Hold the new lives
  private List<Boolean> new_lives;

  public L8onStripLife(GLucose glucose) {
     super(glucose);

     //Print debug info about the strips.
     //outputStripInfo();

     initStripStates();
     randomizeStripStates();
     time_since_last_run = 0;
     any_changes_this_run = false;
     new_lives = new ArrayList<Boolean>();

     addParameter(rateParameter);
     addParameter(mutationParameter);
     addParameter(saturationParameter);

     addModulator(stripPos).trigger();
  }

  public void run(double deltaMs) {
    Integer i = 0;
    StripState strip_state;

    any_changes_this_run = false;
    new_lives.clear();
    time_since_last_run += deltaMs;

    for (Strip strip : model.strips) {
      strip_state = this.strip_states.get(i);

      if(shouldLightStrip(strip_state)) {
        lightLiveStrip(strip, strip_state, deltaMs);
      } else {
        lightDeadStrip(strip, strip_state, deltaMs);
      }
      i++;
    }

    if(!any_changes_this_run) {
      randomizeStripStates();
    } else {
      applyNewLives();
    }

    if(time_since_last_run >= rateParameter.getValuef()) {
      time_since_last_run = 0;
    }
  }

  private void lightLiveStrip(Strip strip, StripState strip_state, double deltaMs) {
    float strip_dist = LXUtils.wrapdistf((float) strip_state.index, stripPos.getValuef(), model.strips.size());
    float hv = (strip_dist / model.strips.size()) * 360;
    float bv = strip_state.current_brightness;

    if(deltaMs >= rateParameter.getValuef() || !strip_state.just_changed) {
      float bright_prop = min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = min(MAX_ALIVE_BRIGHTNESS, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(strip_state.current_brightness < bv) {
        strip_state.current_brightness = bv;
      } else {
        bv = strip_state.current_brightness;
      }
    }

    for (LXPoint p : strip.points) {
      colors[p.index] = lx.hsb(
        hv,
        saturationParameter.getValuef(),
        bv
      );
    }
  }

  private void lightDeadStrip(Strip strip, StripState strip_state, double deltaMs) {
    float strip_dist = LXUtils.wrapdistf((float) strip_state.index, stripPos.getValuef(), model.strips.size());
    float hv = (strip_dist / model.strips.size()) * 360;
    float bv = strip_state.current_brightness;

    if(!strip_state.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = 1.0 - min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = max(0.0, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(strip_state.current_brightness > bv) {
        strip_state.current_brightness = bv;
      } else {
        bv = strip_state.current_brightness;
      }
    }

    for (LXPoint p : strip.points) {
      colors[p.index] = lx.hsb(
        hv,
        saturationParameter.getValuef(),
        bv
      );
    }
  }

  private void outputStripInfo() {
    int i = 0;
    for (Strip strip : model.strips) {
      print("Strip " + i + ": " + strip.cx + "," + strip.cy + "," + strip.cz + "\n");
      ++i;
    }
  }

  private void initStripStates() {
    List<Integer> neighbors;
    boolean alive = false;
    float current_brightness = 0.0;
    StripState strip_state;
    this.strip_states = new ArrayList<StripState>();
    Integer i = 0;

    int total_neighbors = 0;

    for (Strip strip : model.strips) {
      neighbors = findStripNeighbors(strip, i);
      alive = true;
      strip_state = new StripState(i, alive, current_brightness, neighbors);
      this.strip_states.add(strip_state);

      total_neighbors += neighbors.size();
      ++i;
    }

    float average_neighbor_count = (float) total_neighbors / (float) model.strips.size();
    //print("Average neighbor count: " + average_neighbor_count + "\n");
  }

  private void randomizeStripStates() {
    double prob_range = (1.0 - MIN_ALIVE_PROBABILITY) - (1.0 - MAX_ALIVE_PROBABILITY);
    double prob = MIN_ALIVE_PROBABILITY + (prob_range * Math.random());

    //print("Randomizing strips! p = " + prob + "\n");

    for (StripState strip_state : this.strip_states) {
      strip_state.alive = (Math.random() <= prob);
      strip_state.just_changed = true;
    }
  }

  private List<Integer> findStripNeighbors(Strip strip, Integer index) {
    List<Integer> neighbors = new LinkedList<Integer>();
    Integer i = 0;
    int neighbor_count = 0;
    double distance = 0.0;

    for (Strip s : model.strips) {
      if( (int)index != (int)i )  {
        distance = Math.sqrt( Math.pow((s.cx - strip.cx), 2) + Math.pow((s.cy - strip.cy), 2) + Math.pow((s.cz - strip.cz), 2) );

        if(distance < ( (double) Cube.EDGE_WIDTH) ) {
          //print("Strip " + i + " is a neighbor of " + index + "\n");
          neighbors.add(i);
        }
      }
      i++;
    }

    return neighbors;
  }

  private boolean shouldLightStrip(StripState strip_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      strip_state.just_changed = false;
      return strip_state.alive;
    } else {
      boolean new_life = cycleOfStripperLife(strip_state);
      new_lives.add(new_life);
      return new_life;
    }
  }

  private void applyNewLives() {
    int index = 0;
    for(boolean liveliness: new_lives) {
      StripState strip_state = this.strip_states.get(index);
      strip_state.alive = new_lives.get(index);
      index++;
    }
  }

  private boolean cycleOfStripperLife(StripState strip_state) {
    Integer alive_neighbor_count = countLiveNeighbors(strip_state);
    boolean before_alive = strip_state.alive;
    boolean after_alive = before_alive;
    double mutation = Math.random();

    if(strip_state.alive) {
      if(alive_neighbor_count < 2 || alive_neighbor_count > 6) {
        after_alive = false;
      } else {
        after_alive = true;
      }

    } else {
      if(alive_neighbor_count == 5) {
        after_alive = true;
      } else {
        after_alive = false;
      }
    }

    if(mutation < mutationParameter.getValuef()) {
      after_alive = !after_alive;
    }

    if(before_alive != after_alive) {
      any_changes_this_run = true;
      strip_state.just_changed = true;
    }

    return after_alive;
  }

  private Integer countLiveNeighbors(StripState strip_state) {
    Integer count = 0;
    StripState neighbor_strip_state;

    for(Integer neighbor_index: strip_state.neighbors) {
       neighbor_strip_state = this.strip_states.get(neighbor_index);
       if(neighbor_strip_state.alive) {
         count++;
       }
    }

    return count;
  }
}
/**
 * 2 breathing waves with bands of color.
 *
 * Each "string" is a specific color, their intersection is the mix of those two colors.
 * Between each string, there are a discrete number of bands of color.
 */
class L8onBreathe extends SCPattern {
  private float string_center_x;
  private float string_radius;
  private float string_center_z;

  // Oscillates the maximum offfset from the center to create breathing effect.
  private final SinLFO xOffsetMax = new SinLFO( -1 * (model.xRange / 2.0) , model.xRange / 2.0, 10000);

  // Controls the radius of the strings.
  private BasicParameter radiusParameter = new BasicParameter("RAD", Cube.EDGE_WIDTH/2, 1.0, model.xRange / 2.0);
  // Controls the center X coordinate of the waves.
  private BasicParameter centerXParameter = new BasicParameter("X", (model.xMin + model.xMax) / 2.0, model.xMin, model.xMax);
  // Controls the center Z coordinate of the waves.
  private BasicParameter centerZParameter = new BasicParameter("Z", (model.zMin + model.zMax) / 2.0, model.zMin, model.zMax);
  // Controls the number of color "bands" between the strings.
  private BasicParameter numBandParameter = new BasicParameter("BAND", 5.0, 2.0, 10.0);
  // Controls the number of waves
  private BasicParameter numWaves = new BasicParameter("WAVE", 1.0, 1.0, 7.0);

  public L8onBreathe(GLucose glucose) {
     super(glucose);

     addParameter(radiusParameter);
     addParameter(centerXParameter);
     addParameter(centerZParameter);
     addParameter(numBandParameter);
     addParameter(numWaves);
     addModulator(xOffsetMax).trigger();
  }

  public void run(double deltaMs) {
    float offset_value = xOffsetMax.getValuef();
    float string_1_max_offset = offset_value;
    float string_2_max_offset = offset_value * -1;
    float string_1_hv = lx.getBaseHuef();
    float string_2_hv = LXUtils.wrapdistf(0, string_1_hv + 180, 360);
    float min_hv = min(string_1_hv, string_2_hv);
    float max_hv = max(string_1_hv, string_2_hv);
    float blend_hv = (min_hv * 2.0 + max_hv / 2.0) / 2.0;

    color c;
    float dist_percentage;
    float sat_value;

    for (LXPoint p : model.points) {
      float y_percentage = (p.y - model.yMin) / model.yRange;
      float cos_y = cos(PI / 2 + numWaves.getValuef() * PI * y_percentage);

      float string_1_center_x = centerXParameter.getValuef() + (string_1_max_offset * cos_y);
      float string_2_center_x = centerXParameter.getValuef() + (string_2_max_offset * cos_y);

      float dist_from_string_1 = distance_from_string(p, string_1_center_x);
      float dist_from_string_2 = distance_from_string(p, string_2_center_x);

      boolean on_string_1 = (dist_from_string_1 <= radiusParameter.getValuef());
      boolean on_string_2 = (dist_from_string_2 <= radiusParameter.getValuef());

      // Blend string colors if on both strings.
      if(on_string_1 && on_string_2) {
        c = lx.hsb(blend_hv, 100, 80);

      } else if(on_string_1) {
        dist_percentage = dist_from_string_1 / radiusParameter.getValuef();
        sat_value = abs(75 * cos(dist_percentage));
        c = lx.hsb(string_1_hv, sat_value, 80);

      } else if(on_string_2) {
        dist_percentage = dist_from_string_2 / radiusParameter.getValuef();
        sat_value = abs(75 * cos(dist_percentage));
        c = lx.hsb(string_2_hv, sat_value, 80);

      } else if(between_strings(p, string_1_center_x, string_2_center_x)) {
        float hv = between_hv_for_point(p, string_1_center_x, string_2_center_x, string_1_hv, string_2_hv);
        c = lx.hsb(hv, 100, 80);

      } else {
        c = lx.hsb(120.0, 0, 0); // I just like green
      }

      colors[p.index] = c;
    }
  }

  public float distance_from_string(LXPoint p, float string_center_x) {
    double distance = Math.sqrt( Math.pow((p.x - string_center_x), 2) + Math.pow((p.y - p.y), 2) + Math.pow((p.z - centerZParameter.getValuef()), 2) );

    return (float) distance;
  }

  public boolean between_strings(LXPoint p, float string_1_center_x, float string_2_center_x) {
    float min_x = min(string_1_center_x, string_2_center_x);
    float max_x = max(string_1_center_x, string_2_center_x);

    float min_z = centerZParameter.getValuef() - radiusParameter.getValuef();
    float max_z = centerZParameter.getValuef() + radiusParameter.getValuef();

    return ((p.x >= min_x) && (p.x <= max_x) && (p.z >= min_z) && (p.z <= max_z));
  }

  public float between_hv_for_point(LXPoint p, float string_1_center_x, float string_2_center_x, float string_1_hv, float string_2_hv) {
    float hv = 120.0;
    int num_bands = (int) numBandParameter.getValuef();
    float hue_step = 360.0 / (float) num_bands;
    float between_min_x = min(string_1_center_x, string_2_center_x);
    float between_dist = (max(string_1_center_x, string_2_center_x) - radiusParameter.getValuef()) - (between_min_x + radiusParameter.getValuef());

    float between_percentage = (p.x - between_min_x) / between_dist;
    int band_number = (int) ((float) num_bands * between_percentage);
    band_number++;

    if(string_1_center_x < string_2_center_x) {
      hv = LXUtils.wrapdistf(0, string_1_hv + ((float) band_number * hue_step), 360);
    } else {
      hv = LXUtils.wrapdistf(0, string_2_hv + ((float) band_number * hue_step), 360);
    }

    return hv;
  }
}
/**
 * 2 slanted breathing waves with bands of color.
 *
 * Each wave is a specific color, their intersection is the mix of those two colors.
 * Between each string, there are a discrete number of bands of color.
 */
class L8onBreatheSlant extends SCPattern {
  private float string_center_x;
  private float string_radius;
  private float string_center_z;

  private final SinLFO xOffsetMax = new SinLFO( -1 * (model.xRange / 2.0) , model.xRange / 2.0, 15000);

  // Controls the radius of the string.
  private BasicParameter radiusParameter = new BasicParameter("RAD", Cube.EDGE_WIDTH * (3.0/4.0), 1.0, model.xRange / 2.0);
  // Controls the center X coordinate of the waves.
  private BasicParameter centerXParameter = new BasicParameter("X", (model.xMin + model.xMax) / 2.0, model.xMin, model.xMax);
  // Controls the center Z coordinate of the waves.
  private BasicParameter centerZParameter = new BasicParameter("Z", (model.zMin + model.zMax) / 2.0, model.zMin, model.zMax);
  // Controls the number of color "bands" between the strings.
  private BasicParameter numBandParameter = new BasicParameter("BAND", 4.0, 2.0, 10.0);
  // Controls the number of waves.
  private BasicParameter numWaves = new BasicParameter("WAVE", 1.0, 1.0, 7.0);

  public L8onBreatheSlant(GLucose glucose) {
     super(glucose);

     addParameter(radiusParameter);
     addParameter(centerXParameter);
     addParameter(centerZParameter);
     addParameter(numBandParameter);
     addParameter(numWaves);
     addModulator(xOffsetMax).trigger();
  }

  public void run(double deltaMs) {
    float offset_value = xOffsetMax.getValuef();
    float string_max_offset = offset_value;
    float string_1_hv = lx.getBaseHuef();
    float string_2_hv = LXUtils.wrapdistf(0, string_1_hv + 180, 360);
    float min_hv = min(string_1_hv, string_2_hv);
    float max_hv = max(string_1_hv, string_2_hv);
    float blend_hv = (min_hv * 2.0 + max_hv / 2.0) / 2.0;

    color c;
    float dist_percentage;
    float sat_value;

    for (LXPoint p : model.points) {
      float y_percentage = (p.y - model.yMin) / model.yRange;
      float sin_y = sin(PI / 2 + numWaves.getValuef() * PI * y_percentage);
      float cos_y = cos(PI / 2 + numWaves.getValuef() * PI * y_percentage);

      float string_1_center_x = centerXParameter.getValuef() + (string_max_offset * sin_y);
      float string_2_center_x = centerXParameter.getValuef() + (string_max_offset * cos_y);

      float dist_from_string_1 = distance_from_string(p, string_1_center_x);
      float dist_from_string_2 = distance_from_string(p, string_2_center_x);

      boolean on_string_1 = (dist_from_string_1 <= radiusParameter.getValuef());
      boolean on_string_2 = (dist_from_string_2 <= radiusParameter.getValuef());


      if(on_string_1 && on_string_2) {
        c = lx.hsb(blend_hv, 80, 80);

      } else if(on_string_1) {
        dist_percentage = dist_from_string_1 / radiusParameter.getValuef();
        sat_value = abs(75 * cos(dist_percentage));
        c = lx.hsb(string_1_hv, sat_value, 80);

      } else if(on_string_2) {
        dist_percentage = dist_from_string_2 / radiusParameter.getValuef();
        sat_value = abs(75 * cos(dist_percentage));
        c = lx.hsb(string_2_hv, sat_value, 80);

      } else if(between_strings(p, string_1_center_x, string_2_center_x)) {
        float hv = between_hv_for_point(p, string_1_center_x, string_2_center_x, string_1_hv, string_2_hv);
        c = lx.hsb(hv, 80, 80);

      } else {
        c = lx.hsb(120.0, 0, 0); // I just like green
      }

      colors[p.index] = c;
    }
  }

  public float distance_from_string(LXPoint p, float string_center_x) {
    double distance = Math.sqrt( Math.pow((p.x - string_center_x), 2) + Math.pow((p.y - p.y), 2) + Math.pow((p.z - centerZParameter.getValuef()), 2) );

    return (float) distance;
  }

  public boolean between_strings(LXPoint p, float string_1_center_x, float string_2_center_x) {
    float min_x = min(string_1_center_x, string_2_center_x);
    float max_x = max(string_1_center_x, string_2_center_x);

    float min_z = centerZParameter.getValuef() - radiusParameter.getValuef();
    float max_z = centerZParameter.getValuef() + radiusParameter.getValuef();

    return ((p.x >= min_x) && (p.x <= max_x) && (p.z >= min_z) && (p.z <= max_z));
  }

  public float between_hv_for_point(LXPoint p, float string_1_center_x, float string_2_center_x, float string_1_hv, float string_2_hv) {
    float hv = 120.0;
    int num_bands = (int) numBandParameter.getValuef();
    float hue_step = 360.0 / (float) num_bands;
    float between_min_x = min(string_1_center_x, string_2_center_x);
    float between_dist = (max(string_1_center_x, string_2_center_x) - radiusParameter.getValuef()) - (between_min_x + radiusParameter.getValuef());

    float between_percentage = (p.x - between_min_x) / between_dist;
    int band_number = (int) ((float) num_bands * between_percentage);
    band_number++;

    if(string_1_center_x < string_2_center_x) {
      hv = LXUtils.wrapdistf(0, string_1_hv + ((float) band_number * hue_step), 360);
    } else {
      hv = LXUtils.wrapdistf(0, string_2_hv + ((float) band_number * hue_step), 360);
    }

    return hv;
  }
}
