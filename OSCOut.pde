import netP5.*;
import oscP5.*;
import glucose.model.Point;
import java.util.Arrays;
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

	/*public byte unsignedByte( int val ) 
	{
		  return (byte)( val > 127 ? val - 256 : val );
	}*/

	public void createAndSendMsg(NetAddress _bone, ArrayList<Integer> _mappedPointList, ArrayList<Boolean> _masterFlipped) 
	{
	  int size = 1;
	  int msgnum = 0;
	  int mp;
	  int listSize=_mappedPointList.size();
 	  byte r,g,b;
	 
	 Arrays.fill(msgarr,(byte) 0);

	  for (int i=0; i < listSize; i++) 
	  {

	    int p = _mappedPointList.get(i);

	    msgarr[0] = (0 & 0xFF);
	    boolean unflipped = _masterFlipped.get(i);
	    msgarr[size++] = (byte) (unflipped ? ((p >> 16) & 0xFF) : (p & 0xFF));
	    msgarr[size++] = (byte) ((p >> 8) & 0xFF);
	    msgarr[size++] = (byte) (unflipped ? (p & 0xFF) : ((p >> 16) & 0xFF) );

	    if (size >= msgarr.length || i >= listSize-1) { // JAAAAAAAAANK
		      msg.clearArguments();
		      msg.add(msgnum++);
		      msg.add(msgarr.length);
		      msg.add(msgarr);
	      try { 
	        oscP5.send(msg, _bone);
	      } 
	      catch (Exception e) {
	      	//e.printStackTrace();
	      }
	      size=1;
	    }
	  }
	}

	public void start()
	{
		oscP5 = new OscP5(this, 9000);
	}
}