/**
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
import java.lang.reflect.*;
import rwmidi.*;

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

Serialize serialize;
OSCOut oscOut;

void setup() {
  startMillis = lastMillis = millis();

  // Initialize the Processing graphics environment
  size(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, OPENGL);
  frameRate(TARGET_FRAMERATE);
  noSmooth();
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
  SCMidiDevices.initializeStandardDevices(glucose, ui.patternKnobs, ui.transitionKnobs, ui.effectKnobs);
  logTime("Setup MIDI devices");
  
  println("Total setup: " + (millis() - startMillis) + "ms");

  serialize = new Serialize( glucose );
  oscOut = new OSCOut( serialize );
}

void logTime(String evt) {
  int now = millis();
  println(evt + ": " + (now - lastMillis) + "ms");
  lastMillis = now;
}




void draw() {
  // The glucose engine deals with the core simulation here, we don't need
  // to do anything specific. This method just needs to exist.
  int [] colors = glucose.getColors();

  serialize.processColors(colors);
  oscOut.sendToBoards();
  /*for (int i=0;i<colors.length;i++)
  {
    print(colors[i]+" ");
  }*/

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
boolean knobsOn = true;
void keyPressed() {
  switch (key) {
    case 'u':
      uiOn = !uiOn;
      break;
    case 'k':
      knobsOn = !knobsOn;
      break;
  }
}


