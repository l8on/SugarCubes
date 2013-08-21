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
  
  final float CH = Cube.EDGE_HEIGHT;
  
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
  TowerMapping[] towerCubes = new TowerMapping[] {
    
    // DJ booth, from left to right
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
    new TowerMapping(BBX, BBY, BBZ, new CubeMapping[] {
      new CubeMapping(104.75, 0, -27, WRL),
      new CubeMapping(8, -15, 10, WFL),      
    }),    
    
  };
  
  // Single cubes can be constructed directly here if you need them
  Cube[] singleCubes = new Cube[] {
    // new Cube(x, y, z, rx, ry, rz, wiring),
  };

  // The bass box!
  BassBox bassBox = new BassBox(BBX, 0, BBZ);

  // The speakers!
  List<Speaker> speakers = Arrays.asList(new Speaker[] {
    new Speaker(-12, 6, 0, 15),
    new Speaker(TRAILER_WIDTH - Speaker.EDGE_WIDTH + 8, 6, 3, -15)
  });

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

  return new Model(towerList, cubes, bassBox, speakers);
}

public PandaMapping[] buildPandaList() {
  return new PandaMapping[] {
    new PandaMapping(
      "10.200.1.29", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 1, 2, 3, 4 }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 5, 6, 7, 8 }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { 9, 10 }),
        new ChannelMapping(ChannelMapping.MODE_BASS),
        new ChannelMapping(ChannelMapping.MODE_FLOOR),
        new ChannelMapping(ChannelMapping.MODE_SPEAKER, 0),
        new ChannelMapping(ChannelMapping.MODE_SPEAKER, 1),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
    }),

    new PandaMapping(
      "10.200.1.28", new ChannelMapping[] {
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),        
        new ChannelMapping(ChannelMapping.MODE_CUBES, new int[] { }),
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
  public final static int CHANNELS_PER_BOARD = 13;
  
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
 * Each channel on a pandaboard can be mapped in a number of modes. The typial is
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
  public static final int MODE_FLOOR = 4;
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
    } else if ((mode == MODE_FLOOR) || (mode == MODE_BASS) || (mode == MODE_NULL)) {
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

