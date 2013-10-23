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
 * Overlay UI that indicates pattern control, etc. This will be moved
 * into the Processing library once it is stabilized and need not be
 * regularly modified.
 */

class DebugUI {
  
  final ChannelMapping[] channelList;
  final int debugX = 5;
  final int debugY = 5;
  final int debugXSpacing = 28;
  final int debugYSpacing = 21;
  final int[][] debugState;
  final int[] indexState;
    
  final int CUBE_STATE_UNUSED = 0;
  final int CUBE_STATE_USED = 1;
  final int CUBE_STATE_DUPLICATED = 2;
  
  final int DEBUG_STATE_ANIM = 0;
  final int DEBUG_STATE_WHITE = 1;
  final int DEBUG_STATE_OFF = 2;
  final int DEBUG_STATE_UNUSED = 3;  
  
  DebugUI(PandaMapping[] pandaMappings) {
    int totalChannels = pandaMappings.length * PandaMapping.CHANNELS_PER_BOARD;
    debugState = new int[totalChannels+1][ChannelMapping.CUBES_PER_CHANNEL+1];
    indexState = new int[glucose.model.cubes.size()+1];
    
    channelList = new ChannelMapping[totalChannels];
    int channelIndex = 0;
    for (PandaMapping pm : pandaMappings) {
      for (ChannelMapping channel : pm.channelList) {
        channelList[channelIndex++] = channel;
      }
    }
    for (int i = 0; i < debugState.length; ++i) {
      for (int j = 0; j < debugState[i].length; ++j) {
        debugState[i][j] = DEBUG_STATE_ANIM;
      }
    }
    
    for (int rawIndex = 0; rawIndex < glucose.model.cubes.size()+1; ++rawIndex) {
      indexState[rawIndex] = CUBE_STATE_UNUSED;
    }
    for (ChannelMapping channel : channelList) {
      for (int rawCubeIndex : channel.objectIndices) {
        if (rawCubeIndex > 0)
          ++indexState[rawCubeIndex];
      }
    }
  }
  
  void draw() {
    noStroke();
    int xBase = debugX;
    int yPos = debugY;
    
    textSize(10);
    
    fill(#000000);
    rect(0, 0, debugX + 5*debugXSpacing, height);
    
    int channelNum = 0;
    for (ChannelMapping channel : channelList) {
      int xPos = xBase;
      drawNumBox(xPos, yPos, channelNum+1, debugState[channelNum][0]);
      xPos += debugXSpacing;
      
      switch (channel.mode) {
        case ChannelMapping.MODE_CUBES:
          int stateIndex = 0;
          boolean first = true;
          for (int rawCubeIndex : channel.objectIndices) {
            if (rawCubeIndex < 0) {
              break;
            }
            if (first) {
              first = false;
            } else {
              stroke(#999999);          
              line(xPos - 12, yPos + 8, xPos, yPos + 8);
            }
            drawNumBox(xPos, yPos, rawCubeIndex, debugState[channelNum][stateIndex+1], indexState[rawCubeIndex]);
            ++stateIndex;
            xPos += debugXSpacing;            
          }
          break;
        case ChannelMapping.MODE_BASS:
          drawNumBox(xPos, yPos, "B", debugState[channelNum][1]);
          break;
        case ChannelMapping.MODE_SPEAKER:
          drawNumBox(xPos, yPos, "S" + channel.objectIndices[0], debugState[channelNum][1]);
          break;
        case ChannelMapping.MODE_STRUTS_AND_FLOOR:
          drawNumBox(xPos, yPos, "F", debugState[channelNum][1]);
          break;
        case ChannelMapping.MODE_NULL:
          break;
        default:
          throw new RuntimeException("Unhandled channel mapping mode: " + channel.mode);
      }          
      
      yPos += debugYSpacing;
      ++channelNum;
    }
    drawNumBox(xBase, yPos, "A", debugState[channelNum][0]);
    yPos += debugYSpacing * 2;
   
    noFill();
    fill(#CCCCCC);
    text("Unused Cubes",  xBase, yPos + 12);
    yPos += debugYSpacing;
    
    int xIndex = 0;
    for (int rawIndex = 1; rawIndex <= glucose.model.cubes.size(); ++rawIndex) {
      if (indexState[rawIndex] == CUBE_STATE_UNUSED) {
        drawNumBox(xBase + (xIndex * debugXSpacing), yPos, rawIndex, DEBUG_STATE_UNUSED);
        ++xIndex;
        if (xIndex > 4) {
          xIndex = 0;
          yPos += debugYSpacing + 2;
        }
      }
    }
  }

  
  void drawNumBox(int xPos, int yPos, int label, int state) {
    drawNumBox(xPos, yPos, "" + label, state);
  }
  
  void drawNumBox(int xPos, int yPos, String label, int state) {
    drawNumBox(xPos, yPos, "" + label, state, CUBE_STATE_USED);
  }

  void drawNumBox(int xPos, int yPos, int label, int state, int cubeState) {
    drawNumBox(xPos, yPos, "" + label, state, cubeState);
  }
  
  void drawNumBox(int xPos, int yPos, String label, int state, int cubeState) {
    noFill();
    color textColor = #cccccc;
    switch (state) {
      case DEBUG_STATE_ANIM:
        noStroke();
        fill(#880000);
        rect(xPos, yPos, 16, 8);
        fill(#000088);
        rect(xPos, yPos+8, 16, 8);
        noFill();
        stroke(textColor);
        break;
      case DEBUG_STATE_WHITE:
        stroke(textColor);
        fill(#e9e9e9);
        textColor = #333333;
        break;
      case DEBUG_STATE_OFF:
        stroke(textColor);
        break;
      case DEBUG_STATE_UNUSED:
        stroke(textColor);
        fill(#880000);
        break;
    }
    
    if (cubeState >= CUBE_STATE_DUPLICATED) {
      stroke(textColor = #FF0000);
    }

    rect(xPos, yPos, 16, 16);     
    noStroke();
    fill(textColor);
    text(label, xPos + 2, yPos + 12);
  }
  
  void maskColors(color[] colors) {
    color white = #FFFFFF;
    color off = #000000;
    int channelIndex = 0;
    int state;
    for (ChannelMapping channel : channelList) {
      switch (channel.mode) {
        case ChannelMapping.MODE_CUBES:
          int cubeIndex = 1;
          for (int rawCubeIndex : channel.objectIndices) {
            if (rawCubeIndex >= 0) {
              state = debugState[channelIndex][cubeIndex];
              if (state != DEBUG_STATE_ANIM) {
                color debugColor = (state == DEBUG_STATE_WHITE) ? white : off;
                Cube cube = glucose.model.getCubeByRawIndex(rawCubeIndex);
                for (Point p : cube.points) {
                  colors[p.index] = debugColor;
                }
              }
            }
            ++cubeIndex;
          }
          break;
            
         case ChannelMapping.MODE_BASS:
           state = debugState[channelIndex][1];
           if (state != DEBUG_STATE_ANIM) {
              color debugColor = (state == DEBUG_STATE_WHITE) ? white : off;
              for (Strip s : glucose.model.bassBox.boxStrips) {
                for (Point p : s.points) {
                  colors[p.index] = debugColor;
                }
              }
           }
           break;

         case ChannelMapping.MODE_STRUTS_AND_FLOOR:
           state = debugState[channelIndex][1];
           if (state != DEBUG_STATE_ANIM) {
              color debugColor = (state == DEBUG_STATE_WHITE) ? white : off;
              for (Point p : glucose.model.boothFloor.points) {
                colors[p.index] = debugColor;
              }
              for (Strip s : glucose.model.bassBox.struts) {
                for (Point p : s.points) {
                  colors[p.index] = debugColor;
                }
              }
           }
           break;
           
         case ChannelMapping.MODE_SPEAKER:
           state = debugState[channelIndex][1];
           if (state != DEBUG_STATE_ANIM) {
              color debugColor = (state == DEBUG_STATE_WHITE) ? white : off;
              for (Point p : glucose.model.speakers.get(channel.objectIndices[0]).points) {
                colors[p.index] = debugColor;
              }
           }
           break;
           
         case ChannelMapping.MODE_NULL:
           break;
           
        default:
          throw new RuntimeException("Unhandled channel mapping mode: " + channel.mode);           
      }
      ++channelIndex;
    }
  }
  
  boolean mousePressed() {
    int dx = (mouseX - debugX) / debugXSpacing;
    int dy = (mouseY - debugY) / debugYSpacing;
    if ((dy < 0) || (dy >= debugState.length)) {
      return false;
    }
    if ((dx < 0) || (dx >= debugState[dy].length)) {
      return false;
    }
    int newState = debugState[dy][dx] = (debugState[dy][dx] + 1) % 3;
    if (dy == debugState.length-1) {
      for (int[] states : debugState) {
        for (int i = 0; i < states.length; ++i) {
          states[i] = newState;
        }
      }
    } else if (dx == 0) {
      for (int i = 0; i < debugState[dy].length; ++i) {
        debugState[dy][i] = newState;
      }
    }
    return true;
  }    
}

