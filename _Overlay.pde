/**
 * Overlay UI that indicates pattern control, etc. This will be moved
 * into the Processing library once it is stabilized and need not be
 * regularly modified.
 */
class OverlayUI {
  
  private final PFont titleFont = createFont("Myriad Pro", 10);
  private final PFont itemFont = createFont("Lucida Grande", 11);
  private final PFont knobFont = titleFont;
  private final int w = 140;
  private final int leftPos;
  private final int leftTextPos;
  private final int lineHeight = 20;
  private final int sectionSpacing = 12;
  private final int controlSpacing = 18;
  private final int tempoHeight = 20;
  private final int knobSize = 28;
  private final float knobIndent = .4;  
  private final int knobSpacing = 6;
  private final int knobLabelHeight = 14;
  private final color lightBlue = #666699;
  private final color lightGreen = #669966;
  
  private final String[] patternNames;
  private final String[] transitionNames;
  private final String[] effectNames;

  private PImage logo;
  
  private int firstPatternY;
  private int firstPatternKnobY;
  private int firstTransitionY;
  private int firstTransitionKnobY;
  private int firstEffectY;
  private int firstEffectKnobY;

  private int tempoY;
  
  private Method patternStateMethod;
  private Method transitionStateMethod;
  private Method effectStateMethod;
  
  private final int NUM_PATTERN_KNOBS = 8;
  private final int NUM_TRANSITION_KNOBS = 4;
  private final int NUM_EFFECT_KNOBS = 4;
  
  private int activeTransitionIndex = 0;
  private int activeEffectIndex = 0;
  
  public final VirtualPatternKnob[] patternKnobs;
  public final VirtualTransitionKnob[] transitionKnobs;
  public final VirtualEffectKnob[] effectKnobs;
    
  OverlayUI() {
    leftPos = width - w;
    leftTextPos = leftPos + 4;
    logo = loadImage("logo-sm.png");
    
    patternNames = classNameArray(patterns, "Pattern");
    transitionNames = classNameArray(transitions, "Transition");
    effectNames = classNameArray(effects, "Effect");

    patternKnobs = new VirtualPatternKnob[NUM_PATTERN_KNOBS];
    for (int i = 0; i < patternKnobs.length; ++i) {
      patternKnobs[i] = new VirtualPatternKnob(i);
    }

    transitionKnobs = new VirtualTransitionKnob[NUM_TRANSITION_KNOBS];
    for (int i = 0; i < transitionKnobs.length; ++i) {
      transitionKnobs[i] = new VirtualTransitionKnob(i);
    }

    effectKnobs = new VirtualEffectKnob[NUM_EFFECT_KNOBS];
    for (int i = 0; i < effectKnobs.length; ++i) {
      effectKnobs[i] = new VirtualEffectKnob(i);
    }

    try {
      patternStateMethod = getClass().getMethod("getState", LXPattern.class);
      effectStateMethod = getClass().getMethod("getState", LXEffect.class);
      transitionStateMethod = getClass().getMethod("getState", LXTransition.class);
    } catch (Exception x) {
      throw new RuntimeException(x);
    }    
  }
  
  void drawHelpTip() {
    textFont(itemFont);
    textAlign(RIGHT);
    text("Tap 'u' to restore UI", width-4, height-6);
  }
  
  void draw() {    
    image(logo, 4, 4);
    
    stroke(color(0, 0, 100));
    // fill(color(0, 0, 50, 50)); // alpha is bad for perf
    fill(color(0, 0, 30));
    rect(leftPos-1, -1, w+2, height+2);
    
    int yPos = 0;    
    firstPatternY = yPos + lineHeight + 6;
    yPos = drawObjectList(yPos, "PATTERN", patterns, patternNames, patternStateMethod);
    yPos += controlSpacing;
    firstPatternKnobY = yPos;
    int xPos = leftTextPos;
    for (int i = 0; i < NUM_PATTERN_KNOBS/2; ++i) {
      drawKnob(xPos, yPos, knobSize, patternKnobs[i]);
      drawKnob(xPos, yPos + knobSize + knobSpacing + knobLabelHeight, knobSize, patternKnobs[NUM_PATTERN_KNOBS/2 + i]);
      xPos += knobSize + knobSpacing;
    }
    yPos += 2*(knobSize + knobLabelHeight) + knobSpacing;

    yPos += sectionSpacing;
    firstTransitionY = yPos + lineHeight + 6;
    yPos = drawObjectList(yPos, "TRANSITION", transitions, transitionNames, transitionStateMethod);
    yPos += controlSpacing;
    firstTransitionKnobY = yPos;
    xPos = leftTextPos;
    for (int i = 0; i < transitionKnobs.length; ++i) {
      drawKnob(xPos, yPos, knobSize, transitionKnobs[i]);
      xPos += knobSize + knobSpacing;
    }
    yPos += knobSize + knobLabelHeight;
    
    yPos += sectionSpacing;
    firstEffectY = yPos + lineHeight + 6;
    yPos = drawObjectList(yPos, "FX", effects, effectNames, effectStateMethod);
    yPos += controlSpacing;
    firstEffectKnobY = yPos;    
    xPos = leftTextPos;
    for (int i = 0; i < effectKnobs.length; ++i) {
      drawKnob(xPos, yPos, knobSize, effectKnobs[i]);
      xPos += knobSize + knobSpacing;
    }
    yPos += knobSize + knobLabelHeight;
    
    yPos += sectionSpacing;
    yPos = drawObjectList(yPos, "TEMPO", null, null, null);
    yPos += 6;
    tempoY = yPos;
    stroke(#111111);
    fill(tempoDown ? lightGreen : color(0, 0, 35 - 8*lx.tempo.rampf()));
    rect(leftPos + 4, yPos, w - 8, tempoHeight);
    fill(0);
    textAlign(CENTER);
    text("" + ((int)(lx.tempo.bpmf() * 100) / 100.), leftPos + w/2., yPos + tempoHeight - 6);
    yPos += tempoHeight;
    
    fill(#999999);
    textFont(itemFont);
    textAlign(LEFT);
    text("Tap 'u' to hide UI", leftTextPos, height-6);
  }
  
  public LXParameter getOrNull(List<LXParameter> items, int index) {
    if (index < items.size()) {
      return items.get(index);
    }
    return null;
  }
  
  public void drawFPS() {
    textFont(titleFont);
    textAlign(LEFT);
    fill(#666666);
    text("FPS: " + (((int)(frameRate * 10)) / 10.), 4, height-6);     
  }

  private final int STATE_DEFAULT = 0;
  private final int STATE_ACTIVE = 1;
  private final int STATE_PENDING = 2;

  public int getState(LXPattern p) {
    if (p == lx.getPattern()) {
      return STATE_ACTIVE;
    } else if (p == lx.getNextPattern()) {
      return STATE_PENDING;
    }
    return STATE_DEFAULT;
  }
  
  public int getState(LXEffect e) {
    if (e.isEnabled()) {
      return STATE_PENDING;
    } else if (effects[activeEffectIndex] == e) {
      return STATE_ACTIVE;
    }
    return STATE_DEFAULT;
  }
  
  public int getState(LXTransition t) {
    if (t == lx.getTransition()) {
      return STATE_PENDING;
    } else if (t == transitions[activeTransitionIndex]) {
      return STATE_ACTIVE;
    }
    return STATE_DEFAULT;
  }

  protected int drawObjectList(int yPos, String title, Object[] items, Method stateMethod) {
    return drawObjectList(yPos, title, items, classNameArray(items, null), stateMethod);
  }
  
  private int drawObjectList(int yPos, String title, Object[] items, String[] names, Method stateMethod) {
    noStroke();
    fill(#aaaaaa);
    textFont(titleFont);
    textAlign(LEFT);
    text(title, leftTextPos, yPos += lineHeight);    
    if (items != null) {
      textFont(itemFont);
      color textColor;      
      boolean even = true;
      for (int i = 0; i < items.length; ++i) {
        Object o = items[i];
        int state = STATE_DEFAULT;
        try {
           state = ((Integer) stateMethod.invoke(this, o)).intValue();
        } catch (Exception x) {
          throw new RuntimeException(x);
        }
        switch (state) {
          case STATE_ACTIVE:
            fill(lightGreen);
            textColor = #eeeeee;
            break;
          case STATE_PENDING:
            fill(lightBlue);
            textColor = color(0, 0, 75 + 15*sin(millis()/200.));;
            break;
          default:
            textColor = 0;
            fill(even ? #666666 : #777777);
            break;
        }
        rect(leftPos, yPos+6, width, lineHeight);
        fill(textColor);
        text(names[i], leftTextPos, yPos += lineHeight);
        even = !even;       
      }
    }
    return yPos;
  }
  
  private void drawKnob(int xPos, int yPos, int knobSize, LXParameter knob) {
    if (!knobsOn) {
      return;
    }
    final float knobValue = knob.getValuef();
    String knobLabel = knob.getLabel();
    if (knobLabel == null) {
      knobLabel = "-";
    } else if (knobLabel.length() > 4) {
      knobLabel = knobLabel.substring(0, 4);
    }
    
    ellipseMode(CENTER);
    noStroke();
    fill(#222222);
    // For some reason this arc call really crushes drawing performance. Presumably
    // because openGL is drawing it and when we overlap the second set of arcs it
    // does a bunch of depth buffer intersection tests? Ellipse with a trapezoid cut out is faster
    // arc(xPos + knobSize/2, yPos + knobSize/2, knobSize, knobSize, HALF_PI + knobIndent, HALF_PI + knobIndent + (TWO_PI-2*knobIndent));
    ellipse(xPos + knobSize/2, yPos + knobSize/2, knobSize, knobSize);
    
    float endArc = HALF_PI + knobIndent + (TWO_PI-2*knobIndent)*knobValue;
    fill(lightGreen);
    arc(xPos + knobSize/2, yPos + knobSize/2, knobSize, knobSize, HALF_PI + knobIndent, endArc);
    
    // Mask notch out of knob
    fill(color(0, 0, 30));
    beginShape();
    vertex(xPos + knobSize/2, yPos + knobSize/2.);
    vertex(xPos + knobSize/2 - 6, yPos + knobSize);
    vertex(xPos + knobSize/2 + 6, yPos + knobSize);
    endShape();

    // Center circle of knob
    fill(#333333);
    ellipse(xPos + knobSize/2, yPos + knobSize/2, knobSize/2, knobSize/2);    
    
    fill(0);
    rect(xPos, yPos + knobSize + 2, knobSize, knobLabelHeight - 2);
    fill(#999999);
    textAlign(CENTER);
    textFont(knobFont);
    text(knobLabel, xPos + knobSize/2, yPos + knobSize + knobLabelHeight - 2);

  }
  
  private String[] classNameArray(Object[] objects, String suffix) {
    if (objects == null) {
      return null;
    }
    String[] names = new String[objects.length];
    for (int i = 0; i < objects.length; ++i) {
      names[i] = className(objects[i], suffix);
    }
    return names;
  }
  
  private String className(Object p, String suffix) {
    String s = p.getClass().getName();
    int li;
    if ((li = s.lastIndexOf(".")) > 0) {
      s = s.substring(li + 1);
    }
    if (s.indexOf("SugarCubes$") == 0) {
      s = s.substring("SugarCubes$".length());
    }
    if ((suffix != null) && ((li = s.indexOf(suffix)) != -1)) {
      s = s.substring(0, li);
    }
    return s;
  }

  class VirtualPatternKnob extends LXVirtualParameter {
    private final int index;
    
    VirtualPatternKnob(int index) {
      this.index = index;
    }
    
    public LXParameter getRealParameter() {
      List<LXParameter> parameters = glucose.getPattern().getParameters();
      if (index < parameters.size()) {
        return parameters.get(index);
      }
      return null;
    }
  }

  class VirtualTransitionKnob extends LXVirtualParameter {
    private final int index;
    
    VirtualTransitionKnob(int index) {
      this.index = index;
    }
    
    public LXParameter getRealParameter() {
      List<LXParameter> parameters = transitions[activeTransitionIndex].getParameters();
      if (index < parameters.size()) {
        return parameters.get(index);
      }
      return null;
    }
  }

  class VirtualEffectKnob extends LXVirtualParameter {
    private final int index;
    
    VirtualEffectKnob(int index) {
      this.index = index;
    }
    
    public LXParameter getRealParameter() {
      List<LXParameter> parameters = effects[activeEffectIndex].getParameters();
      if (index < parameters.size()) {
        return parameters.get(index);
      }
      return null;
    }
  }
  
  private int patternKnobIndex = -1;
  private int transitionKnobIndex = -1;
  private int effectKnobIndex = -1;
  
  private int lastY;
  private int releaseEffect = -1;
  private boolean tempoDown = false;

  public void mousePressed() {
    lastY = mouseY;
    patternKnobIndex = transitionKnobIndex = effectKnobIndex = -1;
    releaseEffect = -1;
    if (mouseY > tempoY) {
      if (mouseY - tempoY < tempoHeight) {
        lx.tempo.tap();
        tempoDown = true;
      }
    } else if ((mouseY >= firstEffectKnobY) && (mouseY < firstEffectKnobY + knobSize + knobLabelHeight)) {
      effectKnobIndex = (mouseX - leftTextPos) / (knobSize + knobSpacing);
    } else if (mouseY > firstEffectY) {
      int effectIndex = (mouseY - firstEffectY) / lineHeight;
      if (effectIndex < effects.length) {
        if (activeEffectIndex == effectIndex) {
          effects[effectIndex].enable();
          releaseEffect = effectIndex;
        }
        activeEffectIndex = effectIndex;        
      }
    } else if ((mouseY >= firstTransitionKnobY) && (mouseY < firstTransitionKnobY + knobSize + knobLabelHeight)) {
      transitionKnobIndex = (mouseX - leftTextPos) / (knobSize + knobSpacing);
    } else if (mouseY > firstTransitionY) {
      int transitionIndex = (mouseY - firstTransitionY) / lineHeight;
      if (transitionIndex < transitions.length) {
        activeTransitionIndex = transitionIndex;
      }
    } else if ((mouseY >= firstPatternKnobY) && (mouseY < firstPatternKnobY + 2*(knobSize+knobLabelHeight) + knobSpacing)) {
      patternKnobIndex = (mouseX - leftTextPos) / (knobSize + knobSpacing);
      if (mouseY >= firstPatternKnobY + knobSize + knobLabelHeight + knobSpacing) {
        patternKnobIndex += NUM_PATTERN_KNOBS / 2;
      }      
    } else if (mouseY > firstPatternY) {
      int patternIndex = (mouseY - firstPatternY) / lineHeight;
      if (patternIndex < patterns.length) {
        patterns[patternIndex].setTransition(transitions[activeTransitionIndex]);
        lx.goIndex(patternIndex);
      }
    }
  }
  
  public void mouseDragged() {
    int dy = lastY - mouseY;
    lastY = mouseY;
    if (patternKnobIndex >= 0 && patternKnobIndex < NUM_PATTERN_KNOBS) {
      LXParameter p = patternKnobs[patternKnobIndex];
      p.setValue(constrain(p.getValuef() + dy*.01, 0, 1));
    } else if (effectKnobIndex >= 0 && effectKnobIndex < NUM_EFFECT_KNOBS) {
      LXParameter p = effectKnobs[effectKnobIndex];
      p.setValue(constrain(p.getValuef() + dy*.01, 0, 1));
    } else if (transitionKnobIndex >= 0 && transitionKnobIndex < NUM_TRANSITION_KNOBS) {
      LXParameter p = transitionKnobs[transitionKnobIndex];
      p.setValue(constrain(p.getValuef() + dy*.01, 0, 1));
    }
  }
    
  public void mouseReleased() {
    tempoDown = false;
    if (releaseEffect >= 0) {
      effects[releaseEffect].trigger();
      releaseEffect = -1;      
    }
  }
  
}

void mousePressed() {
  if (mouseX > ui.leftPos) {
    ui.mousePressed();
  }
}

void mouseReleased() {
  if (mouseX > ui.leftPos) {
    ui.mouseReleased();
  }
}

void mouseDragged() {
  if (mouseX > ui.leftPos) {
    ui.mouseDragged();
  }
}

