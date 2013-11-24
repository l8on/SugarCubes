class CubeState {  
 public Integer index;
 public boolean alive;
 public List<Integer> neighbors;
 
 public CubeState(Integer index, boolean alive, List<Integer> neighbors) {
   this.index = index;
   this.alive = alive;
   this.neighbors = neighbors;
 }
}

class Life extends SCPattern {
  public final int TIME_BETWEEN_RUNS = 100;
  public final int MAX_DEAD_BRIGHTNESS = 40;
  private final SinLFO xPos = new SinLFO(0, model.xMax, 5000);
  private final SinLFO yPos = new SinLFO(0, model.yMax, 5000);
  
  public List<CubeState> cube_states;
  public int time_since_last_run;
  public boolean any_changes_this_run;
  
  public Life(GLucose glucose) {
     super(glucose);  
     outputCubeInfo();
     initCubeStates();
     time_since_last_run = 0;
     any_changes_this_run = false;
     addModulator(xPos).trigger();
     addModulator(yPos).trigger();          
  }
  
  public void run(double deltaMs) {        
    Integer i = 0;    
    CubeState cube_state;
    
    time_since_last_run += deltaMs;
    
    if(time_since_last_run < TIME_BETWEEN_RUNS) {
      return;  
    }
    any_changes_this_run = false;        
            
    for (Cube cube : model.cubes) {    
      cube_state = this.cube_states.get(i);
      
      if(shouldBeAlive(i)) {
        lightLiveCube(cube);
      } else {
        lightDeadCube(cube);
      }                
      i++;
    }
    
    if(!any_changes_this_run) {
      randomizeCubeStates();  
    }
    
    time_since_last_run = 0;
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
    print("randomizing!\n");
    
    float f = (xPos.getValuef() / model.xMax) * 10;     
    int mod_value = max(2, (int) f);
    
    for (CubeState cube_state: this.cube_states) {      
      if( (cube_state.index % mod_value == 0) == cube_state.alive) {
        cube_state.alive = !cube_state.alive;  
      }           
    }    
  }
  
  public List<Integer> findCubeNeighbors(Cube cube, Integer index) {
    List<Integer> neighbors = new LinkedList<Integer>();
    Integer i = 0;
    
    for (Cube c : model.cubes) {          
      if(index == i)  {
        i++;
        continue;
      }
      
      if(abs(c.x - cube.x) < (Cube.EDGE_WIDTH * 2) && abs(c.y - cube.y) < (Cube.EDGE_HEIGHT * 2)) {      
        print("Cube " + i + " is a neighbor of " + index + "\n");
        neighbors.add(i);
      }
      
      i++;
    }

    return neighbors;    
  }
  
  public boolean shouldBeAlive(Integer index) {
    CubeState cube_state = this.cube_states.get(index);    
    Integer alive_neighbor_count = countLiveNeighbors(cube_state);           
    
    boolean before_alive = cube_state.alive;
            
    if(cube_state.alive) {
      if(alive_neighbor_count < 2 || alive_neighbor_count > 3) {
        cube_state.alive = false;
      } else {
        cube_state.alive = true;
      }
      
    } else {
      if(alive_neighbor_count == 3) {
        cube_state.alive = true;
      } else {
         cube_state.alive = false;   
      }
    }  
    
    this.cube_states.set(index, cube_state);
    
    if(before_alive != cube_state.alive) {
      any_changes_this_run = true;    
    }   
    return cube_state.alive;
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
  
  public void lightLiveCube(Cube cube) {    
    for (LXPoint p : cube.points) {
      float hv = max(0, lx.getBaseHuef() - abs(p.x - xPos.getValuef()));
      float bv = max(0, 100 - abs(p.y - yPos.getValuef()));
      colors[p.index] = lx.hsb(
        hv,
        100,        
        //bv
        75
      );
    }        
  }
  
  public void lightDeadCube(Cube cube) {
    for (LXPoint p : cube.points) {
      float hv = max(0, lx.getBaseHuef() - abs(p.x - xPos.getValuef()));
      float bv = max(0, MAX_DEAD_BRIGHTNESS - abs(p.y - yPos.getValuef()));
      
      colors[p.index] = lx.hsb(
        hv,
        100,        
        //bv
        10
      );     
    }  
  }
  
}
