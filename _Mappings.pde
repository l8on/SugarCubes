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
 * This class implements the mapping functions needed to lay out the physical
 * cubes and the output ports on the panda board. It should only be modified
 * when physical changes or tuning is being done to the structure.
 */
class SCMapping implements GLucose.Mapping {
  public Cube[] buildCubeArray() {
    // TODO(mcslee): find a cleaner way of representing this data, probably
    // serialized in some more neutral form. also figure out what's going on
    // with the indexing starting at 1 and some indices missing.
    Cube[] cubes = new Cube[79];
    
    int cubeIndex = 1;
    
    cubes[cubeIndex++] = new Cube(0, 0, 0, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(5, Cube.EDGE_HEIGHT, -10, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(0, 2*Cube.EDGE_HEIGHT, -6, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(-5, 3*Cube.EDGE_HEIGHT, -2, 0, -20, 0);
    
    cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, 0, 0, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, Cube.EDGE_HEIGHT, 5, 0, 10, 0);
    cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, 2*Cube.EDGE_HEIGHT, 2, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(Cube.EDGE_WIDTH + 2, 3*Cube.EDGE_HEIGHT, 0, 0, 30, 0);
    
    // Back Cubes behind DJ platform (in order of increasing x)
    cubes[cubeIndex++] = new Cube(50, 0, BASS_DEPTH, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(52,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(48, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(45,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(48,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0);
    
    cubes[cubeIndex++] = new Cube(79, 0, BASS_DEPTH, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(81,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(83, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(81,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(79,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0);
    
    cubes[cubeIndex++] = new Cube(107, 0, BASS_DEPTH, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(111,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(113, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(110,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0);
    // cubes[cubeIndex++] = new Cube(115,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0);
    
    cubes[cubeIndex++] = new Cube(133, 0, BASS_DEPTH, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(131,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(133, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(135,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0);
    // cubes[cubeIndex++] = new Cube(137,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0);
    
    cubes[cubeIndex++] = new Cube(165, 0, BASS_DEPTH, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(164,  5+Cube.EDGE_HEIGHT, BASS_DEPTH, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(167, 5+2*Cube.EDGE_HEIGHT, BASS_DEPTH + 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(163,   5+3*Cube.EDGE_HEIGHT, BASS_DEPTH + 15, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(168,  5+4*Cube.EDGE_HEIGHT, BASS_DEPTH + 13, 0, 0, 0);
    
    // front DJ cubes
    cubes[cubeIndex++] = new Cube( (TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + Cube.EDGE_HEIGHT + 3, BASS_HEIGHT, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + Cube.EDGE_HEIGHT + 2, BASS_HEIGHT+Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    

    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 2*Cube.EDGE_HEIGHT + 5, BASS_HEIGHT + 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 2*Cube.EDGE_HEIGHT + 6, BASS_HEIGHT + Cube.EDGE_HEIGHT, 10, 0, 10, 0);
   
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 3*Cube.EDGE_HEIGHT + 9, BASS_HEIGHT + 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 3*Cube.EDGE_HEIGHT + 8, BASS_HEIGHT + Cube.EDGE_HEIGHT, 10, 0, 0, 0);
    
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 14, BASS_HEIGHT + Cube.EDGE_HEIGHT, 10, 0, 0, 0);
    
    // left dj cubes
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + 0, Cube.EDGE_HEIGHT + 2, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 4, 0, 20, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + 0, 2*Cube.EDGE_HEIGHT + 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2, BASS_HEIGHT + Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 6, 0, 20, 0);
    
    // right dj cubes    
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + 0, Cube.EDGE_HEIGHT + 2, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 4, 0, 20, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + 0, 2*Cube.EDGE_HEIGHT + 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube((TRAILER_WIDTH - BASS_WIDTH)/2 + 4*Cube.EDGE_HEIGHT + 15, BASS_HEIGHT + Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 6, 0, 20, 0);
   
    cubes[cubeIndex++] = new Cube(200, 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(205, Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(200, 2*Cube.EDGE_HEIGHT, 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(195, 3*Cube.EDGE_HEIGHT, 8, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(200, 4*Cube.EDGE_HEIGHT, 3, 0, 0, 0);

    cubes[cubeIndex++] = new Cube(200, 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(205, Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(200, 2*Cube.EDGE_HEIGHT, 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(195, 3*Cube.EDGE_HEIGHT, 8, 0, -20, 0);
     
    cubes[cubeIndex++] = new Cube(10, 0 , Cube.EDGE_HEIGHT + 10, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(3, Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 8, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(0, 2*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 10, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(0, 3*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 10, 0, 60, 0);
    cubes[cubeIndex++] = new Cube(0, 4*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 10, 0, 40, 0);
    
    cubes[cubeIndex++] = new Cube(20, 0, 2*Cube.EDGE_HEIGHT + 18, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(30, Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(25, 2*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(30, 3*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 60, 0);
    cubes[cubeIndex++] = new Cube(32, 4*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 18, 0, 40, 0);
    
    cubes[cubeIndex++] = new Cube(210, 0, Cube.EDGE_HEIGHT + 15, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(215, Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(218, 2*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(213, 3*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 60, 0);
    cubes[cubeIndex++] = new Cube(210, 4*Cube.EDGE_HEIGHT, Cube.EDGE_HEIGHT + 15, 0, 40, 0);
    
    cubes[cubeIndex++] = new Cube(210, 0, 2*Cube.EDGE_HEIGHT + 25, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(215, Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(212, 2*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 40, 0);
    cubes[cubeIndex++] = new Cube(215, 3*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 60, 0);
    cubes[cubeIndex++] = new Cube(210, 4*Cube.EDGE_HEIGHT, 2*Cube.EDGE_HEIGHT + 25, 0, 40, 0);
     
    
    return cubes;
  }

  public int[][] buildFrontChannelList() {
    return new int[][] {
      {  1,  2,  3,  4, 0 }, // ch1
      {  5,  6,  7,  8, 0 }, // ch2
      {  9, 10, 11, 12, 0 }, // ch3
      { 13, 14, 15, 16, 0 }, // ch4
      { 17, 18, 19, 20, 0 }, // ch5
      { 21, 22, 23, 24, 0 }, // ch6
      { 25, 26, 27, 28, 0 }, // ch7
      { 29, 30, 31, 32, 0 }, // ch8 
    };
  }

  public int[][] buildRearChannelList() {
    return new int[][] {
      { 33, 34, 35, 36, 0 }, // ch9
      { 37, 38, 39, 40, 0 }, // ch10
      { 41, 42, 43, 44, 0 }, // ch11
      { 45, 46, 47, 48, 0 }, // ch12
      { 49, 50, 51, 52, 0 }, // ch13
      { 53, 54, 55, 56, 0 }, // ch14
      { 57, 58, 59, 60, 0 }, // ch15
      { 61, 62, 63, 64, 0 }, // ch16
    };
  }
}

