/**
 * If you are an artist, you may ignore this file! It just sets
 * up the framework to run the patterns. Should not need modification
 * for general animation work.
 */

import glucose.*;
import glucose.control.*;
import glucose.pattern.*;
import glucose.transition.*;
import glucose.model.*;
import heronarts.lx.*;
import heronarts.lx.effect.*;
import heronarts.lx.pattern.*;
import heronarts.lx.modulator.*;
import heronarts.lx.transition.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.opengl.*;
import java.lang.reflect.*;

final int VIEWPORT_WIDTH = 900;
final int VIEWPORT_HEIGHT = 700;
final int TARGET_FRAMERATE = 45;

int startMillis, lastMillis;
GLucose glucose;
HeronLX lx;
LXPattern[] patterns;
LXTransition[] transitions;
LXEffect[] effects;
OverlayUI ui;
int activeTransitionIndex = 0;

void setup() {
  startMillis = lastMillis = millis();

  // Initialize the Processing graphics environment
  size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, OPENGL);
  frameRate(TARGET_FRAMERATE);
  // hint(ENABLE_OPENGL_4X_SMOOTH); // no discernable improvement?
  logTime("Created viewport");

  // Create the GLucose engine to run the cubes
  glucose = new GLucose(this);
  lx = glucose.lx;
  logTime("Built GLucose engine");
  
  // Set the patterns
  glucose.lx.setPatterns(patterns = patterns(glucose));
  logTime("Built patterns");
  glucose.lx.addEffects(effects = effects(glucose));
  logTime("Built effects");
  transitions = transitions(glucose);
  logTime("Built transitions");
  
  // Build overlay UI
  ui = new OverlayUI();
  logTime("Built overlay UI");
  
  // MIDI devices
  MidiKnobController.initializeStandardDevices(glucose);
  logTime("Setup MIDI controllers");
  
  println("Total setup: " + (millis() - startMillis) + "ms");
}

void logTime(String evt) {
  int now = millis();
  println(evt + ": " + (now - lastMillis) + "ms");
  lastMillis = now;
}

void draw() {
  // The glucose engine deals with the core simulation here, we don't need
  // to do anything specific. This method just needs to exist.
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
void keyPressed() {
  if (key == 'u') {
    uiOn = !uiOn;
  }
}


