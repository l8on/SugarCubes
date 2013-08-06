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
 * If you are an artist, you may ignore this file! It just sets
 * up the framework to run the patterns. Should not need modification
 * for general animation work.
 */

import glucose.*;
import glucose.control.*;
import glucose.effect.*;
import glucose.model.*;
import glucose.pattern.*;
import glucose.transform.*;
import glucose.transition.*;
import heronarts.lx.*;
import heronarts.lx.control.*;
import heronarts.lx.effect.*;
import heronarts.lx.modulator.*;
import heronarts.lx.pattern.*;
import heronarts.lx.transition.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.opengl.*;
import rwmidi.*;

final int VIEWPORT_WIDTH = 900;
final int VIEWPORT_HEIGHT = 700;

int targetFramerate = 60;

int startMillis, lastMillis;
GLucose glucose;
HeronLX lx;
MappingTool mappingTool;
LXPattern[] patterns;
LXTransition[] transitions;
LXEffect[] effects;
OverlayUI ui;
ControlUI controlUI;
MappingUI mappingUI;
PandaDriver pandaFront;
PandaDriver pandaRear;
boolean mappingMode = false;

boolean pandaBoardsEnabled = false;

boolean debugMode = false;
DebugUI debugUI;

// Camera variables
float eyeR, eyeA, eyeX, eyeY, eyeZ, midX, midY, midZ;

final float FEET = 12;

void setup() {
  startMillis = lastMillis = millis();

  // Initialize the Processing graphics environment
  size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, OPENGL);
  frameRate(targetFramerate);
  noSmooth();
  // hint(ENABLE_OPENGL_4X_SMOOTH); // no discernable improvement?
  logTime("Created viewport");

  // Create the GLucose engine to run the cubes
  glucose = new GLucose(this, new SCMapping());
  lx = glucose.lx;
  lx.enableKeyboardTempo();
  logTime("Built GLucose engine");
  
  // Set the patterns
  glucose.lx.setPatterns(patterns = patterns(glucose));
  logTime("Built patterns");
  glucose.lx.addEffects(effects = effects(glucose));
  logTime("Built effects");
  glucose.setTransitions(transitions = transitions(glucose));
  logTime("Built transitions");
    
  // Build output driver
  int[][] frontChannels = glucose.mapping.buildFrontChannelList();
  int[][] rearChannels = glucose.mapping.buildRearChannelList();
  int[][] flippedRGB = glucose.mapping.buildFlippedRGBList();
  mappingTool = new MappingTool(glucose, frontChannels, rearChannels);
  pandaFront = new PandaDriver(new NetAddress("192.168.1.28", 9001), glucose.model, frontChannels, flippedRGB);
  pandaRear = new PandaDriver(new NetAddress("192.168.1.29", 9001), glucose.model, rearChannels, flippedRGB);
  logTime("Build PandaDriver");
  
  // Build overlay UI
  ui = controlUI = new ControlUI();
  mappingUI = new MappingUI(mappingTool);
  debugUI = new DebugUI(frontChannels, rearChannels);
  logTime("Built overlay UI");
    
  // MIDI devices
  for (MidiInputDevice d : RWMidi.getInputDevices()) {
    d.createInput(this);
  }
  SCMidiDevices.initializeStandardDevices(glucose);
  logTime("Setup MIDI devices");
    
  // Setup camera
  midX = glucose.model.xMax/2 + 20;
  midY = glucose.model.yMax/2;
  midZ = glucose.model.zMax/2;
  eyeR = -270;
  eyeA = .15;
  eyeY = midY + 20;
  eyeX = midX + eyeR*sin(eyeA);
  eyeZ = midZ + eyeR*cos(eyeA);
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }}); 
  
  
  println("Total setup: " + (millis() - startMillis) + "ms");
  println("Hit the 'p' key to toggle Panda Board output");
}

void controllerChangeReceived(rwmidi.Controller cc) {
  if (debugMode) {
    println("CC: " + cc.toString());
  }
}

void noteOnReceived(Note note) {
  if (debugMode) {
    println("Note On: " + note.toString());
  }
}

void noteOffReceived(Note note) {
  if (debugMode) {
    println("Note Off: " + note.toString());
  }
}

void logTime(String evt) {
  int now = millis();
  println(evt + ": " + (now - lastMillis) + "ms");
  lastMillis = now;
}

void draw() {
  // Draws the simulation and the 2D UI overlay
  background(40);
  color[] colors = glucose.getColors();
  if (debugMode) {
    debugUI.maskColors(colors);
  }

  camera(
    eyeX, eyeY, eyeZ,
    midX, midY, midZ,
    0, -1, 0
  );

  float trailerWidth = 20*FEET;
  float trailerDepth = 8*FEET;
  float trailerHeight = 2*FEET;
  noStroke();
  fill(#141414);
  drawBox(0, -trailerHeight, 0, 0, 0, 0, trailerWidth, trailerHeight, trailerDepth, trailerHeight/2.);
  fill(#070707);
  stroke(#222222);
  beginShape();
  vertex(0, 0, 0);
  vertex(trailerWidth, 0, 0);
  vertex(trailerWidth, 0, trailerDepth);
  vertex(0, 0, trailerDepth);
  endShape();
  
  noStroke();
  fill(#292929);
  for (Cube c : glucose.model.cubes) {
    drawCube(c);
  }

  noFill();
  strokeWeight(2);
  beginShape(POINTS);
  for (Point p : glucose.model.points) {
    stroke(colors[p.index]);
    vertex(p.fx, p.fy, p.fz);
    // println(p.fx + ":" + p.fy + ":" + p.fz);
  }
  endShape();
  
  // 2D Overlay
  camera();
  noLights();
  javax.media.opengl.GL gl= ((PGraphicsOpenGL)g).beginGL();
  gl.glClear(javax.media.opengl.GL.GL_DEPTH_BUFFER_BIT);
  ((PGraphicsOpenGL)g).endGL();
  strokeWeight(1);
  drawUI();
  
  if (debugMode) {
    debugUI.draw();
  }
  
  // TODO(mcslee): move into GLucose engine
  if (pandaBoardsEnabled) {
    pandaFront.send(colors);
    pandaRear.send(colors);
  }
}

void drawCube(Cube c) {
  drawBox(c.x, c.y, c.z, c.rx, c.ry, c.rz, Cube.EDGE_WIDTH, Cube.EDGE_HEIGHT, Cube.EDGE_WIDTH, Strip.CHANNEL_WIDTH);
}

void drawBox(float x, float y, float z, float rx, float ry, float rz, float xd, float yd, float zd, float sw) {
  pushMatrix();
  translate(x, y, z);
  rotate(rx, 1, 0, 0);
  rotate(ry / 180. * PI, 0, -1, 0);
  rotate(rz, 0, 0, 1);
  for (int i = 0; i < 4; ++i) {
    float wid = (i % 2 == 0) ? xd : zd;
    
    beginShape();
    vertex(0, 0);
    vertex(wid, 0);
    vertex(wid, yd);
    vertex(wid - sw, yd);
    vertex(wid - sw, sw);
    vertex(0, sw);
    endShape();
    beginShape();
    vertex(0, sw);
    vertex(0, yd);
    vertex(wid - sw, yd);
    vertex(wid - sw, yd - sw);
    vertex(sw, yd - sw);
    vertex(sw, sw);
    endShape();

    translate(wid, 0, 0);
    rotate(HALF_PI, 0, -1, 0);
  }
  popMatrix();
}

void drawUI() {
  if (uiOn) {
    ui.draw();
  } else {
    ui.drawHelpTip();
  }
  ui.drawFPS();
}

boolean uiOn = true;
int restoreToIndex = -1;

void keyPressed() {
  if (mappingMode) {
    mappingTool.keyPressed();
  }
  switch (key) {
    case '-':
    case '_':
      frameRate(--targetFramerate);
      break;
    case '=':
    case '+':
      frameRate(++targetFramerate);
      break;
    case 'd':
      debugMode = !debugMode;
      println("Debug output: " + (debugMode ? "ON" : "OFF"));
      break;
    case 'm':
      mappingMode = !mappingMode;
      if (mappingMode) {
        LXPattern pattern = lx.getPattern();
        for (int i = 0; i < patterns.length; ++i) {
          if (pattern == patterns[i]) {
            restoreToIndex = i;
            break;
          }
        }
        ui = mappingUI;
        lx.setPatterns(new LXPattern[] { mappingTool });
      } else {
        ui = controlUI;
        lx.setPatterns(patterns);
        lx.goIndex(restoreToIndex);
      }
      break;
    case 'p':
      pandaBoardsEnabled = !pandaBoardsEnabled;
      println("PandaBoard Output: " + (pandaBoardsEnabled ? "ON" : "OFF"));
      break;
    case 'u':
      uiOn = !uiOn;
      break;
  }
}

int mx, my;

void mousePressed() {
  if (mouseX > ui.leftPos) {
    ui.mousePressed();
  } else {
    if (debugMode) {
      debugUI.mousePressed();
    }    
    mx = mouseX;
    my = mouseY;
  }
}

void mouseDragged() {
  if (mouseX > ui.leftPos) {
    ui.mouseDragged();
  } else {
    int dx = mouseX - mx;
    int dy = mouseY - my;
    mx = mouseX;
    my = mouseY;
    eyeA += dx*.003;
    eyeX = midX + eyeR*sin(eyeA);
    eyeZ = midZ + eyeR*cos(eyeA);
    eyeY += dy;
  }
}

void mouseReleased() {
  if (mouseX > ui.leftPos) {
    ui.mouseReleased();
  }
}
 
void mouseWheel(int delta) {
  eyeR = constrain(eyeR - delta, -500, -80);
  eyeX = midX + eyeR*sin(eyeA);
  eyeZ = midZ + eyeR*cos(eyeA);
}

