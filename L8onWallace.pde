/**
 * A "Game of Life" simulation in 2 dimensions with the cubes as cells.
 *
 * The "DELAY parameter controls the rate of change.
 * The "MUT" parameter controls the probability of mutations. Useful when life oscillates between few states.
 * The "SAT" parameter controls the saturation.
 *
 * Thanks to Jack for starting me up, Tim for the parameter code, and Slee for the fade idea.
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

  // Contains the state of all cubes by index.
  // See L8onUtil.pde for definition of CubeState.
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
     new_lives = new ArrayList<Boolean>(model.cubes.size());
     
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
    
    // Reset "tick" timer
    if(time_since_last_run >= rateParameter.getValuef()) {
      time_since_last_run = 0;
    }    
  }
  
  /**
   * Light a live cube.
   * Uses deltaMs for fade effect.
   */
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
  
  /**
   * Light a dead cube.
   * Uses deltaMs for fade effect.
   */
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
    
  /**
   * Output debug info about the cubes.
   */
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
  
  /**
   * Initialize the list of cube states.
   */
  private void initCubeStates() {
    List<Integer> neighbors;
    boolean alive = false;  
    CubeState cube_state;      
    this.cube_states = new ArrayList<CubeState>(model.cubes.size());
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
 
 /**
  * Randomizes the state of the cubes.
  * A value between MIN_ALIVE_PROBABILITY and MAX_ALIVE_PROBABILITY is chosen.
  * Each cube then has that probability of living.
  */
  private void randomizeCubeStates() {  
    double prob_range = (1.0 - MIN_ALIVE_PROBABILITY) - (1.0 - MAX_ALIVE_PROBABILITY);
    double prob = MIN_ALIVE_PROBABILITY + (prob_range * Math.random());
    
    //print("Randomizing cubes! p = " + prob + "\n");
     
    for (CubeState cube_state: this.cube_states) {   
      cube_state.alive = (Math.random() <= prob);            
    }    
  }
  
  /**
   * Find cubes that are neighbors of the supplied cube.
   */
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
  
  /**
   * Will initiate a cycleOfLife if it is time.
   * Otherwise responds based on the current state of the cube.
   */
  private boolean shouldLightCube(CubeState cube_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      cube_state.just_changed = false;
      return cube_state.alive;
    } else {
      return cycleOfLife(cube_state);
    }
  }

  /**
   * The meat of the life algorithm.
   * Uses the count of live neighbors and the cube's current state
   * to decide the cube's fate as such:
   * - If alive, needs 2 or 3 living neighbors to stay alive.
   * - If dead, needs 2 living neighbors to be born again.
   *
   * Populates the new_lives array and returns the new state of the cube.
   */
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

    new_lives.add(after_alive);

    return after_alive;
  }
      
  /**
   * Counts the number of living neighbors of a cube.
   */
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

  /**
   * Apply the new states from the new_lives array.
   */
  private void applyNewLives() {
    int index = 0;
    for(boolean liveliness: new_lives) {
      CubeState cube_state = this.cube_states.get(index);
      cube_state.alive = new_lives.get(index);
      index++;
    }
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
  // Controls the probability of a mutation in the cycleOfAutomata
  private BasicParameter mutationParameter = new BasicParameter("MUT", 0.000000011, 0.0, 0.1);
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);

  private final SawLFO pointPos = new SawLFO(0, model.points.size(), 8000);

  public final double MIN_ALIVE_PROBABILITY = 0.2;
  public final double MAX_ALIVE_PROBABILITY = 0.5;

  public final float MAX_ALIVE_BRIGHTNESS = 90.0;

  // Contains the state of all points by index.
  // See L8onUtil.pde for definition of PointState.
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
     new_states = new ArrayList<Boolean>(model.points.size());

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

  /**
   * Lights a live point.
   * Uses deltaMS to apply fade effect.
   */
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

  /**
   * Lights a dead point.
   * Uses deltaMS to apply fade effect.
   */
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

  /**
   * Will initiate a cycleOfAutomata if it is time.
   * Otherwise responds based on the current state of the cube.
   */
  private boolean shouldLightPoint(PointState point_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      point_state.just_changed = false;
      return point_state.alive;
    } else {
      boolean new_state = cycleOfAutomata(point_state);
      return new_state;
    }
  }

  /**
   * The meat of the 1 dimensional life algorithm.
   * Uses the count of live neighbors and the point's current state
   * to decide the point's fate and populates new_states array as such:
   * - If alive, needs 1 living neighbor to stay alive.
   * - If dead, needs 1 living neighbor to be reborn.
   *
   * Returns the new state of the point.
   */
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

    new_states.add(after_alive);
    return after_alive;
  }

  /**
   * Initialize the point_states array.
   */
  private void initPointStates() {
    boolean alive = true;
    PointState point_state;
    this.point_states = new ArrayList<PointState>(model.points.size());
    Integer i = 0;
    float current_brightness = 0.0;

    for (LXPoint p : model.points) {
      point_state = new PointState(i, alive, current_brightness);
      this.point_states.add(point_state);
      ++i;
    }
  }

  /**
  * Randomizes the state of the points.
  * A value between MIN_ALIVE_PROBABILITY and MAX_ALIVE_PROBABILITY is chosen.
  * Each point then has that probability of living.
  */
  private void randomizePointStates() {
    double prob_range = (1.0 - MIN_ALIVE_PROBABILITY) - (1.0 - MAX_ALIVE_PROBABILITY);
    double prob = MIN_ALIVE_PROBABILITY + (prob_range * Math.random());

    //print("Randomizing points! p = " + prob + "\n");

    for (PointState point_state: this.point_states) {
      point_state.alive = (Math.random() <= prob);
      point_state.just_changed = true;
    }
  }

  /**
   * Counts the number of living neighbors of a point.
   */
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

  /**
   * Applies states from the new_states array
   */
  private void applyNewStates() {
    int index = 0;
    for(boolean new_state: new_states) {
      PointState point_state = this.point_states.get(index);
      point_state.alive = new_states.get(index);
      index++;
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
  // Controls the probability of a mutation in the cycleOfStripLife
  private BasicParameter mutationParameter = new BasicParameter("MUT", 0.000000011, 0.0, 0.1);
  // Controls the saturation.
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);

  public final double MIN_ALIVE_PROBABILITY = 0.4;
  public final double MAX_ALIVE_PROBABILITY = 0.7;

  public final float MAX_ALIVE_BRIGHTNESS = 90.0;

  private final SawLFO stripPos = new SawLFO(0, model.strips.size(), 8000);

  // Contains the state of all strips by index.
  // See L8onUtil for definition of StripState.
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
     new_lives = new ArrayList<Boolean>(model.strips.size());

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

  /**
   * Lights a live strip.
   * Uses deltaMS to apply fade effect.
   */
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

  /**
   * Lights a dead strip.
   * Uses deltaMS to apply fade effect.
   */
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

  /**
   * Output useful debug info about the strips.
   */
  private void outputStripInfo() {
    int i = 0;
    for (Strip strip : model.strips) {
      print("Strip " + i + ": " + strip.cx + "," + strip.cy + "," + strip.cz + "\n");
      ++i;
    }
  }

  /**
   * Initializes the strip_states array and sets all strips alive.
   */
  private void initStripStates() {
    List<Integer> neighbors;
    boolean alive = true;
    float current_brightness = 0.0;
    StripState strip_state;
    this.strip_states = new ArrayList<StripState>(model.strips.size());
    Integer i = 0;

    int total_neighbors = 0;

    for (Strip strip : model.strips) {
      neighbors = findStripNeighbors(strip, i);
      strip_state = new StripState(i, alive, current_brightness, neighbors);
      this.strip_states.add(strip_state);

      total_neighbors += neighbors.size();
      ++i;
    }

    float average_neighbor_count = (float) total_neighbors / (float) model.strips.size();
    //print("Average neighbor count: " + average_neighbor_count + "\n");
  }

  /**
   * Randomizes the states of the strips.
   * A probability between MIN_ALIVE_PROBABILITY and MAX_ALIVE_PROBABILITY is chosen.
   * Each strip has that probability of being alive.
   */
  private void randomizeStripStates() {
    double prob_range = (1.0 - MIN_ALIVE_PROBABILITY) - (1.0 - MAX_ALIVE_PROBABILITY);
    double prob = MIN_ALIVE_PROBABILITY + (prob_range * Math.random());

    //print("Randomizing strips! p = " + prob + "\n");

    for (StripState strip_state : this.strip_states) {
      strip_state.alive = (Math.random() <= prob);
      strip_state.just_changed = true;
    }
  }

  /**
   * Finds the neighbors of a strip.
   * If another strip's center is within a CUBE_WIDTH of this strip's center, then
   * they are considered neighbors.
   */
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

  /**
   * Will initiate a cycleOfStripLife if it is time.
   * Otherwise responds based on the current state of the strip.
   */
  private boolean shouldLightStrip(StripState strip_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      strip_state.just_changed = false;
      return strip_state.alive;
    } else {
      return cycleOfStripLife(strip_state);
    }
  }

  /**
   * The meat of the 3d life algorithm.
   * Uses the count of live neighbors and the cube's current state
   * to decide the cube's fate as such:
   * - If alive, needs between 2 and 6 inclusive living neighbors to stay alive.
   * - If dead, needs 5 living neighbors to be born again.
   *
   * Populates the new_lives array and returns the new state of the cube.
   */
  private boolean cycleOfStripLife(StripState strip_state) {
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

    new_lives.add(after_alive);
    return after_alive;
  }

  /**
   * Count the number of living niehgbots to a strip.
   */
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

  /**
   * Apply the lives in the new_lives array.
   */
  private void applyNewLives() {
    int index = 0;
    for(boolean liveliness: new_lives) {
      StripState strip_state = this.strip_states.get(index);
      strip_state.alive = new_lives.get(index);
      index++;
    }
  }
}
/**
 * 2 breathing waves with bands of color.
 *
 * Each "wave" is a specific color, their intersection is the mix of those two colors.
 * Between each wave, there are a discrete number of bands of color.
 */
class L8onBreatheColor extends SCPattern {
  // Oscillates the maximum offfset from the center to create breathing effect.
  private final SinLFO xOffsetMax = new SinLFO( -1 * (model.xRange / 2.0) , model.xRange / 2.0, 20000);

  // Controls the radius of the waves.
  private BasicParameter radiusParameter = new BasicParameter("RAD", Cube.EDGE_WIDTH/2, 1.0, model.xRange / 2.0);
  // Controls the center X coordinate of the waves.
  private BasicParameter centerXParameter = new BasicParameter("X", (model.xMin + model.xMax) / 2.0, model.xMin, model.xMax);
  // Controls the center Z coordinate of the waves.
  private BasicParameter centerZParameter = new BasicParameter("Z", (model.zMin + model.zMax) / 2.0, model.zMin, model.zMax);
  // Controls the number of color "bands" between the waves.
  private BasicParameter numBandParameter = new BasicParameter("BAND", 5.0, 2.0, 10.0);
  // Controls the number of waves
  private BasicParameter numWaves = new BasicParameter("WAVE", 1.0, 1.0, 7.0);

  public L8onBreatheColor(GLucose glucose) {
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
    float wave_1_max_offset = offset_value;
    float wave_2_max_offset = offset_value * -1;
    float wave_1_hv = lx.getBaseHuef();
    float wave_2_hv = LXUtils.wrapdistf(0, wave_1_hv + 180, 360);
    float min_hv = min(wave_1_hv, wave_2_hv);
    float max_hv = max(wave_1_hv, wave_2_hv);
    float blend_hv = (min_hv * 2.0 + max_hv / 2.0) / 2.0;

    color c;
    float dist_percentage;
    float sat_value;

    for (LXPoint p : model.points) {
      float y_percentage = (p.y - model.yMin) / model.yRange;
      float cos_y = cos(PI / 2 + numWaves.getValuef() * PI * y_percentage);

      float wave_1_center_x = centerXParameter.getValuef() + (wave_1_max_offset * cos_y);
      float wave_2_center_x = centerXParameter.getValuef() + (wave_2_max_offset * cos_y);

      float dist_from_wave_1 = distance_from_wave(p, wave_1_center_x);
      float dist_from_wave_2 = distance_from_wave(p, wave_2_center_x);

      boolean on_wave_1 = (dist_from_wave_1 <= radiusParameter.getValuef());
      boolean on_wave_2 = (dist_from_wave_2 <= radiusParameter.getValuef());

      // Blend wave colors if on both waves.
      if(on_wave_1 && on_wave_2) {
        c = lx.hsb(blend_hv, 100, 80);

      } else if(on_wave_1) {
        dist_percentage = dist_from_wave_1 / radiusParameter.getValuef();
        sat_value = abs(75 * cos(dist_percentage));
        c = lx.hsb(wave_1_hv, sat_value, 80);

      } else if(on_wave_2) {
        dist_percentage = dist_from_wave_2 / radiusParameter.getValuef();
        sat_value = abs(75 * cos(dist_percentage));
        c = lx.hsb(wave_2_hv, sat_value, 80);

      } else if(between_waves(p, wave_1_center_x, wave_2_center_x)) {
        float hv = between_hv_for_point(p, wave_1_center_x, wave_2_center_x, wave_1_hv, wave_2_hv);
        c = lx.hsb(hv, 100, 80);

      } else {
        c = lx.hsb(120.0, 0, 0); // I just like green
      }

      colors[p.index] = c;
    }
  }

  public float distance_from_wave(LXPoint p, float wave_center_x) {
    double distance = Math.sqrt( Math.pow((p.x - wave_center_x), 2) + Math.pow((p.y - p.y), 2) + Math.pow((p.z - centerZParameter.getValuef()), 2) );

    return (float) distance;
  }

  public boolean between_waves(LXPoint p, float wave_1_center_x, float wave_2_center_x) {
    float min_x = min(wave_1_center_x, wave_2_center_x);
    float max_x = max(wave_1_center_x, wave_2_center_x);

    float min_z = centerZParameter.getValuef() - radiusParameter.getValuef();
    float max_z = centerZParameter.getValuef() + radiusParameter.getValuef();

    return ((p.x >= min_x) && (p.x <= max_x) && (p.z >= min_z) && (p.z <= max_z));
  }

  public float between_hv_for_point(LXPoint p, float wave_1_center_x, float wave_2_center_x, float wave_1_hv, float wave_2_hv) {
    float hv = 120.0;
    int num_bands = (int) numBandParameter.getValuef();
    float hue_step = 360.0 / (float) num_bands;
    float between_min_x = min(wave_1_center_x, wave_2_center_x);
    float between_dist = (max(wave_1_center_x, wave_2_center_x) - radiusParameter.getValuef()) - (between_min_x + radiusParameter.getValuef());

    float between_percentage = (p.x - between_min_x) / between_dist;
    int band_number = (int) ((float) num_bands * between_percentage);
    band_number++;

    if(wave_1_center_x < wave_2_center_x) {
      hv = LXUtils.wrapdistf(0, wave_1_hv + ((float) band_number * hue_step), 360);
    } else {
      hv = LXUtils.wrapdistf(0, wave_2_hv + ((float) band_number * hue_step), 360);
    }

    return hv;
  }
}


/**
 * 2 slanted breathing waves with bands of color.
 *
 * Each wave is a specific color, their intersection is the mix of those two colors.
 * Between each wave, there are a discrete number of bands of color.
 */
class L8onMixColor extends SCPattern {
  // Oscillators for the wave breathing effect.
  private final SinLFO xOffsetMax = new SinLFO( -1 * (model.xRange / 2.0) , model.xRange / 2.0, 20000);
  private final SinLFO yOffsetMax = new SinLFO( -1 * (model.yRange / 2.0) , model.yRange / 2.0, 20000);

  // Used to store info about each wave.
  // See L8onUtil.pde for the definition.
  private List<L8onWave> l8on_waves;

  // Controls the radius of the string.
  private BasicParameter radiusParameterX = new BasicParameter("RADX", Cube.EDGE_WIDTH, 1.0, model.xRange / 2.0);
  private BasicParameter radiusParameterY = new BasicParameter("RADY", Cube.EDGE_WIDTH, 1.0, model.yRange / 2.0);
  // Controls the center X coordinate of the waves.
  private BasicParameter centerXParameter = new BasicParameter("X", (model.xMin + model.xMax) / 2.0, model.xMin, model.xMax);
    // Controles the center Y coordinate of the waves.
  private BasicParameter centerYParameter = new BasicParameter("Y", (model.yMin + model.yMax) / 2.0, model.yMin, model.yMax);
  // Controls the center Z coordinate of the waves.
  private BasicParameter centerZParameter = new BasicParameter("Z", (model.zMin + model.zMax) / 2.0, model.zMin, model.zMax);
  // Controls the number of waves by axis.
  private BasicParameter numWavesX = new BasicParameter("WAVX", 3.0, 1.0, 10.0);
  private BasicParameter numWavesY = new BasicParameter("WAVY", 4.0, 1.0, 10.0);


  public L8onMixColor(GLucose glucose) {
     super(glucose);

     initL8onWaves();

     addParameter(radiusParameterX);
     addParameter(radiusParameterY);
     addParameter(numWavesX);
     addParameter(numWavesY);
     addParameter(centerXParameter);
     addParameter(centerYParameter);
     addParameter(centerZParameter);

     addModulator(xOffsetMax).trigger();
     addModulator(yOffsetMax).trigger();
  }

  public void run(double deltaMs) {
    float offset_value_x = xOffsetMax.getValuef();
    float offset_value_y = yOffsetMax.getValuef();
    float base_hue = lx.getBaseHuef();
    float wave_hue_diff = (float) (360.0 / this.l8on_waves.size());

    for(L8onWave l8on_wave : this.l8on_waves) {
      l8on_wave.hue_value = base_hue;
      base_hue += wave_hue_diff;
    }


    color c;
    float dist_percentage;
    float hue_value = 0.0;
    float sat_value = 100.0;
    float brightness_value;
    float wave_center_x;
    float wave_center_y;
    float wave_radius;
    float min_hv;
    float max_hv;

    for (LXPoint p : model.points) {
      float x_percentage = (p.x - model.xMin) / model.xRange;
      float y_percentage = (p.y - model.yMin) / model.yRange;
      float sin_x = sin(PI / 2 + numWavesX.getValuef() * PI * x_percentage);
      float cos_x = cos(PI / 2 + numWavesX.getValuef() * PI * x_percentage);
      float sin_y = sin(PI / 2 + numWavesY.getValuef() * PI * y_percentage);
      float cos_y = cos(PI / 2 + numWavesY.getValuef() * PI * y_percentage);

      int num_waves_in = 0;

      for(L8onWave l8on_wave : this.l8on_waves) {
        wave_center_x = p.x;
        wave_center_y = p.y;

        if(l8on_wave.direction == L8onWave.DIRECTION_X) {
          wave_center_y = centerYParameter.getValuef() + (l8on_wave.offset_multiplier * offset_value_y * cos_x);
          wave_radius = radiusParameterX.getValuef();
        } else {
          wave_center_x = centerXParameter.getValuef() + (l8on_wave.offset_multiplier * offset_value_x * sin_y);
          wave_radius = radiusParameterY.getValuef();
        }

        float dist_from_wave = distance_from_wave(p, wave_center_x, wave_center_y);

        if(dist_from_wave <= wave_radius) {
          num_waves_in++;

          if(num_waves_in == 1) {
            hue_value = l8on_wave.hue_value;
          } if(num_waves_in == 2) {
            // Blend new color with previous color.
            min_hv = min(hue_value, l8on_wave.hue_value);
            max_hv = max(hue_value, l8on_wave.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          } else {
            // Jump color by 180 before belnding again.
            hue_value = LXUtils.wrapdistf(0, hue_value + 180, 360);
            min_hv = min(hue_value, l8on_wave.hue_value);
            max_hv = max(hue_value, l8on_wave.hue_value);
            hue_value = (min_hv * 2.0 + max_hv / 2.0) / 2.0;
          }
        }
      }

      if(num_waves_in > 0) {
        c = lx.hsb(hue_value, sat_value, 80);
      } else {
        c = lx.hsb(120.0, 0, 0); // I just like green
      }

      colors[p.index] = c;
    }
  }

  /**
   * Calculates the distance between a point the center of the wave with the given coordinates.
   */
  public float distance_from_wave(LXPoint p, float wave_center_x, float wave_center_y) {
    double distance = Math.sqrt( Math.pow((p.x - wave_center_x), 2) + Math.pow((p.y - wave_center_y), 2) + Math.pow((p.z - centerZParameter.getValuef()), 2) );

    return (float) distance;
  }

  /**
   * Initialize the waves.
   */
  private void initL8onWaves() {
    this.l8on_waves = new LinkedList<L8onWave>();

    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_X, 1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_Y, 1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_X, -1.0) );
    this.l8on_waves.add( new L8onWave(L8onWave.DIRECTION_Y, -1.0) );
  }
}




