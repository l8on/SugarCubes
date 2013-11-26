class L8onLife extends SCPattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("DELAY", 112.5, 0.0, 1000.0);
  // Controls the probability of a mutation in the cycleOfLife
  private BasicParameter randomParameter = new BasicParameter("RAND", 0.000000011, 0.0, 0.1);
  // Controls the brightness of dead cubes.
  private BasicParameter deadParameter = new BasicParameter("DEAD", 25.0, 0.0, 100.0);
  // Controls the saturation.
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);
    
  public final double MIN_ALIVE_PROBABILITY = 0.2;
  public final double MAX_ALIVE_PROBABILITY = 0.9;
  
  private final SawLFO cubePos = new SawLFO(0, model.cubes.size(), 2500);

  class CubeState {
     // Index of cube in glucose.model.cubes
     public Integer index;
     // Boolean which describes if cube is alive.
     public boolean alive;
     // List of this cubes neighbors
     public List<Integer> neighbors;

     public CubeState(Integer index, boolean alive, List<Integer> neighbors) {
       this.index = index;
       this.alive = alive;
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
     addParameter(randomParameter);   
     addParameter(deadParameter);
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
        lightLiveCube(cube, i);
      } else {
        lightDeadCube(cube, i);
      } 
      
      i++;      
    }
    
    if(!any_changes_this_run) {
      randomizeCubeStates();  
    } else {
      applyNewLives();
    }
    
    if(time_since_last_run >= rateParameter.getValuef()) {
      time_since_last_run = 0;
    }    
  }
  
  public void lightLiveCube(Cube cube, Integer index) {
    float cube_dist = LXUtils.wrapdistf((float) index, cubePos.getValuef(), model.cubes.size());
    float hv = (cube_dist / model.cubes.size()) * 360;

    for (LXPoint p : cube.points) {
      colors[p.index] = lx.hsb(
        hv,
        saturationParameter.getValuef(),        
        75
      );
    }        
  }
  
  public void lightDeadCube(Cube cube, Integer index) {
    float cube_dist = LXUtils.wrapdistf((float) index, cubePos.getValuef(), model.cubes.size());
    float dist_proportion = (cube_dist / (float) model.cubes.size());
    float hv = dist_proportion * 360;
    float dead_bright = deadParameter.getValuef() * dist_proportion;

    for (LXPoint p : cube.points) {
      colors[p.index] = lx.hsb(
        hv,
        saturationParameter.getValuef(),        
        dead_bright
      );     
    }  
  } 
    
  public void outputCubeInfo() {
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
    Integer i = 0;     
    
    for (Cube c : model.cubes) {      
      neighbors = findCubeNeighbors(c, i);
      alive = true;
      cube_state = new CubeState(i, alive, neighbors);      
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
  
  public List<Integer> findCubeNeighbors(Cube cube, Integer index) {
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
  
  public boolean shouldLightCube(CubeState cube_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      return cube_state.alive;
    } else {
      boolean new_life = cycleOfLife(cube_state);
      new_lives.add(new_life);
      return new_life;
    }
  }

  public void applyNewLives() {
    int index = 0;
    for(boolean liveliness: new_lives) {
      CubeState cube_state = this.cube_states.get(index);
      cube_state.alive = new_lives.get(index);
      index++;
    }
  }
      
  public boolean cycleOfLife(CubeState cube_state) {
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

    if(mutation <= randomParameter.getValuef()) {
      after_alive = !after_alive;
    }

    if(before_alive != after_alive) {
      any_changes_this_run = true;
    }

    return after_alive;
  }
      
  public Integer countLiveNeighbors(CubeState cube_state) {
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

class L8onAutomata extends SCPattern {
  // Controls the probability of a mutation in the cycleOfStripperLife
  private BasicParameter randomParameter = new BasicParameter("RAND", 0.000000011, 0.0, 0.1);
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("DELAY", 75.0, 0.0, 1000.0);

  private final SawLFO pointPos = new SawLFO(0, model.points.size(), 3000);

  public final double MIN_ALIVE_PROBABILITY = 0.2;
  public final double MAX_ALIVE_PROBABILITY = 0.9;

  class PointState {
     // Index of cube in glucose.model.cubes
     public Integer index;
     // Boolean which describes if cube is alive.
     public boolean alive;

     public PointState(Integer index, boolean alive) {
       this.index = index;
       this.alive = alive;
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

     addParameter(randomParameter);
     addParameter(rateParameter);
     addModulator(pointPos).trigger();
  }

  private void initPointStates() {
    boolean alive = false;
    PointState point_state;
    this.point_states = new ArrayList<PointState>();
    Integer i = 0;

    for (LXPoint p : model.points) {
      alive = true;
      point_state = new PointState(i, alive);
      this.point_states.add(point_state);
      ++i;
    }
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
        lightLivePoint(p, i);
      } else {
        lightDeadPoint(p, i);
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

  public void lightLivePoint(LXPoint p, Integer index) {
    float point_dist = LXUtils.wrapdistf((float) index, pointPos.getValuef(), model.points.size());
    float hv = (point_dist / model.points.size()) * 360;

    colors[p.index] = lx.hsb(
      hv,
      90,
      80
    );
  }

  public void lightDeadPoint(LXPoint p, Integer index) {
    colors[p.index] = lx.hsb(
      120,
      0,
      0
    );
  }

  public boolean shouldLightPoint(PointState point_state) {
    // Respect rate parameter.
    if(time_since_last_run < rateParameter.getValuef()) {
      any_changes_this_run = true;
      return point_state.alive;
    } else {
      boolean new_state = cycleOfAutomata(point_state);
      new_states.add(new_state);
      return new_state;
    }
  }

  public boolean cycleOfAutomata(PointState point_state) {
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

    if(mutation < randomParameter.getValuef()) {
      after_alive = !after_alive;
    }

    if(before_alive != after_alive) {
      any_changes_this_run = true;
    }

    return after_alive;
  }

  public int countLiveNeighbors(PointState point_state) {
    Integer index = point_state.index;
    PointState before_neighbor;
    PointState after_neighbor;

    int count = 0;
    if (index > 0) {
      before_neighbor = point_states.get(index - 1);
      if(before_neighbor.alive) {
        count++;
      }
    }

    if (index < (point_states.size() - 1)) {
      after_neighbor = point_states.get(index + 1);
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
    }
  }
}

class L8onStrips extends SCPattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("DELAY", 112.5, 1.0, 1000.0);
  // Controls the probability of a mutation in the cycleOfStripperLife
  private BasicParameter randomParameter = new BasicParameter("RAND", 0.000000011, 0.0, 0.1);
  // Controls the saturation.
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);

  public final double MIN_ALIVE_PROBABILITY = 0.4;
  public final double MAX_ALIVE_PROBABILITY = 0.9;

  public final float MAX_ALIVE_BRIGHTNESS = 95.0;

  private final SawLFO stripPos = new SawLFO(0, model.strips.size(), 3000);

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
       this.neighbors = neighbors;
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

  public L8onStrips(GLucose glucose) {
     super(glucose);

     //Print debug info about the strips.
     //outputStripInfo();

     initStripStates();
     randomizeStripStates();
     time_since_last_run = 0;
     any_changes_this_run = false;
     new_lives = new ArrayList<Boolean>();

     addParameter(rateParameter);
     addParameter(randomParameter);
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

  public void lightLiveStrip(Strip strip, StripState strip_state, double deltaMs) {
    Integer index = strip_state.index;
    float strip_dist = LXUtils.wrapdistf((float) index, stripPos.getValuef(), model.strips.size());
    float hv = (strip_dist / model.strips.size()) * 360;
    float bv = strip_state.current_brightness;

    if(!strip_state.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = min(MAX_ALIVE_BRIGHTNESS, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(index == 100) {
        print("live prop: " + bright_prop + " bv: " + bv + " current: " + strip_state.current_brightness + "\n");
      }

      if(strip_state.current_brightness < bv) {
        strip_state.current_brightness = bv;
      } else {
        bv = strip_state.current_brightness;
      }

      if(index == 100) {
        print("live bv: " + bv + " current: " + strip_state.current_brightness + "\n");
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

  public void lightDeadStrip(Strip strip, StripState strip_state, double deltaMs) {
    Integer index = strip_state.index;
    float strip_dist = LXUtils.wrapdistf((float) index, stripPos.getValuef(), model.strips.size());
    float dist_proportion = (strip_dist / (float) model.strips.size());
    float hv = dist_proportion * 360;
    float bv =  strip_state.current_brightness;

    if(!strip_state.just_changed || deltaMs >= rateParameter.getValuef()) {
      float bright_prop = 1.0 - min(((float) time_since_last_run / rateParameter.getValuef()), 1.0);
      bv = max(0.0, bright_prop * MAX_ALIVE_BRIGHTNESS);

      if(index == 100) {
        print("dead prop: " + bright_prop + " bv: " + bv + " current: " + strip_state.current_brightness + "\n");
      }

      if(strip_state.current_brightness > bv) {
        strip_state.current_brightness = bv;
      } else {
        bv = strip_state.current_brightness;
      }

      if(index == 100) {
        print("dead bv: " + bv + " current: " + strip_state.current_brightness + "\n");
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

  public void outputStripInfo() {
    int i = 0;
    for (Strip strip : model.strips) {
      print("Strip " + i + ": " + strip.cx + "," + strip.cy + "," + strip.cz + "\n");
      ++i;
    }
  }

  private void initStripStates() {
    List<Integer> neighbors;
    boolean alive = false;
    float current_brightness;
    StripState strip_state;
    this.strip_states = new ArrayList<StripState>();
    Integer i = 0;

    int total_neighbors = 0;

    for (Strip strip : model.strips) {
      neighbors = findStripNeighbors(strip, i);
      alive = true;
      current_brightness = 0.0;
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
      if(strip_state.alive) {
        strip_state.current_brightness = 0;
      } else{
        strip_state.current_brightness = MAX_ALIVE_BRIGHTNESS;
      }
    }
  }

  public List<Integer> findStripNeighbors(Strip strip, Integer index) {
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

  public boolean shouldLightStrip(StripState strip_state) {
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

  public void applyNewLives() {
    int index = 0;
    for(boolean liveliness: new_lives) {
      StripState strip_state = this.strip_states.get(index);
      strip_state.alive = new_lives.get(index);
      index++;
    }
  }

  public boolean cycleOfStripperLife(StripState strip_state) {
    Integer index = strip_state.index;
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

    if(mutation < randomParameter.getValuef()) {
      after_alive = !after_alive;
    }

    if(before_alive != after_alive) {
      any_changes_this_run = true;
      strip_state.just_changed = true;
    }

    return after_alive;
  }

  public Integer countLiveNeighbors(StripState strip_state) {
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
