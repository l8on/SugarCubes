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

  // IP address
  public final String ip;
  
  // Address to send to
  private final NetAddress address;
  
  // Whether board output is enabled
  private boolean enabled = false;
  
  // OSC message
  private final OscMessage message;

  // List of point indices on the board
  private final int[] points;
  
  // How many channels are on the panda board
  private final static int CHANNELS_PER_BOARD = 8;
  
  // How many cubes per channel xc_PB is configured for
  private final static int CUBES_PER_CHANNEL = 4;

  // Packet data
  private final byte[] packet = new byte[4*352]; // TODO: de-magic-number, UDP related?

  public PandaDriver(String ip, Model model, int[][] channelList) {
    this.ip = ip;
    this.address = new NetAddress(ip, 9001);
    message = new OscMessage("/shady/pointbuffer");
    List<Integer> pointList = buildMappedList(model, channelList);
    points = new int[pointList.size()];
    int i = 0;
    for (int value : pointList) {
      points[i++] = value;
    }
  }
  
  public void toggle() {
    enabled = !enabled;
    println("PandaBoard Output/" + ip + ": " + (enabled ? "ON" : "OFF"));    
  } 

  private ArrayList<Integer> buildMappedList(Model model, int[][] channelList) {
    ArrayList<Integer> points = new ArrayList<Integer>();
    for (int chi = 0; chi < CHANNELS_PER_BOARD; ++chi) {
      int[] channel = (chi < channelList.length) ? channelList[chi] : new int[]{};
      for (int ci = 0; ci < CUBES_PER_CHANNEL; ++ci) {
        int cubeNumber = (ci < channel.length) ? channel[ci] : 0;
        if (cubeNumber == 0) {
          for (int i = 0; i < Cube.POINTS_PER_CUBE; ++i) {
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
    if (!enabled) {
      return;
    }
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

