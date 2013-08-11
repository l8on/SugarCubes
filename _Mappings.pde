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

public Model buildModel() {
  // TODO(mcslee): find a cleaner way of representing this data, probably
  // serialized in some more neutral form. also figure out what's going on
  // with the indexing starting at 1 and some indices missing.
  ArrayList<Tower> towerList = new ArrayList<Tower>();
  ArrayList<Cube> tower;
  Cube[] cubes = new Cube[79];
  int cubeIndex = 1;

  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube(0, 0, 0, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(5, Cube.EDGE_HEIGHT, -10, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(0, 2*Cube.EDGE_HEIGHT, -6, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(-5, 3*Cube.EDGE_HEIGHT, -2, 0, -20, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, 0, 0, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, Cube.EDGE_HEIGHT, 5, 0, 10, 0));
  tower.add(cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, 2*Cube.EDGE_HEIGHT, 2, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, 3*Cube.EDGE_HEIGHT, 0, 0, 30, 0));
  towerList.add(new Tower(tower));
  
  // Back Cubes behind DJ platform (in order of increasing x)
  tower = new ArrayList<Cube>();  
  tower.add(cubes[cubeIndex++] = new Cube(50, 0, BASS_DEPTH, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(52,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(48, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(45,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(48,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();  
  tower.add(cubes[cubeIndex++] = new Cube(79, 0, BASS_DEPTH, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(81,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(83, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(81,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(79,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();  
  tower.add(cubes[cubeIndex++] = new Cube(107, 0, BASS_DEPTH, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(111,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(113, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(110,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0));
  // tower.add(cubes[cubeIndex++] = new Cube(115,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();  
  tower.add(cubes[cubeIndex++] = new Cube(133, 0, BASS_DEPTH, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(131,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(133, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(135,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0));
  // tower.add(cubes[cubeIndex++] = new Cube(137,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube(165, 0, BASS_DEPTH, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(164,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(167, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(163,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(168,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0));
  towerList.add(new Tower(tower));
  
  // front DJ cubes
  tower = new ArrayList<Cube>();  
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + 0, 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + Cube.EDGE_HEIGHT, 0, 0, 20, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + Cube.EDGE_HEIGHT + 2, BASS_HEIGHT+Cube.EDGE_HEIGHT, 0, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + Cube.EDGE_HEIGHT + 3, BASS_HEIGHT, 10, 0, 0, 0));
  towerList.add(new Tower(tower));

  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 2*Cube.EDGE_HEIGHT + 5, BASS_HEIGHT + 0, 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 2*Cube.EDGE_HEIGHT + 6, BASS_HEIGHT + Cube.EDGE_HEIGHT, 10, 0, 10, 0));
  towerList.add(new Tower(tower));
 
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 3*Cube.EDGE_HEIGHT + 9, BASS_HEIGHT + 0, 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 3*Cube.EDGE_HEIGHT + 8, BASS_HEIGHT + Cube.EDGE_HEIGHT, 10, 0, 0, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + 0, 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 14, BASS_HEIGHT + Cube.EDGE_HEIGHT, 10, 0, 0, 0));
  towerList.add(new Tower(tower));
  
  // left dj cubes
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + 0, Cube.EDGE_HEIGHT + 2, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 4, 0, 20, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + 0, 2*Cube.EDGE_HEIGHT + 4, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 6, 0, 20, 0));
  towerList.add(new Tower(tower));
  
  // right dj cubes    
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + 0, Cube.EDGE_HEIGHT + 2, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 4, 0, 20, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + 0, 2*Cube.EDGE_HEIGHT + 4, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 6, 0, 20, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube(200, 0, 10, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(205, Cube.EDGE_HEIGHT, 0, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(200, 2*Cube.EDGE_HEIGHT, 4, 0, 0, 0));
  tower.add(cubes[cubeIndex++] = new Cube(195, 3*Cube.EDGE_HEIGHT, 8, 0, -20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(200, 4*Cube.EDGE_HEIGHT, 3, 0, 0, 0));
  towerList.add(new Tower(tower));
   
  tower = new ArrayList<Cube>();
  tower.add(cubes[cubeIndex++] = new Cube(10, 0 , Cube.EDGE_HEIGHT + 10, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(3, Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 8, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(0, 2*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 10, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(0, 3*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 10, 0, 60, 0));
  tower.add(cubes[cubeIndex++] = new Cube(0, 4*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 10, 0, 40, 0));
  towerList.add(new Tower(tower));

  tower = new ArrayList<Cube>();  
  tower.add(cubes[cubeIndex++] = new Cube(20, 0, 2*Cube.EDGE_HEIGHT + 18, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(30, Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(25, 2*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(30, 3*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 60, 0));
  tower.add(cubes[cubeIndex++] = new Cube(32, 4*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 40, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();    
  tower.add(cubes[cubeIndex++] = new Cube(210, 0, Cube.EDGE_HEIGHT + 15, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(215, Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(218, 2*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(213, 3*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 60, 0));
  tower.add(cubes[cubeIndex++] = new Cube(210, 4*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 40, 0));
  towerList.add(new Tower(tower));
  
  tower = new ArrayList<Cube>();    
  tower.add(cubes[cubeIndex++] = new Cube(210, 0, 2*Cube.EDGE_HEIGHT + 25, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(215, Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 20, 0));
  tower.add(cubes[cubeIndex++] = new Cube(212, 2*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 40, 0));
  tower.add(cubes[cubeIndex++] = new Cube(215, 3*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 60, 0));
  tower.add(cubes[cubeIndex++] = new Cube(210, 4*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 40, 0));
  towerList.add(new Tower(tower));
       
  return new Model(towerList, cubes);
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
      { 49, 50, 51, 52 }, // ch13
      { 53, 54, 55, 56 }, // ch14
      { 57, 58, 59, 60 }, // ch15
      { 61, 62, 63, 64 }, // ch16
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


