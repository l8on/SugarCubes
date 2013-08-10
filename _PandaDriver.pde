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

  // Packet data
  private final byte[] packet = new byte[4*352]; // TODO: de-magic-number

  public PandaDriver(NetAddress address, Model model, int[][] channelList) {
    this.address = address;
    message = new OscMessage("/shady/pointbuffer");
    List<Integer> pointList = buildMappedList(model, channelList);
    points = new int[pointList.size()];
    int i = 0;
    for (int value : pointList) {
      points[i++] = value;
    }
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
          final int[] stripOrder = new int[] {
            2, 1, 0, 3, 13, 12, 15, 14, 4, 7, 6, 5, 11, 10, 9, 8
          };
          for (int stripIndex : stripOrder) {
            Strip s = cube.strips.get(stripIndex);
            for (int j = s.points.size() - 1; j >= 0; --j) {
              points.add(s.points.get(j).index);
            }
          }
        }
      }
    }
    return points;
  }

  public final void send(int[] colors) {
    int len = 0;
    int packetNum = 0;
    for (int index : points) {
      int c = colors[index];
      byte r = (byte) ((c >> 16) & 0xFF);
      byte g = (byte) ((c >> 8) & 0xFF);
      byte b = (byte) ((c) & 0xFF);
      packet[len++] = 0;
      packet[len++] = r;
      packet[len++] = g;
      packet[len++] = b;

      // Flush once packet is full buffer size
      if (len >= packet.length) {
        sendPacket(packetNum++);
        len = 0;
      }
    }

    // Flush any remaining data
    if (len > 0) {
      sendPacket(packetNum++);
    }
  }
  
  private void sendPacket(int packetNum) {
    message.clearArguments();
    message.add(packetNum);
    message.add(packet.length);
    message.add(packet);
    try {
      OscP5.flush(message, address);
    } catch (Exception x) {
      x.printStackTrace();
    }
  }
}

