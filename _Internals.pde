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
final int TARGET_FRAMERATE = 45;

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

void setup() {
  startMillis = lastMillis = millis();

  // Initialize the Processing graphics environment
  size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, OPENGL);
  frameRate(TARGET_FRAMERATE);
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
  logTime("Built overlay UI");
    
  // MIDI devices
  for (MidiInputDevice d : RWMidi.getInputDevices()) {
    d.createInput(this);
  }
  SCMidiDevices.initializeStandardDevices(glucose);
  logTime("Setup MIDI devices");
  
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
  // The glucose engine deals with the core simulation here, we don't need
  // to do anything specific. This method just needs to exist.
  
  // TODO(mcslee): move into GLucose engine
  if (pandaBoardsEnabled) {
    color[] colors = glucose.getColors();
    pandaFront.send(colors);
    pandaRear.send(colors);
  }
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
    case 'd':
      debugMode = !debugMode;
      println("Debug output: " + (debugMode ? "ON" : "OFF"));
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


