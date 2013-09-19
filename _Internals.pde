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

// The trailer is measured from the outside of the black metal (but not including the higher welded part on the front)
final float TRAILER_WIDTH = 240;
final float TRAILER_DEPTH = 97;
final float TRAILER_HEIGHT = 33;

int targetFramerate = 60;

int startMillis, lastMillis;
GLucose glucose;
HeronLX lx;
MappingTool mappingTool;
LXPattern[] patterns;
LXTransition[] transitions;
LXEffect[] effects;
PandaDriver[] pandaBoards;
boolean mappingMode = false;
boolean debugMode = false;
DebugUI debugUI;
String displayMode;

UIContext[] overlays;
UIPatternDeck uiPatternA;
UIMapping uiMapping;
UIDebugText uiDebugText;

// Camera variables
float eyeR, eyeA, eyeX, eyeY, eyeZ, midX, midY, midZ;

LXPattern[] _patterns(GLucose glucose) {
  LXPattern[] patterns = patterns(glucose);
  for (LXPattern p : patterns) {
    p.setTransition(new DissolveTransition(glucose.lx).setDuration(1000));
  }
  return patterns;
}

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
  Engine engine = lx.engine;
  glucose.setTransitions(transitions = transitions(glucose));
  logTime("Built transitions");
  engine.setPatterns(patterns = _patterns(glucose));
  engine.addDeck(_patterns(glucose));
  engine.getDeck(1).setBlendTransition(transitions[0]);
  logTime("Built patterns");
  glucose.lx.addEffects(effects = effects(glucose));
  logTime("Built effects");
    
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
  debugUI = new DebugUI(pandaMappings);
  overlays = new UIContext[] {
    uiPatternA = new UIPatternDeck(lx.engine.getDeck(0), "PATTERN A", 4, 4, 140, 344),
    new UICrossfader(4, 352, 140, 212),
    
    new UIPatternDeck(lx.engine.getDeck(1), "PATTERN B", width-144, 4, 140, 344),
    new UIEffects(width-144, 352, 140, 144),
    new UITempo(width-144, 498, 140, 50),
    new UIOutput(width-144, 552, 140, 106),
    
    uiDebugText = new UIDebugText(4, height-64, width-8, 44),
    uiMapping = new UIMapping(mappingTool, 4, 4, 140, 344),
  };
  uiMapping.setVisible(false);
  logTime("Built overlay UI");
    
  // MIDI devices
  for (MidiInputDevice d : RWMidi.getInputDevices()) {
    d.createInput(this);
  }
  SCMidiDevices.initializeStandardDevices(glucose);
  logTime("Setup MIDI devices");
    
  // Setup camera
  midX = TRAILER_WIDTH/2.;
  midY = glucose.model.yMax/2;
  midZ = TRAILER_DEPTH/2.;
  eyeR = -290;
  eyeA = .15;
  eyeY = midY + 70;
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
  color[] colors = glucose.getColors();;
  if (displayMode == "A") {
    colors = lx.engine.getDeck(0).getColors();
  } else if (displayMode == "B") {
    colors = lx.engine.getDeck(1).getColors();
  }
  if (debugMode) {
    debugUI.maskColors(colors);
  }

  camera(
    eyeX, eyeY, eyeZ,
    midX, midY, midZ,
    0, -1, 0
  );

  translate(0, 10, 0);

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
//  drawBassBox(glucose.model.bassBox);
//  for (Speaker s : glucose.model.speakers) {
//    drawSpeaker(s);
//  }
  for (Cube c : glucose.model.cubes) {
    drawCube(c);
  }

  noFill();
  strokeWeight(2);
  beginShape(POINTS);
  // TODO(mcslee): restore when bassBox/speakers are right again
  // for (Point p : glucose.model.points) {
  for (Cube cube : glucose.model.cubes) {
    for (Point p : cube.points) {
      stroke(colors[p.index]);
      vertex(p.fx, p.fy, p.fz);
    }
  }
  endShape();
  
  // 2D Overlay UI
  drawUI();
    
  // Send output colors
  color[] sendColors = glucose.getColors();
  if (debugMode) {
    debugUI.maskColors(colors);
  }
  
  // Gamma correction here. Apply a cubic to the brightness
  // for better representation of dynamic range
  for (int i = 0; i < colors.length; ++i) {
    float b = brightness(colors[i]) / 100.f;
    colors[i] = color(
      hue(colors[i]),
      saturation(colors[i]),
      (b*b*b) * 100.
    );
  }
  
  // TODO(mcslee): move into GLucose engine
  for (PandaDriver p : pandaBoards) {
    p.send(colors);
  }
}

void drawBassBox(BassBox b) {
  float in = .15;

  noStroke();
  fill(#191919);
  pushMatrix();
  translate(b.x + BassBox.EDGE_WIDTH/2., b.y + BassBox.EDGE_HEIGHT/2, b.z + BassBox.EDGE_DEPTH/2.);
  box(BassBox.EDGE_WIDTH-20*in, BassBox.EDGE_HEIGHT-20*in, BassBox.EDGE_DEPTH-20*in);
  popMatrix();

  noStroke();
  fill(#393939);
  drawBox(b.x+in, b.y+in, b.z+in, 0, 0, 0, BassBox.EDGE_WIDTH-in*2, BassBox.EDGE_HEIGHT-in*2, BassBox.EDGE_DEPTH-in*2, Cube.CHANNEL_WIDTH-in);

  pushMatrix();
  translate(b.x+(Cube.CHANNEL_WIDTH-in)/2., b.y + BassBox.EDGE_HEIGHT-in, b.z + BassBox.EDGE_DEPTH/2.);
  float lastOffset = 0;
  for (float offset : BoothFloor.STRIP_OFFSETS) {
    translate(offset - lastOffset, 0, 0);
    box(Cube.CHANNEL_WIDTH-in, 0, BassBox.EDGE_DEPTH - 2*in);
    lastOffset = offset;
  }
  popMatrix();

  pushMatrix();
  translate(b.x + (Cube.CHANNEL_WIDTH-in)/2., b.y + BassBox.EDGE_HEIGHT/2., b.z + in);
  for (int j = 0; j < 2; ++j) {
    pushMatrix();
    for (int i = 0; i < BassBox.NUM_FRONT_STRUTS; ++i) {
      translate(BassBox.FRONT_STRUT_SPACING, 0, 0);
      box(Cube.CHANNEL_WIDTH-in, BassBox.EDGE_HEIGHT - in*2, 0);
    }
    popMatrix();
    translate(0, 0, BassBox.EDGE_DEPTH - 2*in);
  }
  popMatrix();
  
  pushMatrix();
  translate(b.x + in, b.y + BassBox.EDGE_HEIGHT/2., b.z + BassBox.SIDE_STRUT_SPACING + (Cube.CHANNEL_WIDTH-in)/2.);
  box(0, BassBox.EDGE_HEIGHT - in*2, Cube.CHANNEL_WIDTH-in);
  translate(BassBox.EDGE_WIDTH-2*in, 0, 0);
  box(0, BassBox.EDGE_HEIGHT - in*2, Cube.CHANNEL_WIDTH-in);
  popMatrix();
  
}

void drawCube(Cube c) {
  float in = .15;
  noStroke();
  fill(#393939);  
  drawBox(c.x+in, c.y+in, c.z+in, c.rx, c.ry, c.rz, Cube.EDGE_WIDTH-in*2, Cube.EDGE_HEIGHT-in*2, Cube.EDGE_WIDTH-in*2, Cube.CHANNEL_WIDTH-in);
}

void drawSpeaker(Speaker s) {
  float in = .15;
  
  noStroke();
  fill(#191919);
  pushMatrix();
  translate(s.x, s.y, s.z);
  rotate(s.ry / 180. * PI, 0, -1, 0);
  translate(Speaker.EDGE_WIDTH/2., Speaker.EDGE_HEIGHT/2., Speaker.EDGE_DEPTH/2.);
  box(Speaker.EDGE_WIDTH-20*in, Speaker.EDGE_HEIGHT-20*in, Speaker.EDGE_DEPTH-20*in);
  translate(0, Speaker.EDGE_HEIGHT/2. + Speaker.EDGE_HEIGHT*.8/2, 0);

  fill(#222222);
  box(Speaker.EDGE_WIDTH*.6, Speaker.EDGE_HEIGHT*.8, Speaker.EDGE_DEPTH*.75);
  popMatrix();
  
  noStroke();
  fill(#393939);  
  drawBox(s.x+in, s.y+in, s.z+in, 0, s.ry, 0, Speaker.EDGE_WIDTH-in*2, Speaker.EDGE_HEIGHT-in*2, Speaker.EDGE_DEPTH-in*2, Cube.CHANNEL_WIDTH-in);
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
  camera();
  javax.media.opengl.GL gl = ((PGraphicsOpenGL)g).beginGL();
  gl.glClear(javax.media.opengl.GL.GL_DEPTH_BUFFER_BIT);
  ((PGraphicsOpenGL)g).endGL();
  strokeWeight(1);

  if (uiOn) {
    for (UIContext context : overlays) {
      context.draw();
    }
  }
  
  // Always draw FPS meter
  fill(#555555);
  textSize(9);
  textAlign(LEFT, BASELINE);
  text("FPS: " + ((int) (frameRate*10)) / 10. + " / " + targetFramerate + " (-/+)", 4, height-4);

  if (debugMode) {
    debugUI.draw();
  }
}

boolean uiOn = true;
LXPattern restoreToPattern = null;

void keyPressed() {
  if (mappingMode) {
    mappingTool.keyPressed(uiMapping);
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
      uiPatternA.setVisible(!mappingMode);
      uiMapping.setVisible(mappingMode);
      if (mappingMode) {
        restoreToPattern = lx.getPattern();
        lx.setPatterns(new LXPattern[] { mappingTool });
      } else {
        lx.setPatterns(patterns);
        lx.goPattern(restoreToPattern);
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
  boolean debugged = false;
  if (debugMode) {
    debugged = debugUI.mousePressed();
  }
  if (!debugged) {
    for (UIContext context : overlays) {
      context.mousePressed(mouseX, mouseY);
    }
  }
  mx = mouseX;
  my = mouseY;
}

void mouseDragged() {
  boolean dragged = false;
  for (UIContext context : overlays) {
    dragged |= context.mouseDragged(mouseX, mouseY);
  }
  if (!dragged) {
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
  for (UIContext context : overlays) {
    context.mouseReleased(mouseX, mouseY);
  }

  // ui.mouseReleased();
}
 
void mouseWheel(int delta) {
  boolean wheeled = false;
  for (UIContext context : overlays) {
    wheeled |= context.mouseWheel(mouseX, mouseY, delta);
  }
  
  if (!wheeled) {
    eyeR = constrain(eyeR - delta, -500, -80);
    eyeX = midX + eyeR*sin(eyeA);
    eyeZ = midZ + eyeR*cos(eyeA);
  }
}
