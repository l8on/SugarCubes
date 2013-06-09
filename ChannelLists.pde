public class ChannelLists
{
	// Ordered lists of cubes on ordered channels
	public ChannelLists()
	{
		  // there are five cubes per channel (A,B,C,D)
	}
	
	public int[][] getFrontChannelList()
	{
	  	int[][] frontChannelList = {
		    {
		      1, 57, 56, 55, 0  // Pandaboard A, structural channel 1
		    }
		    , 
		    {
		      30, 31, 32, 17, 3  // Pandaboard B, structural channel 2
		    }
		    , 
		    {
		      20, 21, 15, 19, 0  // Pandaboard C, structural channel 3
		    }
		    , 
		    {
		      69, 75, 74, 76, 73  // Pandaboard D, structural channel 4
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

    	return frontChannelList;
  }

  public int[][] getRearChannelList()
  {
	  	int[][] rearChannelList = {
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
		      64, 75, 72, 49, 50  // Pandaboard F, structural channel 14, right top backside
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
  
  		return rearChannelList;
	}
}