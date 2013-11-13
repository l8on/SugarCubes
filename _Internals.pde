/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//H
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * If you are an artist, you may ignore this file! It just sets
 * up the framework to run the patterns. Should not need modification
 * for general animation work.
 */

import glucose.*;
import glucose.model.*;
import heronarts.lx.*;
import heronarts.lx.effect.*;
import heronarts.lx.modulator.*;
import heronarts.lx.parameter.*;
import heronarts.lx.pattern.*;
import heronarts.lx.transform.*;
import heronarts.lx.transition.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.opengl.*;
import rwmidi.*;
import java.lang.reflect.*;

final int VIEWPORT_WIDTH = 900;
final int VIEWPORT_HEIGHT = 700;

// The trailer is measured from the outside of the black metal (but not including the higher welded part on the front)
final float TRAILER_WIDTH = 240;
final float TRAILER_DEPTH = 97;
final float TRAILER_HEIGHT = 33;

final int MaxCubeHeight = 5;
final int NumBackTowers = 11;

int targetFramerate = 60;
int startMillis, lastMillis;

// Core engine variables
GLucose glucose;
LX lx;
LXPattern[] patterns;
Effects effects;
MappingTool mappingTool;
PandaDriver[] pandaBoards;
PresetManager presetManager;
MidiEngine midiEngine;

// Display configuration mode
boolean mappingMode = false;
boolean debugMode = false;
DebugUI debugUI;
boolean uiOn = true;
boolean simulationOn = true;
boolean diagnosticsOn = false;
LXPattern restoreToPattern = null;
PImage logo;
float[] hsb = new float[3];

// Handles to UI objects
UIContext[] overlays;
UIPatternDeck uiPatternA;
UICrossfader uiCrossfader;
UIMidi uiMidi;
UIMapping uiMapping;
UIDebugText uiDebugText;
UISpeed uiSpeed;

// Camera variables
float eyeR, eyeA, eyeX, eyeY, eyeZ, midX, midY, midZ;

/**
 * Engine construction and initialization.
 */

LXTransition _transition(GLucose glucose) {
  return new DissolveTransition(glucose.lx).setDuration(1000);
}

LXPattern[] _leftPatterns(GLucose glucose) {
  LXPattern[] patterns = patterns(glucose);
  for (LXPattern p : patterns) {
    p.setTransition(_transition(glucose));
  }
  return patterns;
}

LXPattern[] _rightPatterns(GLucose glucose) {
  LXPattern[] patterns = _leftPatterns(glucose);
  LXPattern[] rightPatterns = new LXPattern[patterns.length+1];
  int i = 0;
  rightPatterns[i++] = new BlankPattern(glucose).setTransition(_transition(glucose));
  for (LXPattern p : patterns) {
    rightPatterns[i++] = p;
  }
  return rightPatterns;
}

LXEffect[] _effectsArray(Effects effects) {
  List<LXEffect> effectList = new ArrayList<LXEffect>();
  for (Field f : effects.getClass().getDeclaredFields()) {
    try {
      Object val = f.get(effects);
      if (val instanceof LXEffect) {
        effectList.add((LXEffect)val);
      }
    } catch (IllegalAccessException iax) {}
  }
  return effectList.toArray(new LXEffect[]{});
} 

void logTime(String evt) {
  int now = millis();
  println(evt + ": " + (now - lastMillis) + "ms");
  lastMillis = now;
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
  LXEngine engine = lx.engine;
  engine.setPatterns(patterns = _leftPatterns(glucose));
  engine.addDeck(_rightPatterns(glucose));
  logTime("Built patterns");
  glucose.setTransitions(transitions(glucose));
  logTime("Built transitions");
  glucose.lx.addEffects(_effectsArray(effects = new Effects()));
  logTime("Built effects");

  // Preset manager
  presetManager = new PresetManager();
  logTime("Loaded presets");

  // MIDI devices
  midiEngine = new MidiEngine();
  logTime("Setup MIDI devices");

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
    uiPatternA = new UIPatternDeck(lx.engine.getDeck(GLucose.LEFT_DECK), "PATTERN A", 4, 4, 140, 324),
    new UIBlendMode(4, 332, 140, 86),
    new UIEffects(4, 422, 140, 144),
    new UITempo(4, 570, 140, 50),
    uiSpeed = new UISpeed(4, 624, 140, 50),
        
    new UIPatternDeck(lx.engine.getDeck(GLucose.RIGHT_DECK), "PATTERN B", width-144, 4, 140, 324),
    uiMidi = new UIMidi(midiEngine, width-144, 332, 140, 158),
    new UIOutput(width-144, 494, 140, 106),
    
    uiCrossfader = new UICrossfader(width/2-90, height-90, 180, 86),
    
    uiDebugText = new UIDebugText(148, height-138, width-304, 44),
    uiMapping = new UIMapping(mappingTool, 4, 4, 140, 324),
  };
  uiMapping.setVisible(false);
  logTime("Built overlay UI");

  // Load logo image
  logo = loadImage("data/logo.png");
  
  // Setup camera
  midX = TRAILER_WIDTH/2.;
  midY = glucose.model.yMax/2;
  midZ = TRAILER_DEPTH/2.;
  eyeR = -290;
  eyeA = .15;
  eyeY = midY + 70;
  eyeX = midX + eyeR*sin(eyeA);
  eyeZ = midZ + eyeR*cos(eyeA);
  
  // Add mouse scrolling event support
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }}); 
  
  println("Total setup: " + (millis() - startMillis) + "ms");
  println("Hit the 'p' key to toggle Panda Board output");
}

/**
 * Core render loop and drawing functionality.
 */
void draw() {
  long drawStart = System.nanoTime();
  
  // Draws the simulation and the 2D UI overlay
  background(40);

  color[] simulationColors;
  color[] sendColors;
  simulationColors = sendColors = glucose.getColors();
  String displayMode = uiCrossfader.getDisplayMode();
  if (displayMode == "A") {
    simulationColors = lx.engine.getDeck(GLucose.LEFT_DECK).getColors();
  } else if (displayMode == "B") {
    simulationColors = lx.engine.getDeck(GLucose.RIGHT_DECK).getColors();
  }
  if (debugMode) {
    debugUI.maskColors(simulationColors);
    debugUI.maskColors(sendColors);
  }

  long simulationStart = System.nanoTime();
  if (simulationOn) {
    drawSimulation(simulationColors);
  }
  long simulationNanos = System.nanoTime() - simulationStart;
  
  // 2D Overlay UI
  long uiStart = System.nanoTime();
  drawUI();
  long uiNanos = System.nanoTime() - uiStart;
  
  long gammaStart = System.nanoTime();
  // Gamma correction here. Apply a cubic to the brightness
  // for better representation of dynamic range
  for (int i = 0; i < sendColors.length; ++i) {
    lx.RGBtoHSB(sendColors[i], hsb);
    float b = hsb[2];
    sendColors[i] = lx.hsb(360.*hsb[0], 100.*hsb[1], 100.*(b*b*b));
  }
  long gammaNanos = System.nanoTime() - gammaStart;
  
  long sendStart = System.nanoTime();
  for (PandaDriver p : pandaBoards) {
    p.send(sendColors);
  }
  long sendNanos = System.nanoTime() - sendStart;
  
  long drawNanos = System.nanoTime() - drawStart;
  
  if (diagnosticsOn) {
    drawDiagnostics(drawNanos, simulationNanos, uiNanos, gammaNanos, sendNanos);
  }
}

void drawDiagnostics(long drawNanos, long simulationNanos, long uiNanos, long gammaNanos, long sendNanos) {
  float ws = 4 / 1000000.;
  int thirtyfps = 1000000000 / 30;
  int sixtyfps = 1000000000 / 60;
  int x = width - 138;
  int y = height - 14;
  int h = 10;
  noFill();
  stroke(#999999);
  rect(x, y, thirtyfps * ws, h);
  noStroke();
  int xp = x;
  float hv = 0;
  for (long val : new long[] {lx.timer.drawNanos, simulationNanos, uiNanos, gammaNanos, sendNanos }) {
    fill(lx.hsb(hv % 360, 100, 80));
    rect(xp, y, val * ws, h-1);
    hv += 140;
    xp += val * ws;
  }
  noFill();
  stroke(#333333);
  line(x+sixtyfps*ws, y+1, x+sixtyfps*ws, y+h-1);
  
  y = y - 14;
  xp = x;
  float tw = thirtyfps * ws;
  noFill();
  stroke(#999999);
  rect(x, y, tw, h);
  h = 5;
  noStroke();
  for (long val : new long[] {
    lx.engine.timer.deckNanos,
    lx.engine.timer.copyNanos,
    lx.engine.timer.fxNanos}) {
    float amt = val / (float) lx.timer.drawNanos;
    fill(lx.hsb(hv % 360, 100, 80));
    rect(xp, y, amt * tw, h-1);
    hv += 140;
    xp += amt * tw;
  }
  
  xp = x;
  y += h;
  hv = 120;
  for (long val : new long[] {
    lx.engine.getDeck(0).timer.runNanos,
    lx.engine.getDeck(1).timer.runNanos,
    lx.engine.getDeck(1).getFaderTransition().timer.blendNanos}) {
    float amt = val / (float) lx.timer.drawNanos;
    fill(lx.hsb(hv % 360, 100, 80));
    rect(xp, y, amt * tw, h-1);
    hv += 140;
    xp += amt * tw;
  }
}

void drawSimulation(color[] simulationColors) {
  camera(
    eyeX, eyeY, eyeZ,
    midX, midY, midZ,
    0, -1, 0
  );

  translate(0, 40, 0);

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

  // Draw the logo on the front of platform  
  pushMatrix();
  translate(0, 0, -1);
  float s = .07;
  scale(s, -s, s);
  image(logo, TRAILER_WIDTH/2/s-logo.width/2, TRAILER_HEIGHT/2/s-logo.height/2-2/s);
  popMatrix();
  
  noStroke();
  if (glucose.model.bassBox.exists) {
    drawBassBox(glucose.model.bassBox, false);
  }
  for (Speaker speaker : glucose.model.speakers) {
    drawSpeaker(speaker);
  }
  for (Cube c : glucose.model.cubes) {
    drawCube(c);
  }

  noFill();
  strokeWeight(2);
  beginShape(POINTS);
  for (LXPoint p : glucose.model.points) {
    stroke(simulationColors[p.index]);
    vertex(p.x, p.y, p.z);
  }
  endShape();
}

void drawBassBox(BassBox b, boolean hasSub) {
  
  float in = .15;
  
  if (hasSub) {
    noStroke();
    fill(#191919);
    pushMatrix();
    translate(b.x + BassBox.EDGE_WIDTH/2., b.y + BassBox.EDGE_HEIGHT/2, b.z + BassBox.EDGE_DEPTH/2.);
    box(BassBox.EDGE_WIDTH-20*in, BassBox.EDGE_HEIGHT-20*in, BassBox.EDGE_DEPTH-20*in);
    popMatrix();
  }

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


/**
 * Top-level keyboard event handling
 */
void keyPressed() {
  if (mappingMode) {
    mappingTool.keyPressed(uiMapping);
  }
  switch (key) {
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
      if (!midiEngine.isQwertyEnabled()) {
        presetManager.select(midiEngine.getFocusedDeck(), key - '1');
      }
      break;
    
    case '!':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 0);
      break;
    case '@':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 1);
      break;
    case '#':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 2);
      break;
    case '$':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 3);
      break;
    case '%':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 4);
      break;
    case '^':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 5);
      break;
    case '&':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 6);
      break;
    case '*':
      if (!midiEngine.isQwertyEnabled()) presetManager.store(midiEngine.getFocusedDeck(), 7);
      break;
      
    case '-':
    case '_':
      frameRate(--targetFramerate);
      break;
    case '=':
    case '+':
      frameRate(++targetFramerate);
      break; 
    case 'b':
      effects.boom.trigger();
      break;    
    case 'd':
      if (!midiEngine.isQwertyEnabled()) {
        debugMode = !debugMode;
        println("Debug output: " + (debugMode ? "ON" : "OFF"));
      }
      break;
    case 'm':
      if (!midiEngine.isQwertyEnabled()) {
        mappingMode = !mappingMode;
        uiPatternA.setVisible(!mappingMode);
        uiMapping.setVisible(mappingMode);
        if (mappingMode) {
          restoreToPattern = lx.getPattern();
          lx.setPatterns(new LXPattern[] { mappingTool });
        } else {
          lx.setPatterns(patterns);
          LXTransition pop = restoreToPattern.getTransition();
          restoreToPattern.setTransition(null);
          lx.goPattern(restoreToPattern);
          restoreToPattern.setTransition(pop);
        }
      }
      break;
    case 't':
      if (!midiEngine.isQwertyEnabled()) {
        lx.engine.setThreaded(!lx.engine.isThreaded());
      }
      break;
    case 'p':
      for (PandaDriver p : pandaBoards) {
        p.toggle();
      }
      break;
    case 'q':
      if (!midiEngine.isQwertyEnabled()) {
        diagnosticsOn = !diagnosticsOn;
      }
      break;
    case 's':
      if (!midiEngine.isQwertyEnabled()) {
        simulationOn = !simulationOn;
      }
      break;
    case 'u':
      if (!midiEngine.isQwertyEnabled()) {
        uiOn = !uiOn;
      }
      break;
  }
}

/**
 * Top-level mouse event handling
 */
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
