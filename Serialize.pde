class Serialize
{
	GLucose _glucose;

	public Integer zp;
	ArrayList<Point> pointList;
	ArrayList<Cube> cubes;
	
	protected int[][] flippedRGBList;

	ArrayList[][][] pointMap = new ArrayList[128][256][128];

	// These are the Viewport/Co-ordinate bounds
	float min_x=256*256;
	float max_x=-256*256;
	float min_y=256*256;
	float max_y=-256*256;
	float min_z=256*256;
	float max_z=-256*256;

	ArrayList<Point> mappedPointListRear = new ArrayList<Point>();
	ArrayList<Point> mappedPointListFront = new ArrayList<Point>();

	ArrayList<Boolean> masterFlippedFront = new ArrayList<Boolean>();
	ArrayList<Boolean> masterFlippedRear = new ArrayList<Boolean>();

	public Serialize(GLucose glucose)
	{
		_glucose=glucose;
		flippedRGBList=new FlippedRGBList().getFlippedRGBList();
		//BEN TODO RECREATE
		pointList = new ArrayList<Point>();
		//BEN TODO RECREATE
		cubes =  new ArrayList<Cube>();
	}
	public void processColors(int[] colors)
	{

	}

	public void createPointMap()
 	{
	    println("point map" + millis());
	    for (int x=0; x<128; x++) 
	    {
	      for (int y=0; y<256; y++) 
	      {
	        for (int z=0; z<128; z++) 
	        {
	        	//TODO BEN RECREATE IF NEEDED
	          pointMap[x][y][z] = new ArrayList<Point>();
	      	}
	      }
	    }
    }
    
	public void createPointMapStructure()
	{
        // there are five cubes per channel (A,B,C,D)
      // After five cubes of data on mappedpointlist, it starts sending points to the next channel

      // If you need a blank cube, then add this for each cube that needs to be blank.
      // for(int i=0; i<(16*3*4); i++) { mappedPointListFront.add(zp);}

   for (int i=0; i<pointList.size(); i++) 
   {
   	
    Point p = (Point)pointList.get(i);
    
    float fx, fy, fz;
	//TODO BEN =0.0; is temp initialize hack
    fx=fy=fz=0.0;
    //TODO BEN MUST RECREATE
    //fx = (p.x + abs(min_x));
    fx/=(max_x+abs(min_x));
    fx*=127;

    //TODO BEN MUST RECREATE
    //fy = p.y + abs(min_y);
    fy/=(max_y+abs(min_y));
    fy*=255;

    //TODO BEN MUST RECREATE
    //fz = (p.z + abs(min_z));
    fz/=(max_z+abs(min_z));
    fz*=127;

    ////TODO BEN MUST RECREATE
    /*p.fx=fx;
    p.fy=fy;
    p.fz=fz;*/

    int ix = (int)floor(fx);
    int iy = (int)floor(fy);
    int iz = (int)floor(fz);
    
    //TODO BEN RECREATE
    //p.ix=ix;
    //p.iy=iy;
    //p.iz=iz;

    //pointMap[ix][iy][iz].add(p);

    //these used to be valuable data structures, but it's better to do
    //the inverse -- iterate across just 17,000 points, and grab
    //from the static arrays.  however the ADDRESSES are nice.

    //volume[ix][iy][iz].add(p);
    //surface[iz][iy].add(p);
  }
 }

	public void createMappedPointList(int[][] _channelList, ArrayList<Integer> _mappedPointList) {
		  for ( int[] channel : _channelList ) {
		    for ( int cubeNumber : channel ) {
		      if ( cubeNumber == 0 ) {  // if no cube is present at location
		        for (int i=0; i<(16*3*4); i++) 
		        { 
		          _mappedPointList.add(zp);
		        }
		      }
		      else {
		      	//TODO BEN RECREATE
		        /*for (Integer p: cubes.get(cubeNumber).points) { 
		          _mappedPointList.add(p);
		        }*/
		      }
		    }
		  }
		}
	
	public void createFlippedPointList( int[][] _channelList, int[][] _flippedRGBlist, int _mappedPointListSize, ArrayList<Boolean> _masterFlipped ) 
	{
	  
	  ArrayList<Integer> linearChannelList = new ArrayList<Integer>();
	  ArrayList<Integer> flippedStripList = new ArrayList<Integer>();
	  ArrayList<Integer> flippedPointList = new ArrayList<Integer>();
		  
		  // creates linear list of cubes from channel list
		  for ( int[] channel : _channelList ) {
		    for ( int cubeNum : channel ) {
		      linearChannelList.add(cubeNum);
		    }
		  }
		  
		    // creates list of flipped strips
		  for ( int[] cubeInfo : _flippedRGBlist ) {
		    int cubeNumber = cubeInfo[0];    // picks out the cube number
		    if ( linearChannelList.contains(cubeNumber) ) {
		      int indexofcube = linearChannelList.indexOf(cubeNumber);
		      // cycle through strips in list
		      for (int i=1; i<cubeInfo.length; i++) {
		        flippedStripList.add( indexofcube*12 + cubeInfo[i] );     //finds strip number of flipped strip in linear array of strips (starts from 1)
		      }
		    }
		  }

		  // creates list of flipped points
		  for ( int stripNum: flippedStripList ) {
		    for (int pointNumInStrip = 1; pointNumInStrip <= 16; pointNumInStrip++) {
		      flippedPointList.add( 16*(stripNum-1) + pointNumInStrip );    //adds all flipped points to a list, starts from point 1 on strip 1
		    }
		  }
		  

		  //creates a boolean array of size equal to mappedPointList, true means colors RGB, false means BGR
		  for (int i = 0; i < _mappedPointListSize; i++) {
		    if ( flippedPointList.contains(i+1) ) { // do this because flippedPointList starts with point index 1
		      _masterFlipped.add(false);
		    }
		    else {
		      _masterFlipped.add(true);
		    }
		  }  
		}


}