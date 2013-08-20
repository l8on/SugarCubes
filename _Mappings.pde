/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * This file implements the mapping functions needed to lay out the physical
 * cubes and the output ports on the panda board. It should only be modified
 * when physical changes or tuning is being done to the structure.
 */

class TowerMapping {
  public final float x, y, z;
  public final float[][] cubePositions;
  
  TowerMapping(float x, float y, float z, float[][] cubePositions) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.cubePositions = cubePositions;
  }
}

public Model buildModel() {
  // The model is represented as an array of towers. The cubes in the tower
  // are represenented relatively. Each tower has an x, y, z reference position,
  // which is typically the base cube's bottom left corner.
  //
  // Following that is an array of floats. A 2-d array contains an x-offset
  // and a z-offset from the reference position. Typically the first cube
  // will just be {0, 0}.
  //
  // A 3-d array contains an x-offset, a z-offset, and a rotation about the
  // y-axis.
  //
  // The cubes automatically increment their y-position by Cube.EDGE_HEIGHT.
  
  final float STACKED_RELATIVE = 1;
  final float STACKED_REL_SPIN = 2;
  final float BASS_DEPTH = BassBox.EDGE_DEPTH + 4;
  
  TowerMapping[] mapping = new TowerMapping[] {

      // Front left cubes
//    new TowerMapping(0, 0, 0, new float[][] {
//      {STACKED_RELATIVE, 0, 0},
//      {STACKED_RELATIVE, 5, -10, 20},
//      {STACKED_RELATIVE, 0, -6},
//      {STACKED_RELATIVE, -5, -2, -20},
//    }),
//
//    new TowerMapping(Cube.EDGE_WIDTH + 2, 0, 0, new float[][] {
//      {STACKED_RELATIVE, 0, 0},
//      {STACKED_RELATIVE, 0, 5, 10},
//      {STACKED_RELATIVE, 0, 2, 20},
//      {STACKED_RELATIVE, 0, 0, 30},
//    }),
    
    // Back Cubes behind DJ platform (in order of increasing x)
    new TowerMapping(50, 5, BASS_DEPTH, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 2, 0, 20},
      {STACKED_RELATIVE, -2, 10},
      {STACKED_RELATIVE, -5, 15, -20},
      {STACKED_RELATIVE, -2, 13},
    }),
    
    new TowerMapping(79, 5, BASS_DEPTH, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 2, 0, 20},
      {STACKED_RELATIVE, 4, 10},
      {STACKED_RELATIVE, 2, 15, -20},
      {STACKED_RELATIVE, 0, 13},
    }),
    
    new TowerMapping(107, 5, BASS_DEPTH, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 4, 0, 20},
      {STACKED_RELATIVE, 6, 10},
      {STACKED_RELATIVE, 3, 15, -20},
      // {STACKED_RELATIVE, 8,  13},
    }),
    
    new TowerMapping(133, 5, BASS_DEPTH, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, -2, 0, 20},
      {STACKED_RELATIVE, 0, 10},
      {STACKED_RELATIVE, 2, 15, -20},
      // {STACKED_RELATIVE, 4, 13}
    }),
    
    new TowerMapping(165, 5, BASS_DEPTH, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, -1, 20},
      {STACKED_RELATIVE, 2, 10},
      {STACKED_RELATIVE, -2, 15, -20},
      {STACKED_RELATIVE, 3, 13},
    }),
    
    // front DJ cubes
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, 10, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 0, -10, 20},
    }),
    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2 + Cube.EDGE_HEIGHT, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, 10, new float[][] {
      {STACKED_RELATIVE, 3, 0},
      {STACKED_RELATIVE, 2, -10, 20},
    }),
    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2 + 2*Cube.EDGE_HEIGHT + 5, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, 10, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 1, 0, 10},
    }),
    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2 + 3*Cube.EDGE_HEIGHT + 9, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, 10, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, -1, 0},
    }),
    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, 10, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, -1, 0},
    }),
    
    // left dj cubes    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, Cube.EDGE_HEIGHT + 2, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 0, 2, 20},
    }),
    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, 2*Cube.EDGE_HEIGHT + 4, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 0, 2, 20},
    }),
    
    // right dj cubes    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, Cube.EDGE_HEIGHT + 2, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 0, 2, 20},
    }),
    
    new TowerMapping((TRAILER_WIDTH - BassBox.EDGE_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH, 2*Cube.EDGE_HEIGHT + 4, new float[][] {
      {STACKED_RELATIVE, 0, 0},
      {STACKED_RELATIVE, 0, 2, 20},
    }),

//    new TowerMapping(200, 0, 0, new float[][] {
//      {STACKED_RELATIVE, 0, 10},
//      {STACKED_RELATIVE, 5, 0, 20},
//      {STACKED_RELATIVE, 0, 4},
//      {STACKED_RELATIVE, -5, 8, -20},
//      {STACKED_RELATIVE, 0, 3},
//    }),
    
//    new TowerMapping(0, 0, Cube.EDGE_HEIGHT + 10, new float[][] {
//      {STACKED_RELATIVE, 10, 0, 40},
//      {STACKED_RELATIVE, 3, -2, 20},
//      {STACKED_RELATIVE, 0, 0, 40},
//      {STACKED_RELATIVE, 0, 0, 60},
//      {STACKED_RELATIVE, 0, 0, 40},
//    }),
    
    new TowerMapping(20, 0, 2*Cube.EDGE_HEIGHT + 18, new float[][] {
      {STACKED_RELATIVE, 0, 0, 40},
      {STACKED_RELATIVE, 10, 0, 20},
      {STACKED_RELATIVE, 5, 0, 40},
      {STACKED_RELATIVE, 10, 0, 60},
      {STACKED_RELATIVE, 12, 0, 40},
    }),
    
//    new TowerMapping(210, 0, Cube.EDGE_HEIGHT + 15, new float[][] {
//      {STACKED_RELATIVE, 0, 0, 40},
//      {STACKED_RELATIVE, 5, 0, 20},
//      {STACKED_RELATIVE, 8, 0, 40},
//      {STACKED_RELATIVE, 3, 0, 60},
//      {STACKED_RELATIVE, 0, 0, 40},
//    }),
    
    new TowerMapping(210, 0, 2*Cube.EDGE_HEIGHT + 25, new float[][] {
      {STACKED_RELATIVE, 0, 0, 40},
      {STACKED_RELATIVE, 5, 0, 20},
      {STACKED_RELATIVE, 2, 0, 40},
      {STACKED_RELATIVE, 5, 0, 60},
      {STACKED_RELATIVE, 0, 0, 40},
    }),
    
  };

  ArrayList<Tower> towerList = new ArrayList<Tower>();
  ArrayList<Cube> tower;
  Cube[] cubes = new Cube[79];
  int cubeIndex = 1;  
  float tx, ty, tz, px, pz, ny, dx, dz, ry;
  for (TowerMapping tm : mapping) {
    tower = new ArrayList<Cube>();
    px = tx = tm.x;
    ny = ty = tm.y;
    pz = tz = tm.z;
    int ti = 0;
    for (float[] cp : tm.cubePositions) {
      float mode = cp[0];
      if (mode == STACKED_RELATIVE) {
        dx = cp[1];
        dz = cp[2];
        ry = (cp.length >= 4) ? cp[3] : 0;
        tower.add(cubes[cubeIndex++] = new Cube(px = tx + dx, ny, pz = tz + dz, 0, ry, 0));
        ny += Cube.EDGE_HEIGHT;
      } else if (mode == STACKED_REL_SPIN) {
        // Same as above but the front left of this cube is actually its back right for wiring
        // TODO(mcslee): implement this
      }
    }
    towerList.add(new Tower(tower));
  }

  BassBox bassBox = new BassBox(56, 0, 2);

  List<Speaker> speakers = new ArrayList<Speaker>();
  speakers.add(new Speaker(-12, 6, 0, 15));
  speakers.add(new Speaker(TRAILER_WIDTH - Speaker.EDGE_WIDTH, 6, 6, -15));

  return new Model(towerList, cubes, bassBox, speakers);
}

public PandaMapping[] buildPandaList() {
  return new PandaMapping[] {
    new PandaMapping(
      "10.200.1.28", new int[][] {
      {  1,  2,  3,  4 }, // ch1
      {  5,  6,  7,  8 }, // ch2
      {  9, 10, 11, 12 }, // ch3
      { 13, 14, 15, 16 }, // ch4
      { 17, 18, 19, 20 }, // ch5
      { 21, 22, 23, 24 }, // ch6
      { 25, 26, 27, 28 }, // ch7
      { 29, 30, 31, 32 }, // ch8
    }),

    new PandaMapping(
      "10.200.1.29", new int[][] {
      { 33, 34, 35, 36 }, // ch9
      { 37, 38, 39, 40 }, // ch10
      { 41, 42, 43, 44 }, // ch11
      { 45, 46, 47, 48 }, // ch12
      { 33, 34, 35, 36 }, // ch13
      { 37, 38, 39, 40 }, // ch14
      { 41, 42, 43, 44 }, // ch15
      { 45, 46, 47, 48 }, // ch16
    }),
    
  };
}

class PandaMapping {
  
  // How many channels are on the panda board
  public final static int CHANNELS_PER_BOARD = 8;
  
  // How many cubes per channel xc_PB is configured for
  public final static int CUBES_PER_CHANNEL = 4;
  
  // How many total pixels on each channel
  public final static int PIXELS_PER_CHANNEL = Cube.POINTS_PER_CUBE * CUBES_PER_CHANNEL;
  
  // How many total pixels on the whole board
  public final static int PIXELS_PER_BOARD = PIXELS_PER_CHANNEL * CHANNELS_PER_BOARD;
  
  final String ip;
  final int[][] channelList = new int[CHANNELS_PER_BOARD][CUBES_PER_CHANNEL];
  
  PandaMapping(String ip, int[][] rawChannelList) {
    this.ip = ip;
    for (int chi = 0; chi < CHANNELS_PER_BOARD; ++chi) {
      int[] cubes = (chi < rawChannelList.length) ? rawChannelList[chi] : new int[]{};
      for (int cui = 0; cui < CUBES_PER_CHANNEL; ++cui) {
        channelList[chi][cui] = (cui < cubes.length) ? cubes[cui] : 0;
      }
    }
  }
}


