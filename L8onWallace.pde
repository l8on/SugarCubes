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

class L8onLife extends SCPattern {
  // Controls the rate of life algorithm ticks, in milliseconds
  private BasicParameter rateParameter = new BasicParameter("RATE", 122.5, 0.0, 2000.0);
  // Controls if the cubes should be randomized even if something changes. Set above 0.5 to randomize cube aliveness.
  private BasicParameter randomParameter = new BasicParameter("RAND", 0.0);
  // Controls the brightness of dead cubes.
  private BasicParameter deadParameter = new BasicParameter("DEAD", 25.0, 0.0, 100.0);
  // Controls the saturation.
  private BasicParameter saturationParameter = new BasicParameter("SAT", 90.0, 0.0, 100.0);
    
  public final double MIN_ALIVE_PROBABILITY = 0.2;
  public final double MAX_ALIVE_PROBABILITY = 0.9;
  
  private final SinLFO xPos = new SinLFO(0, model.xMax, 4500);
  
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
     addModulator(xPos).trigger();
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
        lightLiveCube(cube);
      } else {
        lightDeadCube(cube);
      } 
      
      i++;      
    }
    
    boolean should_randomize_anyway = (randomParameter.getValuef() > 0.5);
    if(should_randomize_anyway || !any_changes_this_run) {
      randomizeCubeStates();  
    } else {
      applyNewLives();
    }
    
    if(time_since_last_run >= rateParameter.getValuef()) {
      time_since_last_run = 0;
    }    
  }
  
  public void lightLiveCube(Cube cube) {    
    for (LXPoint p : cube.points) {
      float hv = max(0, lx.getBaseHuef() - abs(p.x - xPos.getValuef()));
      colors[p.index] = lx.hsb(
        hv,
        saturationParameter.getValuef(),        
        75
      );
    }        
  }
  
  public void lightDeadCube(Cube cube) {
    for (LXPoint p : cube.points) {
      float hv = max(0, lx.getBaseHuef() - abs(p.x - xPos.getValuef()));
      double dead_bright = deadParameter.getValuef() * Math.random();
      
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
    this.cube_states = new LinkedList<CubeState>(); 
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
              
    if(cube_state.alive) {
      if(alive_neighbor_count < 2 || alive_neighbor_count > 3) {
        after_alive = false;
      } else {
        after_alive = true;
      }
      
    } else {
      if(alive_neighbor_count == 3) {
        after_alive = true;
      } else {
        after_alive = false;
      }
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
