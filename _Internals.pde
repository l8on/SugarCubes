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

final float TRAILER_WIDTH = 240;
final float TRAILER_DEPTH = 97;
final float TRAILER_HEIGHT = 33;

final float BASS_WIDTH = 124;
final float BASS_HEIGHT = 31.5;
final float BASS_DEPTH = 66;
final float BASS_X = (TRAILER_WIDTH - BASS_WIDTH) / 2.;
final float BASS_Z = (TRAILER_DEPTH - BASS_DEPTH) / 2.;

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
PandaDriver[] pandaBoards;
boolean mappingMode = false;
boolean debugMode = false;
DebugUI debugUI;

// Camera variables
float eyeR, eyeA, eyeX, eyeY, eyeZ, midX, midY, midZ;

void setup() {
  startMillis = lastMillis = millis();

  // Initialize the Processing graphics environment
  size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, OPENGL);
  frameRate(targetFramerate);
  noSmooth();
  // hint(ENABLE_OPENGL_4X_SMOOTH); // no discernable improvement?
  logTime("Created viewport");

  // Create the GLucose engine to run the cubes
  glucose = new GLucose(this, buildModel());
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
  PandaMapping[] pandaMappings = buildPandaList();
  pandaBoards = new PandaDriver[pandaMappings.length];
  int pbi = 0;
  for (PandaMapping pm : pandaMappings) {
    pandaBoards[pbi++] = new PandaDriver(pm.ip, glucose.model, pm);
  }
  mappingTool = new MappingTool(glucose, pandaMappings);
  logTime("Built PandaDriver");
  
  // Build overlay UI
  ui = controlUI = new ControlUI();
  mappingUI = new MappingUI(mappingTool);
  debugUI = new DebugUI(pandaMappings);
  logTime("Built overlay UI");
    
  // MIDI devices
  for (MidiInputDevice d : RWMidi.getInputDevices()) {
    d.createInput(this);
  }
  SCMidiDevices.initializeStandardDevices(glucose);
  logTime("Setup MIDI devices");
    
  // Setup camera
  midX = TRAILER_WIDTH/2. + 20;
  midY = glucose.model.yMax/2;
  midZ = TRAILER_DEPTH/2.;
  eyeR = -290;
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

  noStroke();
  fill(#141414);
  drawBox(0, -TRAILER_HEIGHT, 0, 0, 0, 0, TRAILER_WIDTH, TRAILER_HEIGHT, TRAILER_DEPTH, TRAILER_HEIGHT/2.);
  fill(#070707);
  stroke(#222222);
  beginShape();
  vertex(0, 0, 0);
  vertex(TRAILER_WIDTH, 0, 0);
  vertex(TRAILER_WIDTH, 0, TRAILER_DEPTH);
  vertex(0, 0, TRAILER_DEPTH);
  endShape();
  
  noStroke();
  fill(#292929);
  drawBox(BASS_X, 0, BASS_Z, 0, 0, 0, BASS_WIDTH, BASS_HEIGHT, BASS_DEPTH, Cube.CHANNEL_WIDTH);
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
  javax.media.opengl.GL gl = ((PGraphicsOpenGL)g).beginGL();
  gl.glClear(javax.media.opengl.GL.GL_DEPTH_BUFFER_BIT);
  ((PGraphicsOpenGL)g).endGL();
  strokeWeight(1);
  drawUI();
  
  if (debugMode) {
    debugUI.draw();
  }
  
  // TODO(mcslee): move into GLucose engine
  for (PandaDriver p : pandaBoards) {
    p.send(colors);
  }
}

void drawCube(Cube c) {
  float in = .15;
  drawBox(c.x+in, c.y+in, c.z+in, c.rx, c.ry, c.rz, Cube.EDGE_WIDTH-in*2, Cube.EDGE_HEIGHT-in*2, Cube.EDGE_WIDTH-in*2, Cube.CHANNEL_WIDTH-in);
}

void drawBox(float x, float y, float z, float rx, float ry, float rz, float xd, float yd, float zd, float sw) {
  pushMatrix();
  translate(x, y, z);
  rotate(rx / 180. * PI, -1, 0, 0);
  rotate(ry / 180. * PI, 0, -1, 0);
  rotate(rz / 180. * PI, 0, 0, -1);
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
      for (PandaDriver p : pandaBoards) {
        p.toggle();
      }
      break;
    case 'u':
      uiOn = !uiOn;
      break;
  }
}

int mx, my;
void mousePressed() {
  ui.mousePressed();
  if (mouseX < ui.leftPos) {
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
  ui.mouseReleased();
}
 
void mouseWheel(int delta) {
  if (mouseX > ui.leftPos) {
    ui.mouseWheel(delta);
  } else {
    eyeR = constrain(eyeR - delta, -500, -80);
    eyeX = midX + eyeR*sin(eyeA);
    eyeZ = midZ + eyeR*cos(eyeA);
  }
}

