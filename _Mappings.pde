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

    cubes[cubeIndex++] = new Cube(15, 0, 50, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(20, Cube.EDGE_HEIGHT, 40, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(15, 2*Cube.EDGE_HEIGHT, 46, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(10, 3*Cube.EDGE_HEIGHT, 42, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(15, 4*Cube.EDGE_HEIGHT, 42, 0, 0, 0);

    cubes[cubeIndex++] = new Cube(40, BASS_HEIGHT + 5, 20, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(45, BASS_HEIGHT + 5+Cube.EDGE_HEIGHT, 10, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(40, BASS_HEIGHT + 5+2*Cube.EDGE_HEIGHT, 14, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(35, BASS_HEIGHT + 5+3*Cube.EDGE_HEIGHT, 18, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(40, BASS_HEIGHT + 5+4*Cube.EDGE_HEIGHT, 13, 0, 0, 0);

    cubes[cubeIndex++] = new Cube(80, BASS_HEIGHT + 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(85, BASS_HEIGHT + Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(80, BASS_HEIGHT + 2*Cube.EDGE_HEIGHT, 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(75, BASS_HEIGHT + 3*Cube.EDGE_HEIGHT, 8, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(80, BASS_HEIGHT + 4*Cube.EDGE_HEIGHT, 3, 0, 0, 0);

    cubes[cubeIndex++] = new Cube(120, BASS_HEIGHT + 10, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(125, BASS_HEIGHT + 10+Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(120, BASS_HEIGHT + 10+2*Cube.EDGE_HEIGHT, 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(115, BASS_HEIGHT + 10+3*Cube.EDGE_HEIGHT, 8, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(120, BASS_HEIGHT + 10+4*Cube.EDGE_HEIGHT, 3, 0, 0, 0);

    cubes[cubeIndex++] = new Cube(160, BASS_HEIGHT + 0, 30, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(165, BASS_HEIGHT + Cube.EDGE_HEIGHT, 20, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(160, BASS_HEIGHT + 2*Cube.EDGE_HEIGHT, 24, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(155, BASS_HEIGHT + 3*Cube.EDGE_HEIGHT, 28, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(160, BASS_HEIGHT + 4*Cube.EDGE_HEIGHT, 23, 0, 0, 0);

    cubes[cubeIndex++] = new Cube(200, 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(205, Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(200, 2*Cube.EDGE_HEIGHT, 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(195, 3*Cube.EDGE_HEIGHT, 8, 0, -20, 0);
    cubes[cubeIndex++] = new Cube(200, 4*Cube.EDGE_HEIGHT, 3, 0, 0, 0);

    cubes[cubeIndex++] = new Cube(210, 0, 60, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(215, Cube.EDGE_HEIGHT, 50, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(210, 2*Cube.EDGE_HEIGHT, 54, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(205, 3*Cube.EDGE_HEIGHT, 58, 0, -20, 0);
    
    return cubes;
  }

  public int[][] buildFrontChannelList() {
    return new int[][] {
      { 1, 2, 3, 0, 0 }, // ch1
      { 4, 5, 6, 0, 0 }, // ch2
      { 0, 0, 0, 0, 0 }, // ch3
      { 0, 0, 0, 0, 0 }, // ch4
      { 0, 0, 0, 0, 0 }, // ch5
      { 0, 0, 0, 0, 0 }, // ch6
      { 0, 0, 0, 0, 0 }, // ch7
      { 0, 0, 0, 0, 0 }, // ch8 
    };
  }

  public int[][] buildRearChannelList() {
    return new int[][] {
      { 0, 0, 0, 0, 0 }, // ch9
      { 0, 0, 0, 0, 0 }, // ch10
      { 0, 0, 0, 0, 0 }, // ch11
      { 0, 0, 0, 0, 0 }, // ch12
      { 0, 0, 0, 0, 0 }, // ch13
      { 0, 0, 0, 0, 0 }, // ch14
      { 0, 0, 0, 0, 0 }, // ch15
      { 0, 0, 0, 0, 0 }, // ch16
    };
  }
}

