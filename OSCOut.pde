import netP5.*;
import oscP5.*;
import glucose.model.Point;
class OSCOut
{
	protected NetAddress bone_front = new NetAddress("192.168.1.28", 9001);
	protected NetAddress bone_rear = new NetAddress("192.168.1.29", 9001);
	protected Serialize _serializer;
	protected OscP5 oscP5;
	protected OscMessage msg;
	protected byte[] msgarr = new byte[4*352];

	public OSCOut(Serialize serializer)
	{
		_serializer= serializer;
		msg = new OscMessage("/shady/pointbuffer"); 
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

	public void createAndSendMsg(NetAddress _bone, ArrayList<Integer> _mappedPointList, ArrayList<Boolean> _masterFlipped) 
	{
	  int size = 0;
	  int msgnum = 0;
	  int mp;

	  for (int i=0; i<msgarr.length; i++) 
	  {
	    msgarr[i] = 0;
	  }

	  for (int i=0; i<_mappedPointList.size(); i++) {
	    Integer p = _mappedPointList.get(i);
	    byte r,g,b;
	    // LOGIC TO SEE IF POINT IS RGB FLIPPED
	    if ( _masterFlipped.get(i)==false ) { 
	      //IF FLIPPED, DO THIS
		      r = (byte) (p & 0xFF);
		      g = (byte) ((p >> 8) & 0xFF);
		      b = (byte) ((p >> 16) & 0xFF);

	      //print("Flipped at linear point: ");println(i);
	    }
	    else {
		      r = (byte) ((p >> 16) & 0xFF);
		      g = (byte) ((p >> 8) & 0xFF);
		      b = (byte) (p & 0xFF);
	    }

	    msgarr[size++]=unsignedByte((int)(0));
	    
	    msgarr[size++]=unsignedByte((int)(r));
	    msgarr[size++]=unsignedByte((int)(g));
	    msgarr[size++]=unsignedByte((int)(b));

	    if (size>=msgarr.length || i>=_mappedPointList.size()-1) { // JAAAAAAAAANK
		      msg.clearArguments();
		      msg.add(msgnum++);
		      msg.add(msgarr.length);
		      msg.add(msgarr);
	      try { 
	        oscP5.send(msg, _bone);
	      } 
	      catch (Exception e) {
	      	e.printStackTrace();
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