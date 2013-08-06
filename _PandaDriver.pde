import netP5.*;
import oscP5.*;

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
 * This class implements the output function to the Panda Boards. It
 * will be moved into GLucose once stabilized.
 */
public class PandaDriver {

  // Address to send to
  private final NetAddress address;
  
  // OSC message
  private final OscMessage message;

  // List of point indices on the board
  private final int[] points;

  // Bit for flipped status of each point index
  private final boolean[] flipped;

  // Packet data
  private final byte[] packet = new byte[4*352]; // TODO: de-magic-number

  public PandaDriver(NetAddress address, Model model, int[][] channelList, int[][] flippedList) {
    this.address = address;
    message = new OscMessage("/shady/pointbuffer");
    List<Integer> pointList = buildMappedList(model, channelList);
    points = new int[pointList.size()];
    int i = 0;
    for (int value : pointList) {
      points[i++] = value;
    }
    flipped = buildFlippedList(model, flippedList);
  }

  private ArrayList<Integer> buildMappedList(Model model, int[][] channelList) {
    ArrayList<Integer> points = new ArrayList<Integer>();
    for (int[] channel : channelList) {
      for (int cubeNumber : channel) {
        if (cubeNumber == 0) {
          for (int i = 0; i < (Cube.FACES_PER_CUBE*Face.STRIPS_PER_FACE*Strip.POINTS_PER_STRIP); ++i) {
            points.add(0);
          }
        } else {
          Cube cube = model.getCubeByRawIndex(cubeNumber);
          if (cube == null) {
            throw new RuntimeException("Non-zero, non-existing cube specified in channel mapping (" + cubeNumber + ")");
          }
          for (Point p : cube.points) {
            points.add(p.index);
          }
        }
      }
    }
    return points;
  }

  private boolean[] buildFlippedList(Model model, int[][] flippedRGBList) {
    boolean[] flipped = new boolean[model.points.size()];
    for (int i = 0; i < flipped.length; ++i) {
      flipped[i] = false;
    }
    for (int[] cubeInfo : flippedRGBList) {
      int cubeNumber = cubeInfo[0];
      Cube cube = model.getCubeByRawIndex(cubeNumber);
      if (cube == null) {
        throw new RuntimeException("Non-existing cube specified in flipped RGB mapping (" + cubeNumber + ")");
      }
      for (int i = 1; i < cubeInfo.length; ++i) {
        int stripIndex = cubeInfo[i];
        for (Point p : cube.strips.get(stripIndex-1).points) {
          flipped[p.index] = true;
        }
      }
    }
    return flipped;
  } 

  public final void send(int[] colors) {
    int len = 0;
    int packetNum = 0;
    for (int index : points) {
      int c = colors[index];
      byte r = (byte) ((c >> 16) & 0xFF);
      byte g = (byte) ((c >> 8) & 0xFF);
      byte b = (byte) ((c) & 0xFF);
      if (flipped[index]) {
        byte tmp = r;
        r = g;
        g = tmp;
      }
      packet[len++] = 0;
      packet[len++] = r;
      packet[len++] = g;
      packet[len++] = b;

      // Flush once packet is full buffer size
      if (len >= packet.length) {
        sendPacket(packetNum++, len);
        len = 0;
      }
    }

    // Flush any remaining data
    if (len > 0) {
      sendPacket(packetNum++, len);
    }
  }
  
  private void sendPacket(int packetNum, int len) {
    message.clearArguments();
    message.add(packetNum);
    message.add(len);
    message.add(packet);
    try {
      OscP5.flush(message, address);     
    } catch (Exception x) {
      x.printStackTrace();
    }
  }
}

