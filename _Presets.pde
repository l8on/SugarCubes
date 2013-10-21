interface PresetListener {
  public void onPresetLoaded(Engine.Deck deck, Preset preset);
  public void onPresetDirty(Engine.Deck deck, Preset preset);
  public void onPresetStored(Engine.Deck deck, Preset preset);
  public void onPresetUnloaded();
}

class PresetManager implements LXParameter.Listener {
  
  public static final int NUM_PRESETS = 8;
  public static final String FILENAME = "data/presets.txt";
  public static final String DELIMITER = "\t";
  
  private final Preset[] presets = new Preset[NUM_PRESETS];
  private final List<PresetListener> listeners = new ArrayList<PresetListener>();
  
  private Preset loadedPreset = null;
  private LXPattern loadedPattern = null;
  
  PresetManager() {
    for (int i = 0; i < presets.length; ++i) {
      presets[i] = new Preset(this, i);
    }
    String[] values = loadStrings(FILENAME);
    if (values == null) {
      write();
    } else {
      int i = 0;
      for (String serialized : values) {
        presets[i++].load(serialized);
        if (i >= NUM_PRESETS) {
          break;
        }
      }
    }
    for (Engine.Deck deck : lx.engine.getDecks()) {
      deck.addListener(new Engine.AbstractListener() {
        public void patternDidChange(Engine.Deck deck, LXPattern pattern) {
          if (pattern != loadedPattern) {
            onPresetDirty(deck);
          }
        }
      });
    }
  }
  
  public void setMidiEngine(MidiEngine midiEngine) {
    midiEngine.addListener(new MidiEngineListener() {
      public void onFocusedDeck(int deckIndex) {
        loadedPreset = null;
        for (PresetListener listener : listeners) {
          listener.onPresetUnloaded();
        }
      }
    });
  }
  
  public void addListener(PresetListener listener) {
    listeners.add(listener);
  }
  
  public Engine.Deck deckForPattern(LXPattern pattern) {
    for (Engine.Deck deck : lx.engine.getDecks()) {
      for (LXPattern p : deck.getPatterns()) {
        if (p == pattern) {
          return deck;
        }
      }
    }
    return null;
  }

  public void dirty(LXPattern pattern) {
    onPresetDirty(deckForPattern(pattern));
  }

  public void select(Engine.Deck deck, int index) {
    presets[index].select(deck);
  }

  public void store(Engine.Deck deck, int index) {
    presets[index].store(midiEngine.getFocusedPattern());
    for (PresetListener listener : listeners) {
      listener.onPresetStored(deck, presets[index]);
    }
    select(deck, index);
  }
  
  public void onPresetLoaded(Engine.Deck deck, Preset preset, LXPattern pattern) {
    if (loadedPattern != pattern) {
      if (loadedPattern != null) {
        for (LXParameter p : loadedPattern.getParameters()) {
          ((LXListenableParameter) p).removeListener(this);
        }
      }
    }
    for (PresetListener listener : listeners) {
      listener.onPresetLoaded(deck, preset);
    }
    loadedPreset = preset;
    loadedPattern = pattern;
    for (LXParameter p : loadedPattern.getParameters()) {
      ((LXListenableParameter) p).addListener(this);
    }
  }
  
  private void onPresetDirty(Engine.Deck deck) {
    if (loadedPreset != null) {
      for (PresetListener listener : listeners) {
        listener.onPresetDirty(deck, loadedPreset);
      }
    }
  }
  
  public void onParameterChanged(LXParameter p) {
    onPresetDirty(deckForPattern(loadedPattern));
  }
  
  public void write() {
    String[] lines = new String[NUM_PRESETS];
    int i = 0;
    for (Preset preset : presets) {
      lines[i++] = preset.serialize(); 
    }
    saveStrings(FILENAME, lines);
  }
}

class Preset {
  
  final PresetManager manager;
  final int index;
  
  String className;
  final Map<String, Float> parameters = new HashMap<String, Float>();
  
  Preset(PresetManager manager, int index) {
    this.manager = manager;
    this.index = index;
  }
  
  public void load(String serialized) {
    className = null;
    parameters.clear();
    try {
      String[] parts = serialized.split(PresetManager.DELIMITER);
      className = parts[0];
      int i = 1;
      while (i < parts.length - 1) {
        parameters.put(parts[i], Float.parseFloat(parts[i+1]));
        i += 2;
      }
    } catch (Exception x) {
      className = null;
      parameters.clear();
    }
  }
  
  public String serialize() {
    if (className == null) {
      return "null";
    }
    String val = className + PresetManager.DELIMITER;
    for (String pKey : parameters.keySet()) {
      val += pKey + PresetManager.DELIMITER + parameters.get(pKey) + PresetManager.DELIMITER;
    }
    return val;
  }
  
  public void store(LXPattern pattern) {
    className = null;
    parameters.clear();
    className = pattern.getClass().getName();
    for (LXParameter p : pattern.getParameters()) {
      parameters.put(p.getLabel(), p.getValuef());
    }
    if (pattern instanceof DPat) {
      DPat dpattern = (DPat) pattern;
      for (DBool bool : dpattern.bools) {
        parameters.put(bool.tag, bool.b ? 1.f : 0.f);
      }
      for (Pick pick : dpattern.picks) {
        parameters.put(pick.tag, pick.CurRow + pick.CurCol/100.f);
      }
    }
    manager.write();
  }
  
  public void select(Engine.Deck deck) {
    for (LXPattern pattern : deck.getPatterns()) {
      if (pattern.getClass().getName().equals(className)) {
        for (String pLabel : parameters.keySet()) {
          for (LXParameter p : pattern.getParameters()) {
            if (p.getLabel().equals(pLabel)) {
              p.setValue(parameters.get(pLabel));
            }
          }
          if (pattern instanceof DPat) {
            DPat dpattern = (DPat) pattern;
            for (DBool bool : dpattern.bools) {
              if (bool.tag.equals(pLabel)) {
                bool.set(bool.row, bool.col, parameters.get(pLabel) > 0);
              }
            }
            for (Pick pick : dpattern.picks) {
              if (pick.tag.equals(pLabel)) {
                float f = parameters.get(pLabel);
                pick.set((int) floor(f), (int) round((f%1)*100.));
              }
            }
          }
        }
        deck.goPattern(pattern);
        if (pattern instanceof DPat) {
          ((DPat)pattern).updateLights();
        }
        manager.onPresetLoaded(deck, this, pattern);
        break;
      }
    }    
  }
}

