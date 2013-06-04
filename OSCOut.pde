import netP5.*;
import oscP5.*;
class OSCOut
{
	protected NetAddress bone_front = new NetAddress("192.168.1.28", 9001);
	protected NetAddress bone_rear = new NetAddress("192.168.1.29", 9001);
	protected Serialize _serializer;
	protected OscP5 oscP5;
	protected OscMessage msg;
	protected byte[] msgarr = new byte[4*352];
	protected ArrayList[][][] pointMap = new ArrayList[128][256][128];

	public OSCOut(Serialize serializer)
	{
		_serializer= serializer;
		start();
	}

	public void sendToBoards()
	{
	  
	    createAndSendMsg(bone_front, _serializer.mappedPointListFront, _serializer.masterFlippedFront);
	    createAndSendMsg(bone_rear, _serializer.mappedPointListRear, _serializer.masterFlippedRear);
	  
	}

	public byte unsignedByte( int val ) 
	{
		  return (byte)( val > 127 ? val - 256 : val );
	}

	public void createAndSendMsg(NetAddress _bone, ArrayList<Point> _mappedPointList, ArrayList<Boolean> _masterFlipped) 
	{
	  int size = 0;
	  int msgnum = 0;
	  

	  for (int i=0; i<msgarr.length; i++) 
	  {
	    msgarr[i] = 0;
	  }


	  for (int i=0; i<_mappedPointList.size(); i++) {
	    Point p = _mappedPointList.get(i);

	    // LOGIC TO SEE IF POINT IS RGB FLIPPED
	    if ( _masterFlipped.get(i)==false ) { 
	    //BEN TODO RECREATE
	      //IF FLIPPED, DO THIS
	      //mp.r=p.b;
	      //mp.g=p.g;
	      //mp.b=p.r;
	      //      print("Flipped at linear point: ");println(i);
	    }
	    else {
	      //IF NORMAL, DO THIS
	      //BEN TODO RECREATE
	      //mp.r=p.r;
	      //mp.g=p.g;
	      //mp.b=p.b;
	    }

	    msgarr[size++]=unsignedByte((int)(0));
	    //BEN TODO RECREATE
	    //msgarr[size++]=unsignedByte((int)(mp.r*255));
	    //msgarr[size++]=unsignedByte((int)(mp.g*255));
	    //msgarr[size++]=unsignedByte((int)(mp.b*255));

	    if (size>=msgarr.length || i>=_mappedPointList.size()-1) { // JAAAAAAAAANK
		      msg.clearArguments();
		      msg.add(msgnum++);
		      msg.add(msgarr.length);
		      msg.add(msgarr);
	      try { 
	        oscP5.send(msg, _bone);
	      } 
	      catch (Exception e) {
	      } // ignore
	      size=0;
	    }
	  }
	}

	public void start()
	{
		oscP5 = new OscP5(this, 9000);
	}
}