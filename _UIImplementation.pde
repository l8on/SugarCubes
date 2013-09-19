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
 * Custom UI components using the framework.
 */
 
class UIPatternDeck extends UIWindow {
    
  Engine.Deck deck;
  
  public UIPatternDeck(Engine.Deck deck, String label, float x, float y, float w, float h) {
    super(label, x, y, w, h);
    this.deck = deck;
    int yp = titleHeight;
        
    List<ScrollItem> items = new ArrayList<ScrollItem>();
    for (LXPattern p : deck.getPatterns()) {
      items.add(new PatternScrollItem(p));
    }    
    final UIScrollList patternList = new UIScrollList(1, yp, w-2, 160).setItems(items);
    patternList.addToContainer(this);
    yp += patternList.h + 10;
    
    final UIParameterKnob[] parameterKnobs = new UIParameterKnob[12];
    for (int ki = 0; ki < parameterKnobs.length; ++ki) {
      parameterKnobs[ki] = new UIParameterKnob(5 + 34*(ki % 4), yp + (ki/4) * 48);
      parameterKnobs[ki].addToContainer(this);
    }
    
    Engine.Listener lxListener = new Engine.Listener() {
      public void patternWillChange(Engine.Deck deck, LXPattern pattern, LXPattern nextPattern) {
        patternList.redraw();
      }
      public void patternDidChange(Engine.Deck deck, LXPattern pattern) {
        patternList.redraw();
        int pi = 0;
        for (LXParameter parameter : pattern.getParameters()) {
          if (pi >= parameterKnobs.length) {
            break;
          }
          parameterKnobs[pi++].setParameter(parameter);
        }
        while (pi < parameterKnobs.length) {
          parameterKnobs[pi++].setParameter(null);
        }
      }
    };
    
    deck.addListener(lxListener);
    lxListener.patternDidChange(deck, deck.getActivePattern());
    
  }
  
  class PatternScrollItem extends AbstractScrollItem {
    
    private LXPattern pattern;
    private String label;
    
    PatternScrollItem(LXPattern pattern) {
      this.pattern = pattern;
      label = className(pattern, "Pattern");
    }
    
    public String getLabel() {
      return label;
    }
    
    public boolean isSelected() {
      return deck.getActivePattern() == pattern;
    }
    
    public boolean isPending() {
      return deck.getNextPattern() == pattern;
    }
    
    public void onMousePressed() {
      deck.goPattern(pattern);
    }
  }
}

class UICrossfader extends UIWindow {
    
  public UICrossfader(float x, float y, float w, float h) {
    super("CROSSFADER", x, y, w, h);

    List<ScrollItem> items = new ArrayList<ScrollItem>();
    for (LXTransition t : transitions) {
      items.add(new TransitionScrollItem(t));
    }    
    new UIScrollList(1, titleHeight, w-2, 120).setItems(items).addToContainer(this);
    new UIParameterSlider(4, titleHeight + 126, w-10, 24).setParameter(lx.engine.getDeck(1).getCrossfader()).addToContainer(this);
    new UIToggleSet(4, 182, w-10, 20) {
      protected void onToggle(String value) {
        displayMode = value;
      }
    }.setOptions(new String[] { "A", "COMP", "B" }).setValue(displayMode = "COMP").addToContainer(this);
  }
}

class TransitionScrollItem extends AbstractScrollItem {
  private final LXTransition transition;
  private String label;
  
  TransitionScrollItem(LXTransition transition) {
    this.transition = transition;
    label = className(transition, "Transition");
  }
  
  public String getLabel() {
    return label;
  }
  
  public boolean isSelected() {
    return transition == lx.engine.getDeck(1).getBlendTransition();
  }
  
  public boolean isPending() {
    return false;
  }
  
  public void onMousePressed() {
    lx.engine.getDeck(1).setBlendTransition(transition);
  }
}

class UIEffects extends UIWindow {
  UIEffects(float x, float y, float w, float h) {
    super("FX", x, y, w, h);

    int yp = titleHeight;
    List<ScrollItem> items = new ArrayList<ScrollItem>();
    for (LXEffect fx : glucose.lx.getEffects()) {
      items.add(new FXScrollItem(fx));
    }    
    final UIScrollList effectsList = new UIScrollList(1, yp, w-2, 60).setItems(items);
    effectsList.addToContainer(this);
    yp += effectsList.h + 10;
    
    final UIParameterKnob[] parameterKnobs = new UIParameterKnob[4];
    for (int ki = 0; ki < parameterKnobs.length; ++ki) {
      parameterKnobs[ki] = new UIParameterKnob(5 + 34*(ki % 4), yp + (ki/4) * 48);
      parameterKnobs[ki].addToContainer(this);
    }
    
    GLucose.EffectListener fxListener = new GLucose.EffectListener() {
      public void effectSelected(LXEffect effect) {
        int i = 0;
        for (LXParameter p : effect.getParameters()) {
          if (i >= parameterKnobs.length) {
            break;
          }
          parameterKnobs[i++].setParameter(p);
        }
        while (i < parameterKnobs.length) {
          parameterKnobs[i++].setParameter(null);
        }
      }
    };
    
    glucose.addEffectListener(fxListener);
    fxListener.effectSelected(glucose.getSelectedEffect());

  }
  
  class FXScrollItem extends AbstractScrollItem {
    
    private LXEffect effect;
    private String label;
    
    FXScrollItem(LXEffect effect) {
      this.effect = effect;
      label = className(effect, "Effect");
    }
    
    public String getLabel() {
      return label;
    }
    
    public boolean isSelected() {
      return !effect.isEnabled() && (glucose.getSelectedEffect() == effect);
    }
    
    public boolean isPending() {
      return effect.isEnabled();
    }
    
    public void onMousePressed() {
      if (glucose.getSelectedEffect() == effect) {
        if (effect.isMomentary()) {
          effect.enable();
        } else {
          effect.toggle();
        }
      } else {
        glucose.setSelectedEffect(effect);
      }
    }
    
    public void onMouseReleased() {
      if (effect.isMomentary()) {
        effect.disable();
      }
    }

  }

}

class UIOutput extends UIWindow {
  public UIOutput(float x, float y, float w, float h) {
    super("OUTPUT", x, y, w, h);
    float yp = titleHeight;
    
    final UIScrollList outputs = new UIScrollList(1, titleHeight, w-2, 80);
    
    List<ScrollItem> items = new ArrayList<ScrollItem>();
    for (final PandaDriver panda : pandaBoards) {
      items.add(new PandaScrollItem(panda));
      panda.setListener(new PandaDriver.Listener() {
        public void onToggle(boolean active) {
           outputs.redraw();
        }
      });
    }
    outputs.setItems(items).addToContainer(this);
  } 
 
  class PandaScrollItem extends AbstractScrollItem {
    final PandaDriver panda;
    PandaScrollItem(PandaDriver panda) {
      this.panda = panda;
    }
    
    public String getLabel() {
      return panda.ip;
    }
    
    public boolean isSelected() {
      return panda.isEnabled();
    }
    
    public void onMousePressed() {
      panda.toggle();
    }
  } 
}

class UITempo extends UIWindow {
  
  private final UIButton tempoButton;
  
  UITempo(float x, float y, float w, float h) {
    super("TEMPO", x, y, w, h);
    tempoButton = new UIButton(4, titleHeight, w-10, 20) {
      protected void onToggle(boolean active) {
        if (active) {
          lx.tempo.tap();
        }
      }
    }.setMomentary(true);
    tempoButton.addToContainer(this);
  }
  
  public void draw() {
    tempoButton.setLabel("" + ((int)(lx.tempo.bpm() * 10)) / 10.);
    super.draw();
    
    // Overlay tempo thing with openGL, redraw faster than button UI
    fill(color(0, 0, 24 - 8*lx.tempo.rampf()));
    noStroke();
    rect(x + 8, y + titleHeight + 5, 12, 12);
  }
}

class UIMapping extends UIWindow {
  
  private static final String MAP_MODE_ALL = "ALL";
  private static final String MAP_MODE_CHANNEL = "CHNL";
  private static final String MAP_MODE_CUBE = "CUBE";
  
  private static final String CUBE_MODE_ALL = "ALL";
  private static final String CUBE_MODE_STRIP = "SNGL";
  private static final String CUBE_MODE_PATTERN = "PTRN";
  
  private final MappingTool mappingTool;
  
  private final UIIntegerBox channelBox;
  private final UIIntegerBox cubeBox;
  private final UIIntegerBox stripBox;
  
  UIMapping(MappingTool tool, float x, float y, float w, float h) {
    super("MAPPING", x, y, w, h);
    mappingTool = tool;
    
    int yp = titleHeight;
    new UIToggleSet(4, yp, w-10, 20) {
      protected void onToggle(String value) {
        if (value == MAP_MODE_ALL) mappingTool.mappingMode = mappingTool.MAPPING_MODE_ALL;
        else if (value == MAP_MODE_CHANNEL) mappingTool.mappingMode = mappingTool.MAPPING_MODE_CHANNEL;
        else if (value == MAP_MODE_CUBE) mappingTool.mappingMode = mappingTool.MAPPING_MODE_SINGLE_CUBE;
      }
    }.setOptions(new String[] { MAP_MODE_ALL, MAP_MODE_CHANNEL, MAP_MODE_CUBE }).addToContainer(this);
    yp += 24;
    new UILabel(4, yp+8, w-10, 20).setLabel("CHANNEL ID").addToContainer(this);
    yp += 24;
    (channelBox = new UIIntegerBox(4, yp, w-10, 20) {
      protected void onValueChange(int value) {
        mappingTool.setChannel(value-1);
      }
    }).setRange(1, mappingTool.numChannels()).addToContainer(this);
    yp += 24;
    
    new UILabel(4, yp+8, w-10, 20).setLabel("CUBE ID").addToContainer(this);
    yp += 24;
    (cubeBox = new UIIntegerBox(4, yp, w-10, 20) {
      protected void onValueChange(int value) {
        mappingTool.setCube(value-1);
      }
    }).setRange(1, glucose.model.cubes.size()).addToContainer(this);
    yp += 24;
    
    new UILabel(4, yp+8, w-10, 20).setLabel("COLORS").addToContainer(this);
    yp += 24;
    
    new UIScrollList(1, yp, w-2, 60).setItems(Arrays.asList(new ScrollItem[] {
      new ColorScrollItem(ColorScrollItem.COLOR_RED),
      new ColorScrollItem(ColorScrollItem.COLOR_GREEN),
      new ColorScrollItem(ColorScrollItem.COLOR_BLUE),
    })).addToContainer(this);
    yp += 64;

    new UILabel(4, yp+8, w-10, 20).setLabel("STRIP MODE").addToContainer(this);
    yp += 24;
    
    new UIToggleSet(4, yp, w-10, 20) {
      protected void onToggle(String value) {
        if (value == CUBE_MODE_ALL) mappingTool.cubeMode = mappingTool.CUBE_MODE_ALL;
        else if (value == CUBE_MODE_STRIP) mappingTool.cubeMode = mappingTool.CUBE_MODE_SINGLE_STRIP;
        else if (value == CUBE_MODE_PATTERN) mappingTool.cubeMode = mappingTool.CUBE_MODE_STRIP_PATTERN;
      }
    }.setOptions(new String[] { CUBE_MODE_ALL, CUBE_MODE_STRIP, CUBE_MODE_PATTERN }).addToContainer(this);
    
    yp += 24;
    new UILabel(4, yp+8, w-10, 20).setLabel("STRIP ID").addToContainer(this);
    
    yp += 24;
    (stripBox = new UIIntegerBox(4, yp, w-10, 20) {
      protected void onValueChange(int value) {
        mappingTool.setStrip(value-1);
      }
    }).setRange(1, Cube.STRIPS_PER_CUBE).addToContainer(this);
    
  }
  
  public void setChannelID(int value) {
    channelBox.setValue(value);
  }

  public void setCubeID(int value) {
    cubeBox.setValue(value);
  }

  public void setStripID(int value) {
    stripBox.setValue(value);
  }
  
  class ColorScrollItem extends AbstractScrollItem {
    
    public static final int COLOR_RED = 1;
    public static final int COLOR_GREEN = 2;
    public static final int COLOR_BLUE = 3;
    
    private final int colorChannel;
    
    ColorScrollItem(int colorChannel) {
      this.colorChannel = colorChannel;
    }

    public String getLabel() {
      switch (colorChannel) {
        case COLOR_RED: return "Red";
        case COLOR_GREEN: return "Green";
        case COLOR_BLUE: return "Blue";
      }
      return "";
    }
    
    public boolean isSelected() {
      switch (colorChannel) {
        case COLOR_RED: return mappingTool.channelModeRed;
        case COLOR_GREEN: return mappingTool.channelModeGreen;
        case COLOR_BLUE: return mappingTool.channelModeBlue;
      }
      return false;
    }
    
    public void select() {
      switch (colorChannel) {
        case COLOR_RED: mappingTool.channelModeRed = !mappingTool.channelModeRed; break;
        case COLOR_GREEN: mappingTool.channelModeGreen = !mappingTool.channelModeGreen; break;
        case COLOR_BLUE: mappingTool.channelModeBlue = !mappingTool.channelModeBlue; break;
      }
    }
  }
}

class UIDebugText extends UIContext {
  
  private String line1 = "";
  private String line2 = "";
  
  UIDebugText(float x, float y, float w, float h) {
    super(x, y, w, h);
  }

  public UIDebugText setText(String line1) {
    return setText(line1, "");
  }
  
  public UIDebugText setText(String line1, String line2) {
    if (!line1.equals(this.line1) || !line2.equals(this.line2)) {
      this.line1 = line1;
      this.line2 = line2;
      setVisible(line1.length() + line2.length() > 0);
      redraw();
    }
    return this;
  }
  
  protected void onDraw(PGraphics pg) {
    super.onDraw(pg);
    if (line1.length() + line2.length() > 0) {
      pg.noStroke();
      pg.fill(#444444);
      pg.rect(0, 0, w, h);
      pg.textFont(defaultItemFont);
      pg.textAlign(LEFT, TOP);
      pg.fill(#cccccc);
      pg.text(line1, 4, 4);
      pg.text(line2, 4, 24);
    }
  }
}

String className(Object p, String suffix) {
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
