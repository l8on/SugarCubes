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
  final float CW = Cube.EDGE_WIDTH ;

  
  
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

  // To-Do:  (Mark Slee, Alex Green, or Ben Morrow):   The Cube # is determined by the order in this list.
  // "raw object index" is serialized by running through towermapping and then individual cube mapping below.
  //  We can do better than this.  The raw object index should be obvious from the code-- looking through the
  //  rendered simulation and counting through cubes in mapping mode is grossly inefficient. 

  TowerMapping[] towerCubes = new TowerMapping[] {};
  
  // Single cubes can be constructed directly here if you need them
  Cube[] singleCubes = new Cube[] {
    // new Cube(15, int( Cube.EDGE_HEIGHT), 39, 0, 10, 0,  WRL),     // Back left channel behind speaker
     //new Cube(x, y, z, rx, ry, rz, wiring),
   //new Cube(0,0,0,0,225,0, WRR),
  };

  // The bass box!
  // BassBox bassBox = BassBox.unlitBassBox(BBX, 0, BBZ); // frame exists, no lights
     BassBox bassBox = BassBox.noBassBox(); // no bass box at all
  // BassBox bassBox = new BassBox(BBX, 0, BBZ); // bass box with lights
 
  // The speakers!
  List<Speaker> speakers = Arrays.asList(new Speaker[] {
     // Each speaker parameter is x, y, z, rotation, the left speaker comes first
     // new Speaker(TRAILER_WIDTH - Speaker.EDGE_WIDTH + 8, 6, 3, -15)
  });


  ////////////////////////////////////////////////////////////////////////
  // dan's proposed lattice
        ArrayList<StaggeredTower> scubes = new ArrayList<StaggeredTower>();
        if (NumBackTowers != 11) exit();
        // for (int i=0; i<NumBackTowers; i++) scubes.add(new StaggeredTower(
        //           (i+1)*CW,                                                                 // x
        //           (i % 2 == 0) ? 0 : CH * 2./3.                ,   // y
        //          - ((i % 2 == 0) ? 0 : 11) + 97          ,   // z
        //          225, (i % 2 == 0) ? MaxCubeHeight : MaxCubeHeight-1) );         // num cubes
        
        ArrayList<Cube> dcubes = new ArrayList<Cube>();
        // for (int i=1; i<6; i++) {
        //         if (i>1) dcubes.add(new Cube(-6+CW*4/3*i             , 0, 0, 0, 0, 0, WRR));        
        //                          dcubes.add(new Cube(-6+CW*4/3*i+CW*2/3., CH*.5, 0, 0, 0, 0, WRR));        
        // }

float current_x_position = 0;
scubes.add(new StaggeredTower(//tower 1
      current_x_position,               // x
       15   ,   // y
       0  ,   // z
     45, 6, new Cube.Wiring[] { WFL, WRR, WFL, WRR, WFL, WRR}) );
current_x_position += 25.25;
scubes.add(new StaggeredTower(// tower 2
      current_x_position,               // x
       0  ,   // y
       -10.5   ,   // z
     45, 6, new Cube.Wiring[] { WFR, WFL, WRR, WRR, WFL, WRR}) );
current_x_position += 25.25;
scubes.add(new StaggeredTower(//tower 3
      current_x_position,               // x
       15   ,   // y
       0,   // z
     45, 6, new Cube.Wiring[] { WRR, WFL, WRR, WRR, WFL, WRR}) );
current_x_position += 25.25;
scubes.add(new StaggeredTower(//tower 4
    current_x_position,               // x
       0,   // y
       -10.5  ,   // z
     45, 6, new Cube.Wiring[] { WFL, WRR, WFL, WRR, WFL, WRR}) );
current_x_position += 28;
scubes.add(new StaggeredTower(//tower 5
      current_x_position,               // x
       15   ,   // y
       -4.5 ,   // z
     45, 6, new Cube.Wiring[] { WRR, WFL, WRR, WFL, WRR, WFL}) );
current_x_position += 28;
scubes.add(new StaggeredTower(//tower 6
      current_x_position,               // x
       0 ,   // y
       -10.5,   // z
     45, 6, new Cube.Wiring[] { WFL, WRR, WFL, WRR, WFL, WRR}) );
current_x_position += 25.25;
scubes.add(new StaggeredTower(// tower 7
      current_x_position,               // x
       15   ,   // y
      0,   // z
     45, 6, new Cube.Wiring[] { WRR, WFL, WRR, WFL, WRR, WFL}) );
current_x_position += 25.25;     
scubes.add(new StaggeredTower(//tower 8
      current_x_position,               // x
       0  ,   // y
       -10.5 ,   // z
     45, 6, new Cube.Wiring[] { WFL, WRR, WFL, WRR, WFL, WRR}) );
current_x_position += 25.25;
scubes.add(new StaggeredTower(//tower 9
      current_x_position,               // x
       15   ,   // y
       0,   // z
     45, 6, new Cube.Wiring[] { WFL, WRR, WFL, WRR, WFL, WRR}) );
current_x_position += 25.25;

//TOWERS ON DANCE FLOOR
scubes.add(new StaggeredTower(//tower 10
      83.75+39+43-124.5,   // x
      0,   // y
       -47.5-43,   // z
     0,  4, new Cube.Wiring[]{ WRR, WFL, WRR, WFL})  ); 
scubes.add(new StaggeredTower(//tower 11
      83.75,   // x
       0,   // y
       -47.5,   // z
     0,  4, new Cube.Wiring[]{ WFL, WRR, WFL, WRR})  );  
scubes.add(new StaggeredTower(//tower 12
      83.75+39,   // x
       0,   // y
       -47.5,   // z
     0,  4, new Cube.Wiring[]{ WRR, WFL, WRR, WFL})  ); 
scubes.add(new StaggeredTower(//tower 13
       83.75+39+43,   // x
       0,   // y
       -47.5-43,   // z
     0,  4, new Cube.Wiring[]{ WRR, WFL, WRR, WFL})  ); 

// scubes.add(new StaggeredTower(// Single cube on top of tower 4
//       42,               // x
//        112   ,   // y
//          72,   // z
//      -10,  1, new Cube.Wiring[]{ WRL})  );  







  //////////////////////////////////////////////////////////////////////
  //      BENEATH HERE SHOULD NOT REQUIRE ANY MODIFICATION!!!!        //
  //////////////////////////////////////////////////////////////////////

  // These guts just convert the shorthand mappings into usable objects
  ArrayList<Tower> towerList = new ArrayList<Tower>();
  ArrayList<Cube> tower;
  Cube[] cubes = new Cube[100];
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

  
  for (Cube cube : singleCubes) cubes[cubeIndex++] = cube;
  for (Cube cube : dcubes)                 cubes[cubeIndex++] = cube;
for (StaggeredTower st : scubes) {
    tower = new ArrayList<Cube>();
    for (int i=0; i < st.n; i++) {
      Cube.Wiring w = (i < st.wiring.length) ? st.wiring[i] : WRR;
      tower.add(cubes[cubeIndex++] = new Cube(st.x, st.y + CH* 4/3.*i, st.z, 0, st.r, 0, w));
    }
    towerList.add(new Tower(tower));
  }

  return new Model(towerList, cubes, bassBox, speakers);
}

/**
 * This function maps the panda boards. We have an array of them, each has
 * an IP address and a list of channels.
 */
public PandaMapping[] buildPandaList() {
  final int LEFT_SPEAKER = 0;
  final int RIGHT_SPEAKER = 1;
  
  // 8 channels map to:  3, 4, 7, 8, 13, 14, 15, 16.
  return new PandaMapping[] {
    new PandaMapping(
      "10.200.1.28", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 16, 17, 18}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1, 2, 3}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 4, 5, 6}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 7, 8, 9}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 10, 11, 12}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 13, 14, 15}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
    }),
    new PandaMapping(
      "10.200.1.29", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 34, 35, 36}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 19, 20, 21}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 22, 23, 24}), 
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 25, 26, 27}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 28, 29, 30}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 31, 32, 33}),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
    }),    
    new PandaMapping(
      "10.200.1.30", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }), // 30 J3 *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),  // 30 J4 //ORIG *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 37, 38, 39}),                // 30 J7 *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 40, 41, 42}),  // 30 J8 *
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 43, 44, 45}),                // 30 J13 (not working)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 46, 47, 48}),                // 30 J14 (unplugged)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 49, 50, 51}),                // 30 J15 (unplugged)
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 52, 53, 54}), // 30 J16
   }),    
     new PandaMapping(
       "10.200.1.31", new ChannelMapping[] {
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),       // J3 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),       // J4
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 55, 56}), // 30 J7 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 57, 58}), //  J8 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 59, 60}),           // J13 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 61, 62}),                // 30 J14 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 63, 64}),                //  J15
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 65, 66}),              //  J16
     }),
     new PandaMapping(
       "10.200.1.32", new ChannelMapping[] {
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),       // J3 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),       // J4
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 67, 68}), // 30 J7 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 69, 70}), //  J8 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),           // J13 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),                // 30 J14 
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),                //  J15
         new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),              //  J16
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
    this(dx, dz, 0., wiring);
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

class StaggeredTower {
  public final float x, y, z, r;
  public final int n;
  public final Cube.Wiring[] wiring;
  StaggeredTower(float _x, float _y, float _z, float _r, int _n) { this(_x, _y, _z, _r, _n, new Cube.Wiring[]{}); }
  StaggeredTower(float _x, float _y, float _z, float _r, int _n, Cube.Wiring[] _wiring) { x=_x; y=_y; z=_z; r=_r; n=_n; wiring=_wiring;}
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
        throw new RuntimeException("Invalid speaker channel mapping: " + speakerIndex);
      }
    } else if ((mode == MODE_STRUTS_AND_FLOOR) || (mode == MODE_BASS) || (mode == MODE_NULL)) {
      if (rawObjectIndices.length > 0) {
        throw new RuntimeException("Bass/floor/null mappings cannot specify object indices");
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