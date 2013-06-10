import java.util.List;
import glucose.model.Cube;
import glucose.model.Model;
import glucose.model.Point;
class Serialize
{
	GLucose _glucose;

	public Cube[] cubes;
	
	protected int[][] flippedRGBList;

	ArrayList<Integer> mappedPointListRear = new ArrayList<Integer>();
	ArrayList<Integer> mappedPointListFront = new ArrayList<Integer>();

	ArrayList<Boolean> masterFlippedFront = new ArrayList<Boolean>();
	ArrayList<Boolean> masterFlippedRear = new ArrayList<Boolean>();

	ChannelLists channelLists = new ChannelLists();

	int[][] frontChannelList;
	int[][] rearChannelList;


	public Serialize(GLucose glucose)
	{
		_glucose = glucose;
		//println(glucose.model == null);
		cubes = _glucose.model._cubes;
		setupChannelData();
	}
	public void setupChannelData()
	{
		
		frontChannelList = channelLists.getFrontChannelList();
		rearChannelList = channelLists.getRearChannelList();

		// Creates linear point array, ordered as sent to Pandaboard

		flippedRGBList = new FlippedRGBList().getFlippedRGBList();

		
	}
	public void processColors(int[] colors)
	{
		mappedPointListFront.clear();
		mappedPointListRear.clear();
		masterFlippedFront.clear();
		masterFlippedRear.clear();

		createMappedPointList(frontChannelList, mappedPointListFront, colors);
		createMappedPointList(rearChannelList, mappedPointListRear, colors);

		createFlippedPointList( frontChannelList, flippedRGBList, mappedPointListFront.size(), masterFlippedFront );
	  	createFlippedPointList( rearChannelList, flippedRGBList, mappedPointListRear.size(), masterFlippedRear );

	}


	public void createMappedPointList(int[][] _channelList, ArrayList<Integer> _mappedPointList, int[] colors) {
		  for ( int[] channel : _channelList ) {
		    for ( int cubeNumber : channel ) {
		      if ( cubeNumber == 0 ) {  // if no cube is present at location
		        for (int i=0; i<(16*3*4); i++) 
		        { 
		          _mappedPointList.add(0);
		        }
		      }
		      else {
		        for (Point p: cubes[cubeNumber].points) { 
		          _mappedPointList.add(colors!=null ? colors[p.index] : 0);
		        }
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
		        flippedStripList.add( indexofcube * 12 + cubeInfo[i] );     //finds strip number of flipped strip in linear array of strips (starts from 1)
		      }
		    }
		  }

		  // creates list of flipped points
		  for ( int stripNum: flippedStripList ) {
		    for (int pointNumInStrip = 1; pointNumInStrip <= 16; pointNumInStrip++) {
		      flippedPointList.add( 16 * (stripNum - 1) + pointNumInStrip );    //adds all flipped points to a list, starts from point 1 on strip 1
		    }
		  }
		  

		  //creates a boolean array of size equal to mappedPointList, true means colors RGB, false means BGR
		  for (int i = 0; i < _mappedPointListSize; i++) {
		    if ( flippedPointList.contains(i + 1) ) { // do this because flippedPointList starts with point index 1
		      _masterFlipped.add(false);
		    }
		    else {
		      _masterFlipped.add(true);
		    }
		  }  
		}


}