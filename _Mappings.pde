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

    cubes[cubeIndex++] = new Cube(200, 0, 10, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(205, Cube.EDGE_HEIGHT, 0, 0, 20, 0);
    cubes[cubeIndex++] = new Cube(200, 2*Cube.EDGE_HEIGHT, 4, 0, 0, 0);
    cubes[cubeIndex++] = new Cube(195, 3*Cube.EDGE_HEIGHT, 8, 0, -20, 0);

        
    if (true) {
      return cubes;
    }
    
    cubes[1]  = new Cube(17.25, 0, 0, 0, 0, 80);
    cubes[2]  = new Cube(50.625, -1.5, 0, 0, 0, 55);
    cubes[3]  = new Cube(70.75, 12.375, 0, 0, 0, 55);
    cubes[4]  = new Cube(49.75, 24.375, 0, 0, 0, 48);//dnw
    cubes[5]  = new Cube(14.25, 32, 0, 0, 0, 80);
    cubes[6]  = new Cube(50.375, 44.375, 0, 0, 0, 0);//dnw
    cubes[7]  = new Cube(67.5, 64.25, 0, 27, 0, 0);//dnw
    cubes[8]  = new Cube(44, 136, 0, 0, 0, 0);
    cubes[9]  = new Cube(39, 162, 0, 0, 0, 0);
    cubes[10] = new Cube(58, 182, -4, 12, 0, 0);
    cubes[11] = new Cube(28, 182, -4, 12, 0, 0);
    cubes[12] = new Cube(0, 182, -4, 12, 0, 0);
    cubes[13] = new Cube(18.75, 162, 0, 0, 0, 0);
    cubes[14] = new Cube(13.5, 136, 0, 0, 0, 0);
    cubes[15] = new Cube(6.5, -8.25, 20, 0, 0, 25);
    cubes[16] = new Cube(42, 15, 20, 0, 0, 4);
    cubes[17] = new Cube(67, 24, 20, 0, 0, 25);
    cubes[18] = new Cube(56, 41, 20, 0, 0, 30);
    cubes[19] = new Cube(24, 2, 20, 0, 0, 25);
    cubes[20] = new Cube(26, 26, 20, 0, 0, 70);
    cubes[21] = new Cube(3.5, 10.5, 20, 0, 0, 35);
    cubes[22] = new Cube(63, 133, 20, 0, 0, 80);
    cubes[23] = new Cube(56, 159, 20, 0, 0, 65);
    cubes[24] = new Cube(68, 194, 20, 0, -45, 0);
    cubes[25] = new Cube(34, 194, 20, 20, 0, 35);
    cubes[26] = new Cube(10, 194, 20, 0, -45, 0); // wired a bit funky
    cubes[27] = new Cube(28, 162, 20, 0, 0, 65);
    cubes[28] = new Cube(15.5, 134, 20, 0, 0, 20);
    cubes[29] = new Cube(13, 29, 40, 0, 0, 0);
    cubes[30] = new Cube(55, 15, 40, 0, 0, 50);
    cubes[31] = new Cube(78, 9, 40, 0, 0, 60);
    cubes[32] = new Cube(80, 39, 40, 0, 0, 80);
    cubes[33] = new Cube(34, 134, 40, 0, 0, 50);
    cubes[34] = new Cube(42, 177, 40, 0, 0, 0);
    cubes[35] = new Cube(41, 202, 40, 20, 0, 80);
    cubes[36] = new Cube(21, 178, 40, 0, 0, 35);
    cubes[37] = new Cube(18, 32, 60, 0, 0, 65);
    cubes[38] = new Cube(44, 20, 60, 0, 0, 20); //front power cube
    cubes[39] = new Cube(39, 149, 60, 0, 0, 15);
    cubes[40] = new Cube(60, 186, 60, 0, 0, 45);
    cubes[41] = new Cube(48, 213, 56, 20, 0, 25);
    cubes[42] = new Cube(22, 222, 60, 10, 10, 15);
    cubes[43] = new Cube(28, 198, 60, 20, 0, 20);
    cubes[44] = new Cube(12, 178, 60, 0, 0, 50);
    cubes[45] = new Cube(18, 156, 60, 0, 0, 40);
    cubes[46] = new Cube(30, 135, 60, 0, 0, 45);
    cubes[47] = new Cube(10, 42, 80, 0, 0, 17);
    cubes[48] = new Cube(34, 23, 80, 0, 0, 45);
    cubes[49] = new Cube(77, 28, 80, 0, 0, 45);
    cubes[50] = new Cube(53, 22, 80, 0, 0, 45);
    cubes[51] = new Cube(48, 175, 80, 0, 0, 45); 
    cubes[52] = new Cube(66, 172, 80, 0, 0, 355);// _,195,_ originally
    cubes[53] = new Cube(33, 202, 80, 25, 0, 85);
    cubes[54] = new Cube(32, 176, 100, 0, 0, 20);
    cubes[55] = new Cube(5.75, 69.5, 0, 0, 0, 80);
    cubes[56] = new Cube(1, 53, 0, 40, 70, 70);
    cubes[57] = new Cube(-15, 24, 0, 15, 0, 0);
    //cubes[58] what the heck happened here? never noticed before 4/8/2013
    cubes[59] = new Cube(40, 46, 100, 0, 0, 355); // copies from 75
    cubes[60] = new Cube(40, 164, 120, 0, 0, 12.5);
    cubes[61] = new Cube(32, 148, 100, 0, 0, 3);
    cubes[62] = new Cube(30, 132, 90, 10, 350, 5);
    cubes[63] = new Cube(22, 112, 100, 0, 20, 0);
    cubes[64] = new Cube(35, 70, 95, 15, 345, 20);
    cubes[65] = new Cube(38, 112, 98, 25, 0, 0);
    cubes[66] = new Cube(70, 164, 100, 0, 0, 22);
    cubes[68] = new Cube(29, 94, 105, 15, 20, 10);
    cubes[69] = new Cube(30, 77, 100, 15, 345, 20);
    cubes[70] = new Cube(38, 96, 95, 30, 0, 355);
    //cubes[71] = new Cube(38,96,95,30,0,355); //old power cube
    cubes[72] = new Cube(44, 20, 100, 0, 0, 345);
    cubes[73] = new Cube(28, 24, 100, 0, 0, 13);
    cubes[74] = new Cube(8, 38, 100, 10, 0, 0);
    cubes[75] = new Cube(20, 58, 100, 0, 0, 355);
    cubes[76] = new Cube(22, 32, 120, 15, 327, 345); 
    cubes[77] = new Cube(50, 132, 80, 0, 0, 0); 
    cubes[78] = new Cube(20, 140, 80, 0, 0, 0);
    return cubes;
  }

  public int[][] buildFrontChannelList() {
    if (true) {
      return new int[][] {
        { 1, 0 },
      };
    }
    
    return new int[][] {
      {
        1, 57, 56, 55, 0  // Pandaboard A, structural channel 1
      }
      , 
      {
        31, 32, 17, 3, 0  // Pandaboard B, structural channel 2,  normally 30, 31, 32, 17, 3 (disconnected 30)
      }
      , 
      {
        20, 21, 15, 19, 0  // Pandaboard C, structural channel 3
      }
      , 
      {
        69, 75, 74, 76, 73  // Pandaboard D, structural channel 4, normally 64 first
      }
      , 
      {
        16, 2, 5, 0, 0  // Pandaboard E, structural channel 5
      }
      , 
      {
        48, 47, 37, 29, 0  // Pandaboard F, structural channel 6 (is there a 5th?)
      }
      , 
      {
        68, 63, 62, 78, 45  // Pandaboard G, structural channel 7, left top front side
      }
      , 
      {
        18, 6, 7, 0, 0  // Pandaboard H, structural channel 8
      }
    };
  }

  public int[][] buildRearChannelList() {
    if (true) {
      return new int[][] {
        { 1, 0 },
      };
    }
    
    return new int[][] {
      {
        22, 8, 14, 28, 0  // Pandaboard A, structural channel 9
      }
      , 
      {
        36, 34, 40, 52, 66  // Pandaboard B, structural channel 10
      }
      , 
      {
        65, 61, 60, 54, 51  // Pandaboard C, structural channel 11
      }
      , 
      {
        35, 25, 11, 10, 24  // Pandaboard D, structural channel 12
      }
      , 
      {
        23, 9, 13, 27, 12  // Pandaboard E, structural channel 13, missing taillight?
      }
      , 
      {
        64, 59, 72, 49, 50  // Pandaboard F, structural channel 14, right top backside (second cube is missing from sim)
      }
      , 
      {
        77, 39, 46, 33, 26  // Pandaboard G, structural channel 15
      }
      , 
      {
        44, 53, 42, 43, 41  // Pandaboard H, structural channel 16, last cube busted?
      }
    };
  }

  public int[][] buildFlippedRGBList() {
    if (true) {
      return new int[][] {};
    }
        
    // syntax is {cube #, strip #, strip #, . . . }
    return new int[][] { 
      {
        22, 4, 7
      }
      , 
      {
        50, 1, 3
      }
      , 
      {
        7, 1, 2, 11
      }
      , 
      {
        49, 1
      }
      , 
      {
        39, 1
      }
      , 
      {
        41, 1
      }
      , 
      {
        26, 3, 5
      }
      , 
      {
        64, 1
      }
      , 
      {
        32, 2
      }
      , 
      {
        20, 6, 7
      }
      , 
      {
        19, 1, 2
      }
      , 
      {
        15, 6, 8, 9
      }
      , 
      {
        29, 3, 10
      }
      , 
      {
        68, 4, 9
      }
      , 
      {
        18, 12
      }
      , 
      {
        6, 2, 4
      }
      , 
      {
        78, 11
      }
      , 
      {
        56, 2
      }
      , 
      {
        57, 3
      }
      , 
      {
        74, 6, 7
      }
      , 
      {
        21, 10
      }
      , 
      {
        37, 11
      }
      , 
      {
        61, 5
      }
      , 
      {
        33, 12
      }
    };
  }
}

