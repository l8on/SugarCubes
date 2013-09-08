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

  
  // Shorthand helpers for specifying wiring more quickly
  final Cube.Wiring WFL = Cube.Wiring.FRONT_LEFT;
  final Cube.Wiring WFR = Cube.Wiring.FRONT_RIGHT;
  final Cube.Wiring WRL = Cube.Wiring.REAR_LEFT;
  final Cube.Wiring WRR = Cube.Wiring.REAR_RIGHT;
  
  // Utility value if you need the height of a cube shorthand
  final float CH = Cube.EDGE_HEIGHT;
  
  // Positions for the bass box
  final float BBY = BassBox.EDGE_HEIGHT + BoothFloor.PLEXI_WIDTH;
  final float BBX = 56;
  final float BBZ = 2;


  // The model is represented as an array of towers. The cubes in the tower
  // are represenented relatively. Each tower has an x, y, z reference position,
  // which is typically the base cube's bottom left corner.
  //
  // Following that is an array of floats. A 2-d array contains an x-offset
  // and a z-offset from the previous reference position. Typically the first cube
  // will just be {0, 0}. Each successive cube uses the position of the previous
  // cube as its reference.
  //
  // A 3-d array contains an x-offset, a z-offset, and a rotation about the
  // y-axis.
  //
  // The cubes automatically increment their y-position by Cube.EDGE_HEIGHT.

  // To-Do:  (Mark Slee, Alex Green, or Ben Morrow):   The Cube # is determined by the order in this list.  "raw object index" is serialized by running through towermapping and then individual cube mapping below.
  //  We can do better than this.  The raw object index should be obvious from the code-- looking through the rendered simulation and counting through cubes in mapping mode is grossly inefficient. 
  TowerMapping[] towerCubes = new TowerMapping[] {
    
   
  
   //back left cubes: temp Channel 1 
  new TowerMapping(0, 3*Cube.EDGE_HEIGHT, 72, new CubeMapping[] {
      new CubeMapping(0, 14,  -45 , WRL), // #1
      new CubeMapping(10, -12, -20, WFL), //#2
      new CubeMapping(5, 9, 45, WRR),  //#3
     
      
    }),
    //back left cube tower: Channel 2 
    new TowerMapping(0, Cube.EDGE_HEIGHT, 70, new CubeMapping[] {
     new CubeMapping(18, -2.5, 45, WRL),  //#4
     new CubeMapping(15, -6, 45, WFR),  //#5
      new CubeMapping(-6 , 7, 5,  WRR),  //#6
      new CubeMapping(18, 11, -5, WFL)
     
   }),
    
     //second from left back tower: Channel 3
      new TowerMapping(31, Cube.EDGE_HEIGHT, 73.5, new CubeMapping[] {
       new CubeMapping( 12.5, 5.5 , 10 , WRR),
       new CubeMapping( 16.5, 2.5 , 30, WRR),
      new CubeMapping( 16.5, 3, 10, WRR),
      new CubeMapping(.5, 4.5, -10 , WFL)
    } ), 
    
          //center tower,  Channel 4
     new TowerMapping(106, Cube.EDGE_HEIGHT, 84, new CubeMapping[] {
       new CubeMapping( -3.5, -2, 10, WFL),
       new CubeMapping( -11, 5, 30, WFR),
      new CubeMapping( 13.5, 2, 15, WRR),
      new CubeMapping(20.75, -4, 35 , WRL)
    } ), 
    
        //second from back right tower,  Channel 5
   
    new TowerMapping(160, Cube.EDGE_HEIGHT, 78, new CubeMapping[] {
       new CubeMapping( -31.5, -.5 , 5 , WFR),
       new CubeMapping( 7, -.5, 60, WRL),
      new CubeMapping( -5.5, -3, 0, WFR),
      new CubeMapping(22 , 2 , 30 , WRL)
    }), 
     
    
  //back right cubes: temp Channel 6
   new TowerMapping(201, Cube.EDGE_HEIGHT, 72, new CubeMapping[] {
     new CubeMapping(7.5, 6, 25, WRL),
     new CubeMapping(-4.5, -0.5, 18, WFR),
      new CubeMapping(8.5, .5, 30,  WRL),
      new CubeMapping(-7, -14, 10, WFR)
     
   }),

    
   
   
         
       //tower to the right of BASS BOX
     new TowerMapping (192, Cube.EDGE_HEIGHT, 40, new CubeMapping[] {
       new CubeMapping(-6, 4, -10, WRL), 
       new CubeMapping(5 ,5 , 5, WFR ), 
       new CubeMapping(-2, .5 , -3, WFL), 
       new CubeMapping(-10, 5.5 , -20, WRR )
     }),
     
     //end right tower in middle, right of previous tower
      //new TowerMapping (214, Cube.EDGE_HEIGHT, 37, new CubeMapping[] {
       //new CubeMapping(10,0 ,  50, WRR), 
       //new CubeMapping(5 ,5 , 65, WFL)
     //}),
//    // DJ booth, from back left to back right

 new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(3, 28, 3, WFL),
      new CubeMapping(-4, -8, 10, WFR),
      new CubeMapping(-15, 8, 40, WFR)
     
      
    }),

    
 
    new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(-7.25, 7.5, -25, WFR),
      new CubeMapping(7.5, -15.75, 12, WRL),
     
      
    }),
    new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(19.625, 5.375, -22, WFR),
      new CubeMapping(8, -14.5, 10, WRR),
    }),
    new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(48, 4.75, -35, WRL),
      new CubeMapping(8, -15, 10, WRR),
    }),
    new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(78.75, 3.75, -28, WRR),
      new CubeMapping(8, -15, 10, WRR),
    }),
    
    // next two are right DJ channel
    
   new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(105, 20.5, 20, WRR),
      new CubeMapping(6, -6, 30, WFR),
   }),
   
      new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(104.75, 0, -27, WRL),
      new CubeMapping(8, -15, 10, WFL),      
    }),    
    
   
  };
  
  // Single cubes can be constructed directly here if you need them
  Cube[] singleCubes = new Cube[] {
    //back left channel behind speaker
    new Cube(15, int( Cube.EDGE_HEIGHT), 39, 0, 10, 0,  WRL), 
    
   
    
    // Top left Channel Above DJ booth
    
    //new Cube(35, int(5*Cube.EDGE_HEIGHT ),  52, 0, 10, 0, WRR), 
    //new Cube(56, int(5*Cube.EDGE_HEIGHT ),  69, 0, 10, 0, WFL), 
    //new Cube(76, int(5*Cube.EDGE_HEIGHT ),  61, 0, -45, 0, WRL), 
    
    //next channel to the right, same height
     //new Cube(85, int(5*Cube.EDGE_HEIGHT ),  77, 0, 20, 0, WRL), 
     //new Cube(92, int(6*Cube.EDGE_HEIGHT ),  63, 0,20, 0, WRR), 
     //new Cube(86, int(6*Cube.EDGE_HEIGHT ),  47, 0, -45, 0, WRL), 
     //new Cube(123, int(6*Cube.EDGE_HEIGHT ),  31, 0, 20, 0, WFR), 
     
     // next channel to right, same height
     //new Cube(111, int(5*Cube.EDGE_HEIGHT ),  79, 0, 30, 0, WRL), 
     //new Cube(125, int(6*Cube.EDGE_HEIGHT ),  76, 0,27, 0, WRL), 
     //new Cube(144, int(5*Cube.EDGE_HEIGHT ),  44, 0, 45, 0, WRR), 
     //new Cube(134, int(5*Cube.EDGE_HEIGHT ),  42, 0, 45, 0, WRL), 
     
     //next channel to right
      new Cube(185, int(4*Cube.EDGE_HEIGHT ),  73, 0, -45, 0, WRR), 
     //new Cube(170, int(5*Cube.EDGE_HEIGHT ),  58, 0,40, 0, WRL), 
     //new Cube(158, int(6*Cube.EDGE_HEIGHT ),  34, 0, 40, 0, WFR), 
     //new Cube(130, int(6*Cube.EDGE_HEIGHT ),  10, 0, -5, 30, WRL), 
     
     //next channel highest to the right
      //new Cube(203, int(5*Cube.EDGE_HEIGHT ),  55, 0, 35, 0, WRR), 
     //new Cube(174, int(5*Cube.EDGE_HEIGHT ),  32, 0,35, 0, WFR), 
     //new Cube(178, int(6.5*Cube.EDGE_HEIGHT ),  16, 0, 20 , 30, WRL), 
     //new Cube(212, int(6.5*Cube.EDGE_HEIGHT ), 23, 0, 20 ,30, WRR), 
     
    //last channel
     //new Cube(204, int(5*Cube.EDGE_HEIGHT ),  28, 0, 25, 0, WFR), 
     ///new Cube(185, int(6*Cube.EDGE_HEIGHT ),  38, 0,40, 0, WRR), 
    
   //new cubes above DJ deck

      new Cube(BBX + 78.5, BBY + 2*Cube.EDGE_HEIGHT, BBZ, 0, 10, 0, WRR), 
      new Cube(BBX + 49.5, BBY + 2*Cube.EDGE_HEIGHT, BBZ - 7, 0, 10, 0, WRR),
      new Cube(BBX + 13, BBY + 2*Cube.EDGE_HEIGHT, BBZ + 11, 0, -30, 0, WRL), 
      new Cube(BBX - 15, BBY + 2*Cube.EDGE_HEIGHT, BBZ + 30, 0, -35, 0, WRR), 
       
      // new cubes above DJ deck at crazy angles
      new Cube(BBX - 5, BBY + 3*Cube.EDGE_HEIGHT, BBZ + 15.5, 0, -15, 0, WRL), 
      new Cube(BBX + 27, BBY + 3*Cube.EDGE_HEIGHT, BBZ + 12.5, 0, -18, -15, WRR),
      new Cube(BBX + 59, BBY + 3*Cube.EDGE_HEIGHT + 4, BBZ + 12.5, -12, 10, -10, WRL), 
      new Cube(BBX + 93, BBY + 3*Cube.EDGE_HEIGHT + 7, BBZ + 20.5, -15, 20, -35, WRR), 
       
       //new cubes on right side of DJ deck
      new Cube(161, BBY + 2*Cube.EDGE_HEIGHT, 15, 0, -40, 0, WFR), 
      new Cube(161, BBY + 3*Cube.EDGE_HEIGHT, 24, 0, -30, 0, WFL),
      new Cube(165, BBY + 4*Cube.EDGE_HEIGHT, 41, 0, 5, 0, WFR), 
      
       //new cubes top back left
      new Cube(BBX + 32, 5*Cube.EDGE_HEIGHT, BBZ + BassBox.EDGE_DEPTH + 7, 0, -25, 0, WFR), 
      new Cube(BBX + 5.5,  5*Cube.EDGE_HEIGHT, BBZ + BassBox.EDGE_DEPTH +7, 0, -25, 0, WFL),
      new Cube(BBX - 23,  5*Cube.EDGE_HEIGHT, BBZ + BassBox.EDGE_DEPTH + 11, 0, -25, 0, WFL), 
      new Cube(BBX - 33,  5*Cube.EDGE_HEIGHT + 8, BBZ +BassBox.EDGE_DEPTH- 29, 0, 10, 0, WFL), 
      
      //on top of previous channel
       new Cube(BBX + 22, 6*Cube.EDGE_HEIGHT, BBZ + BassBox.EDGE_DEPTH , 0, 5, 0, WRL), 
      new Cube(BBX + 27,  6*Cube.EDGE_HEIGHT - 13, BBZ + BassBox.EDGE_DEPTH- 25, 0, 3, -20, WRR),
      new Cube(BBX +5,  6*Cube.EDGE_HEIGHT - 13, BBZ + BassBox.EDGE_DEPTH -27, 0, 5, -15, WRL), 
      new Cube(BBX - 11,  6*Cube.EDGE_HEIGHT -1.5, BBZ +BassBox.EDGE_DEPTH - 11, 0, 30, 0, WRR), 
      
      //top center
       new Cube(BBX +37, 6*Cube.EDGE_HEIGHT, BBZ + BassBox.EDGE_DEPTH +13 , 0, 15, 0, WRR), 
      new Cube(BBX + 64,  6*Cube.EDGE_HEIGHT, BBZ + BassBox.EDGE_DEPTH + 25, 0, 15, 0, WFR),
      new Cube(BBX + 64,  6*Cube.EDGE_HEIGHT - 3, BBZ + BassBox.EDGE_DEPTH -4 , 0, 0, -30, WRL), 
      new Cube(BBX + 87.5,  6*Cube.EDGE_HEIGHT + 13, BBZ +BassBox.EDGE_DEPTH - 10, 0, 0, 0, WRL), 
      
      //top right
      new Cube(BBX + 76, 107.5, BBZ + BassBox.EDGE_DEPTH + 23, 0, -40, 0, WRR), 
      new Cube(BBX +  98, 129, BBZ + BassBox.EDGE_DEPTH - 5, 0, 10, 0, WRR),
      new Cube(BBX + 104,  107.5, BBZ + BassBox.EDGE_DEPTH + 17, 0, -35, 0, WRR), 
      new Cube(BBX + 129,  107.5, BBZ +BassBox.EDGE_DEPTH +10, 0, -35, 0, WFL), 
      
     new Cube(179, 4*Cube.EDGE_HEIGHT, BBZ + BassBox.EDGE_DEPTH + 14,0, -20, 0 , WFR)

    // new Cube(x, y, z, rx, ry, rz, wiring),
  };

  // The bass box!
  //BassBox bassBox = new BassBox(BBX, 0, BBZ);
  //test for Alex, should be commented out
 
  // The speakers!
  //List<Speaker> speakers = Arrays.asList(new Speaker[] {
    // each speaker parameter is x, y, z, rotation, the left speaker comes first
   // new Speaker(-12, 6, 0, 15),
   // new Speaker(TRAILER_WIDTH - Speaker.EDGE_WIDTH + 8, 6, 3, -15)
 // });

  //////////////////////////////////////////////////////////////////////
  //      BENEATH HERE SHOULD NOT REQUIRE ANY MODIFICATION!!!!        //
  //////////////////////////////////////////////////////////////////////

  // These guts just convert the shorthand mappings into usable objects
  ArrayList<Tower> towerList = new ArrayList<Tower>();
  ArrayList<Cube> tower;
  Cube[] cubes = new Cube[80];
  int cubeIndex = 1;  
  float px, pz, ny;
  for (TowerMapping tm : towerCubes) {
    px = tm.x;
    ny = tm.y;
    pz = tm.z;
    tower = new ArrayList<Cube>();
    for (CubeMapping cm : tm.cubeMappings) {
      tower.add(cubes[cubeIndex++] = new Cube(px = px + cm.dx, ny, pz = pz + cm.dz, 0, cm.ry, 0, cm.wiring));
      ny += Cube.EDGE_HEIGHT;
    }
    towerList.add(new Tower(tower));
  }
  for (Cube cube : singleCubes) {
    cubes[cubeIndex++] = cube;
  }

  return new Model(towerList, cubes, null, null);
}

/**
 * This function maps the panda boards. We have an array of them, each has
 * an IP address and a list of channels.
 */
public PandaMapping[] buildPandaList() {
  final int LEFT_SPEAKER = 0;
  final int RIGHT_SPEAKER = 1;
  
  return new PandaMapping[] {
    new PandaMapping(
    // 8 maps to:  3, 4, 7, 8, 13, 14, 15, 16.  So if it's J4, 
      "10.200.1.30", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 39,40,41,42 }),  //30 J3 *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 37, 38, 36, 35}),  //30 J4 //ORIG *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 20,21,22,23}),  //30 J7 *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 16, 17, 18, 19}), //30 J8 *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1,1,1,1}), //30 J13 (not working)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] {1,1,1,1}), //30 J14  (unplugged)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1,1,1,1 }), // 30 J15   (unplugged)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 53, 54, 55, 72}), // 30 J16
    }),
    new PandaMapping(
      "10.200.1.29", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1,1,1,1}), //29 J3  (not connected)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1, 1, 1, 1}), //29 J4  (not connected)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 28, 29, 30, 2}), // 29 J7
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 33,34,32,31}), //29 J8 //XXX   
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1, 1, 1, 1 }), //29 J13 //XX //bassbox  (not working)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1,1,1,1}), //29 J14  (not working)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] {12, 13, 14, 15 }),  //29 J15
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[]  {8,9,10,11 } ),  //29 J16
    }),    
    new PandaMapping(
      "10.200.1.28", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 60, 61, 62, 63 }), //28 J3
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 56, 57, 58, 59}), //28 J4
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 45,46,47,48 }), //28 J7
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[]  {24,25,26,27}), //28 J8
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 4,5,6,7}), //28 J13
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 64, 65, 66, 67 }), //28 J14
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 68, 69, 70, 71 }), //28 J15
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 49,50,51,52}), //28 J16
    }),    
  };  

}



class TowerMapping {
  public final float x, y, z;
  public final CubeMapping[] cubeMappings;
  
  TowerMapping(float x, float y, float z, CubeMapping[] cubeMappings) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.cubeMappings = cubeMappings;
  }
}

class CubeMapping {
  public final float dx, dz, ry;
  public final Cube.Wiring wiring;
  
  CubeMapping(float dx, float dz, Cube.Wiring wiring) {
    this(dx, dz, 0, wiring);
  }

  CubeMapping(float dx, float dz, float ry) {
    this(dz, dz, ry, Cube.Wiring.FRONT_LEFT);
  }
  
  CubeMapping(float dx, float dz, float ry, Cube.Wiring wiring) {
    this.dx = dx;
    this.dz = dz;
    this.ry = ry;
    this.wiring = wiring;
  }
}

/**
 * Each panda board has an IP address and a fixed number of channels. The channels
 * each have a fixed number of pixels on them. Whether or not that many physical
 * pixels are connected to the channel, we still send it that much data.
 */
class PandaMapping {
  
  // How many channels are on the panda board
  public final static int CHANNELS_PER_BOARD = 8;
  
  // How many total pixels on the whole board
  public final static int PIXELS_PER_BOARD = ChannelMapping.PIXELS_PER_CHANNEL * CHANNELS_PER_BOARD;
  
  final String ip;
  final ChannelMapping[] channelList = new ChannelMapping[CHANNELS_PER_BOARD];
  
  PandaMapping(String ip, ChannelMapping[] rawChannelList) {
    this.ip = ip;
    
    // Ensure our array is the right length and has all valid items in it
    for (int i = 0; i < channelList.length; ++i) {
      channelList[i] = (i < rawChannelList.length) ? rawChannelList[i] : new ChannelMapping();
      if (channelList[i] == null) {
        channelList[i] = new ChannelMapping();
      }
    }
  }
}

/**
 * Each channel on a pandaboard can be mapped in a number of modes. The typical is
 * to a series of connected cubes, but we also have special mappings for the bass box,
 * the speaker enclosures, and the DJ booth floor.
 *
 * This class is just the mapping meta-data. It sanitizes the input to make sure
 * that the cubes and objects being referenced actually exist in the model.
 *
 * The logic for how to encode the pixels is contained in the PandaDriver.
 */
class ChannelMapping {

  // How many cubes per channel xc_PB is configured for
  public final static int CUBES_PER_CHANNEL = 4;  

  // How many total pixels on each channel
  public final static int PIXELS_PER_CHANNEL = Cube.POINTS_PER_CUBE * CUBES_PER_CHANNEL;
  
  public static final int MODE_NULL = 0;
  public static final int MODE_CUBES = 1;
  public static final int MODE_BASS = 2;
  public static final int MODE_SPEAKER = 3;
  public static final int MODE_STRUTS_AND_FLOOR = 4;
  public static final int MODE_INVALID = 5;
  
  public static final int NO_OBJECT = -1;
  
  final int mode;
  final int[] objectIndices = new int[CUBES_PER_CHANNEL];
  
  ChannelMapping() {
    this(MODE_NULL);
  }
  
  ChannelMapping(int mode) {
    this(mode, new int[]{});
  }
  
  ChannelMapping(int mode, int rawObjectIndex) {
    this(mode, new int[]{ rawObjectIndex });
  }
  
  ChannelMapping(int mode, int[] rawObjectIndices) {
    if (mode < 0 || mode >= MODE_INVALID) {
      throw new RuntimeException("Invalid channel mapping mode: " + mode);
    }
    if (mode == MODE_SPEAKER) {
      if (rawObjectIndices.length != 1) {
        throw new RuntimeException("Speaker channel mapping mode must specify one speaker index");
      }
      int speakerIndex = rawObjectIndices[0];
      if (speakerIndex < 0 || speakerIndex >= glucose.model.speakers.size()) {
        //throw new RuntimeException("Invalid speaker channel mapping: " + speakerIndex);
      }
    } else if ((mode == MODE_STRUTS_AND_FLOOR) || (mode == MODE_BASS) || (mode == MODE_NULL)) {
      if (rawObjectIndices.length > 0) {
        //throw new RuntimeException("Bass/floor/null mappings cannot specify object indices");
      }
    } else if (mode == MODE_CUBES) {
      for (int rawCubeIndex : rawObjectIndices) {
        if (glucose.model.getCubeByRawIndex(rawCubeIndex) == null) {
          throw new RuntimeException("Non-existing cube specified in cube mapping: " + rawCubeIndex);
        }
      }
    }
    
    this.mode = mode;
    for (int i = 0; i < objectIndices.length; ++i) {
      objectIndices[i] = (i < rawObjectIndices.length) ? rawObjectIndices[i] : NO_OBJECT;
    }
  }
}
